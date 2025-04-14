import SQLKit

extension SQLExpression {
    /// A convenience method for creating an `SQLGroupExpression` from a content expression.
    public static func group(_ content: some SQLExpression) -> Self where Self == SQLGroupExpression {
        .init(content)
    }
}
