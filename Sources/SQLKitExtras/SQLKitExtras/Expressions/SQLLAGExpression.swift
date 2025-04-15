import SQLKit

/// Represents a `LAG(value, offset) OVER (ORDER BY ...)` expression.
/// This expression is used to access data from a previous row in the result set.
public struct SQLLAGExpression: SQLExpression {
    /// The value to be accessed from the previous row.
    public let value: any SQLExpression
    /// The offset from the current row to the previous row.
    public let offset: any SQLExpression
    /// The default value to be used if the offset is out of bounds.
    public let defaultValue: (any SQLExpression)?

    /// Create a new ``SQLLAGExpression``.
    /// 
    /// - Parameters:
    ///   - value: The value to be accessed from the previous row.
    ///   - offset: The offset from the current row to the previous row.
    ///   - defaultValue: The default value to be used if the offset is out of bounds.
    public init(
        value: some SQLExpression,
        offset: some SQLExpression,
        defaultValue: (some SQLExpression)? = SQLRaw?.none
    ) {
        self.value = value
        self.offset = offset
        self.defaultValue = defaultValue
    }

    /// See `SQLExpression.serialize(to:)`.
    public func serialize(to serializer: inout SQLSerializer) {
        serializer.write("LAG(")
        value.serialize(to: &serializer)
        serializer.write(") OVER (ORDER BY ")
        offset.serialize(to: &serializer)
        serializer.write(")")
        if let defaultValue = defaultValue {
            serializer.write(" DEFAULT ")
            defaultValue.serialize(to: &serializer)
        }
    }
}

extension SQLExpression {
    /// Convenience method for creating an ``SQLLAGExpression``.
    public static func lag(
        _ value: some SQLExpression,
        offset: some SQLExpression,
        defaultValue: (some SQLExpression)? = SQLRaw?.none
    ) -> Self where Self == SQLLAGExpression {
        .init(value: value, offset: offset, defaultValue: defaultValue)
    }
}
