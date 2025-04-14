#if PostgreSQLKitExtras
import SQLKit

/// An expression representing a PostgreSQL `VALUES` expression.
///
/// The intended usage of this expression is for each "row" expression to be an `SQLList` with the
/// same number of subexpressions. Example:
///
/// ```swift
/// let values = PostgreSQLValuesExpression(rows:
///     .init([SQLLiteral.string("a"), SQLLiteral.number("1")]),
///     .init([SQLLiteral.string("b"), SQLLiteral.number("2")])
/// )
/// ```
public struct PostgreSQLValuesExpression: SQLExpression {
    public var rows: [any SQLExpression]

    public init(rows: SQLList...) {
        self.init(rows: rows)
    }

    public init(rows: [any SQLExpression]) {
        self.rows = rows
    }

    public func serialize(to serializer: inout SQLSerializer) {
        serializer.statement {
            $0.append("VALUES", SQLList(self.rows.map { SQLGroupExpression($0) }))
        }
    }
}

extension SQLExpression {
    /// Convenience method for creating a ``PostgreSQLValuesExpression`` expression.
    public static func psql_values(_ rows: SQLList...) -> Self where Self == PostgreSQLValuesExpression {
        .psql_values(rows)
    }

    /// Convenience method for creating a ``PostgreSQLValuesExpression`` expression.
    public static func psql_values(_ rows: [any SQLExpression]) -> Self where Self == PostgreSQLValuesExpression {
        .init(rows: rows)
    }
}
#endif
