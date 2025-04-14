#if PostgreSQLKitExtras
import SQLKit

/// An expression representing a PostgreSQL `SET name = value` query.
public struct PostgreSQLSetQuery: SQLExpression {
    /// An expression representing the name of the variable to be set.
    public let name: any SQLExpression

    /// An expression representing the value to set the variable to.
    public let value: any SQLExpression

    /// Memberwise initializer
    ///
    /// - Parameters:
    ///   - name: The name of the variable to set.
    ///   - value: The value to set the variable to.
    public init(name: any SQLExpression, value: any SQLExpression) {
        self.name = name
        self.value = value
    }

    // See `SQLExpression.serialize(to:)`.
    public func serialize(to serializer: inout SQLSerializer) {
        serializer.statement {
            $0.append("SET", self.name)
            $0.append(SQLBinaryOperator.equal, self.value)
        }
    }
}

/// A query builder for constructing ``PostgreSQLSetQuery`` expressions.
public final class PostgreSQLSetQueryBuilder: SQLQueryBuilder {
    /// The actual query.
    public let setQuery: PostgreSQLSetQuery

    // See `SQLQueryBuilder.database`.
    public let database: any SQLDatabase

    // See `SQLQueryBuilder.query`.
    public var query: any SQLExpression { self.setQuery }
    
    /// Memberwise initializer.
    ///
    /// - Parameters:
    ///   - setQuery: The variable assignment query to run.
    ///   - database: The database to run the query on.
    public init(setQuery: PostgreSQLSetQuery, on database: any SQLDatabase) {
        self.setQuery = setQuery
        self.database = database
    }
}

extension SQLDatabase {
    /// Create a new ``PostgreSQLSetQueryBuilder`` using a string for both the variable name and value.
    public func psql_set(_ name: some StringProtocol, to value: some StringProtocol) -> PostgreSQLSetQueryBuilder {
        self.psql_set(.identifier(name), to: .literal(value))
    }

    /// Create a new ``PostgreSQLSetQueryBuilder`` using a string for the variable name and an expression for the value.
    public func psql_set(_ name: some StringProtocol, to value: some SQLExpression) -> PostgreSQLSetQueryBuilder {
        self.psql_set(.identifier(name), to: value)
    }

    /// Create a new ``PostgreSQLSetQueryBuilder`` using expressions for both the variable name and value.
    public func psql_set(_ name: some SQLExpression, to value: some SQLExpression) -> PostgreSQLSetQueryBuilder {
        .init(setQuery: .init(name: name, value: value), on: self)
    }
}
#endif
