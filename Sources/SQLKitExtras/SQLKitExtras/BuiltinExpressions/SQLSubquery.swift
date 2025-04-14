import SQLKit

extension SQLExpression {
    /// A convenience method for calling `SQLSubquery.select(_:)`.
    public static func subquery(
        _ build: (SQLSubqueryBuilder) throws -> SQLSubqueryBuilder
    ) rethrows -> Self where Self == SQLSubquery {
        // N.B.: We have to reimplement `SQLSubquery.select()` here instead of calling it because it returns `some SQLExpression` and we
        // need a concrete type for this method to work.
        let builder = SQLSubqueryBuilder()
        _ = try build(builder)
        return builder.query
    }
}
