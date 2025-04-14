#if FluentSQLKitExtras
import FluentKit
import SQLKit

extension SQLExpression {
    /// Allow specifying an alias using a Fluent model keypath.
    public static func alias(
        _ keypath: KeyPath<some Schema, some QueryAddressableProperty>,
        as alias: some StringProtocol
    ) -> Self where Self == SQLAlias {
        .alias(.column(keypath), as: alias)
    }

    /// Allow specifying an alias using a Fluent model keypath.
    public static func alias(
        _ keypath: KeyPath<some Schema, some QueryAddressableProperty>,
        as alias: some SQLExpression
    ) -> Self where Self == SQLAlias {
        .alias(.column(keypath), as: alias)
    }
}
#endif
