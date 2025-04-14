#if FluentSQLKitExtras
import FluentKit
import SQLKit

extension SQLColumnUpdateBuilder {
    /// Allow specifying a column to update using a Fluent model keypath.
    @discardableResult
    public func set(
        _ keypath: KeyPath<some Fields, some QueryAddressableProperty>,
        to bind: some Encodable & Sendable
    ) -> Self {
        self.set(.identifier(keypath), to: bind)
    }

    /// Allow specifying a column to update using a Fluent model keypath.
    @discardableResult
    public func set(
        _ keypath: KeyPath<some Fields, some QueryAddressableProperty>,
        to value: some SQLExpression
    ) -> Self {
        self.set(.identifier(keypath), to: value)
    }
}
#endif
