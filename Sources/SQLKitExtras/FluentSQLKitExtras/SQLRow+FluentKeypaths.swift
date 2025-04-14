#if FluentSQLKitExtras
import FluentKit
import SQLKit

extension SQLRow {
    /// Allow using `SQLRow.contains(column:)` with Fluent model keypaths.
    public func contains<F: Fields>(
        column keypath: KeyPath<F, some QueryAddressableProperty>
    ) -> Bool {
        self.contains(column: F.key(for: keypath))
    }

    /// Allow using `SQLRow.decodeNil(column:)` with Fluent model keypaths.
    public func decodeNil<F: Fields>(
        column keypath: KeyPath<F, some QueryAddressableProperty>
    ) throws -> Bool {
        try self.decodeNil(column: F.key(for: keypath))
    }

    /// Allow using `SQLRow.decode(column:as:)` with Fluent model keypaths. The result type is inferred from
    /// the referneced property.
    public func decode<F: Fields, P: QueryAddressableProperty>(
        column keypath: KeyPath<F, P>
    ) throws -> P.QueryablePropertyType.Value {
        try self.decode(column: F.key(for: keypath), as: P.QueryablePropertyType.Value.self)
    }

    /// For each keypath in an arbitrary list of Fluent model keypaths, decode the appropriate column from the
    /// `SQLRow`, returning the combined results as a tuple where the types of each item of the tuple are inferred
    /// from the property referenced by the corresponding keypath.
    ///
    /// Example:
    ///
    /// ```swift
    /// final class MyModel: FluentKit.Model, @unchecked Sendable {
    ///     @ID(custom: .id) var id: Int?
    ///     @Field(key: "field1") var field1: String
    ///     @Parent(key: "parent_id") var parent: ParentModel
    ///     @Enum(key: "field2") var field2: SomeEnum
    ///     init() {}
    /// }
    ///
    /// let rows = try await sqlDatabase.select()
    ///     .columns(\MyModel.$id, \MyModel.$field1, \MyModel.$parent, \MyModel.$field2)
    ///     .from(MyModel.self)
    ///     .all()
    ///
    /// for row in rows {
    ///     let tuple/*(id, field1, parentId, field2)*/ = try row.decode(columns:
    ///         \MyModel.$id, \MyModel$field1, \MyModel.$parent, \MyModel.$field2
    ///     )
    ///     // type(of: tuple) == (Int, String, ParentModel.IDValue, SomeEnum).self
    /// }
    /// ```
    public func decode<each S: Schema, each P: QueryAddressableProperty>(
        columns keypaths: repeat KeyPath<each S, each P>
    ) throws -> (repeat (each P).QueryablePropertyType.Value) {
        (repeat try self.decode(column: each keypaths))
    }
}
#endif
