#if FluentSQLKitExtras
import FluentKit
import SQLKit

extension SQLExpression {
    /// Allow using `.identifier(_:)` with Fluent model keypaths. See `Fields.sqlIdentifier(for:)`.
    public static func identifier<M: Fields>(
        _ keypath: KeyPath<M, some QueryAddressableProperty>
    ) -> Self where Self == SQLIdentifier {
        M.sqlIdentifier(for: keypath)
    }
}
#endif
