#if FluentSQLKitExtras
public import FluentKit
public import SQLKit

extension SQLPredicateBuilder {
    @discardableResult
    @inlinable
    public func `where`(
        _ operand: KeyPath<some Schema, some QueryAddressableProperty>,
        between lowerBound: some SQLExpression,
        and upperBound: some SQLExpression
    ) -> Self {
        self.where(.column(operand), between: lowerBound, and: upperBound)
    }

    @discardableResult
    @inlinable
    public func `where`(
        _ operand: KeyPath<some Schema, some QueryAddressableProperty>,
        between lowerBound: KeyPath<some Schema, some QueryAddressableProperty>,
        and upperBound: some SQLExpression
    ) -> Self {
        self.where(.column(operand), between: .column(lowerBound), and: upperBound)
    }

    @discardableResult
    @inlinable
    public func `where`(
        _ operand: KeyPath<some Schema, some QueryAddressableProperty>,
        between lowerBound: some SQLExpression,
        and upperBound: KeyPath<some Schema, some QueryAddressableProperty>
    ) -> Self {
        self.where(.column(operand), between: lowerBound, and: .column(upperBound))
    }

    @discardableResult
    @inlinable
    public func `where`(
        _ operand: some SQLExpression,
        between lowerBound: KeyPath<some Schema, some QueryAddressableProperty>,
        and upperBound: some SQLExpression
    ) -> Self {
        self.where(operand, between: .column(lowerBound), and: upperBound)
    }

    @discardableResult
    @inlinable
    public func `where`(
        _ operand: some SQLExpression,
        between lowerBound: some SQLExpression,
        and upperBound: KeyPath<some Schema, some QueryAddressableProperty>
    ) -> Self {
        self.where(operand, between: lowerBound, and: .column(upperBound))
    }

    @discardableResult
    @inlinable
    public func `where`(
        _ operand: some SQLExpression,
        between lowerBound: KeyPath<some Schema, some QueryAddressableProperty>,
        and upperBound: KeyPath<some Schema, some QueryAddressableProperty>
    ) -> Self {
        self.where(operand, between: .column(lowerBound), and: .column(upperBound))
    }

    @discardableResult
    @inlinable
    public func `where`(
        _ operand: KeyPath<some Schema, some QueryAddressableProperty>,
        between lowerBound: KeyPath<some Schema, some QueryAddressableProperty>,
        and upperBound: KeyPath<some Schema, some QueryAddressableProperty>
    ) -> Self {
        self.where(.column(operand), between: .column(lowerBound), and: .column(upperBound))
    }

    @discardableResult
    @inlinable
    public func orWhere(
        _ operand: KeyPath<some Schema, some QueryAddressableProperty>,
        between lowerBound: some SQLExpression,
        and upperBound: some SQLExpression
    ) -> Self {
        self.orWhere(.column(operand), between: lowerBound, and: upperBound)
    }

    @discardableResult
    @inlinable
    public func orWhere(
        _ operand: KeyPath<some Schema, some QueryAddressableProperty>,
        between lowerBound: KeyPath<some Schema, some QueryAddressableProperty>,
        and upperBound: some SQLExpression
    ) -> Self {
        self.orWhere(.column(operand), between: .column(lowerBound), and: upperBound)
    }

    @discardableResult
    @inlinable
    public func orWhere(
        _ operand: KeyPath<some Schema, some QueryAddressableProperty>,
        between lowerBound: some SQLExpression,
        and upperBound: KeyPath<some Schema, some QueryAddressableProperty>
    ) -> Self {
        self.orWhere(.column(operand), between: lowerBound, and: .column(upperBound))
    }

    @discardableResult
    @inlinable
    public func orWhere(
        _ operand: some SQLExpression,
        between lowerBound: KeyPath<some Schema, some QueryAddressableProperty>,
        and upperBound: some SQLExpression
    ) -> Self {
        self.orWhere(operand, between: .column(lowerBound), and: upperBound)
    }

    @discardableResult
    @inlinable
    public func orWhere(
        _ operand: some SQLExpression,
        between lowerBound: some SQLExpression,
        and upperBound: KeyPath<some Schema, some QueryAddressableProperty>
    ) -> Self {
        self.orWhere(operand, between: lowerBound, and: .column(upperBound))
    }

    @discardableResult
    @inlinable
    public func orWhere(
        _ operand: some SQLExpression,
        between lowerBound: KeyPath<some Schema, some QueryAddressableProperty>,
        and upperBound: KeyPath<some Schema, some QueryAddressableProperty>
    ) -> Self {
        self.orWhere(operand, between: .column(lowerBound), and: .column(upperBound))
    }

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
    @discardableResult
    @inlinable
    public func having(
        _ operand: KeyPath<some Schema, some QueryAddressableProperty>,
        between lowerBound: some SQLExpression,
        and upperBound: some SQLExpression
    ) -> Self {
        self.having(.column(operand), between: lowerBound, and: upperBound)
    }

    @discardableResult
    @inlinable
    public func having(
        _ operand: KeyPath<some Schema, some QueryAddressableProperty>,
        between lowerBound: KeyPath<some Schema, some QueryAddressableProperty>,
        and upperBound: some SQLExpression
    ) -> Self {
        self.having(.column(operand), between: .column(lowerBound), and: upperBound)
    }

    @discardableResult
    @inlinable
    public func having(
        _ operand: KeyPath<some Schema, some QueryAddressableProperty>,
        between lowerBound: some SQLExpression,
        and upperBound: KeyPath<some Schema, some QueryAddressableProperty>
    ) -> Self {
        self.having(.column(operand), between: lowerBound, and: .column(upperBound))
    }

    @discardableResult
    @inlinable
    public func having(
        _ operand: some SQLExpression,
        between lowerBound: KeyPath<some Schema, some QueryAddressableProperty>,
        and upperBound: some SQLExpression
    ) -> Self {
        self.having(operand, between: .column(lowerBound), and: upperBound)
    }

    @discardableResult
    @inlinable
    public func having(
        _ operand: some SQLExpression,
        between lowerBound: some SQLExpression,
        and upperBound: KeyPath<some Schema, some QueryAddressableProperty>
    ) -> Self {
        self.having(operand, between: lowerBound, and: .column(upperBound))
    }

    @discardableResult
    @inlinable
    public func having(
        _ operand: some SQLExpression,
        between lowerBound: KeyPath<some Schema, some QueryAddressableProperty>,
        and upperBound: KeyPath<some Schema, some QueryAddressableProperty>
    ) -> Self {
        self.having(operand, between: .column(lowerBound), and: .column(upperBound))
    }

    @discardableResult
    @inlinable
    public func having(
        _ operand: KeyPath<some Schema, some QueryAddressableProperty>,
        between lowerBound: KeyPath<some Schema, some QueryAddressableProperty>,
        and upperBound: KeyPath<some Schema, some QueryAddressableProperty>
    ) -> Self {
        self.having(.column(operand), between: .column(lowerBound), and: .column(upperBound))
    }

    @discardableResult
    @inlinable
    public func orHaving(
        _ operand: KeyPath<some Schema, some QueryAddressableProperty>,
        between lowerBound: some SQLExpression,
        and upperBound: some SQLExpression
    ) -> Self {
        self.orHaving(.column(operand), between: lowerBound, and: upperBound)
    }

    @discardableResult
    @inlinable
    public func orHaving(
        _ operand: KeyPath<some Schema, some QueryAddressableProperty>,
        between lowerBound: KeyPath<some Schema, some QueryAddressableProperty>,
        and upperBound: some SQLExpression
    ) -> Self {
        self.orHaving(.column(operand), between: .column(lowerBound), and: upperBound)
    }

    @discardableResult
    @inlinable
    public func orHaving(
        _ operand: KeyPath<some Schema, some QueryAddressableProperty>,
        between lowerBound: some SQLExpression,
        and upperBound: KeyPath<some Schema, some QueryAddressableProperty>
    ) -> Self {
        self.orHaving(.column(operand), between: lowerBound, and: .column(upperBound))
    }

    @discardableResult
    @inlinable
    public func orHaving(
        _ operand: some SQLExpression,
        between lowerBound: KeyPath<some Schema, some QueryAddressableProperty>,
        and upperBound: some SQLExpression
    ) -> Self {
        self.orHaving(operand, between: .column(lowerBound), and: upperBound)
    }

    @discardableResult
    @inlinable
    public func orHaving(
        _ operand: some SQLExpression,
        between lowerBound: some SQLExpression,
        and upperBound: KeyPath<some Schema, some QueryAddressableProperty>
    ) -> Self {
        self.orHaving(operand, between: lowerBound, and: .column(upperBound))
    }

    @discardableResult
    @inlinable
    public func orHaving(
        _ operand: some SQLExpression,
        between lowerBound: KeyPath<some Schema, some QueryAddressableProperty>,
        and upperBound: KeyPath<some Schema, some QueryAddressableProperty>
    ) -> Self {
        self.orHaving(operand, between: .column(lowerBound), and: .column(upperBound))
    }

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
