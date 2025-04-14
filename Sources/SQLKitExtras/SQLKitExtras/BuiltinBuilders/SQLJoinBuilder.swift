import SQLKit

extension SQLJoinBuilder {
    /// Allow specifying aliases for joined tables directly in the join method.
    @discardableResult
    public func join(
        _ table: some StringProtocol, as alias: some StringProtocol,
        method: SQLJoinMethod = .inner,
        on expression: some SQLExpression
    ) -> Self {
         self.join(.alias(table, as: alias), method: method, on: expression)
    }

    /// Allow specifying aliases for joined tables directly in the join method.
    @discardableResult
    public func join(
        _ table: some SQLExpression, as alias: some StringProtocol,
        method: SQLJoinMethod = .inner,
        on expression: some SQLExpression
    ) -> Self {
        self.join(.alias(table, as: alias), method: method, on: expression)
    }

    /// Allow specifying aliases for joined tables directly in the join method.
    @discardableResult
    public func join(
        _ table: some StringProtocol, as alias: some StringProtocol,
        method: SQLJoinMethod = .inner,
        on lhs: some SQLExpression, _ op: SQLBinaryOperator, _ rhs: some SQLExpression
    ) -> Self {
        self.join(.alias(table, as: alias), method: method, on: lhs, op, rhs)
    }

    /// Allow specifying aliases for joined tables directly in the join method.
    @discardableResult
    public func join(
        _ table: some SQLExpression, as alias: some StringProtocol,
        method: SQLJoinMethod = .inner,
        on lhs: some SQLExpression, _ op: SQLBinaryOperator, _ rhs: some SQLExpression
    ) -> Self {
        self.join(.alias(table, as: alias), method: method, on: lhs, op, rhs)
    }

    /// Allow specifying aliases for joined tables directly in the join method.
    @discardableResult
    public func join<each E: SQLExpression>(
        _ table: some SQLExpression, as alias: some StringProtocol,
        method: SQLJoinMethod = .inner,
        using cols: repeat each E
    ) -> Self {
        var columns: [any SQLExpression] = []
        for col in repeat each cols {
            columns.append(col)
        }
        return self.join(table, as: alias, method: method, using: columns)
    }

    /// Allow specifying aliases for joined tables directly in the join method.
    @discardableResult
    public func join(
        _ table: some SQLExpression, as alias: some StringProtocol,
        method: SQLJoinMethod = .inner,
        using columns: some Sequence<any SQLExpression>
    ) -> Self {
        self.join(.alias(table, as: alias), method: method, using: .list(columns))
    }
}
