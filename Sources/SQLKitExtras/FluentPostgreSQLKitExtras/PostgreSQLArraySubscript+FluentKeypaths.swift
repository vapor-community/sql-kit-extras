#if FluentSQLKitExtras && PostgreSQLKitExtras
import FluentKit
import SQLKit

extension SQLExpression {
    /// Convenience method for creating a ``PostgreSQLArraySubscript`` using Fluent keypaths for the array value
    /// and the subscript.
    public static func psql_subscript(
        _ colKeypath: KeyPath<some Schema, some QueryAddressableProperty>,
        at subKeypath: KeyPath<some Schema, some QueryAddressableProperty>
    ) -> Self where Self == PostgreSQLArraySubscript {
        .psql_subscript(.column(colKeypath), at: .column(subKeypath))
    }

    /// Convenience method for creating a ``PostgreSQLArraySubscript`` using a Fluent keypath for the array value
    /// and an expression for the subscript.
    public static func psql_subscript(
        _ colKeypath: KeyPath<some Schema, some QueryAddressableProperty>,
        at `subscript`: some SQLExpression
    ) -> Self where Self == PostgreSQLArraySubscript {
        .psql_subscript(.column(colKeypath), at: `subscript`)
    }

    /// Convenience method for creating a ``PostgreSQLArraySubscript`` using an expression for the array value and
    /// a Fluent keypath for the subscript.
    public static func psql_subscript(
        _ column: some SQLExpression,
        at subKeypath: KeyPath<some Schema, some QueryAddressableProperty>
    ) -> Self where Self == PostgreSQLArraySubscript {
        .psql_subscript(column, at: .column(subKeypath))
    }
}
#endif
