import protocol SQLKit.SQLDatabase
import protocol FluentKit.Database
import protocol FluentKit.AsyncMigration

/// A variant of `AsyncMigration` designed to simplify using SQLKit to write migrations.
///
/// > Warning: Use of ``AsyncSQLMigration`` will cause runtime errors if the migration is added to a Fluent
/// > database which is not compatible with SQLKit (such as MongoDB).
public protocol AsyncSQLMigration: AsyncMigration {
    /// Perform the desired migration.
    ///
    /// - Parameter database: The database to migrate.
    func prepare(on database: any SQLDatabase) async throws
    
    /// Reverse, if possible, the migration performed by `prepare(on:)`.
    ///
    /// It is not uncommon for a given migration to be lossy if run in reverse, or to be irreversible in the
    /// entire. While it is recommended that such a migration throw an error (thus stopping any further progression
    /// of the revert operation), there is no requirement that it do so. In practice, most irreversible migrations
    /// choose to simply do nothing at all in this method. Implementors should carefully consider the consequences
    /// of progressively older migrations attempting to revert themselves afterwards before leaving this method blank.
    ///
    /// - Parameter database: The database to revert.
    func revert(on database: any SQLDatabase) async throws
}

extension AsyncSQLMigration {
    // See `AsyncMigration.prepare(on:)`.
    public func prepare(on database: any Database) async throws {
        try await self.prepare(on: database as! any SQLDatabase)
    }

    // See `AsyncMigration.revert(on:)`.
    public func revert(on database: any Database) async throws {
        try await self.revert(on: database as! any SQLDatabase)
    }
}
