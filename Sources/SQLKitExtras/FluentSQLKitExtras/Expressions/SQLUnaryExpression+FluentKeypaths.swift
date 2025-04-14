#if FluentSQLKitExtras
import FluentKit
import SQLKit

extension SQLExpression {
    /// Allow specifying a unary expression using a Fluent model keypath.
    public static func expr(
        _ op: SQLUnaryOperator,
        _ kp: KeyPath<some Schema, some QueryAddressableProperty>
    ) -> Self where Self == SQLUnaryExpression {
        .expr(op, .column(kp))
    }

    /// Allow specifying a unary inversion expression using a Fluent model keypath.
    public static func not(
        _ kp: KeyPath<some Schema, some QueryAddressableProperty>
    ) -> Self where Self == SQLUnaryExpression {
        .not(.column(kp))
    }
}
#endif
