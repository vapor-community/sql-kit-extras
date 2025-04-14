#if FluentSQLKitExtras
import FluentKit
import SQLKit

extension SQLPartialResultBuilder {
    /// Allow specifying a sorting column using a Fluent model keypath. See `Schema.sqlColumn(for:)`.
    @discardableResult
    public func orderBy(
        _ keypath: KeyPath<some Schema, some QueryAddressableProperty>,
        _ direction: SQLDirection = .ascending
    ) -> Self {
        self.orderBy(.column(keypath), direction)
    }
}
#endif
