#if FluentSQLKitExtras
import FluentKit
import SQLKit

extension SQLSubqueryClauseBuilder {
    /// Allow specifying a table for a `FROM` clause using a Fluent model. Note that due to `FROM`'s place in query
    /// syntax, the result of `Schema.sqlTable` is not suitable here. If an `alias` is provided, it takes precedence
    /// over that specified by the model type (such as by a `ModelAlias`) and it will be the caller's responsibility
    /// to deal with that override in other contexts that assume the model's alias is the one to use. (This will never
    /// be a concern for 99.999999% of users.)
    @discardableResult
    public func from(_ type: any Schema.Type, as alias: String? = nil) -> Self {
        if let alias = alias ?? type.alias {
            self.from(SQLQualifiedTable(type.schema, space: type.space), as: .identifier(alias))
        } else {
            self.from(SQLQualifiedTable(type.schema, space: type.space))
        }
    }

    /// Allow specifying columns in a `GROUP BY` clause using Fluent model keypaths.
    @discardableResult
    public func groupBy<each S: Schema, each P: QueryAddressableProperty>(
        _ keypaths: repeat KeyPath<each S, each P>
    ) -> Self {
        repeat _ = self.groupBy(.column(each keypaths))
        return self
    }
}
#endif
