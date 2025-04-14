#if FluentSQLKitExtras
import FluentKit
import SQLKit

extension SQLExpression {
    /// Allow specifying a binary expression using two Fluent model keypaths, which may optionally refer
    /// to different models.
    public static func expr(
        _ kp1: KeyPath<some Schema, some QueryAddressableProperty>,
        _ op: SQLBinaryOperator,
        _ kp2: KeyPath<some Schema, some QueryAddressableProperty>
    ) -> Self where Self == SQLBinaryExpression {
        .expr(kp1, op, .column(kp2))
    }

    /// Allow specifying a binary expression using a Fluent model keypath as the left-hand operand.
    public static func expr(
        _ keypath: KeyPath<some Schema, some QueryAddressableProperty>,
        _ op: SQLBinaryOperator,
        _ rhs: some SQLExpression
    ) -> Self where Self == SQLBinaryExpression {
        .expr(.column(keypath), op, rhs)
    }
}
#endif
