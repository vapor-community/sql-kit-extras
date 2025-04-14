#if FluentSQLKitExtras
import FluentKit
import SQLKit

/// Read each method's comments in the order they appear (from `fieldKey(for:)` through `sqlColumn(for:)`) for an
/// _EXTREMELY_ detailed breakdown of how the heck this all works.
extension Fields {
    /// Returns the singular `FieldKey` corresponding to a specific property of the model.
    ///
    /// Detailed operation:
    ///
    /// 1. We must enforce that the caller pass a key path referring to a property of a Fluent model, and more
    ///    specifically a property which conforms to `QueryAddressableProperty`. Here's why:
    ///      1. First and foremost, the property must conform to the very generically-named `Property` protocol,
    ///         meaning that it is an instance of one of the Fluent property wrappers. There is an important
    ///         distinction between "a property which uses one of the property wrappers" and "the property
    ///         wrapper instance itself"; that distinction is critical for this purpose. The latter is the backing
    ///         storage synthesized by the compiler whenever a wrapper is used. Fluent's property wrappers always
    ///         return this storage from the wrapper's `projectedValue` accessor, which means that
    ///         `model.$foo` - or in the case of a keypath, `\Model.$foo` - refers to that same storage. We need
    ///         this because it's how Fluent makes a property's `FieldKey` available, even to itself.
    ///      2. The `QueryAddressableProperty` protocol indicates that the property may be "addressed" by a
    ///         query - in other words, the property represents, directly or indirectly, a `QueryableProperty`.
    ///         In turn, a `QueryableProperty` is a property which directly corresponds to exactly one column in
    ///         the actual database. A `@Field` is both queryable and query-addressable, because it directly
    ///         represents a single column. A `@Parent` is query-addressable, but _not_ queryable, because
    ///         while there is an underlying database column, that column is not the value of the property (the
    ///         actual parent model)- it's that model's ID. And `@Children`, `@Group`, and so forth are neither
    ///         queryable nor query-addressable; there is no single column in the database that corresponds to
    ///         these properties.
    /// 2. We now have a keypath pointing to a property that we know can tell us how to refer to a single database
    ///    column by providing the apporpriate `FieldKey`. To actually _get_ that `FieldKey`, we first have to
    ///    create an empty instance of the model (a serious design flaw in how Fluent uses keypaths) so that we
    ///    can access the keypath and retrieve the instance of the property wrapper. The instance we want is _not_
    ///    (necessarily) the one referenced by the keypath - it's the one that property addresses via the
    ///    `QueryAddressableProperty` protocol - so we append the accessor defined by that protocol to the
    ///    keypath.
    ///  3. Oops, this didn't yield a `FieldKey` - it yielded an _array_ of `FieldKey`s. This was a design choice
    ///     made early in Fluent 4's development that was intended to enable accessing properties nested within
    ///     JSON columns as if they were nested keypaths. This functionality, however, was never actually
    ///     implemented, and in practice, it is explicitly safe to assume that any array of `FieldKey`s returned
    ///     by any Fluent accessor always has exactly one element. As such, we subscript the array without
    ///     bothering to check whether it actually has only one element (or any at all).
    ///
    /// > Note: By placing this method on `Fields` rather the more specific `Model`, we allow using it with, for
    /// > example, the `IDValue` type of models which use `@CompositeID`, or the secondary structures referenced
    /// > by `@Group` properties.
    public static func fieldKey(for keypath: KeyPath<Self, some QueryAddressableProperty>) -> FieldKey {
        Self()[keyPath: keypath.appending(path: \.queryablePath)][0]
    }

    /// Return an `SQLIdentifier` containing the _unqualified_ name of the column corresponding to a specific
    /// property of the model.
    ///
    /// Detailed operation (see `fieldKey(for:)` above for steps 1-3):
    ///
    /// 4. A `FieldKey`'s `description` property is explicitly defined to be the canonical representation of the
    ///    column name in SQL, so we now have the correct column name addressed by the provided property. As a
    ///    bonus, for `@Parent` etc. properties, this works with a keypath such as `\MyModel.$parent` - despite
    ///    the fact that in Fluent's API, one would be required to write `\MyModel.$parent.$id`. This is a
    ///    limitation in Fluent's API caused by the fact that I didn't add `QueryAddressableProperty` to the
    ///    API until long after the original release of Fluent 4 and updating the query builder APIs appropriately
    ///    has never been considered worth the risk of problems.
    ///
    /// > Note: By placing this method on `Fields` rather the more specific `Model`, we allow using it with, for
    /// > example, the `IDValue` type of models which use `@CompositeID`, or the secondary structures referenced
    /// > by `@Group` properties.
    public static func sqlIdentifier(for keypath: KeyPath<Self, some QueryAddressableProperty>) -> SQLIdentifier {
        .init(Self.fieldKey(for: keypath).description)
    }

    /// A convenience method for returning the result of ``fieldKey(for:)`` as a string.
    ///
    /// As a general rule, users should try to avoid working with the string names of columns; the `FieldKey` - or
    /// better yet, the appropriate `SQLExpression`s (such as returned by ``sqlIdentifier(for:)``) - are always to
    /// be preferred when possible. However, we recognize that there are cases when this would result in excessive
    /// code verbosity, such as when implementing an API which needs to ensure that a given input is a valid column.
    ///
    /// > Note: Another reason for having this method is that it at least minimally insulates users from the
    /// > rather unfortunate fact that the most correct way to get the string representation of a `FieldKey` is to
    /// > request its `description` - a behavior which the stdlib would discourage if it could. It can't, because
    /// > use of `description` is extremely widespread, but technically one is _supposed_ to invoke conformance to
    /// > `CustomStringConvertible` by calling `String(describing:)`, although no one ever does. We don't do so
    /// > here because `FieldKey.description` is not a proper `CustomStringConvertible` conformance in the first
    /// > place, which makes calling it directly an (oxymoronically) incorrectly correct behavior.
    public static func key(for keypath: KeyPath<Self, some QueryAddressableProperty>) -> String {
        self.fieldKey(for: keypath).description
    }
}

extension Schema {
    /// Return an `SQLQualifiedTable` containing the fully qualified name of the table corresponding to this model.
    ///
    /// Detailed operation:
    ///
    /// - Fluent 4, though it did not have this feature at the time of its initial release, eventually gained support
    ///   for models whose tables exist in different "spaces" (short for "namespaces". What Fluent calls a "space"
    ///   corresponds to a schema in PostgreSQL, a database in MySQL, or to an attached database in SQLite - in all
    ///   three cases the SQL syntax for referring to such a table is identical: `other_space.some_table` (where both
    ///   names are identifiers and should be quoted accordingly).
    /// - Fluent 4 also eventually gained working support for model aliasing (this feature was supposedly included in
    ///   the initial release, but very few people - not zero, but very few - have ever actually used it in real code,
    ///   and it spent the first year or two of its existence being either partially or completely broken). Model
    ///   aliasing, in the form of the `ModelAlias` protocol, is intended to allow joining the same model multiple
    ///   times in a single query at the Fluent level, without using SQLKit (although in an SQLKit context, not only
    ///   would use of `ModelAlias` be pointless, it would be actively and significantly harmful for performance).
    ///   `ModelAlias` is the _only_ Fluent-provided type which conforms to `Schema` without also conforming to `Model`,
    ///   and the only proximate reason that the `Schema` protocol exists separately from `Model` in the first place.
    /// - Thanks to the existence of spaces, we specify a Fluent model's table in SQLKit with `SQLQualifiedTable`, an
    ///   expression which serves the same purpose for table and space identifiers that `SQLColumn` does for column
    ///   and table identifiers. To specify a _fully_ qualified column in a space-qualified table, one thus uses an
    ///   `SQLColumn` whose table _is_ an `SQLQualifiedTable`, e.g.
    ///   `SQLColumn(column_name, table: SQLQualifiedTable(table_name, space: space_name))`.
    ///  - In order to fully respect `ModelAlias`es (just in case), when constructing an `SQLQualifiedTable` for a
    ///    Fluent model, we check whether the model (or more precisely, the `Schema`) has an `alias`. If it does, we
    ///    ignore the model's space (if any) and use the alias in place of the real table name (which, confusingly, is
    ///    specified by the `schema` property). Otherwise we use the values of the `schema` and `space` properties
    ///    as-is.
    ///
    /// > Note: This level of support for even a very obscure and little-used Fluent feature - both by placing this
    /// > method on `Schema` rather than `Model` and including the check for the presence of a model alias - is
    /// > rather pedantic at best, and arguably unnecessary given that it will never matter to 99.9% of Fluent users
    /// > even if these utilities were upstreamed to SQLKit in the first place. We do it anyway because 1) all of this
    /// > is intended to have the additional purpose of at least somewhat documenting Fluent's behavior, 2) adding the
    /// > feature support has no overhead at runtime (actual _use_ of `ModelAlias` with SQLKit is actively harmful, but
    /// > simply _supporting_ its use is not), and 3) it is considered good practice in Swift to place utility
    /// > extensions as close to the  "root" of the protocol "inheritance" hierarchy as possible - thus we extend
    /// > `Schema` rather than `Model`, in the same fashion that one would try to extend `Sequence` rather than
    /// `> Collection` when possible.
    public static var sqlTable: SQLKit.SQLQualifiedTable {
        .init(
            self.schemaOrAlias,
            space: self.spaceIfNotAliased
        )
    }

    /// Return an `SQLColumn` containing the _fully qualified_ name and table of the column corresponding to a
    /// specific property of the model.
    ///
    /// Detailed operation (see `fieldKey(for:)` and `sqlIdentifier(for:)` above for steps 1-4, and `sqlTable` above
    /// for additional information):
    ///
    ///  5. There are two kinds of column references in SQL syntax - qualified and unqualified. Many areas of SQL
    ///     syntax require _unqualified_ column names, such as the column list of an INSERT query, the left-hand side
    ///     of an assignment in an UPDATE query, the list of columns in a join's USING clause, or the column list of
    ///     an index or table constraint. However, most of the time SQL allows (and where ambiguity exists, requires)
    ///     _qualified_ column names, which specify the table to which the column belongs by full name or alias. Even
    ///     in cases where columns are not ambiguous, it is almost always preferable to fully qualify them regardless,
    ///     both for clarity and to guard against future changes in database structure which may introduce ambiguity
    ///     to a previously unambiguous reference. Thus we return an `SQLColumn` which specifies the `sqlTable` of the
    ///     model as the column's table, guaranteeing a fully-qualified reference. In places where an unqualified
    ///     reference is needed, `sqlIdentifier(for:)` should be used instead (if no table is specified, an
    ///     `SQLColumn` behaves identically to an `SQLIdentifier`).
    ///
    /// > Note: As with `sqlTable`, by placing this method on `Schema` rather the more specific `Model`, we allow using
    /// > it transparently with `ModelAlias` (as ill-advised as doing so may be).
    public static func sqlColumn(for keypath: KeyPath<Self, some QueryAddressableProperty>) -> SQLColumn {
        .init(
            Self.sqlIdentifier(for: keypath),
            table: Self.sqlTable
        )
    }
}
#endif
