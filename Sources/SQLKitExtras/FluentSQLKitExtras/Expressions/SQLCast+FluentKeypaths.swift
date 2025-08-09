#if FluentSQLKitExtras
import FluentKit
import SQLKit

extension SQLExpression {
    /// Convenience method for creating a ``SQLCastExpression`` expression using a Fluent keypath for the value and a string
    /// for the desired type.
    public static func cast(
        _ column: KeyPath<some Schema, some QueryAddressableProperty>,
        to type: String
    ) -> Self where Self == SQLCastExpression {
        .cast(.column(column), to: type)
    }
}
#endif
