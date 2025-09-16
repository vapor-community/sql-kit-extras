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

    /// Despite the name of the builder protocol, this method specifies a variable number of _fully qualified_ columns
    /// using Fluent model keypaths. To specify _unqualified_ columns with keypaths, consider using
    /// `SQLUnqualifiedColumnListBuilder.column(.identifier(\Model.$property))`. This is identical to
    /// ``columns<each Schema, each QueryAddressableProperty>(_: repeat...)``, except that on that method, each KeyPath
    /// can refer to a different Schema,forcing the caller to specify the root type on all of them. However, it is a very
    /// common use case to specify many keypaths from the same model in a row, e.g.,
    /// `.columns(\MyModel.$foo, \MyModel.$bar, \MyModel.$baz, \MyModel.$bam)`. This quickly becomes quite tedious. By
    /// contrast, this method accepts only a single `Schema` type, and all KeyPaths are assumed to refer to it, allowing
    /// the previous example to be written as `.columns(of: MyModel.self, \.$bar, \.$baz, \.$bam)`.
    @discardableResult
    public func columns<S: Schema, each P: QueryAddressableProperty>(
        of: S.Type, _ keypaths: repeat KeyPath<S, each P>
    ) -> Self {
        repeat _ = self.column(each keypaths)
        return self
    }
}
#endif
