#if FluentSQLKitExtras
public import FluentKit
public import SQLKit

extension SQLExpression {
    /// Allow using `.identifier(_:)` with Fluent model keypaths. See `Fields.sqlIdentifier(for:)`.
    public static func identifier<M: Fields>(
        _ keypath: KeyPath<M, some QueryAddressableProperty>
    ) -> Self where Self == SQLIdentifier {
        M.sqlIdentifier(for: keypath)
    }
}
#endif
