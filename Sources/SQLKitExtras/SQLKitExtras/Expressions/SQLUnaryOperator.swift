import SQLKit

/// SQL unary expression operators.
public enum SQLUnaryOperator: SQLExpression {
    /// Boolean inversion, or `NOT`.
    case not

    /// Arithmetic negation, or `-`.
    case negate

    /// Arithmetic positation, or `+` (no operation).
    case plus

    /// Bitwise inversion, or `~`.
    case invert

    /// Escape hatch for easily defining additional unary operators.
    case custom(String)

    // See `SQLExpression.serialize(to:)`.
    @inlinable
    public func serialize(to serializer: inout SQLSerializer) {
        switch self {
        case .not:
            serializer.write("NOT")
        case .negate:
            serializer.write("-")
        case .plus:
            serializer.write("+")
        case .invert:
            serializer.write("~")
        case .custom(let custom):
            serializer.write(custom)
        }
    }
}
