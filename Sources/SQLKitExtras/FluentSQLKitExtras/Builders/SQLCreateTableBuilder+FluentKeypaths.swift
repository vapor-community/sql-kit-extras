#if FluentSQLKitExtras
import FluentKit
import SQLKit

extension SQLDatabase {
    /// Allow specifying a table for a `CREATE TABLE` query using a Fluent model.
    public func create(table model: (some Schema).Type) -> SQLCreateTableBuilder {
        self.create(table: model.sqlTable)
    }
}
#endif
