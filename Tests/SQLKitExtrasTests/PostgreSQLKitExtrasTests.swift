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

    @Test
    func constraintConflictResolutionStrategy() {
        #expect(
            serialize(SQLInsertBuilder.PostgreSQLConstraintConflictResolutionStrategy(constraint: "uq_users_email", action: .noAction))
            == #"ON CONFLICT ON CONSTRAINT "uq_users_email" DO NOTHING"#
        )

        #expect(
            serialize(SQLInsertBuilder.PostgreSQLConstraintConflictResolutionStrategy(
                constraint: "uq_users_email",
                action: .update(assignments: [SQLColumnAssignment(settingExcludedValueFor: "email")], predicate: nil)
            ))
            == #"ON CONFLICT ON CONSTRAINT "uq_users_email" DO UPDATE SET "email" = EXCLUDED."email""#
        )

        #expect(
            serialize(SQLInsertBuilder.PostgreSQLConstraintConflictResolutionStrategy(
                constraint: "uq_users_email",
                action: .update(
                    assignments: [SQLColumnAssignment(settingExcludedValueFor: "email")],
                    predicate: SQLBinaryExpression(left: SQLColumn("active"), op: SQLBinaryOperator.equal, right: SQLLiteral.boolean(true))
                )
            ))
            == #"ON CONFLICT ON CONSTRAINT "uq_users_email" DO UPDATE SET "email" = EXCLUDED."email" WHERE "active" = true"#
        )

        #expect(
            serialize(MockSQLDatabase()
                .insert(into: "users")
                .columns("id", "email")
                .values(SQLBind(1), SQLBind("alice@example.com"))
                .psql_ignoringConflicts(withConstraint: "uq_users_email")
            )
            == #"INSERT INTO "users" ("id", "email") VALUES ($1, $2) ON CONFLICT ON CONSTRAINT "uq_users_email" DO NOTHING"#
        )

        #expect(
            serialize(MockSQLDatabase()
                .insert(into: "users")
                .columns("id", "email")
                .values(SQLBind(1), SQLBind("alice@example.com"))
                .psql_onConflict(withConstraint: "uq_users_email") { $0
                    .set(excludedValueOf: "email")
                }
            )
            == #"INSERT INTO "users" ("id", "email") VALUES ($1, $2) ON CONFLICT ON CONSTRAINT "uq_users_email" DO UPDATE SET "email" = EXCLUDED."email""#
        )

        #expect(
            serialize(MockSQLDatabase()
                .insert(into: "users")
                .columns("id", "email")
                .values(SQLBind(1), SQLBind("alice@example.com"))
                .onConflict { $0.set(excludedValueOf: "email") }
                .psql_ignoringConflicts(withConstraint: "uq_users_email")
            )
            == #"INSERT INTO "users" ("id", "email") VALUES ($1, $2) ON CONFLICT ON CONSTRAINT "uq_users_email" DO NOTHING"#
        )
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
