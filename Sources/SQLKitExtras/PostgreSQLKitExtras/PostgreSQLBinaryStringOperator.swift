#if PostgreSQLKitExtras
import SQLKit

/// An expression representing one of several binary string comparison operators specific to PostgreSQL.
public enum PostgreSQLBinaryStringOperator: SQLExpression {
    /// The PostgreSQL `ILIKE` operator.
    case caseInsensitiveLike

    /// The PostgreSQL `NOT ILIKE` operator.
    case caseInsensitiveNotLike

    /// The PostgreSQL `SIMILAR TO` operator.
    case similarTo

    /// The PostgreSQL `NOT SIMILAR TO` operator.
    case notSimilarTo

    // See `SQLExpression.serialize(to:)`.
    public func serialize(to serializer: inout SQLSerializer) {
        switch self {
        case .caseInsensitiveLike:    serializer.write("ILIKE")
        case .caseInsensitiveNotLike: serializer.write("NOT ILIKE")
        case .similarTo:              serializer.write("SIMILAR TO")
        case .notSimilarTo:           serializer.write("NOT SIMILAR TO")
        }
    }
}

/// > Note: We could of course define extensions on `SQLBinaryExpression` et al to allow specifying values of
/// > ``PostgreSQLBinaryStringOperator`` type directly rather than relying upon static methods added to `SQLExpression`.
/// > However, as attractive as this solution seems, the typechecker choked badly on the additional overloads when it
/// > was tried, throwing numerous "Unable to type-check this expression in reasonable time" errors in code which had
/// > previously compiled without issues.

extension SQLExpression {
    /// Convenience method for creating a ``PostgreSQLBinaryStringOperator`` for the `ILIKE` operator.
    public static func ilike() -> Self where Self == PostgreSQLBinaryStringOperator {
        .caseInsensitiveLike
    }

    /// Convenience method for creating a ``PostgreSQLBinaryStringOperator`` for the `NOT ILIKE` operator.
    public static func notILike() -> Self where Self == PostgreSQLBinaryStringOperator {
        .caseInsensitiveNotLike
    }

    /// Convenience method for creating a ``PostgreSQLBinaryStringOperator`` for the `SIMILAR TO` operator.
    public static func similarTo() -> Self where Self == PostgreSQLBinaryStringOperator {
        .similarTo
    }

    /// Convenience method for creating a ``PostgreSQLBinaryStringOperator`` for the `NOT SIMILAR TO` operator.
    public static func notSimilarTo() -> Self where Self == PostgreSQLBinaryStringOperator {
        .notSimilarTo
    }
}
#endif
