#if FluentSQLKitExtras
import FluentKit
import SQLKit

extension SQLQueryString {
    /// Allow specifying a Fluent keypath as an identifier interpolation in an `SQLQueryString`.
    @inlinable
    public mutating func appendInterpolation(ident: KeyPath<some Schema, some QueryAddressableProperty>) {
        self.appendInterpolation(.identifier(ident))
    }

    /// Allow specifying a Fluent keypath as an column interpolation in an `SQLQueryString`.
    @inlinable
    public mutating func appendInterpolation(col: KeyPath<some Schema, some QueryAddressableProperty>) {
        self.appendInterpolation(.column(col))
    }
}
#endif

