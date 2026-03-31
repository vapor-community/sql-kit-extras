#if PostgreSQLKitExtras
public import SQLKit

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
public struct PostgreSQLConflictResolutionStrategy: SQLExpression {
    /// The constraint name or expression used to identify the conflict target.
    public let constraint: any SQLExpression
    
    /// The action to take when the named constraint is violated.
    public let action: SQLConflictAction

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
            $0.append("ON CONFLICT ON CONSTRAINT", self.constraint)
            switch self.action {
            case .noAction: 
                $0.append("DO NOTHING")
            case .update(let assignments, let predicate):
                $0.append("DO UPDATE SET", SQLList(assignments))
                if let predicate { 
                    $0.append("WHERE", predicate) 
                }
            }
        }
    }
}

extension SQLInsertBuilder {
    /// Adds an `ON CONFLICT ON CONSTRAINT <name> DO NOTHING` clause, ignoring rows that violate the named constraint.
    /// Overrides `.onConflict` and `.ignoringConflicts`.
    ///
    /// ```swift
    /// try await db.insert(into: "users")
    ///     .columns("id", "email")
    ///     .values(1, "alice@example.com")
    ///     .psql_ignoringConflicts(withConstraint: "uq_users_email")
    ///     .run()
    /// // INSERT INTO "users" ("id","email") VALUES ($1,$2)
    /// // ON CONFLICT ON CONSTRAINT "uq_users_email" DO NOTHING
    /// ```
    @discardableResult
    public func psql_ignoringConflicts(withConstraint constraint: some StringProtocol) -> Self {
        self.psql_ignoringConflicts(withConstraint: .identifier(constraint))
    }

    /// Adds an `ON CONFLICT ON CONSTRAINT <name> DO NOTHING` clause, ignoring rows that violate the named constraint.
    /// Overrides `.onConflict` and `.ignoringConflicts`.
    ///
    /// ```swift
    /// try await db.insert(into: "users")
    ///     .columns("id", "email")
    ///     .values(1, "alice@example.com")
    ///     .psql_ignoringConflicts(withConstraint: .identifier("uq_users_email"))
    ///     .run()
    /// // INSERT INTO "users" ("id","email") VALUES ($1,$2)
    /// // ON CONFLICT ON CONSTRAINT "uq_users_email" DO NOTHING
    /// ```
    @discardableResult
    public func psql_ignoringConflicts(withConstraint constraint: any SQLExpression) -> Self {
        self.insert.genericConflictStrategy = PostgreSQLConflictResolutionStrategy(constraint: constraint, action: .noAction)
        return self
    }

    /// Adds an `ON CONFLICT ON CONSTRAINT <name>` clause with the given action.
    /// Overrides `.onConflict` and `.ignoringConflicts`.
    ///
    /// ```swift
    /// try await db.insert(into: "users")
    ///     .columns("id", "email", "name")
    ///     .values(1, "alice@example.com", "Alice")
    ///     .psql_onConflict(withConstraint: "uq_users_email") { $0
    ///         .set(excludedValueOf: "name")
    ///     }
    ///     .run()
    /// // INSERT INTO "users" ("id","email","name") VALUES ($1,$2,$3)
    /// // ON CONFLICT ON CONSTRAINT "uq_users_email" DO UPDATE SET "name" = EXCLUDED."name"
    /// ```
    @discardableResult
    public func psql_onConflict(
        withConstraint constraint: some StringProtocol, 
        `do` updatePredicate: (SQLConflictUpdateBuilder) throws -> SQLConflictUpdateBuilder
    ) rethrows -> Self {
        try self.psql_onConflict(withConstraint: .identifier(constraint), do: updatePredicate)
    }

    /// Adds an `ON CONFLICT ON CONSTRAINT <name>` clause with the given action.
    /// Overrides `.onConflict` and `.ignoringConflicts`.
    ///
    /// ```swift
    /// try await db.insert(into: "users")
    ///     .columns("id", "email", "name")
    ///     .values(1, "alice@example.com", "Alice")
    ///     .psql_onConflict(withConstraint: .identifier("uq_users_email") { $0
    ///         .set(excludedValueOf: "name")
    ///     }
    ///     .run()
    /// // INSERT INTO "users" ("id","email","name") VALUES ($1,$2,$3)
    /// // ON CONFLICT ON CONSTRAINT "uq_users_email" DO UPDATE SET "name" = EXCLUDED."name"
    /// ```
    @discardableResult
    public func psql_onConflict(
        withConstraint constraint: any SQLExpression, 
        `do` updatePredicate: (SQLConflictUpdateBuilder) throws -> SQLConflictUpdateBuilder
    ) rethrows -> Self {
        let conflictBuilder = SQLConflictUpdateBuilder()
        _ = try updatePredicate(conflictBuilder)
        self.insert.genericConflictStrategy = PostgreSQLConflictResolutionStrategy(
            constraint: constraint, action: .update(assignments: conflictBuilder.values, predicate: conflictBuilder.predicate)
        )
        return self
    }
}
#endif
