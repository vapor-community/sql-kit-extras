#if PostgreSQLKitExtras
import SQLKit
import SQLKitExtras
import Testing

@Suite("PostgreSQLKit Extras")
struct PostgreSQLKitExtrasTests {
    @Test
    func arraySubscriptExpression() {
        #expect(serialize(PostgreSQLArraySubscript(array: .column("foo"), subscript: .column("bar"))) == #""foo"["bar"]"#)
        #expect(serialize(.psql_subscript("foo", at: "bar")) == #""foo"["bar"]"#)
        #expect(serialize(.psql_subscript(.column("foo"), at: .column("bar"))) == #""foo"["bar"]"#)
    }

    @Test
    func binaryStringOperator() {
        #expect(serialize(PostgreSQLBinaryStringOperator.caseInsensitiveLike) == #"ILIKE"#)
        #expect(serialize(PostgreSQLBinaryStringOperator.caseInsensitiveNotLike) == #"NOT ILIKE"#)
        #expect(serialize(PostgreSQLBinaryStringOperator.similarTo) == #"SIMILAR TO"#)
        #expect(serialize(PostgreSQLBinaryStringOperator.notSimilarTo) == #"NOT SIMILAR TO"#)

        #expect(serialize(.ilike()) == #"ILIKE"#)
        #expect(serialize(.notILike()) == #"NOT ILIKE"#)
        #expect(serialize(.similarTo()) == #"SIMILAR TO"#)
        #expect(serialize(.notSimilarTo()) == #"NOT SIMILAR TO"#)
    }

    @Test
    func setQuery() {
        #expect(serialize(PostgreSQLSetQuery(name: .identifier("foo.bar"), value: .literal("baz"))) == #"SET "foo.bar" = 'baz'"#)
        #expect(serialize(MockSQLDatabase().psql_set("foo.bar", to: "baz")) == #"SET "foo.bar" = 'baz'"#)
        #expect(serialize(MockSQLDatabase().psql_set("foo.bar", to: .literal("baz"))) == #"SET "foo.bar" = 'baz'"#)
        #expect(serialize(MockSQLDatabase().psql_set(.identifier("foo.bar"), to: .literal("baz"))) == #"SET "foo.bar" = 'baz'"#)
    }

    @Test
    func valuesExpression() {
        #expect(serialize(PostgreSQLValuesExpression(rows: .list(.literal("foo")), .list(.literal("bar")))) == #"VALUES ('foo'), ('bar')"#)
        #expect(serialize(PostgreSQLValuesExpression(rows: [.list(.literal("foo")), .list(.literal("bar"))])) == #"VALUES ('foo'), ('bar')"#)
        #expect(serialize(.psql_values(.list(.literal("foo")), .list(.literal("bar")))) == #"VALUES ('foo'), ('bar')"#)
        #expect(serialize(.psql_values([.list(.literal("foo")), .list(.literal("bar"))])) == #"VALUES ('foo'), ('bar')"#)
    }

    #if FluentSQLKitExtras
    @Suite("FluentPostgreSQLKit Extras")
    struct FluentPostgreSQLKitExtrasTests {
        @Test
        func arraySubscriptExpression() {
            #expect(serialize(.psql_subscript(\FooModel.$field, at: \FooModel.$id)) == #""foos"."field"["foos"."id"]"#)
            #expect(serialize(.psql_subscript(\FooModel.$field, at: .literal(0))) == #""foos"."field"[0]"#)
            #expect(serialize(.psql_subscript(.identifier("foo"), at: \FooModel.$id)) == #""foo"["foos"."id"]"#)
        }
    }
    #endif
}
#endif
