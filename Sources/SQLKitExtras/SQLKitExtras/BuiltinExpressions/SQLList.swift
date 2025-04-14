import SQLKit

extension SQLExpression {
    /// A convenience method for creating an `SQLList` from a list of component expressions and a separator string.
    public static func list<each E: SQLExpression>(
        _ pieces: repeat each E,
        separator: some StringProtocol
    ) -> Self where Self == SQLList {
        var args: [any SQLExpression] = []
        repeat args.append(each pieces)
        return .list(args, separator: separator)
    }

    /// A convenience method for creating an `SQLList` from a sequence of component expressions and a separator string.
    public static func list(
        _ pieces: some Sequence<any SQLExpression>,
        separator: some StringProtocol
    ) -> Self where Self == SQLList {
        .init(Array(pieces), separator: .unsafeRaw(separator))
    }

    /// A convenience method for creating an `SQLList` from a list of component expressions, using a comma as the separator.
    public static func list<each E: SQLExpression>(_ pieces: repeat each E) -> Self where Self == SQLList {
        .list(repeat each pieces, separator: ", ")
    }

    /// A convenience method for creating an `SQLList` from a sequence of component expressions, using a comma as the separator.
    public static func list(_ pieces: some Sequence<any SQLExpression>) -> Self where Self == SQLList {
        .list(pieces, separator: ", ")
    }

    /// A convenience method for creating an `SQLList` from a list of component expressions, using a space as the separator.
    public static func clause<each E: SQLExpression>(_ pieces: repeat each E) -> Self where Self == SQLList {
        .list(repeat each pieces, separator: " ")
    }

    /// A convenience method for creating an `SQLList` from a sequence of component expressions, using a space as the separator.
    public static func clause(_ pieces: some Sequence<any SQLExpression>) -> Self where Self == SQLList {
        .list(pieces, separator: " ")
    }
}
