#if FluentSQLKitExtras
import FluentKit
import SQLKit

extension SQLConflictUpdateBuilder {
    /// Allow specifying a column to use the excluded value of on conflict using a Fluent model keypath.
    @discardableResult
    public func set(excludedValueOf keypath: KeyPath<some Fields, some QueryAddressableProperty>) -> Self {
        self.set(excludedValueOf: .identifier(keypath))
    }
}
#endif
