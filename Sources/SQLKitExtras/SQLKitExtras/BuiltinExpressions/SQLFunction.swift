import Algorithms
import SQLKit

extension SQLExpression {
    /// A convenience method for creating an `SQLFunction` from a name and a list of argument expressions.
    public static func function<each E: SQLExpression>(
        _ name: some StringProtocol,
        _ params: repeat each E
    ) -> Self where Self == SQLFunction {
        var args: [any SQLExpression] = []
        repeat args.append(each params)
        return .function(name, args)
    }

    /// A convenience method for creating an `SQLFunction` from a name and a sequence of argument expressions.
    public static func function(
        _ name: some StringProtocol,
        _ params: some Sequence<any SQLExpression>
    ) -> Self where Self == SQLFunction {
        .init(String(name), args: Array(params))
    }

    /// A convenience method for creating a call to the `coalesce()` SQL function with a list of argument expressions.
    public static func coalesce<each E: SQLExpression>(_ params: repeat each E) -> Self where Self == SQLFunction {
        .function("coalesce", repeat each params)
    }

    /// A convenience method for creating a call to the `coalesce()` SQL function with a sequence of argument expressions.
    public static func coalesce(_ params: some Sequence<any SQLExpression>) -> Self where Self == SQLFunction {
        .function("coalesce", params)
    }

    /// A convenience method for creating a call to the `concat()` SQL function with a list of argument expressions.
    public static func concat<each E: SQLExpression>(_ params: repeat each E) -> Self where Self == SQLFunction {
        .function("concat", repeat each params)
    }

    /// A convenience method for creating a call to the `concat()` SQL function with a sequence of argument expressions.
    public static func concat(_ params: some Sequence<any SQLExpression>) -> Self where Self == SQLFunction {
        .function("concat", params)
    }

    /// A convenience method for creating a call to the `concat_ws()` SQL function with a separator string and a
    /// list of argument expressions.
    public static func concat_ws<each E: SQLExpression>(
        separator: some StringProtocol,
        _ params: repeat each E
    ) -> Self where Self == SQLFunction {
        .function("concat_ws", .literal(separator), repeat each params)
    }

    /// A convenience method for creating a call to the `concat_ws()` SQL function with a separator string and a
    /// sequence of argument expressions.
    public static func concat_ws(
        separator: some StringProtocol,
        _ params: some Sequence<any SQLExpression>
    ) -> Self where Self == SQLFunction {
        .function("concat_ws", chain([.literal(separator)], params))
    }

    /// A convenience method for creating a call to the `length()` SQL function with a single argument expression.
    public static func length(_ arg: some SQLExpression) -> Self where Self == SQLFunction {
        .function("length", [arg])
    }

    /// A convenience method for creating a call to the `count()` aggregate SQL function with an argument expression and
    /// a distinct flag.
    public static func count(_ expr: some SQLExpression, distinct: Bool = false) -> Self where Self == SQLFunction {
        distinct ?
            .function("count", SQLDistinct(expr)) :
            .function("count", expr)
    }

    /// A convenience method for creating a call to the `sum()` aggregate SQL function with an argument expression and
    /// a distinct flag.
    public static func sum(_ expr: some SQLExpression, distinct: Bool = false) -> Self where Self == SQLFunction {
        distinct ?
            .function("sum", SQLDistinct(expr)) :
            .function("sum", expr)
    }
}
