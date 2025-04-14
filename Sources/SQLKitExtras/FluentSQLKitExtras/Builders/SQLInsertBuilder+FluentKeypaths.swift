#if FluentSQLKitExtras
import FluentKit
import SQLKit

/// > Note: `SQLInsertBuilder` is not an `SQLUnqualifiedColumnListBuilder`, although it should be. See `SQLInsertBuilder`'s
/// > documentation for details.
extension SQLInsertBuilder {
    /// Allow specifying a set of unqualified column names for an insert builder using Fluent model keypaths. As with
    /// all other `.columns()` methods of `SQLInsertBuilder`, this method _replaces_ all existing columns.
    @discardableResult
    public func columns<each S: Schema, each P: QueryAddressableProperty>(
        _ keypaths: repeat KeyPath<each S, each P>
    ) -> Self {
        // N.B.: Due to the nature of parameter packs, we must manage the builder's `SQLInsert` expression directly.
        self.insert.columns = []
        for keypath in repeat each keypaths {
          self.insert.columns.append(.identifier(keypath))
        }
        return self
    }
}

extension SQLDatabase {
    /// Allow specifying a table for an `INSERT` query using a Fluent model.
    public func insert(into model: (some Schema).Type) -> SQLInsertBuilder {
        self.insert(into: model.sqlTable)
    }
}
#endif
