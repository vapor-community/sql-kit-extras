public import SQLKit

extension SQLExpression {
    /// A convenience method for creating an `SQLBetween` from set of `SQLExpression`s.
    public static func expr<T: SQLExpression, U: SQLExpression, V: SQLExpression>(
        _ operand: T,
        between lowerBound: U,
        and upperBound: V
    ) -> Self where Self == SQLBetween<T, U, V> {
        SQLBetween(operand: operand, lowerBound: lowerBound, upperBound: upperBound)
    }
}
