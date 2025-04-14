#if FluentSQLKitExtras
import FluentKit
import SQLKit

extension SQLDatabase {
    /// Allow specifying a table for an `UPDATE` query using a Fluent model.
    public func update(_ model: (some Schema).Type) -> SQLUpdateBuilder {
        self.update(model.sqlTable)
    }
}
#endif
