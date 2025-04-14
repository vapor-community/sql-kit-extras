import SQLKit

extension SQLExpression {
    /// A convenience method for creating an `SQLRaw` from a string.
    ///
    /// > Warning: Using raw SQL is not safe. Handle with care.
    public static func unsafeRaw(_ content: some StringProtocol) -> Self where Self == SQLRaw {
        .init(String(content))
    }
}
