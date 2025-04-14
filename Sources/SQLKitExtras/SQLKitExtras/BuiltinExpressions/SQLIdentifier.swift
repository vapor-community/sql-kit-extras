import SQLKit

extension SQLExpression {
    /// A convenience method for creating an `SQLIdentifier` from a string.
    public static func identifier(_ str: some StringProtocol) -> Self where Self == SQLIdentifier {
        .init(String(str))
    }
}
