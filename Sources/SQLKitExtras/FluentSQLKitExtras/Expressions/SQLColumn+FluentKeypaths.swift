#if FluentSQLKitExtras
import FluentKit
import SQLKit

extension SQLExpression {
    /// Allow using `.column(_:)` with Fluent model keypaths. See `Schema.sqlColumn(for:)`.
    public static func column<M: Schema>(
        _ keypath: KeyPath<M, some QueryAddressableProperty>
    ) -> Self where Self == SQLColumn {
        M.sqlColumn(for: keypath)
    }
}
#endif
