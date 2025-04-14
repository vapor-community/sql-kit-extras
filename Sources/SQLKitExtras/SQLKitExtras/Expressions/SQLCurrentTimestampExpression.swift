import SQLKit

/// An expression representing a timestamp value corresponding to the current date and time.
public struct SQLCurrentTimestampExpression: SQLExpression {
    /// Create an ``SQLCurrentTimestampExpression``.
    public init() {}

    // See `SQLExpression.serialize(to:)`.
    public func serialize(to serializer: inout SQLSerializer) {
        switch serializer.dialect.name {
        case "sqlite":
            // For SQLite, we match the behavior of SQLiteKit and use the UNIX epoch.
            SQLFunction("unixepoch").serialize(to: &serializer)
        case "postgresql":
            // For PostgreSQL, "current_timestamp" is a keyword, not a function, so use "now()" instead.
            SQLFunction("now").serialize(to: &serializer)
        default:
            // Everywhere else, just call the SQL standard function.
            SQLFunction("current_timestamp").serialize(to: &serializer)
        }
    }
}

extension SQLExpression {
    /// A convenience method for specifying the current date and time as an SQL expression.
    public static func now() -> Self where Self == SQLCurrentTimestampExpression {
        .init()
    }
}
