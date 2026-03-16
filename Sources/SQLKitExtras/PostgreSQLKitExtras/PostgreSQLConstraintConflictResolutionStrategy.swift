import SQLKit

/// A PostgreSQL `ON CONFLICT ON CONSTRAINT` clause that targets a named constraint rather than
/// a column list.
///
/// SQLKit's built-in `SQLConflictResolutionStrategy` only supports column-targeted upserts
/// (`ON CONFLICT (col1, col2) ...`). This type serializes the named-constraint form instead:
///
/// ```sql
/// ON CONFLICT ON CONSTRAINT uq_users_email DO NOTHING
/// ON CONFLICT ON CONSTRAINT uq_users_email DO UPDATE SET name = EXCLUDED.name WHERE ...
/// ```
///
/// Use it via the `SQLInsertBuilder` extensions rather than constructing it directly.
public struct PostgreSQLConstraintConflictResolutionStrategy: SQLExpression {
    /// The constraint name or expression used to identify the conflict target.
    public var constraint: any SQLExpression

    /// The action to take when the named constraint is violated.
    public var action: SQLConflictAction

    /// Creates a strategy targeting a constraint by name.
    @inlinable
    public init(constraint: String, action: SQLConflictAction) {
        self.init(constraint: SQLIdentifier(constraint), action: action)
    }

    /// Creates a strategy targeting a constraint by an arbitrary SQL expression.
    @inlinable
    public init(constraint: any SQLExpression, action: SQLConflictAction) {
        self.constraint = constraint
        self.action = action
    }

    public func serialize(to serializer: inout SQLSerializer) {
        serializer.statement {
            $0.append("ON CONFLICT ON CONSTRAINT")
            $0.append(constraint)
            switch self.action {
            case .noAction: $0.append("DO NOTHING")
            case .update(let assignments, let predicate):
                $0.append("DO UPDATE SET", SQLList(assignments))
                if let predicate { $0.append("WHERE", predicate) }
            }
        }
    }
}

/// A query builder that carries a named-constraint conflict strategy.
///
/// Returned by the ``SQLInsertBuilder/psql_onConflictOnConstraint`` and ``SQLInsertBuilder/psql_ignoringConstraintConflict``.
/// Conforms to `SQLQueryBuilder` so it can be executed with `.run()` like any other builder.
public final class PostgreSQLInsertConstraintBuilder: SQLQueryBuilder, SQLExpression {
    private let insert: SQLInsert
    private let conflictStrategy: PostgreSQLConstraintConflictResolutionStrategy

    // See `SQLQueryBuilder.database`.
    public let database: any SQLDatabase

    // See `SQLQueryBuilder.query`.
    public var query: any SQLExpression { self }

    init(insert: SQLInsert, conflictStrategy: PostgreSQLConstraintConflictResolutionStrategy, database: any SQLDatabase) {
        var insert = insert
        insert.conflictStrategy = nil
        self.insert = insert
        self.conflictStrategy = conflictStrategy
        self.database = database
    }

    public func serialize(to serializer: inout SQLSerializer) {
        insert.serialize(to: &serializer)
        serializer.write(" ")
        conflictStrategy.serialize(to: &serializer)
    }
}

extension SQLInsertBuilder {
    /// Adds an `ON CONFLICT ON CONSTRAINT <name>` clause with the given action.
    /// Overrides `.onConflict` and `.ignoringConflicts`.
    ///
    /// ```swift
    /// try await db.insert(into: "users")
    ///     .columns("id", "email", "name")
    ///     .values(1, "alice@example.com", "Alice")
    ///     .psql_onConflictOnConstraint("uq_users_email", action: .update([
    ///         SQLColumnAssignment("name", to: SQLExcluded("name"))
    ///     ]))
    ///     .run()
    /// // INSERT INTO "users" ("id","email","name") VALUES ($1,$2,$3)
    /// // ON CONFLICT ON CONSTRAINT "uq_users_email" DO UPDATE SET "name" = EXCLUDED."name"
    /// ```
    public func psql_onConflictOnConstraint(_ name: String, action: SQLConflictAction = .noAction) -> PostgreSQLInsertConstraintBuilder {
        .init(insert: self.insert, conflictStrategy: .init(constraint: name, action: action), database: self.database)
    }

    /// Adds an `ON CONFLICT ON CONSTRAINT <name> DO NOTHING` clause, ignoring rows that violate the named constraint.
    /// Overrides `.onConflict` and `.ignoringConflicts`.
    ///
    /// ```swift
    /// try await db.insert(into: "users")
    ///     .columns("id", "email")
    ///     .values(1, "alice@example.com")
    ///     .psql_ignoringConstraintConflict("uq_users_email")
    ///     .run()
    /// // INSERT INTO "users" ("id","email") VALUES ($1,$2)
    /// // ON CONFLICT ON CONSTRAINT "uq_users_email" DO NOTHING
    /// ```
    public func psql_ignoringConstraintConflict(_ name: String) -> PostgreSQLInsertConstraintBuilder {
        .init(insert: self.insert, conflictStrategy: .init(constraint: name, action: .noAction), database: self.database)
    }
}
