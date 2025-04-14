#if PostgreSQLKitExtras
import SQLKit

/// An expression providing PostgreSQL's `value::type` syntax for explicit typecasting.
public struct PostgreSQLCast: SQLExpression {
    /// The value expression to be typecast.
    public let expr: any SQLExpression

    /// An expression representing the type to which the value expression is to be cast.
    public let castType: any SQLExpression
    
    /// Memberwise initializer.
    ///
    /// - Parameters:
    ///   - expr: The value expression to be typecast.
    ///   - castType: The type to which the value is to be cast.
    public init(expr: any SQLExpression, castType: any SQLExpression) {
        self.expr = expr
        self.castType = castType
    }
    
    /// Convenience initializer for specfying the type to cast to as a string.
    ///
    /// - Parameters:
    ///   - expr: The value expression to tbe typecast.
    ///   - castType: The type to which the value is to be cast.
    public init(_ expr: any SQLExpression, as castType: String) {
        self.init(expr: expr, castType: .identifier(castType))
    }

    // See `SQLExpression.serialize(to:)`.
    public func serialize(to serializer: inout SQLSerializer) {
        self.expr.serialize(to: &serializer)
        serializer.write("::")
        self.castType.serialize(to: &serializer)
    }
}

extension SQLExpression {
    /// Convenience method for creating a ``PostgreSQLCast`` using strings for the value and the desired type.
    public static func psql_cast(
        _ column: some StringProtocol,
        to type: some StringProtocol
    ) -> Self where Self == PostgreSQLCast {
        .psql_cast(.column(column), to: .identifier(type))
    }

    /// Convenience method for creating a ``PostgreSQLCast`` using an expression for the value and a string for
    /// the desired type.
    public static func psql_cast(
        _ column: some SQLExpression,
        to type: some StringProtocol
    ) -> Self where Self == PostgreSQLCast {
        .psql_cast(column, to: .identifier(type))
    }

    /// Convenience method for creating a ``PostgreSQLCast`` using expressions for the value and the desired type.
    public static func psql_cast(
        _ column: some SQLExpression,
        to type: some SQLExpression
    ) -> Self where Self == PostgreSQLCast {
        .init(expr: column, castType: type)
    }
}
#endif
