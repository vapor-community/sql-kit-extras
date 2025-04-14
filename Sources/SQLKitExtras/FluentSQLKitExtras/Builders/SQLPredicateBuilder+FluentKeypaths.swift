#if FluentSQLKitExtras
import FluentKit
import SQLKit

extension SQLPredicateBuilder {
    /// Allow specifying a conjunctive `WHERE` condition using a Fluent model keypath as the left-hand operand.
    @discardableResult
    public func `where`(
        _ keypath: KeyPath<some Schema, some QueryAddressableProperty>,
        _ op: SQLBinaryOperator,
        _ rhs: some Encodable & Sendable
    ) -> Self {
        self.where(keypath, op, .bind(rhs))
    }

    /// Allow specifying a conjunctive `WHERE` condition using two Fluent model keypaths, which may optionally refer
    /// to different models, as the operands.
    @discardableResult
    public func `where`(
        _ keypath1: KeyPath<some Schema, some QueryAddressableProperty>,
        _ op: SQLBinaryOperator,
        _ keypath2: KeyPath<some Schema, some QueryAddressableProperty>
    ) -> Self {
        self.where(keypath1, op, .column(keypath2))
    }

    /// Allow specifying a conjunctive `WHERE` condition using a Fluent model keypath as the left-hand operand.
    @discardableResult
    public func `where`(
        _ keypath: KeyPath<some Schema, some QueryAddressableProperty>,
        _ op: SQLBinaryOperator,
        _ rhs: some SQLExpression
    ) -> Self {
        self.where(.column(keypath), op, rhs)
    }

    /// Allow specifying a conjunctive `WHERE` condition using a Fluent model keypath as the left-hand operand.
    /// This overload allows more convenient use of custom operators like `ILIKE`.
    @discardableResult
    public func `where`(
        _ keypath: KeyPath<some Schema, some QueryAddressableProperty>,
        _ op: some SQLExpression,
        _ rhs: some SQLExpression
    ) -> Self {
        self.where(.column(keypath), op, rhs)
    }

    /// Allow specifying a conjunctive `WHERE` condition using a Fluent model keypath having a boolean value as the
    /// sole operand. This overload allows more convenient boolean testing.
    @discardableResult
    public func `where`<Prop: QueryAddressableProperty>(
        _ keypath: KeyPath<some Schema, Prop>
    ) -> Self where Prop.Value == Bool {
        self.where(.column(keypath))
    }

    /// Allow specifying an inclusively disjunctive `WHERE` condition using a Fluent model keypath as the
    /// left-hand operand.
    @discardableResult
    public func orWhere(
        _ keypath: KeyPath<some Schema, some QueryAddressableProperty>,
        _ op: SQLBinaryOperator,
        _ rhs: some Encodable & Sendable
    ) -> Self {
        self.orWhere(keypath, op, .bind(rhs))
    }

    /// Allow specifying an inclusively disjunctive `WHERE` condition using two Fluent model keypaths, which may
    /// optionally refer to different models, as the operands.
    @discardableResult
    public func orWhere(
        _ keypath1: KeyPath<some Schema, some QueryAddressableProperty>,
        _ op: SQLBinaryOperator,
        _ keypath2: KeyPath<some Schema, some QueryAddressableProperty>
    ) -> Self {
        self.orWhere(keypath1, op, .column(keypath2))
    }

    /// Allow specifying an inclusively disjunctive `WHERE` condition using a Fluent model keypath as the
    /// left-hand operand.
    @discardableResult
    public func orWhere(
        _ keypath: KeyPath<some Schema, some QueryAddressableProperty>,
        _ op: SQLBinaryOperator,
        _ rhs: some SQLExpression
    ) -> Self {
        self.orWhere(.column(keypath), op, rhs)
    }

    /// Allow specifying an inclusively disjunctive `WHERE` condition using a Fluent model keypath as the
    /// left-hand operand. This overload allows more convenient use of custom operators like `ILIKE`.
    @discardableResult
    public func orWhere(
        _ keypath: KeyPath<some Schema, some QueryAddressableProperty>,
        _ op: some SQLExpression,
        _ rhs: some SQLExpression
    ) -> Self {
        self.orWhere(.column(keypath), op, rhs)
    }

    /// Allow specifying an inclusively disjunctive `WHERE` condition using a Fluent model keypath having a boolean
    /// value as the sole operand. This overload allows more convenient boolean testing.
    @discardableResult
    public func orWhere<Prop: QueryAddressableProperty>(
        _ keypath: KeyPath<some Schema, Prop>
    ) -> Self where Prop.Value == Bool {
        self.orWhere(.column(keypath))
    }
}
#endif
