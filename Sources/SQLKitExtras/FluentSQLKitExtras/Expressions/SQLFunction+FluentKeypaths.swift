#if FluentSQLKitExtras
import FluentKit
import SQLKit

extension SQLExpression {
    /// Allow specifying an argument to the `length()` SQL function using a Fluent model keypath.
    public static func length(
        _ keypath: KeyPath<some Schema, some QueryAddressableProperty>
    ) -> Self where Self == SQLFunction {
        .length(.column(keypath))
    }

    /// Allow specifying an argument to the `count()` SQL function using a Fluent model keypath.
    public static func count(
        _ keypath: KeyPath<some Schema, some QueryAddressableProperty>,
        distinct: Bool = false
    ) -> Self where Self == SQLFunction {
        .count(.column(keypath), distinct: distinct)
    }

    /// Allow specifying an argument to the `sum()` SQL function using a Fluent model keypath.
    public static func sum(
        _ keypath: KeyPath<some Schema, some QueryAddressableProperty>,
        distinct: Bool = false
    ) -> Self where Self == SQLFunction {
        .sum(.column(keypath), distinct: distinct)
    }
}
#endif
