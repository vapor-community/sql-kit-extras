#if FluentSQLKitExtras
import FluentKit
import SQLKit

extension SQLQueryFetcher {
    /// Allow specifying a Fluent model keypath as a column name when decoding a single query fetcher result.
    public func first<M: Schema, P: QueryAddressableProperty>(
        decodingColumn keypath: KeyPath<M, P>
    ) async throws -> P.QueryablePropertyType.Value? {
        try await self.first(decodingColumn: M.fieldKey(for: keypath).description, as: P.QueryablePropertyType.Value.self)
    }

    /// For each keypath in an arbitrary list of Fluent model keypaths, decodes the appropriate column from the result
    /// row (if any), returning the combined results as a tuple where the types of each item of the tuple are inferred
    /// from the property referenced by the corresponding keypath. If the query produced no results, `nil` is returned.
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
    /// let tuple/*(id, field1, parentId, field2)*/ = try await sqlDatabase.select()
    ///     .columns(\MyModel.$id, \MyModel.$field1, \MyModel.$parent, \MyModel.$field2)
    ///     .from(MyModel.self)
    ///     .first(decodingColumns: \MyModel.$id, \MyModel$field1, \MyModel.$parent, \MyModel.$field2)
    ///
    /// // type(of: tuple) == (Int, String, ParentModel.IDValue, SomeEnum).self
    /// ```
    public func first<each S: Schema, each P: QueryAddressableProperty>(
        decodingColumns keypaths: repeat KeyPath<each S, each P>
    ) async throws -> (repeat (each P).QueryablePropertyType.Value)? {
        try await self.first().map {
            try $0.decode(columns: repeat each keypaths)
        }
    }

    /// Allow specifying a Fluent model keypath as a column name when decoding multiple query fetcher results.
    public func all<M: Schema, P: QueryAddressableProperty>(
        decodingColumn keypath: KeyPath<M, P>
    ) async throws -> [P.QueryablePropertyType.Value] {
        try await self.all(decodingColumn: M.fieldKey(for: keypath).description, as: P.QueryablePropertyType.Value.self)
    }

    /// For each keypath in an arbitrary list of Fluent model keypaths, decodes the appropriate column from each result
    /// row, returning the combined results as an array of tuples where the types of each item of the tuple are inferred
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
    /// let tuples = try await sqlDatabase.select()
    ///     .columns(\MyModel.$id, \MyModel.$field1, \MyModel.$parent, \MyModel.$field2)
    ///     .from(MyModel.self)
    ///     .all(decodingColumns: \MyModel.$id, \MyModel$field1, \MyModel.$parent, \MyModel.$field2)
    ///
    /// // type(of: tuples) == Array<(Int, String, ParentModel.IDValue, SomeEnum)>.self
    /// ```
    public func all<each S: Schema, each P: QueryAddressableProperty>(
        decodingColumns keypaths: repeat KeyPath<each S, each P>
    ) async throws -> [(repeat (each P).QueryablePropertyType.Value)] {
        try await self.all().map {
            try $0.decode(columns: repeat each keypaths)
        }
    }
}
#endif
