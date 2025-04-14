#if FluentSQLKitExtras
import FluentKit
import SQLKit

extension SQLDropIndexBuilder {
    /// Allow specifying the target table for a `DROP INDEX` query using a Fluent model.
    @discardableResult
    public func on(_ type: (some Schema).Type) -> Self {
        self.on(type.sqlTable)
    }
}
#endif
