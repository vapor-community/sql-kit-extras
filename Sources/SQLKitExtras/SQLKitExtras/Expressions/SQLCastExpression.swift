import SQLKit

/// Represents a `CAST` expression in SQL, which converts a value from one type to another.
public struct SQLCastExpression: SQLExpression {
    /// The original expression to be cast.
    public let original: any SQLExpression

    /// The desired type to cast the original expression to.
    public let desiredType: String

    /// Convenience initializer for creating a ``SQLCastExpression`` with a string for the original expression and a string for the desired type.
    ///
    /// - Parameters:
    ///   - original: The original expression to be cast.
    ///   - desiredType: The desired type to cast the original expression to, represented as a string.
    public init(_ original: some SQLExpression, to type: String) {
        self.original = original
        self.desiredType = type
    }

    /// See `SQLExpression.serialize(to:)`.
    public func serialize(to serializer: inout SQLSerializer) {
        if serializer.dialect.name == "mysql" {
            SQLFunction("CAST", args: SQLAlias(self.original, as: SQLRaw(self.desiredType)))
                .serialize(to: &serializer)
        } else {
            SQLFunction("CAST", args: SQLAlias(self.original, as: SQLIdentifier(self.desiredType)))
                .serialize(to: &serializer)
        }
    }
}

extension SQLExpression {
    /// Convenience method for creating a ``SQLCastExpression`` using a column name and a string for the desired type.
    public static func cast(
        _ column: some StringProtocol,
        to type: String
    ) -> Self where Self == SQLCastExpression {
        .cast(.column(column), to: type)
    }

    /// Convenience method for creating a ``SQLCastExpression`` using a column name and a string for the desired type.
    public static func cast(
        _ column: some SQLExpression,
        to type: String
    ) -> Self where Self == SQLCastExpression {
        .init(column, to: type)
    }
}
