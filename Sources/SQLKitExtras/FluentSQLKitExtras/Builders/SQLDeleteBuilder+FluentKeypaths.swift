#if FluentSQLKitExtras
import FluentKit
import SQLKit

extension SQLDatabase {
    /// Allow specifying a table for a `DELETE` query using a Fluent model.
    public func delete(from model: (some Schema).Type) -> SQLDeleteBuilder {
        self.delete(from: model.sqlTable)
    }
}
#endif
