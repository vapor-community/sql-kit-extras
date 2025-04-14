import SQLKit

extension SQLExpression {
    /// A convenience method for creating an `SQLBinaryExpression` from an expression operand, a binary operator,
    /// and an encodable operand.
    public static func expr(
        _ lhs: some SQLExpression,
        _ op: SQLBinaryOperator,
        _ rhs: some Encodable & Sendable
    ) -> Self where Self == SQLBinaryExpression {
        .expr(lhs, op, .bind(rhs))
    }

    /// A convenience method for creating an `SQLBinaryExpression` from two expression operands and a binary operator.
    public static func expr(
        _ lhs: some SQLExpression,
        _ op: SQLBinaryOperator,
        _ rhs: some SQLExpression
    ) -> Self where Self == SQLBinaryExpression {
        .init(lhs, op, rhs)
    }

    /// Produces a left-nested binary expression joining each of the provided subexpressions with the given operator.
    /// Due to the limtations of variadic generics, at least two subexpressions must be provided. Subexpressions may be
    /// of any valid expression type.
    ///
    /// Example:
    ///
    /// ```swift
    /// let allExprs: SQLBinaryExpression = .expr(
    ///     op: .and,
    ///     .expr(.identifier("foo"), .equal, "bar"),
    ///     .not(.literal(false)),
    ///     .function("bool_func"),
    ///     .expr(.identifier("baz"), .notLike, .literal("%bamf%"))
    /// )
    ///
    /// // Identical to:
    /// let allExprs: SQLBinaryExpression = .expr(
    ///     .expr(
    ///         .expr(
    ///             .expr("foo", .equal, "bar"),
    ///             .and,
    ///             .not(.literal(false))
    ///         ),
    ///         .and,
    ///         .function("bool_func")
    ///     ),
    ///     .and,
    ///     .expr("baz", .notLike, .literal("%bamf%"))
    /// )
    ///
    /// // Serializes to (Postgres dialect):
    /// //  "foo" = $1 AND NOT false AND bool_func() AND "baz" NOT LIKE '%bamf%' ['bar'::text]
    /// ```
    ///
    public static func expr<each E: SQLExpression>(
        op: SQLBinaryOperator,
        _ expr1: some SQLExpression,
        _ expr2: some SQLExpression,
        _ exprs: repeat each E
    ) -> Self where Self == SQLBinaryExpression {
        var finalExpr = SQLBinaryExpression(expr1, op, expr2)
        for expr in repeat each exprs {
            finalExpr = .expr(finalExpr, op, expr)
        }
        return finalExpr
    }
}
