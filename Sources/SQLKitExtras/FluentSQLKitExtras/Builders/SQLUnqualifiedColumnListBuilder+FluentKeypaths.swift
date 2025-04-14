#if FluentSQLKitExtras
import FluentKit
import SQLKit

extension SQLUnqualifiedColumnListBuilder {
    /// Despite the name of the builder protocol, this method specifies a _fully qualified_ column using a Fluent model
    /// keypath. To specify an _unqualified_ column with a keypath, consider using
    /// `SQLUnqualifiedColumnListBuilder.column(.identifier(\Model.$property))`.
    @discardableResult
    public func column(
        _ keypath: KeyPath<some Schema, some QueryAddressableProperty>
    ) -> Self {
        self.column(.column(keypath))
    }

    /// Despite the name of the builder protocol, this method specifies a variable number of _fully qualified_ columns
    /// using Fluent model keypaths. To specify _unqualified_ columns with keypaths, consider using
    /// `SQLUnqualifiedColumnListBuilder.column(.identifier(\Model.$property))`.
    @discardableResult
    public func columns<each S: Schema, each P: QueryAddressableProperty>(
        _ keypaths: repeat KeyPath<each S, each P>
    ) -> Self {
        repeat _ = self.column(each keypaths)
        return self
    }
}
#endif
