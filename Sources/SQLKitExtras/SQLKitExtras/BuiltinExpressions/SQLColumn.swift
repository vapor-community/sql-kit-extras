import SQLKit

extension SQLExpression {
    /// A convenience method for creating an `SQLColumn` from a column name and an optional table name.
    public static func column(
        _ name: some StringProtocol,
        table: (some StringProtocol)? = String?.none
    ) -> Self where Self == SQLColumn {
        .init(String(name), table: table.map { String($0) })
    }

    /// A convenience method for creating an `SQLColumn` from a column name and table expression.
    public static func column(
        _ name: some StringProtocol,
         table: some SQLExpression
    ) -> Self where Self == SQLColumn {
        .column(.identifier(name), table: table)
    }

    /// A convenience method for creating an `SQLColumn` from a column expression and a table name.
    public static func column(
        _ name: some SQLExpression,
        table: some StringProtocol
    ) -> Self where Self == SQLColumn {
        .column(name, table: .some(.identifier(table)))
    }

    /// A convenience method for creating an `SQLColumn` from a column expression and an optional table expression.
    public static func column(
        _ name: some SQLExpression,
        table: (some SQLExpression)? = SQLRaw?.none
    ) -> Self where Self == SQLColumn {
        .init(name, table: table)
    }
}
