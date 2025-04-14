import SQLKit

extension SQLExpression {
    /// A convenience method for creating an `SQLLiteral` from a string.
    public static func literal(_ str: some StringProtocol) -> Self where Self == SQLLiteral {
        .string(String(str))
    }

    /// A convenience method for creating an `SQLLiteral` from an optional string. The literal will be NULL if the input is nil.
    public static func literal(_ str: (some StringProtocol)?) -> Self where Self == SQLLiteral {
        str.map { .string(String($0)) } ?? .null
    }

    /// A convenience method for creating an `SQLLiteral` from an integer.
    public static func literal(_ int: some FixedWidthInteger) -> Self where Self == SQLLiteral {
        .numeric("\(int)")
    }

    /// A convenience method for creating an `SQLLiteral` from an optional integer. The literal will be NULL if the input is nil.
    public static func literal(_ int: (some FixedWidthInteger)?) -> Self where Self == SQLLiteral {
        int.map { .numeric("\($0)") } ?? .null
    }

    /// A convenience method for creating an `SQLLiteral` from a floating-point value.
    public static func literal(_ real: some BinaryFloatingPoint) -> Self where Self == SQLLiteral {
        .numeric("\(real)")
    }

    /// A convenience method for creating an `SQLLiteral` from an optional floating-point value. The literal will be NULL if
    /// the input is nil.
    public static func literal(_ real: (some BinaryFloatingPoint)?) -> Self where Self == SQLLiteral {
        real.map { .numeric("\($0)") } ?? .null
    }

    /// A convenience method for creating an `SQLLiteral` from a boolean value.
    public static func literal(_ bool: Bool) -> Self where Self == SQLLiteral {
        .boolean(bool)
    }

    /// A convenience method for creating an `SQLLiteral` from an optional boolean value. The literal will be NULL if
    /// the input is nil.
    public static func literal(_ bool: Bool?) -> Self where Self == SQLLiteral {
        bool.map { .boolean($0) } ?? .null
    }

    /// A convenience method for creating an `SQLLiteral.null`.
    public static func null() -> Self where Self == SQLLiteral {
        .null
    }

    /// A convenience method for creating an `SQLLiteral.all`.
    public static func all() -> Self where Self == SQLLiteral {
        .all
    }

    /// A convenience method for creating an `SQLLiteral.default`.
    public static func `default`() -> Self where Self == SQLLiteral {
        .default
    }
}
