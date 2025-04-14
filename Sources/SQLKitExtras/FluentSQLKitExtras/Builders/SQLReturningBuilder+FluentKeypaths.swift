#if FluentSQLKitExtras
import FluentKit
import SQLKit

extension SQLReturningBuilder {
    /// Allow specifying columns in a `RETURNING` clause using Fluent model keypaths.
    @discardableResult
    public func returning<each S: Schema, each P: QueryAddressableProperty>(
        _ keypaths: repeat KeyPath<each S, each P>
    ) -> SQLReturningResultBuilder<Self> {
        var columns: [any SQLExpression] = []

        repeat columns.append(.column(each keypaths))
        return self.returning(columns)
    }
}
#endif
