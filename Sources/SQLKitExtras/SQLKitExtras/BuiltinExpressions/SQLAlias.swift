import SQLKit

extension SQLExpression {
    /// A convenience method for creating an `SQLAlias` from an identifier string and an alias string.
    public static func alias(
        _ identifier: some StringProtocol,
        as alias: some StringProtocol
    ) -> Self where Self == SQLAlias {
        .alias(.identifier(identifier), as: alias)
    }

    /// A convenience method for creating an `SQLAlias` from an identifier expression and an alias string.
    public static func alias(
        _ identifier: some SQLExpression,
        as alias: some StringProtocol
    ) -> Self where Self == SQLAlias {
        .alias(identifier, as: .identifier(alias))
    }

    /// A convenience method for creating an `SQLAlias` from an identifier expression and an alias expression.
    public static func alias(
        _ identifier: some SQLExpression,
        as alias: some SQLExpression
    ) -> Self where Self == SQLAlias {
        .init(identifier, as: alias)
    }
}
