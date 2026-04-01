#if FluentSQLKitExtras
public import FluentKit
public import SQLKit

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

    /// For each keypath in an arbitrary list of Fluent model keypaths, decodes the appropriate column from the result
    /// row (if any), returning the combined results as a tuple where the types of each item of the tuple are inferred
    /// from the property referenced by the corresponding keypath. If the query produced no results, `nil` is returned.
    /// This is identical to ``first<each Schema, each QueryAddressableProperty>(decodingColumns: repeat...)``, except
    /// that on that method, each KeyPath can refer to a different Schema, forcing the caller to specify the root type on
    /// all of them. However, it is a very common use case to specify many keypaths from the same model in a row, e.g.,
    /// `.first(decodingColumns: \MyModel.$foo, \MyModel.$bar, \MyModel.$baz, \MyModel.$bam)`. This quickly becomes quite
    /// tedious. By contrast, this method accepts only a single `Schema` type, and all KeyPaths are assumed to refer to
    /// it, allowing the previous example to be written as `.first(decodingColumnsOf: MyModel.self, \.$bar, \.$baz, \.$bam)`.
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
    public func first<S: Schema, each P: QueryAddressableProperty>(
        decodingColumnsOf: S.Type, _ keypaths: repeat KeyPath<S, each P>
    ) async throws -> (repeat (each P).QueryablePropertyType.Value)? {
        try await self.first().map {
            try $0.decode(columnsOf: S.self, repeat each keypaths)
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

    /// For each keypath in an arbitrary list of Fluent model keypaths, decodes the appropriate column from each result
    /// row, returning the combined results as an array of tuples where the types of each item of the tuple are inferred
    /// from the property referenced by the corresponding keypath. This is identical to
    /// ``all<each Schema, each QueryAddressableProperty>(decodingColumns: repeat...)``, except that on that method, each
    /// KeyPath can refer to a different Schema, forcing the caller to specify the root type on all of them. However, it is
    /// a very common use case to specify many keypaths from the same model in a row, e.g.,
    /// `.all(decodingColumns: \MyModel.$foo, \MyModel.$bar, \MyModel.$baz, \MyModel.$bam)`. This quickly becomes quite
    /// tedious. By contrast, this method accepts only a single `Schema` type, and all KeyPaths are assumed to refer to
    /// it, allowing the previous example to be written as `.all(decodingColumnsOf: MyModel.self, \.$bar, \.$baz, \.$bam)`.
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
    public func all<S: Schema, each P: QueryAddressableProperty>(
        decodingColumnsOf: S.Type, _ keypaths: repeat KeyPath<S, each P>
    ) async throws -> [(repeat (each P).QueryablePropertyType.Value)] {
        try await self.all().map {
            try $0.decode(columnsOf: S.self, repeat each keypaths)
        }
    }
}
#endif
