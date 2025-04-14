#if FluentSQLKitExtras
import FluentKit
import SQLKit

extension SQLCreateIndexBuilder {
    /// Allow specifying the target table for a `CREATE INDEX` query using a Fluent model.
    @discardableResult
    public func on(_ type: (some Schema).Type) -> Self {
        self.on(type.sqlTable)
    }
}
#endif
