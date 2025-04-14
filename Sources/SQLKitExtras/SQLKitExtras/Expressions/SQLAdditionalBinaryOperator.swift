import SQLKit

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

/// > Note: We could of course define extensions on `SQLBinaryExpression` et al to allow specifying values of
/// > ``SQLAdditionalBinaryOperator`` type directly rather than relying upon static methods added to `SQLExpression`.
/// > However, as attractive as this solution seems, the typechecker choked badly on the additional overloads when it
/// > was tried, throwing numerous "Unable to type-check this expression in reasonable time" errors in code which had
/// > previously compiled without issues.

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
