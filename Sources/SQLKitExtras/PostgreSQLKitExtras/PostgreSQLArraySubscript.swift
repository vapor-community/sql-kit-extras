#if PostgreSQLKitExtras
import SQLKit

/// An expression providing PostgreSQL's `array[N]` syntax for accessing elements of an array.
public struct PostgreSQLArraySubscript: SQLExpression {
    /// An expression representing the array value to be subscripted.
    public let array: any SQLExpression

    /// An expression representing the subscript into the array expression.
    public let `subscript`: any SQLExpression
    
    /// Memberwise initializer.
    ///
    /// - Parameters:
    ///   - array: The array value to be subscripted.
    ///   - subscript: The desired subscript into the array value.
    public init(array: any SQLExpression, subscript: any SQLExpression) {
        self.array = array
        self.subscript = `subscript`
    }

    // See `SQLExpression.serialize(to:)`.
    public func serialize(to serializer: inout SQLSerializer) {
        self.array.serialize(to: &serializer)
        serializer.write("[")
        self.subscript.serialize(to: &serializer)
        serializer.write("]")
    }
}

extension SQLExpression {
    /// Convenience method for creating a ``PostgreSQLArraySubscript`` using strings for the array value and the subscript.
    public static func psql_subscript(
        _ column: some StringProtocol,
        at `subscript`: some StringProtocol
    ) -> Self where Self == PostgreSQLArraySubscript {
        .psql_subscript(.column(column), at: .column(`subscript`))
    }

    /// Convenience method for creating a ``PostgreSQLArraySubscript`` using expressions for the array value and the subscript.
    public static func psql_subscript(
        _ column: some SQLExpression,
        at `subscript`: some SQLExpression
    ) -> Self where Self == PostgreSQLArraySubscript {
        .init(array: column, subscript: `subscript`)
    }
}
#endif
