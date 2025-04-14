#if FluentSQLKitExtras
import FluentKit
import SQLKit

extension SQLDatabase {
    /// Allow specifying a table for a `CREATE TRIGGER` query using a Fluent model.
    public func create(
        trigger: String,
        table: (some Schema).Type,
        when: SQLCreateTrigger.WhenSpecifier,
        event: SQLCreateTrigger.EventSpecifier
    ) -> SQLCreateTriggerBuilder {
        self.create(trigger: .identifier(trigger), table: table.sqlTable, when: when, event: event)
    }

    /// Allow specifying a table for a `CREATE TRIGGER` query using a Fluent model.
    public func create(
        trigger: any SQLExpression,
        table: (some Schema).Type,
        when: any SQLExpression,
        event: any SQLExpression
    ) -> SQLCreateTriggerBuilder {
        self.create(trigger: trigger, table: table.sqlTable, when: when, event: event)
    }
}
#endif
