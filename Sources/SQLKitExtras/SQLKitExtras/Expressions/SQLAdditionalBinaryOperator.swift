public import SQLKit

/// An expression representing one of several additional binary operators not represented by `SQLBinaryOperator`.
public enum SQLAdditionalBinaryOperator: SQLExpression {
    /// The `&` (bitwise `AND`) operator.
    case AND

    /// The `|` (bitwise `OR`) operator.
    case OR

    /// The bitwise `XOR` operator (`#` in PostgreSQL, `^` in MySQL).
    case XOR

    /// The `<<` (bitwise left shift) operator.
    case leftShift

    /// The `>>` (bitwise right shift) operator.
    case rightShift

    // See `SQLExpression.serialize(to:)`.
    public func serialize(to serializer: inout SQLSerializer) {
        switch self {
        case .AND:        serializer.write("&")
        case .OR:         serializer.write("|")
        case .XOR:
            switch serializer.dialect.name {
            case "postgresql": serializer.write("#")
            case "mysql":      serializer.write("^")
            default:           break // SQLite has no XOR operator
            }
        case .leftShift:  serializer.write("<<")
        case .rightShift: serializer.write(">>")
        }
    }
}

extension SQLExpression {
    /// A convenience method for creating an `SQLBinaryExpression` from an expression operand, a
    /// ``SQLAdditionalBinaryOperator``, and an encodable operand.
    public static func expr(
        _ lhs: some SQLExpression,
        _ op: SQLAdditionalBinaryOperator,
        _ rhs: some Encodable & Sendable
    ) -> Self where Self == SQLBinaryExpression {
        .init(left: lhs, op: op, right: .bind(rhs))
    }

    /// Produces a left-nested binary expression joining each of the provided subexpressions with the given
    /// ``SQLAdditionalBinaryOperator``. Due to the limtations of variadic generics, at least two subexpressions
    /// must be provided. Subexpressions may be of any valid expression type.
    ///
    /// Example:
    ///
    /// ```swift
    /// let allExprs: SQLBinaryExpression = .expr(
    ///     op: .AND,
    ///     .expr(.identifier("foo"), .equal, "bar"),
    ///     .not(.literal(false)),
    /// )
    /// ```
    public static func expr<each E: SQLExpression>(
        op: SQLAdditionalBinaryOperator,
        _ expr1: some SQLExpression,
        _ expr2: some SQLExpression,
        _ exprs: repeat each E
    ) -> Self where Self == SQLBinaryExpression {
        var finalExpr = SQLBinaryExpression(left: expr1, op: op, right: expr2)
        for expr in repeat each exprs {
            finalExpr = SQLBinaryExpression(left: finalExpr, op: op, right: expr)
        }
        return finalExpr
    }
}

/// > Note: We could of course define extensions on `SQLBinaryExpression` et al to allow specifying values of
/// > ``SQLAdditionalBinaryOperator`` type directly rather than relying upon static methods added to
/// > `SQLExpression`. However, as attractive as this solution seems, the typechecker choked badly on the
/// > additional overloads when it was tried, throwing numerous "Unable to type-check this expression in
/// > reasonable time" errors in code which had previously compiled without issues.

extension SQLExpression {
    /// Convenience method for using the ``SQLAdditionalBinaryOperator/AND`` operator.
    public static func AND() -> Self where Self == SQLAdditionalBinaryOperator {
        .AND
    }

    /// Convenience method for using the ``SQLAdditionalBinaryOperator/OR`` operator.
    public static func OR() -> Self where Self == SQLAdditionalBinaryOperator {
        .OR
    }

    /// Convenience method for using the ``SQLAdditionalBinaryOperator/XOR`` operator.
    public static func XOR() -> Self where Self == SQLAdditionalBinaryOperator {
        .XOR
    }

    /// Convenience method for using the ``SQLAdditionalBinaryOperator/leftShift`` operator.
    public static func leftShift() -> Self where Self == SQLAdditionalBinaryOperator {
        .leftShift
    }

    /// Convenience method for using the ``SQLAdditionalBinaryOperator/rightShift`` operator.
    public static func rightShift() -> Self where Self == SQLAdditionalBinaryOperator {
        .rightShift
    }
}
