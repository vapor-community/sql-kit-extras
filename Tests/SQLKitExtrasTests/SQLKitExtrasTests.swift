import SQLKit
import SQLKitExtras
import Testing

@Suite("SQLKit Extras")
struct SQLKitExtrasTests {
    @Suite("Builtin Expressions")
    struct BuiltinExpressionsTests {
        @Test
        func aliasExpression() {
            #expect(serialize(.alias("foo", as: "bar")) == #""foo" AS "bar""#)
            #expect(serialize(.alias("foo"[...], as: "bar"[...])) == #""foo" AS "bar""#)
            #expect(serialize(.alias(.column("foo"), as: "bar")) == #""foo" AS "bar""#)
            #expect(serialize(.alias(.column("foo"), as: .identifier("bar"))) == #""foo" AS "bar""#)
        }

        @Test
        func binaryExpression() {
            #expect(serialize(.expr(.column("foo"), .equal, 1)) == #""foo" = $1"#)
            #expect(serialize(.expr(.column("foo"), .equal, .literal(1))) == #""foo" = 1"#)
            #expect(serialize(.expr(op: .and,
                .expr(.identifier("foo"), .equal, "bar"),
                .not(.literal(false)),
                .function("bool_func"),
                .expr(.identifier("baz"), .notLike, .literal("%bamf%"))
            )) == #""foo" = $1 AND NOT false AND bool_func() AND "baz" NOT LIKE '%bamf%'"#)
        }

        @Test
        func bindExpression() {
            #expect(serialize(.bind("")) == #"$1"#)
            #expect(serialize(.bindGroup(["", ""])) == #"($1, $2)"#)
        }

        @Test
        func columnExpression() {
            #expect(serialize(.column("foo")) == #""foo""#)
            #expect(serialize(.column("foo"[...])) == #""foo""#)
            #expect(serialize(.column("foo", table: "bar")) == #""bar"."foo""#)
            #expect(serialize(.column("foo"[...], table: "bar"[...])) == #""bar"."foo""#)
            #expect(serialize(.column("foo", table: .identifier("bar"))) == #""bar"."foo""#)
            #expect(serialize(.column("foo"[...], table: .identifier("bar"))) == #""bar"."foo""#)
            #expect(serialize(.column(.identifier("foo"), table: "bar")) == #""bar"."foo""#)
            #expect(serialize(.column(.identifier("foo"), table: "bar"[...])) == #""bar"."foo""#)
            #expect(serialize(.column(.identifier("foo"))) == #""foo""#)
            #expect(serialize(.column(.identifier("foo"), table: .some(.identifier("bar")))) == #""bar"."foo""#)
        }

        @Test
        func functionExpression() {
            #expect(serialize(.function("foo", .literal("bar"), .literal(1), .literal(true))) == #"foo('bar', 1, true)"#)
            #expect(serialize(.function("foo"[...], .literal("bar"), .literal(1), .literal(true))) == #"foo('bar', 1, true)"#)
            #expect(serialize(.function("foo", [.literal("bar"), .literal(1), .literal(true)])) == #"foo('bar', 1, true)"#)
            #expect(serialize(.function("foo"[...], [.literal("bar"), .literal(1), .literal(true)])) == #"foo('bar', 1, true)"#)

            #expect(serialize(.coalesce(.identifier("foo"), .column("bar"), .literal(0))) == #"coalesce("foo", "bar", 0)"#)
            #expect(serialize(.coalesce([.identifier("foo"), .column("bar"), .literal(0)])) == #"coalesce("foo", "bar", 0)"#)

            #expect(serialize(.concat(.identifier("foo"), .literal(" "), .identifier("bar"))) == #"concat("foo", ' ', "bar")"#)
            #expect(serialize(.concat([.identifier("foo"), .literal(" "), .identifier("bar")])) == #"concat("foo", ' ', "bar")"#)

            #expect(serialize(.concat_ws(separator: " ", .identifier("foo"), .identifier("bar"))) == #"concat_ws(' ', "foo", "bar")"#)
            #expect(serialize(.concat_ws(separator: " ", [.identifier("foo"), .identifier("bar")])) == #"concat_ws(' ', "foo", "bar")"#)

            #expect(serialize(.length(.column("foo"))) == #"length("foo")"#)

            #expect(serialize(.count(.column("foo"))) == #"count("foo")"#)
            #expect(serialize(.count(.column("foo"), distinct: true)) == #"count(DISTINCT "foo")"#)

            #expect(serialize(.sum(.column("foo"))) == #"sum("foo")"#)
            #expect(serialize(.sum(.column("foo"), distinct: true)) == #"sum(DISTINCT "foo")"#)
        }

        @Test
        func groupExpression() {
            #expect(serialize(.group(.literal("foo"))) == #"('foo')"#)
        }

        @Test
        func identifierExpression() {
            #expect(serialize(.identifier("foo")) == #""foo""#)
            #expect(serialize(.identifier("foo"[...])) == #""foo""#)
        }

        @Test
        func listExpression() {
            #expect(serialize(.list(.literal(1), .literal(2))) == #"1, 2"#)
            #expect(serialize(.list([.literal(1), .literal(2)])) == #"1, 2"#)
            #expect(serialize(.list(.literal(1), .literal(2), separator: " BUT ")) == #"1 BUT 2"#)
            #expect(serialize(.list(.literal(1), .literal(2), separator: " BUT "[...])) == #"1 BUT 2"#)
            #expect(serialize(.list([.literal(1), .literal(2)], separator: " BUT ")) == #"1 BUT 2"#)
            #expect(serialize(.list([.literal(1), .literal(2)], separator: " BUT "[...])) == #"1 BUT 2"#)

            #expect(serialize(.clause(.literal(1), .literal(2))) == #"1 2"#)
            #expect(serialize(.clause([.literal(1), .literal(2)])) == #"1 2"#)
        }

        @Test
        func literalExpression() {
            #expect(serialize(.literal("foo")) == #"'foo'"#)
            #expect(serialize(.literal("foo"[...])) == #"'foo'"#)
            #expect(serialize(.literal(.some("foo"))) == #"'foo'"#)
            #expect(serialize(.literal(.some("foo"[...]))) == #"'foo'"#)
            #expect(serialize(.literal(String?.none)) == #"NULL"#)
            #expect(serialize(.literal(Substring?.none)) == #"NULL"#)

            #expect(serialize(.literal(0 as Int8)) == #"0"#)
            #expect(serialize(.literal(0 as UInt8)) == #"0"#)
            #expect(serialize(.literal(0 as Int16)) == #"0"#)
            #expect(serialize(.literal(0 as UInt16)) == #"0"#)
            #expect(serialize(.literal(0 as Int32)) == #"0"#)
            #expect(serialize(.literal(0 as UInt32)) == #"0"#)
            #expect(serialize(.literal(0 as Int64)) == #"0"#)
            #expect(serialize(.literal(0 as UInt64)) == #"0"#)
            #expect(serialize(.literal(0 as Int)) == #"0"#)
            #expect(serialize(.literal(0 as UInt)) == #"0"#)
            #expect(serialize(.literal(Int?.some(0))) == #"0"#)
            #expect(serialize(.literal(Int?.none)) == #"NULL"#)

            #expect(serialize(.literal(0.1 as Float)) == #"0.1"#)
            #expect(serialize(.literal(0.1 as Double)) == #"0.1"#)
            #expect(serialize(.literal(Double?.some(0.1))) == #"0.1"#)
            #expect(serialize(.literal(Double?.none)) == #"NULL"#)

            #expect(serialize(.literal(true)) == #"true"#)
            #expect(serialize(.literal(false)) == #"false"#)
            #expect(serialize(.literal(.some(true))) == #"true"#)
            #expect(serialize(.literal(.some(false))) == #"false"#)
            #expect(serialize(.literal(Bool?.none)) == #"NULL"#)

            #expect(serialize(.null()) == #"NULL"#)

            #expect(serialize(.all()) == #"*"#)

            #expect(serialize(.default()) == #"DEFAULT"#)
        }

        @Test
        func qualifiedTableExpression() {
            #expect(serialize(.table("foo")) == #""foo""#)
            #expect(serialize(.table("foo"[...])) == #""foo""#)
            #expect(serialize(.table("foo", space: "bar")) == #""bar"."foo""#)
            #expect(serialize(.table("foo"[...], space: "bar"[...])) == #""bar"."foo""#)
            #expect(serialize(.table("foo", space: .identifier("bar"))) == #""bar"."foo""#)
            #expect(serialize(.table("foo"[...], space: .identifier("bar"))) == #""bar"."foo""#)
            #expect(serialize(.table(.identifier("foo"), space: "bar")) == #""bar"."foo""#)
            #expect(serialize(.table(.identifier("foo"), space: "bar"[...])) == #""bar"."foo""#)
            #expect(serialize(.table(.identifier("foo"))) == #""foo""#)
            #expect(serialize(.table(.identifier("foo"), space: .some(.identifier("bar")))) == #""bar"."foo""#)
        }

        @Test
        func rawExpression() {
            #expect(serialize(.unsafeRaw("foo")) == #"foo"#)
        }

        @Test
        func subqueryExpression() {
            #expect(serialize(.subquery { $0.column("foo") }) == #"(SELECT "foo")"#)
        }
    }

    @Suite("Builtin Builders")
    struct BuiltinBuildersTests {
        @Test
        func joinBuilder() {
            #expect(serialize(.subquery { $0.join("foo", as: "bar", on: .literal(true)) }) == #"(SELECT INNER JOIN "foo" AS "bar" ON true)"#)
            #expect(serialize(.subquery { $0.join("foo"[...], as: "bar"[...], on: .literal(true)) }) == #"(SELECT INNER JOIN "foo" AS "bar" ON true)"#)
            #expect(serialize(.subquery { $0.join("foo", as: "bar", method: .left, on: .literal(true)) }) == #"(SELECT LEFT JOIN "foo" AS "bar" ON true)"#)
            #expect(serialize(.subquery { $0.join("foo"[...], as: "bar"[...], method: .left, on: .literal(true)) }) == #"(SELECT LEFT JOIN "foo" AS "bar" ON true)"#)
            #expect(serialize(.subquery { $0.join(.table("foo"), as: "bar", on: .literal(true)) }) == #"(SELECT INNER JOIN "foo" AS "bar" ON true)"#)
            #expect(serialize(.subquery { $0.join(.table("foo"), as: "bar"[...], on: .literal(true)) }) == #"(SELECT INNER JOIN "foo" AS "bar" ON true)"#)
            #expect(serialize(.subquery { $0.join(.table("foo"), as: "bar", method: .left, on: .literal(true)) }) == #"(SELECT LEFT JOIN "foo" AS "bar" ON true)"#)
            #expect(serialize(.subquery { $0.join(.table("foo"), as: "bar"[...], method: .left, on: .literal(true)) }) == #"(SELECT LEFT JOIN "foo" AS "bar" ON true)"#)

            #expect(serialize(.subquery { $0.join("foo", as: "bar", on: .literal(0), .equal, .literal(0)) }) == #"(SELECT INNER JOIN "foo" AS "bar" ON 0 = 0)"#)
            #expect(serialize(.subquery { $0.join("foo"[...], as: "bar"[...], on: .literal(0), .equal, .literal(0)) }) == #"(SELECT INNER JOIN "foo" AS "bar" ON 0 = 0)"#)
            #expect(serialize(.subquery { $0.join("foo", as: "bar", method: .left, on: .literal(0), .equal, .literal(0)) }) == #"(SELECT LEFT JOIN "foo" AS "bar" ON 0 = 0)"#)
            #expect(serialize(.subquery { $0.join("foo"[...], as: "bar"[...], method: .left, on: .literal(0), .equal, .literal(0)) }) == #"(SELECT LEFT JOIN "foo" AS "bar" ON 0 = 0)"#)
            #expect(serialize(.subquery { $0.join(.table("foo"), as: "bar", on: .literal(0), .equal, .literal(0)) }) == #"(SELECT INNER JOIN "foo" AS "bar" ON 0 = 0)"#)
            #expect(serialize(.subquery { $0.join(.table("foo"), as: "bar"[...], on: .literal(0), .equal, .literal(0)) }) == #"(SELECT INNER JOIN "foo" AS "bar" ON 0 = 0)"#)
            #expect(serialize(.subquery { $0.join(.table("foo"), as: "bar", method: .left, on: .literal(0), .equal, .literal(0)) }) == #"(SELECT LEFT JOIN "foo" AS "bar" ON 0 = 0)"#)
            #expect(serialize(.subquery { $0.join(.table("foo"), as: "bar"[...], method: .left, on: .literal(0), .equal, .literal(0)) }) == #"(SELECT LEFT JOIN "foo" AS "bar" ON 0 = 0)"#)

            #expect(serialize(.subquery { $0.join(.table("foo"), as: "bar", using: .column("a")) }) == #"(SELECT INNER JOIN "foo" AS "bar" USING ("a"))"#)
            #expect(serialize(.subquery { $0.join(.table("foo"), as: "bar"[...], using: .column("a")) }) == #"(SELECT INNER JOIN "foo" AS "bar" USING ("a"))"#)
            #expect(serialize(.subquery { $0.join(.table("foo"), as: "bar", method: .left, using: .column("a")) }) == #"(SELECT LEFT JOIN "foo" AS "bar" USING ("a"))"#)
            #expect(serialize(.subquery { $0.join(.table("foo"), as: "bar"[...], method: .left, using: .column("a")) }) == #"(SELECT LEFT JOIN "foo" AS "bar" USING ("a"))"#)
            #expect(serialize(.subquery { $0.join(.table("foo"), as: "bar", using: [.column("a")]) }) == #"(SELECT INNER JOIN "foo" AS "bar" USING ("a"))"#)
            #expect(serialize(.subquery { $0.join(.table("foo"), as: "bar"[...], using: [.column("a")]) }) == #"(SELECT INNER JOIN "foo" AS "bar" USING ("a"))"#)
            #expect(serialize(.subquery { $0.join(.table("foo"), as: "bar", method: .left, using: [.column("a")]) }) == #"(SELECT LEFT JOIN "foo" AS "bar" USING ("a"))"#)
            #expect(serialize(.subquery { $0.join(.table("foo"), as: "bar"[...], method: .left, using: [.column("a")]) }) == #"(SELECT LEFT JOIN "foo" AS "bar" USING ("a"))"#)
        }
    }

    @Suite("Additional Expressions")
    struct AdditionalExpressionsTests {
        @Test
        func additionalBinaryOperatorExpression() {
            #expect(serialize(SQLAdditionalBinaryOperator.AND) == #"&"#)
            #expect(serialize(SQLAdditionalBinaryOperator.OR) == #"|"#)
            #expect(serialize(SQLAdditionalBinaryOperator.XOR) == #""#)
            #expect(MockSQLDatabase(dialect: "mysql").serialize(SQLAdditionalBinaryOperator.XOR).sql == #"^"#)
            #expect(MockSQLDatabase(dialect: "postgresql").serialize(SQLAdditionalBinaryOperator.XOR).sql == #"#"#)

            #expect(serialize(SQLAdditionalBinaryOperator.leftShift) == #"<<"#)
            #expect(serialize(SQLAdditionalBinaryOperator.rightShift) == #">>"#)

            #expect(serialize(.AND()) == #"&"#)
            #expect(serialize(.OR()) == #"|"#)
            #expect(serialize(.XOR()) == #""#)
            #expect(MockSQLDatabase(dialect: "mysql").serialize(.XOR()).sql == #"^"#)
            #expect(MockSQLDatabase(dialect: "postgresql").serialize(.XOR()).sql == #"#"#)
            #expect(serialize(.leftShift()) == #"<<"#)
            #expect(serialize(.rightShift()) == #">>"#)
        }

        @Test
        func caseExpression() {
            #expect(serialize(SQLCaseExpression(clauses: [
                (condition: .literal(true), result: .literal(1))
            ], alternativeResult: nil)) == #"CASE WHEN true THEN 1 END"#)
            #expect(serialize(SQLCaseExpression(clauses: [
                (condition: .literal(true), result: .literal(1))
            ], alternativeResult: .literal(0))) == #"CASE WHEN true THEN 1 ELSE 0 END"#)

            #expect(serialize(SQLCaseExpression(clauses: [
                (condition: .literal(0), result: .literal(9)), (condition: .literal(1), result: .literal(8)),
                (condition: .literal(2), result: .literal(7)), (condition: .literal(3), result: .literal(6)),
                (condition: .literal(4), result: .literal(5)), (condition: .literal(5), result: .literal(4)),
                (condition: .literal(6), result: .literal(3)), (condition: .literal(7), result: .literal(2)),
                (condition: .literal(8), result: .literal(1)), (condition: .literal(9), result: .literal(0)),
            ], alternativeResult: nil)) == #"CASE WHEN 0 THEN 9 WHEN 1 THEN 8 WHEN 2 THEN 7 WHEN 3 THEN 6 WHEN 4 THEN 5 WHEN 5 THEN 4 WHEN 6 THEN 3 WHEN 7 THEN 2 WHEN 8 THEN 1 WHEN 9 THEN 0 END"#)
            #expect(serialize(SQLCaseExpression(clauses: [
                (condition: .literal(0), result: .literal(9)), (condition: .literal(1), result: .literal(8)),
                (condition: .literal(2), result: .literal(7)), (condition: .literal(3), result: .literal(6)),
                (condition: .literal(4), result: .literal(5)), (condition: .literal(5), result: .literal(4)),
                (condition: .literal(6), result: .literal(3)), (condition: .literal(7), result: .literal(2)),
                (condition: .literal(8), result: .literal(1)), (condition: .literal(9), result: .literal(0)),
            ], alternativeResult: .literal(-1))) == #"CASE WHEN 0 THEN 9 WHEN 1 THEN 8 WHEN 2 THEN 7 WHEN 3 THEN 6 WHEN 4 THEN 5 WHEN 5 THEN 4 WHEN 6 THEN 3 WHEN 7 THEN 2 WHEN 8 THEN 1 WHEN 9 THEN 0 ELSE -1 END"#)

            #expect(serialize(.case(when: .literal(0), then: .literal(1))) == #"CASE WHEN 0 THEN 1 END"#)
            #expect(serialize(.case(when: .literal(0), then: .literal(1), else: .some(.literal(0)))) == #"CASE WHEN 0 THEN 1 ELSE 0 END"#)
            #expect(serialize(.case(when: .literal(0), then: .literal(1), when: .literal(1), then: .literal(2))) == #"CASE WHEN 0 THEN 1 WHEN 1 THEN 2 END"#)
            #expect(serialize(.case(when: .literal(0), then: .literal(1), when: .literal(1), then: .literal(2), else: .some(.literal(0)))) == #"CASE WHEN 0 THEN 1 WHEN 1 THEN 2 ELSE 0 END"#)
            #expect(serialize(.case(when: .literal(0), then: .literal(1), when: .literal(1), then: .literal(2), when: .literal(2), then: .literal(3))) == #"CASE WHEN 0 THEN 1 WHEN 1 THEN 2 WHEN 2 THEN 3 END"#)
            #expect(serialize(.case(when: .literal(0), then: .literal(1), when: .literal(1), then: .literal(2), when: .literal(2), then: .literal(3), else: .some(.literal(0)))) == #"CASE WHEN 0 THEN 1 WHEN 1 THEN 2 WHEN 2 THEN 3 ELSE 0 END"#)
            #expect(serialize(.case(when: .literal(0), then: .literal(1), when: .literal(1), then: .literal(2), when: .literal(2), then: .literal(3), when: .literal(3), then: .literal(4))) == #"CASE WHEN 0 THEN 1 WHEN 1 THEN 2 WHEN 2 THEN 3 WHEN 3 THEN 4 END"#)
            #expect(serialize(.case(when: .literal(0), then: .literal(1), when: .literal(1), then: .literal(2), when: .literal(2), then: .literal(3), when: .literal(3), then: .literal(4), else: .some(.literal(0)))) == #"CASE WHEN 0 THEN 1 WHEN 1 THEN 2 WHEN 2 THEN 3 WHEN 3 THEN 4 ELSE 0 END"#)
            #expect(serialize(.case(when: .literal(0), then: .literal(1), when: .literal(1), then: .literal(2), when: .literal(2), then: .literal(3), when: .literal(3), then: .literal(4), when: .literal(4), then: .literal(5))) == #"CASE WHEN 0 THEN 1 WHEN 1 THEN 2 WHEN 2 THEN 3 WHEN 3 THEN 4 WHEN 4 THEN 5 END"#)
            #expect(serialize(.case(when: .literal(0), then: .literal(1), when: .literal(1), then: .literal(2), when: .literal(2), then: .literal(3), when: .literal(3), then: .literal(4), when: .literal(4), then: .literal(5), else: .some(.literal(0)))) == #"CASE WHEN 0 THEN 1 WHEN 1 THEN 2 WHEN 2 THEN 3 WHEN 3 THEN 4 WHEN 4 THEN 5 ELSE 0 END"#)
        }

        @Test
        func currentTimestampExpression() {
            #expect(serialize(SQLCurrentTimestampExpression()) == #"current_timestamp()"#)
            #expect(MockSQLDatabase(dialect: "sqlite").serialize(SQLCurrentTimestampExpression()).sql == #"unixepoch()"#)
            #expect(MockSQLDatabase(dialect: "postgresql").serialize(SQLCurrentTimestampExpression()).sql == #"now()"#)
            
            #expect(serialize(.now()) == #"current_timestamp()"#)
            #expect(MockSQLDatabase(dialect: "sqlite").serialize(.now()).sql == #"unixepoch()"#)
            #expect(MockSQLDatabase(dialect: "postgresql").serialize(.now()).sql == #"now()"#)
        }

        @Test
        func unaryOperatorExpression() {
            #expect(serialize(SQLUnaryOperator.not) == #"NOT"#)
            #expect(serialize(SQLUnaryOperator.negate) == #"-"#)
            #expect(serialize(SQLUnaryOperator.plus) == #"+"#)
            #expect(serialize(SQLUnaryOperator.invert) == #"~"#)
            #expect(serialize(SQLUnaryOperator.custom("^")) == #"^"#)
        }

        @Test
        func unaryExpression() {
            #expect(serialize(SQLUnaryExpression(.not, .literal(true))) == #"NOT true"#)
            #expect(serialize(SQLUnaryExpression(op: SQLUnaryOperator.invert, operand: .literal(0))) == #"~ 0"#)

            #expect(serialize(.expr(.negate, .literal(1))) == "- 1")
            #expect(serialize(.not(.literal(false))) == "NOT false")
        }
    }
}
