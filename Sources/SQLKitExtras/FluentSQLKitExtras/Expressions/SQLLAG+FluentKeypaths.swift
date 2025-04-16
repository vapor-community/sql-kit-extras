#if FluentSQLKitExtras
import FluentKit
import SQLKit

extension SQLExpression {
    /// Allow specifying an argument to the `lag()` SQL function using a Fluent model keypath.
    public static func lag(
        _ keypath: KeyPath<some Schema, some QueryAddressableProperty>,
        offset: KeyPath<some Schema, some QueryAddressableProperty>,
        defaultValue: (some SQLExpression)? = SQLRaw?.none
    ) -> Self where Self == SQLLAGExpression {
        .lag(.column(keypath), offset: .column(offset), defaultValue: defaultValue)
    }

    /// Allow specifying an argument to the `lag()` SQL function using a Fluent model keypath.
    public static func lag(
        _ keypath: some SQLExpression,
        offset: KeyPath<some Schema, some QueryAddressableProperty>,
        defaultValue: (some SQLExpression)? = SQLRaw?.none
    ) -> Self where Self == SQLLAGExpression {
        .lag(.column(keypath), offset: .column(offset), defaultValue: defaultValue)
    }

    /// Allow specifying an argument to the `lag()` SQL function using a Fluent model keypath.
    public static func lag(
        _ keypath: KeyPath<some Schema, some QueryAddressableProperty>,
        offset: some SQLExpression,
        defaultValue: (some SQLExpression)? = SQLRaw?.none
    ) -> Self where Self == SQLLAGExpression {
        .lag(.column(keypath), offset: offset, defaultValue: defaultValue)
    }
}
#endif
