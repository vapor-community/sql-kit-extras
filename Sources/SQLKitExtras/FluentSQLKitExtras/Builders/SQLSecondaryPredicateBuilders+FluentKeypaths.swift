#if FluentSQLKitExtras
import FluentKit
import SQLKit

extension SQLSecondaryPredicateBuilder {
    /// Allow specifying a conjunctive `HAVING` condition using a Fluent model keypath as the left-hand operand.
    @discardableResult
    public func having(
        _ keypath: KeyPath<some Schema, some QueryAddressableProperty>,
        _ op: SQLBinaryOperator,
        _ rhs: some Encodable & Sendable
    ) -> Self {
        self.having(keypath, op, .bind(rhs))
    }

    /// Allow specifying a conjunctive `HAVING` condition using two Fluent model keypaths, which may optionally refer
    /// to different models, as the operands.
    @discardableResult
    public func having(
        _ keypath1: KeyPath<some Schema, some QueryAddressableProperty>,
        _ op: SQLBinaryOperator,
        _ keypath2: KeyPath<some Schema, some QueryAddressableProperty>
    ) -> Self {
        self.having(keypath1, op, .column(keypath2))
    }

    /// Allow specifying a conjunctive `HAVING` condition using a Fluent model keypath as the left-hand operand.
    @discardableResult
    public func having(
        _ keypath: KeyPath<some Schema, some QueryAddressableProperty>,
        _ op: SQLBinaryOperator,
        _ rhs: some SQLExpression
    ) -> Self {
        self.having(.column(keypath), op, rhs)
    }

    /// Allow specifying a conjunctive `HAVING` condition using a Fluent model keypath as the left-hand operand.
    /// This overload allows more convenient use of custom operators like `ILIKE`.
    @discardableResult
    public func having(
        _ keypath: KeyPath<some Schema, some QueryAddressableProperty>,
        _ op: some SQLExpression,
        _ rhs: some SQLExpression
    ) -> Self {
        self.having(.column(keypath), op, rhs)
    }

    /// Allow specifying a conjunctive `HAVING` condition using a Fluent model keypath having a boolean value as the
    /// sole operand. This overload allows more convenient boolean testing.
    @discardableResult
    public func having<Prop: QueryAddressableProperty>(
        _ keypath: KeyPath<some Schema, Prop>
    ) -> Self where Prop.Value == Bool {
        self.having(.column(keypath))
    }

    /// Allow specifying an inclusively disjunctive `HAVING` condition using a Fluent model keypath as the
    /// left-hand operand.
    @discardableResult
    public func orHaving(
        _ keypath: KeyPath<some Schema, some QueryAddressableProperty>,
        _ op: SQLBinaryOperator,
        _ rhs: some Encodable & Sendable
    ) -> Self {
        self.orHaving(keypath, op, .bind(rhs))
    }

    /// Allow specifying an inclusively disjunctive `HAVING` condition using two Fluent model keypaths, which may
    /// optionally refer to different models, as the operands.
    @discardableResult
    public func orHaving(
        _ keypath1: KeyPath<some Schema, some QueryAddressableProperty>,
        _ op: SQLBinaryOperator,
        _ keypath2: KeyPath<some Schema, some QueryAddressableProperty>
    ) -> Self {
        self.orHaving(keypath1, op, .column(keypath2))
    }

    /// Allow specifying an inclusively disjunctive `HAVING` condition using a Fluent model keypath as the
    /// left-hand operand.
    @discardableResult
    public func orHaving(
        _ keypath: KeyPath<some Schema, some QueryAddressableProperty>,
        _ op: SQLBinaryOperator,
        _ rhs: some SQLExpression
    ) -> Self {
        self.orHaving(.column(keypath), op, rhs)
    }

    /// Allow specifying an inclusively disjunctive `HAVING` condition using a Fluent model keypath as the
    /// left-hand operand. This overload allows more convenient use of custom operators like `ILIKE`.
    @discardableResult
    public func orHaving(
        _ keypath: KeyPath<some Schema, some QueryAddressableProperty>,
        _ op: some SQLExpression,
        _ rhs: some SQLExpression
    ) -> Self {
        self.orHaving(.column(keypath), op, rhs)
    }

    /// Allow specifying an inclusively disjunctive `HAVING` condition using a Fluent model keypath having a boolean
    /// value as the sole operand. This overload allows more convenient boolean testing.
    @discardableResult
    public func orHaving<Prop: QueryAddressableProperty>(
        _ keypath: KeyPath<some Schema, Prop>
    ) -> Self where Prop.Value == Bool {
        self.orHaving(.column(keypath))
    }
}
#endif
