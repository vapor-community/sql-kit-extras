#if FluentSQLKitExtras
public import FluentKit
public import SQLKit

extension SQLDatabase {
    /// Allow specifying a table for a `DROP TABLE` query using a Fluent model.
    public func drop(table model: (some Schema).Type) -> SQLDropTableBuilder {
        self.drop(table: model.sqlTable)
    }
}
#endif
