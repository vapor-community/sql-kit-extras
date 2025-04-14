import SQLKit

extension SQLExpression {
    /// A convenience method for creating an `SQLBind` from an encodable value.
    public static func bind(_ value: some Encodable & Sendable) -> Self where Self == SQLBind {
        .init(value)
    }

    /// A convenience method for creating an `SQLGroupExpession` which wraps a series of `SQLBind` expressions
    /// from a sequence of encodable values.
    public static func bindGroup(_ values: some Sequence<some Encodable & Sendable>) -> Self where Self == SQLGroupExpression {
        .init(values.map(SQLBind.init(_:)))
    }
}
