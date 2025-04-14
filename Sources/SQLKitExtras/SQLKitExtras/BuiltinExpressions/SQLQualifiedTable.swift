import SQLKit

extension SQLExpression {
    /// A convenience method for creating an `SQLQualifiedTable` from a table name and an optional space name.
    public static func table(
        _ name: some StringProtocol,
        space: (some StringProtocol)? = String?.none
    ) -> Self where Self == SQLQualifiedTable {
        .init(String(name), space: space.map { String($0) })
    }

    /// A convenience method for creating an `SQLQualifiedTable` from a table name and a space expression.
    public static func table(
        _ name: some StringProtocol,
        space: some SQLExpression
    ) -> Self where Self == SQLQualifiedTable {
        .table(.identifier(name), space: space)
    }

    /// A convenience method for creating an `SQLQualifiedTable` from a table expession and a space name.
    public static func table(
        _ name: some SQLExpression,
        space: some StringProtocol
    ) -> Self where Self == SQLQualifiedTable {
        .table(name, space: .identifier(space))
    }

    /// A convenience method for creating an `SQLQualifiedTable` from a table expression and an optional space expression.
    public static func table(
        _ name: some SQLExpression,
        space: (any SQLExpression)? = SQLRaw?.none
    ) -> Self where Self == SQLQualifiedTable {
        .init(name, space: space)
    }
}
