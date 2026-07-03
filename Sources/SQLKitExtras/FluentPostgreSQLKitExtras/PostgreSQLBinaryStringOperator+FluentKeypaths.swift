#if FluentSQLKitExtras && PostgreSQLKitExtras
public import FluentKit
public import SQLKit

extension SQLExpression {
    /// Allow specifying a binary expression using two Fluent model keypaths, which may optionally refer
    /// to different models,  and a ``PostgreSQLBinaryStringOperator``.
    public static func expr(
        _ kp1: KeyPath<some Schema, some QueryAddressableProperty>,
        _ op: PostgreSQLBinaryStringOperator,
        _ kp2: KeyPath<some Schema, some QueryAddressableProperty>
    ) -> Self where Self == SQLBinaryExpression {
        .init(left: .column(kp1), op: op, right: .column(kp2))
    }

    /// Allow specifying a binary expression using a Fluent model keypath as the left-hand operand, an encodable
    /// value as the right-hand operand, and a ``PostgreSQLBinaryStringOperator`` as the operator.
    public static func expr(
        _ keypath: KeyPath<some Schema, some QueryAddressableProperty>,
        _ op: PostgreSQLBinaryStringOperator,
        _ rhs: some Encodable & Sendable
    ) -> Self where Self == SQLBinaryExpression {
        .expr(.column(keypath), op, rhs)
    }
}

extension SQLPredicateBuilder {
    /// Allow specifying a conjunctive `WHERE` condition using a Fluent model keypath as the left-hand operand and
    /// a ``PostgreSQLBinaryStringOperator`` as the operator.
    @discardableResult
    public func `where`(
        _ keypath: KeyPath<some Schema, some QueryAddressableProperty>,
        _ op: PostgreSQLBinaryStringOperator,
        _ rhs: some Encodable & Sendable
    ) -> Self {
        self.where(keypath, op, .bind(rhs))
    }

    /// Allow specifying a conjunctive `WHERE` condition using two Fluent model keypaths, which may optionally refer
    /// to different models, as the operands and a ``PostgreSQLBinaryStringOperator`` as the operator.
    @discardableResult
    public func `where`(
        _ keypath1: KeyPath<some Schema, some QueryAddressableProperty>,
        _ op: PostgreSQLBinaryStringOperator,
        _ keypath2: KeyPath<some Schema, some QueryAddressableProperty>
    ) -> Self {
        self.where(keypath1, op, .column(keypath2))
    }

    /// Allow specifying an inclusively disjunctive `WHERE` condition using a Fluent model keypath as the
    /// left-hand operand and a ``PostgreSQLBinaryStringOperator`` as the operator.
    @discardableResult
    public func orWhere(
        _ keypath: KeyPath<some Schema, some QueryAddressableProperty>,
        _ op: PostgreSQLBinaryStringOperator,
        _ rhs: some Encodable & Sendable
    ) -> Self {
        self.orWhere(keypath, op, .bind(rhs))
    }

    /// Allow specifying an inclusively disjunctive `WHERE` condition using two Fluent model keypaths, which may
    /// optionally refer to different models, as the operands and a ``PostgreSQLBinaryStringOperator`` as
    /// the operator.
    @discardableResult
    public func orWhere(
        _ keypath1: KeyPath<some Schema, some QueryAddressableProperty>,
        _ op: PostgreSQLBinaryStringOperator,
        _ keypath2: KeyPath<some Schema, some QueryAddressableProperty>
    ) -> Self {
        self.orWhere(keypath1, op, .column(keypath2))
    }
}

extension SQLSecondaryPredicateBuilder {
    /// Allow specifying a conjunctive `HAVING` condition using a Fluent model keypath as the left-hand operand
    /// and a ``PostgreSQLBinaryStringOperator`` as the operator.
    @discardableResult
    public func having(
        _ keypath: KeyPath<some Schema, some QueryAddressableProperty>,
        _ op: PostgreSQLBinaryStringOperator,
        _ rhs: some Encodable & Sendable
    ) -> Self {
        self.having(keypath, op, .bind(rhs))
    }

    /// Allow specifying a conjunctive `HAVING` condition using two Fluent model keypaths, which may optionally
    /// refer to different models, as the operands, and a ``PostgreSQLBinaryStringOperator`` as the operator.
    @discardableResult
    public func having(
        _ keypath1: KeyPath<some Schema, some QueryAddressableProperty>,
        _ op: PostgreSQLBinaryStringOperator,
        _ keypath2: KeyPath<some Schema, some QueryAddressableProperty>
    ) -> Self {
        self.having(keypath1, op, .column(keypath2))
    }

    /// Allow specifying an inclusively disjunctive `HAVING` condition using a Fluent model keypath as the
    /// left-hand operand and a ``PostgreSQLBinaryStringOperator`` as the operator.
    @discardableResult
    public func orHaving(
        _ keypath: KeyPath<some Schema, some QueryAddressableProperty>,
        _ op: PostgreSQLBinaryStringOperator,
        _ rhs: some Encodable & Sendable
    ) -> Self {
        self.orHaving(keypath, op, .bind(rhs))
    }

    /// Allow specifying an inclusively disjunctive `HAVING` condition using two Fluent model keypaths, which may
    /// optionally refer to different models, as the operands and a ``PostgreSQLBinaryStringOperator`` as the operator.
    @discardableResult
    public func orHaving(
        _ keypath1: KeyPath<some Schema, some QueryAddressableProperty>,
        _ op: PostgreSQLBinaryStringOperator,
        _ keypath2: KeyPath<some Schema, some QueryAddressableProperty>
    ) -> Self {
        self.orHaving(keypath1, op, .column(keypath2))
    }
}
#endif
