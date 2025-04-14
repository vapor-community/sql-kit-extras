#if FluentSQLKitExtras
import FluentKit
import SQLKit

extension SQLJoinBuilder {
    /// Allow specifying a table for a `JOIN` clause using a Fluent model and the join condition using two Fluent model
    /// keypaths, which may optionally refer to different models, as the operands. The same caveats which apply to
    /// `SQLSubqueryClauseBuilder.from(_:as:)` apply to this method.
    @discardableResult
    public func join(
        _ type: (some Schema).Type, as alias: (some StringProtocol)? = String?.none,
        method: SQLJoinMethod = .inner,
        on lhs: KeyPath<some Schema, some QueryAddressableProperty>, _ op: SQLBinaryOperator, _ rhs: KeyPath<some Schema, some QueryAddressableProperty>
    ) -> Self {
        self.join(type, as: alias, method: method, on: lhs, op, .column(rhs))
    }

    /// Allow specifying a table for a `JOIN` clause using a Fluent model and the join condition using a Fluent model
    /// keypath as the left-hand operand. The same caveats which apply to  `SQLSubqueryClauseBuilder.from(_:as:)` apply
    /// to this method.
    @discardableResult
    public func join(
        _ type: (some Schema).Type, as alias: (some StringProtocol)? = String?.none,
        method: SQLJoinMethod = .inner,
        on lhs: KeyPath<some Schema, some QueryAddressableProperty>, _ op: SQLBinaryOperator, _ rhs: some SQLExpression
    ) -> Self {
        self.join(type, as: alias, method: method, on: .column(lhs), op, rhs)
    }

    /// Allow specifying a table for a `JOIN` clause using a Fluent model. The same caveats which apply to
    /// `SQLSubqueryClauseBuilder.from(_:as:)` apply to this method.
    @discardableResult
    public func join(
        _ type: (some Schema).Type, as alias: (some StringProtocol)? = String?.none,
        method: SQLJoinMethod = .inner,
        on left: some SQLExpression, _ op: SQLBinaryOperator, _ right: some SQLExpression
    ) -> Self {
        self.join(type, as: alias, method: method, on: .expr(left, op, right))
    }

    /// Allow specifying a table for a `JOIN` clause using a Fluent model. The same caveats which apply to
    /// `SQLSubqueryClauseBuilder.from(_:as:)` apply to this method.
    @discardableResult
    public func join(
        _ type: (some Schema).Type, as alias: (some StringProtocol)? = String?.none,
        method: SQLJoinMethod = .inner,
        on expression: some SQLExpression
    ) -> Self {
        if let alias = alias.map(String.init(_:)) ?? type.alias {
            self.join(.table(type.schema, space: type.space), as: alias, method: method, on: expression)
        } else {
            self.join(.table(type.schema, space: type.space), method: method, on: expression)
        }
    }

    /// Allow specifying a table for a `JOIN` clause using a Fluent model. The same caveats which apply to
    /// `SQLSubqueryClauseBuilder.from(_:as:)` apply to this method.
    @discardableResult
    public func join<each E: SQLExpression>(
        _ type: (some Schema).Type, as alias: (some StringProtocol)? = String?.none,
        method: SQLJoinMethod = .inner,
        using columns: repeat each E
    ) -> Self {
        var cols: [any SQLExpression] = []
        for col in repeat each columns {
            cols.append(col)
        }
        return self.join(type, as: alias, method: method, using: cols)
    }

    /// Allow specifying a table for a `JOIN` clause using a Fluent model. The same caveats which apply to
    /// `SQLSubqueryClauseBuilder.from(_:as:)` apply to this method.
    @discardableResult
    public func join(
        _ type: (some Schema).Type, as alias: (some StringProtocol)? = String?.none,
        method: SQLJoinMethod = .inner,
        using columns: some Sequence<any SQLExpression>
    ) -> Self {
        if let alias = alias.map(String.init(_:)) ?? type.alias {
            self.join(.table(type.schema, space: type.space), as: alias, method: method, using: columns)
        } else {
            self.join(.table(type.schema, space: type.space), method: method, using: .list(columns))
        }
    }
}
#endif
