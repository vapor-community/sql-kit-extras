import SQLKit

/// Represents a `CAST` expression in SQL, which converts a value from one type to another.
public struct SQLCastExpression: SQLExpression {
    /// The original expression to be cast.
    public let original: any SQLExpression

    /// The desired type to cast the original expression to.
    public let desiredType: any SQLExpression

    /// Create a new ``SQLCastExpression``.
    ///
    /// - Parameters:
    ///   - original: The original expression to be cast.
    ///   - desiredType: The desired type to cast the original expression to.
    public init(expr: some SQLExpression, castType: some SQLExpression) {
        self.original = expr
        self.desiredType = castType
    }

    /// Convenience initializer for creating a ``SQLCastExpression`` with a string for the original expression and a string for the desired type.
    ///
    /// - Parameters:
    ///   - original: The original expression to be cast.
    ///   - desiredType: The desired type to cast the original expression to, represented as a string.
    public init(_ original: some SQLExpression, to type: some StringProtocol) {
        self.init(expr: original, castType: .identifier(type))
    }

    /// See `SQLExpression.serialize(to:)`.
    public func serialize(to serializer: inout SQLSerializer) {
        SQLFunction("CAST", args: SQLAlias(self.original, as: self.desiredType))
            .serialize(to: &serializer)
    }
}

extension SQLExpression {
    /// Convenience method for creating a ``SQLCastExpression`` using a column name and a string for the desired type.
    public static func cast(
        _ column: some StringProtocol,
        to type: some StringProtocol
    ) -> Self where Self == SQLCastExpression {
        .cast(.column(column), to: .identifier(type))
    }

    /// Convenience method for creating a ``SQLCastExpression`` using a column name and a string for the desired type.
    public static func cast(
        _ column: some SQLExpression,
        to type: some StringProtocol
    ) -> Self where Self == SQLCastExpression {
        .cast(column, to: .identifier(type))
    }

    /// Convenience method for creating a ``SQLCastExpression`` using a column name and an expression for the desired type.
    public static func cast(
        _ column: some SQLExpression,
        to type: some SQLExpression
    ) -> Self where Self == SQLCastExpression {
        .init(expr: column, castType: type)
    }
}
