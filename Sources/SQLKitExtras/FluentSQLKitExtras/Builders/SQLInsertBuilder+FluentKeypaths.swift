#if FluentSQLKitExtras
import FluentKit
import SQLKit

/// > Note: `SQLInsertBuilder` is not an `SQLUnqualifiedColumnListBuilder`, although it should be. See `SQLInsertBuilder`'s
/// > documentation for details.
extension SQLInsertBuilder {
    /// Allow specifying a set of unqualified column names for an insert builder using Fluent model keypaths. As with
    /// all other `.columns()` methods of `SQLInsertBuilder`, this method _replaces_ all existing columns.
    @discardableResult
    public func columns<each S: Schema, each P: QueryAddressableProperty>(
        _ keypaths: repeat KeyPath<each S, each P>
    ) -> Self {
        // N.B.: Due to the nature of parameter packs, we must manage the builder's `SQLInsert` expression directly.
        self.insert.columns = []
        for keypath in repeat each keypaths {
          self.insert.columns.append(.identifier(keypath))
        }
        return self
    }

    /// Allow specifying a set of unqualified column names for an insert builder using Fluent model keypaths which all
    /// belong to the same model. This is identical to ``columns<each Schema, each QueryAddressableProperty>(_: repeat...)``,
    /// except that on that method, each KeyPath can refer to a different Schema,forcing the caller to specify the root
    /// type on all of them. However, it is a very common use case to specify many keypaths from the same model in a row,
    /// e.g., `.columns(\MyModel.$foo, \MyModel.$bar, \MyModel.$baz, \MyModel.$bam)`. This quickly becomes quite tedious.
    /// By contrast, this method accepts only a single `Schema` type, and all KeyPaths are assumed to refer to it, allowing
    /// the previous example to be written as `.columns(of: MyModel.self, \.$bar, \.$baz, \.$bam)`. As with all other
    /// `.columns()` methods of `SQLInsertBuilder`, this method _replaces_ all existing columns.
    @discardableResult
    public func columns<S: Schema, each P: QueryAddressableProperty>(
        of: S.Type, _ keypaths: repeat KeyPath<S, each P>
    ) -> Self {
        self.insert.columns = []
        for keypath in repeat each keypaths {
          self.insert.columns.append(.identifier(keypath))
        }
        return self
    }

    /// Allow specifying a column or columns for ignoring insert conflicts using Fluent model keypaths.
    @discardableResult
    public func ignoringConflicts<each F: Fields, each P: QueryAddressableProperty>(with keypaths: repeat KeyPath<each F, each P>) -> Self {
        var identifiers: [SQLIdentifier] = []
        for keypath in repeat each keypaths {
            identifiers.append(.identifier(keypath))
        }
        return self.ignoringConflicts(with: identifiers)
    }

    /// Allow specifying a column or columns for resolving insert conflicts using Fluent model keypaths.
    @discardableResult
    public func onConflict<each F: Fields, each P: QueryAddressableProperty>(
        with keypaths: repeat KeyPath<each F, each P>,
        `do` updatePredicate: (SQLConflictUpdateBuilder) throws -> SQLConflictUpdateBuilder
    ) rethrows -> Self {
        var identifiers: [SQLIdentifier] = []
        for keypath in repeat each keypaths {
            identifiers.append(.identifier(keypath))
        }
        return try self.onConflict(with: identifiers, do: updatePredicate)
    }
}

extension SQLDatabase {
    /// Allow specifying a table for an `INSERT` query using a Fluent model.
    public func insert(into model: (some Schema).Type) -> SQLInsertBuilder {
        self.insert(into: model.sqlTable)
    }
}
#endif
