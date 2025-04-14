#if FluentSQLKitExtras
import FluentKit
import SQLKit

extension SQLDropTriggerBuilder {
    /// Allow specifying the target table for a `DROP TRIGGER` query using a Fluent model.
    @discardableResult
    public func table(_ type: (some Schema).Type) -> Self {
        self.table(type.sqlTable)
    }
}
#endif
