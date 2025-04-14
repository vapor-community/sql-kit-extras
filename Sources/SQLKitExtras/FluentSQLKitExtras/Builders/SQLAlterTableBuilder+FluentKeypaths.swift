#if FluentSQLKitExtras
import FluentKit
import SQLKit

extension SQLDatabase {
    /// Allow specifying a table for an `ALTER TABLE` query using a Fluent model.
    public func alter(table model: (some Schema).Type) -> SQLAlterTableBuilder {
        self.alter(table: model.sqlTable)
    }
}
#endif
