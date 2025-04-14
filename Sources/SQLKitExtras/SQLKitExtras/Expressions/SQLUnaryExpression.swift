import SQLKit

/// A fundamental syntactical expression - a unary operator and its single operand.
public struct SQLUnaryExpression: SQLExpression {
    /// The unary operator.
    public let op: any SQLExpression

    /// The operand to which the operator applies.
    public let operand: any SQLExpression

    /// Create a new unary expression from components.
    ///
    /// - Parameters:
    ///   - op: The operator.
    ///   - operand: The operand.
    public init(op: some SQLExpression, operand: some SQLExpression) {
        self.op = op
        self.operand = operand
    }

    /// Create a unary expression from a predefined unary operator and an operand expression.
    ///
    /// - Parameters:
    ///   - op: The operator.
    ///   - operand: The operand.
    public init(_ op: SQLUnaryOperator, _ operand: some SQLExpression) {
        self.init(op: op, operand: operand)
    }

    // See `SQLExpression.serialize(to:)`.
    public func serialize(to serializer: inout SQLSerializer) {
        serializer.statement {
            $0.append(self.op, self.operand)
        }
    }
}

extension SQLExpression {
    /// A convenience method for creating an ``SQLUnaryExpression`` from an operator and operand.
    public static func expr(
        _ op: SQLUnaryOperator,
        _ operand: some SQLExpression
    ) -> Self where Self == SQLUnaryExpression {
        .init(op, operand)
    }

    /// A convenience method for creating an ``SQLUnaryExpression`` for the `NOT` operator given an operand.
    public static func not(_ operand: some SQLExpression) -> Self where Self == SQLUnaryExpression {
        .expr(.not, operand)
    }
}
