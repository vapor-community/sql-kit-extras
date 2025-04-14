import SQLKit

/// Represents a `CASE [WHEN ... THEN ...] ... [ELSE ...] END` expression.
public struct SQLCaseExpression: SQLExpression {
    /// The list of alternatives for the `CASE` expression, expressed as a set of "if condition"+"then result" pairs.
    public let clauses: [(condition: any SQLExpression, result: any SQLExpression)]

    /// The optional "default" alternative for the `CASE` expression.
    public let alternativeResult: (any SQLExpression)?
    
    /// Create a new ``SQLCaseExpression``.
    ///
    /// - Parameters:
    ///   - clauses: The list of alternatives for the `CASE` expression. Each alternative consists of an expression
    ///     representing the alternative's condition and an expression representing the result produced when the
    ///     condition is true.
    ///   - alternativeResult: The optional default alternative for the `CASE` expression.
    public init(clauses: [(condition: any SQLExpression, result: any SQLExpression)], alternativeResult: (any SQLExpression)?) {
        self.clauses = clauses
        self.alternativeResult = alternativeResult
    }

    // See `SQLExpression.serialize(to:)`.
    public func serialize(to serializer: inout SQLSerializer) {
        serializer.statement {
            $0.append("CASE")
            for clause in self.clauses {
                $0.append("WHEN", clause.condition)
                $0.append("THEN", clause.result)
            }
            if let alternativeResult = self.alternativeResult {
                $0.append("ELSE", alternativeResult)
            }
            $0.append("END")
        }
    }
}

extension SQLExpression {
    /// Convenience method for creating an ``SQLCaseExpression`` with a single alternative and an optional default.
    public static func `case`(
        when condition1: some SQLExpression, then result1: some SQLExpression,
        `else` alternative: (some SQLExpression)? = SQLRaw?.none
    ) -> Self where Self == SQLCaseExpression {
        .init(
            clauses: [
                (condition1, result1),
            ],
            alternativeResult: alternative
        )
    }

    /// Convenience method for creating an ``SQLCaseExpression`` with two alternatives and an optional default.
    public static func `case`(
        when condition1: some SQLExpression, then result1: some SQLExpression,
        when condition2: some SQLExpression, then result2: some SQLExpression,
        `else` alternative: (some SQLExpression)? = SQLRaw?.none
    ) -> Self where Self == SQLCaseExpression {
        .init(
            clauses: [
                (condition1, result1),
                (condition2, result2),
            ],
            alternativeResult: alternative
        )
    }

    /// Convenience method for creating an ``SQLCaseExpression`` with three alternatives and an optional default.
    public static func `case`(
        when condition1: some SQLExpression, then result1: some SQLExpression,
        when condition2: some SQLExpression, then result2: some SQLExpression,
        when condition3: some SQLExpression, then result3: some SQLExpression,
        `else` alternative: (some SQLExpression)? = SQLRaw?.none
    ) -> Self where Self == SQLCaseExpression {
        .init(
            clauses: [
                (condition1, result1),
                (condition2, result2),
                (condition3, result3),
            ],
            alternativeResult: alternative
        )
    }

    /// Convenience method for creating an ``SQLCaseExpression`` with four alternatives and an optional default.
    public static func `case`(
        when condition1: some SQLExpression, then result1: some SQLExpression,
        when condition2: some SQLExpression, then result2: some SQLExpression,
        when condition3: some SQLExpression, then result3: some SQLExpression,
        when condition4: some SQLExpression, then result4: some SQLExpression,
        `else` alternative: (some SQLExpression)? = SQLRaw?.none
    ) -> Self where Self == SQLCaseExpression {
        .init(
            clauses: [
                (condition1, result1),
                (condition2, result2),
                (condition3, result3),
                (condition4, result4),
            ],
            alternativeResult: alternative
        )
    }

    /// Convenience method for creating an ``SQLCaseExpression`` with five alternatives and an optional default.
    public static func `case`(
        when condition1: some SQLExpression, then result1: some SQLExpression,
        when condition2: some SQLExpression, then result2: some SQLExpression,
        when condition3: some SQLExpression, then result3: some SQLExpression,
        when condition4: some SQLExpression, then result4: some SQLExpression,
        when condition5: some SQLExpression, then result5: some SQLExpression,
        `else` alternative: (some SQLExpression)? = SQLRaw?.none
    ) -> Self where Self == SQLCaseExpression {
        .init(
            clauses: [
                (condition1, result1),
                (condition2, result2),
                (condition3, result3),
                (condition4, result4),
                (condition5, result5),
            ],
            alternativeResult: alternative
        )
    }
}
