#if FluentSQLKitExtras
public import FluentKit
public import SQLKit

extension SQLExpression {
    /// Convenience method for creating a `SQLBetween` expression using a Fluent keypath for the operand and expressions
    /// for the bounds.
    public static func expr<U: SQLExpression, V: SQLExpression>(
        _ operand: KeyPath<some Schema, some QueryAddressableProperty>,
        between lowerBound: U,
        and upperBound: V
    ) -> Self where Self == SQLBetween<SQLColumn, U, V> {
        self.expr(.column(operand), between: lowerBound, and: upperBound)
    }

    /// Convenience method for creating a `SQLBetween` expression using Fluent keypaths for the operand and lower bound and
    /// an expression for the upper bound.
    public static func expr<V: SQLExpression>(
        _ operand: KeyPath<some Schema, some QueryAddressableProperty>,
        between lowerBound: KeyPath<some Schema, some QueryAddressableProperty>,
        and upperBound: V
    ) -> Self where Self == SQLBetween<SQLColumn, SQLColumn, V> {
        self.expr(.column(operand), between: .column(lowerBound), and: upperBound)
    }

    /// Convenience method for creating a `SQLBetween` expression using Fluent keypaths for the operand and upper bound and
    /// an expression for the lower bound.
    public static func expr<U: SQLExpression>(
        _ operand: KeyPath<some Schema, some QueryAddressableProperty>,
        between lowerBound: U,
        and upperBound: KeyPath<some Schema, some QueryAddressableProperty>
    ) -> Self where Self == SQLBetween<SQLColumn, U, SQLColumn> {
        self.expr(.column(operand), between: lowerBound, and: .column(upperBound))
    }

    /// Convenience method for creating a `SQLBetween` expression using a Fluent keypath for the lower bound and expressions
    /// for the oeprand and upper bound.
    public static func expr<T: SQLExpression, V: SQLExpression>(
        _ operand: T,
        between lowerBound: KeyPath<some Schema, some QueryAddressableProperty>,
        and upperBound: V
    ) -> Self where Self == SQLBetween<T, SQLColumn, V> {
        self.expr(operand, between: .column(lowerBound), and: upperBound)
    }

    /// Convenience method for creating a `SQLBetween` expression using a Fluent keypath for the upper bound and expressions
    /// for the lower and upper bounds.
    public static func expr<T: SQLExpression, U: SQLExpression>(
        _ operand: T,
        between lowerBound: U,
        and upperBound: KeyPath<some Schema, some QueryAddressableProperty>
    ) -> Self where Self == SQLBetween<T, U, SQLColumn> {
        self.expr(operand, between: lowerBound, and: .column(upperBound))
    }

    /// Convenience method for creating a `SQLBetween` expression using a Fluent keypath for the lower and upper boudns and
    /// an expression for the operand.
    public static func expr<T: SQLExpression>(
        _ operand: T,
        between lowerBound: KeyPath<some Schema, some QueryAddressableProperty>,
        and upperBound: KeyPath<some Schema, some QueryAddressableProperty>
    ) -> Self where Self == SQLBetween<T, SQLColumn, SQLColumn> {
        self.expr(operand, between: .column(lowerBound), and: .column(upperBound))
    }

    /// Convenience method for creating a `SQLBetween` expression using Fluent keypaths for the operand and bounds.
    public static func expr(
        _ operand: KeyPath<some Schema, some QueryAddressableProperty>,
        between lowerBound: KeyPath<some Schema, some QueryAddressableProperty>,
        and upperBound: KeyPath<some Schema, some QueryAddressableProperty>
    ) -> Self where Self == SQLBetween<SQLColumn, SQLColumn, SQLColumn> {
        self.expr(.column(operand), between: .column(lowerBound), and: .column(upperBound))
    }

}

extension SQLPredicateBuilder {
    /// Allow specifying a conjunctive `WHERE` condition with a BETWEEN clause using a Fluent model keypath as the operand.
    @discardableResult
    @inlinable
    public func `where`(
        _ operand: KeyPath<some Schema, some QueryAddressableProperty>,
        between lowerBound: some SQLExpression,
        and upperBound: some SQLExpression
    ) -> Self {
        self.where(.column(operand), between: lowerBound, and: upperBound)
    }

    /// Allow specifying a conjunctive `WHERE` condition with a BETWEEN clause using Fluent model keypaths as the operand and lower bound.
    @discardableResult
    @inlinable
    public func `where`(
        _ operand: KeyPath<some Schema, some QueryAddressableProperty>,
        between lowerBound: KeyPath<some Schema, some QueryAddressableProperty>,
        and upperBound: some SQLExpression
    ) -> Self {
        self.where(.column(operand), between: .column(lowerBound), and: upperBound)
    }

    /// Allow specifying a conjunctive `WHERE` condition with a BETWEEN clause using Fluent model keypaths as the operand and upper bound.
    @discardableResult
    @inlinable
    public func `where`(
        _ operand: KeyPath<some Schema, some QueryAddressableProperty>,
        between lowerBound: some SQLExpression,
        and upperBound: KeyPath<some Schema, some QueryAddressableProperty>
    ) -> Self {
        self.where(.column(operand), between: lowerBound, and: .column(upperBound))
    }

    /// Allow specifying a conjunctive `WHERE` condition with a BETWEEN clause using a Fluent model keypath as the lower bound.
    @discardableResult
    @inlinable
    public func `where`(
        _ operand: some SQLExpression,
        between lowerBound: KeyPath<some Schema, some QueryAddressableProperty>,
        and upperBound: some SQLExpression
    ) -> Self {
        self.where(operand, between: .column(lowerBound), and: upperBound)
    }

    /// Allow specifying a conjunctive `WHERE` condition with a BETWEEN clause using a Fluent model keypath as the upper bound.
    @discardableResult
    @inlinable
    public func `where`(
        _ operand: some SQLExpression,
        between lowerBound: some SQLExpression,
        and upperBound: KeyPath<some Schema, some QueryAddressableProperty>
    ) -> Self {
        self.where(operand, between: lowerBound, and: .column(upperBound))
    }

    /// Allow specifying a conjunctive `WHERE` condition with a BETWEEN clause using Fluent model keypaths as the lower and upper bounds.
    @discardableResult
    @inlinable
    public func `where`(
        _ operand: some SQLExpression,
        between lowerBound: KeyPath<some Schema, some QueryAddressableProperty>,
        and upperBound: KeyPath<some Schema, some QueryAddressableProperty>
    ) -> Self {
        self.where(operand, between: .column(lowerBound), and: .column(upperBound))
    }

    /// Allow specifying a conjunctive `WHERE` condition with a BETWEEN clause using Fluent model keypaths as the operand and both bounds.
    @discardableResult
    @inlinable
    public func `where`(
        _ operand: KeyPath<some Schema, some QueryAddressableProperty>,
        between lowerBound: KeyPath<some Schema, some QueryAddressableProperty>,
        and upperBound: KeyPath<some Schema, some QueryAddressableProperty>
    ) -> Self {
        self.where(.column(operand), between: .column(lowerBound), and: .column(upperBound))
    }

    /// Allow specifying an inclusively disjunctive `WHERE` condition with a BETWEEN clause using a Fluent model keypath as the operand.
    @discardableResult
    @inlinable
    public func orWhere(
        _ operand: KeyPath<some Schema, some QueryAddressableProperty>,
        between lowerBound: some SQLExpression,
        and upperBound: some SQLExpression
    ) -> Self {
        self.orWhere(.column(operand), between: lowerBound, and: upperBound)
    }

    /// Allow specifying an inclusively disjunctive `WHERE` condition with a BETWEEN clause using Fluent model keypaths as the
    /// operand and lower bound.
    @discardableResult
    @inlinable
    public func orWhere(
        _ operand: KeyPath<some Schema, some QueryAddressableProperty>,
        between lowerBound: KeyPath<some Schema, some QueryAddressableProperty>,
        and upperBound: some SQLExpression
    ) -> Self {
        self.orWhere(.column(operand), between: .column(lowerBound), and: upperBound)
    }

    /// Allow specifying an inclusively disjunctive `WHERE` condition with a BETWEEN clause using Fluent model keypaths as the
    /// operand and upper bound.
    @discardableResult
    @inlinable
    public func orWhere(
        _ operand: KeyPath<some Schema, some QueryAddressableProperty>,
        between lowerBound: some SQLExpression,
        and upperBound: KeyPath<some Schema, some QueryAddressableProperty>
    ) -> Self {
        self.orWhere(.column(operand), between: lowerBound, and: .column(upperBound))
    }

    /// Allow specifying an inclusively disjunctive `WHERE` condition with a BETWEEN clause using a Fluent model keypath as
    /// the lower bound.
    @discardableResult
    @inlinable
    public func orWhere(
        _ operand: some SQLExpression,
        between lowerBound: KeyPath<some Schema, some QueryAddressableProperty>,
        and upperBound: some SQLExpression
    ) -> Self {
        self.orWhere(operand, between: .column(lowerBound), and: upperBound)
    }

    /// Allow specifying an inclusively disjunctive `WHERE` condition with a BETWEEN clause using a Fluent model keypath as
    /// the upper bound.
    @discardableResult
    @inlinable
    public func orWhere(
        _ operand: some SQLExpression,
        between lowerBound: some SQLExpression,
        and upperBound: KeyPath<some Schema, some QueryAddressableProperty>
    ) -> Self {
        self.orWhere(operand, between: lowerBound, and: .column(upperBound))
    }

    /// Allow specifying an inclusively disjunctive `WHERE` condition with a BETWEEN clause using Fluent model keypaths as the
    /// lower and upper bounds.
    @discardableResult
    @inlinable
    public func orWhere(
        _ operand: some SQLExpression,
        between lowerBound: KeyPath<some Schema, some QueryAddressableProperty>,
        and upperBound: KeyPath<some Schema, some QueryAddressableProperty>
    ) -> Self {
        self.orWhere(operand, between: .column(lowerBound), and: .column(upperBound))
    }

    /// Allow specifying an inclusively disjunctive `WHERE` condition with a BETWEEN clause using Fluent model keypaths as the
    /// operand and both bounds.
    @discardableResult
    @inlinable
    public func orWhere(
        _ operand: KeyPath<some Schema, some QueryAddressableProperty>,
        between lowerBound: KeyPath<some Schema, some QueryAddressableProperty>,
        and upperBound: KeyPath<some Schema, some QueryAddressableProperty>
    ) -> Self {
        self.orWhere(.column(operand), between: .column(lowerBound), and: .column(upperBound))
    }
}

extension SQLSecondaryPredicateBuilder {
    /// Allow specifying a conjunctive `HAVING` condition with a BETWEEN clause using a Fluent model keypath as the operand.
    @discardableResult
    @inlinable
    public func having(
        _ operand: KeyPath<some Schema, some QueryAddressableProperty>,
        between lowerBound: some SQLExpression,
        and upperBound: some SQLExpression
    ) -> Self {
        self.having(.column(operand), between: lowerBound, and: upperBound)
    }

    /// Allow specifying a conjunctive `HAVING` condition with a BETWEEN clause using Fluent model keypaths as the operand and lower bound.
    @discardableResult
    @inlinable
    public func having(
        _ operand: KeyPath<some Schema, some QueryAddressableProperty>,
        between lowerBound: KeyPath<some Schema, some QueryAddressableProperty>,
        and upperBound: some SQLExpression
    ) -> Self {
        self.having(.column(operand), between: .column(lowerBound), and: upperBound)
    }

    /// Allow specifying a conjunctive `HAVING` condition with a BETWEEN clause using Fluent model keypaths as the operand and upper bound.
    @discardableResult
    @inlinable
    public func having(
        _ operand: KeyPath<some Schema, some QueryAddressableProperty>,
        between lowerBound: some SQLExpression,
        and upperBound: KeyPath<some Schema, some QueryAddressableProperty>
    ) -> Self {
        self.having(.column(operand), between: lowerBound, and: .column(upperBound))
    }

    /// Allow specifying a conjunctive `HAVING` condition with a BETWEEN clause using a Fluent model keypath as the lower bound.
    @discardableResult
    @inlinable
    public func having(
        _ operand: some SQLExpression,
        between lowerBound: KeyPath<some Schema, some QueryAddressableProperty>,
        and upperBound: some SQLExpression
    ) -> Self {
        self.having(operand, between: .column(lowerBound), and: upperBound)
    }

    /// Allow specifying a conjunctive `HAVING` condition with a BETWEEN clause using a Fluent model keypath as the upper bound.
    @discardableResult
    @inlinable
    public func having(
        _ operand: some SQLExpression,
        between lowerBound: some SQLExpression,
        and upperBound: KeyPath<some Schema, some QueryAddressableProperty>
    ) -> Self {
        self.having(operand, between: lowerBound, and: .column(upperBound))
    }

    /// Allow specifying a conjunctive `HAVING` condition with a BETWEEN clause using Fluent model keypaths as the lower and upper bounds.
    @discardableResult
    @inlinable
    public func having(
        _ operand: some SQLExpression,
        between lowerBound: KeyPath<some Schema, some QueryAddressableProperty>,
        and upperBound: KeyPath<some Schema, some QueryAddressableProperty>
    ) -> Self {
        self.having(operand, between: .column(lowerBound), and: .column(upperBound))
    }

    /// Allow specifying a conjunctive `HAVING` condition with a BETWEEN clause using Fluent model keypaths as the operand and both bounds.
    @discardableResult
    @inlinable
    public func having(
        _ operand: KeyPath<some Schema, some QueryAddressableProperty>,
        between lowerBound: KeyPath<some Schema, some QueryAddressableProperty>,
        and upperBound: KeyPath<some Schema, some QueryAddressableProperty>
    ) -> Self {
        self.having(.column(operand), between: .column(lowerBound), and: .column(upperBound))
    }

    /// Allow specifying an inclusively disjunctive `HAVING` condition with a BETWEEN clause using a Fluent model keypath as the operand.
    @discardableResult
    @inlinable
    public func orHaving(
        _ operand: KeyPath<some Schema, some QueryAddressableProperty>,
        between lowerBound: some SQLExpression,
        and upperBound: some SQLExpression
    ) -> Self {
        self.orHaving(.column(operand), between: lowerBound, and: upperBound)
    }

    /// Allow specifying an inclusively disjunctive `HAVING` condition with a BETWEEN clause using Fluent model keypaths as the
    /// operand and lower bound.
    @discardableResult
    @inlinable
    public func orHaving(
        _ operand: KeyPath<some Schema, some QueryAddressableProperty>,
        between lowerBound: KeyPath<some Schema, some QueryAddressableProperty>,
        and upperBound: some SQLExpression
    ) -> Self {
        self.orHaving(.column(operand), between: .column(lowerBound), and: upperBound)
    }

    /// Allow specifying an inclusively disjunctive `HAVING` condition with a BETWEEN clause using Fluent model keypaths as the
    /// operand and upper bound.
    @discardableResult
    @inlinable
    public func orHaving(
        _ operand: KeyPath<some Schema, some QueryAddressableProperty>,
        between lowerBound: some SQLExpression,
        and upperBound: KeyPath<some Schema, some QueryAddressableProperty>
    ) -> Self {
        self.orHaving(.column(operand), between: lowerBound, and: .column(upperBound))
    }

    /// Allow specifying an inclusively disjunctive `HAVING` condition with a BETWEEN clause using a Fluent model keypath as
    /// the lower bound.
    @discardableResult
    @inlinable
    public func orHaving(
        _ operand: some SQLExpression,
        between lowerBound: KeyPath<some Schema, some QueryAddressableProperty>,
        and upperBound: some SQLExpression
    ) -> Self {
        self.orHaving(operand, between: .column(lowerBound), and: upperBound)
    }

    /// Allow specifying an inclusively disjunctive `HAVING` condition with a BETWEEN clause using a Fluent model keypath as
    /// the upper bound.
    @discardableResult
    @inlinable
    public func orHaving(
        _ operand: some SQLExpression,
        between lowerBound: some SQLExpression,
        and upperBound: KeyPath<some Schema, some QueryAddressableProperty>
    ) -> Self {
        self.orHaving(operand, between: lowerBound, and: .column(upperBound))
    }

    /// Allow specifying an inclusively disjunctive `HAVING` condition with a BETWEEN clause using Fluent model keypaths as the
    /// lower and upper bounds.
    @discardableResult
    @inlinable
    public func orHaving(
        _ operand: some SQLExpression,
        between lowerBound: KeyPath<some Schema, some QueryAddressableProperty>,
        and upperBound: KeyPath<some Schema, some QueryAddressableProperty>
    ) -> Self {
        self.orHaving(operand, between: .column(lowerBound), and: .column(upperBound))
    }

    /// Allow specifying an inclusively disjunctive `HAVING` condition with a BETWEEN clause using Fluent model keypaths as the
    /// operand and both bounds.
    @discardableResult
    @inlinable
    public func orHaving(
        _ operand: KeyPath<some Schema, some QueryAddressableProperty>,
        between lowerBound: KeyPath<some Schema, some QueryAddressableProperty>,
        and upperBound: KeyPath<some Schema, some QueryAddressableProperty>
    ) -> Self {
        self.orHaving(.column(operand), between: .column(lowerBound), and: .column(upperBound))
    }
}
#endif
