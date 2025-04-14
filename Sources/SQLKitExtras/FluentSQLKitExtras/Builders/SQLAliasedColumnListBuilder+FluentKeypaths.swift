#if FluentSQLKitExtras
import FluentKit
import SQLKit

extension SQLAliasedColumnListBuilder {
    /// Allow specifying a fully qualified column with an aliased name using a Fluent model keypath.
    @discardableResult
    public func column(
        _ keypath: KeyPath<some Schema, some QueryAddressableProperty>,
        as alias: some StringProtocol
    ) -> Self {
        self.column(.column(keypath), as: String(alias))
    }
}
#endif
