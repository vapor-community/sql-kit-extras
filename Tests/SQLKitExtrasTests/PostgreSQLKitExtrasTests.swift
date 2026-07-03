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
        #expect(serialize(PostgreSQLBinaryStringOperator.ilike) == #"ILIKE"#)
        #expect(serialize(PostgreSQLBinaryStringOperator.caseInsensitiveNotLike) == #"NOT ILIKE"#)
        #expect(serialize(PostgreSQLBinaryStringOperator.notILike) == #"NOT ILIKE"#)
        #expect(serialize(PostgreSQLBinaryStringOperator.similarTo) == #"SIMILAR TO"#)
        #expect(serialize(PostgreSQLBinaryStringOperator.notSimilarTo) == #"NOT SIMILAR TO"#)

        #expect(serialize(.ilike()) == #"ILIKE"#)
        #expect(serialize(.notILike()) == #"NOT ILIKE"#)
        #expect(serialize(.similarTo()) == #"SIMILAR TO"#)
        #expect(serialize(.notSimilarTo()) == #"NOT SIMILAR TO"#)

        #expect(serialize(.expr(.column("foo"), .caseInsensitiveLike, "bar")) == #""foo" ILIKE $1"#)
        #expect(serialize(.expr(.column("foo"), .ilike, "bar")) == #""foo" ILIKE $1"#)
        #expect(serialize(.expr(.column("foo"), .caseInsensitiveNotLike, "bar")) == #""foo" NOT ILIKE $1"#)
        #expect(serialize(.expr(.column("foo"), .notILike, "bar")) == #""foo" NOT ILIKE $1"#)
        #expect(serialize(.expr(.column("foo"), .similarTo, "bar")) == #""foo" SIMILAR TO $1"#)
        #expect(serialize(.expr(.column("foo"), .notSimilarTo, "bar")) == #""foo" NOT SIMILAR TO $1"#)
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
            serialize(PostgreSQLConflictResolutionStrategy(constraint: "uq_users_email", action: .noAction))
            == #"ON CONFLICT ON CONSTRAINT "uq_users_email" DO NOTHING"#
        )

        #expect(
            serialize(PostgreSQLConflictResolutionStrategy(constraint: .identifier("uq_users_email"), action: .noAction))
            == #"ON CONFLICT ON CONSTRAINT "uq_users_email" DO NOTHING"#
        )

        #expect(
            serialize(PostgreSQLConflictResolutionStrategy(
                constraint: "uq_users_email",
                action: .update(assignments: [SQLColumnAssignment(settingExcludedValueFor: "email")], predicate: nil)
            ))
            == #"ON CONFLICT ON CONSTRAINT "uq_users_email" DO UPDATE SET "email" = EXCLUDED."email""#
        )

        #expect(
            serialize(PostgreSQLConflictResolutionStrategy(
                constraint: .identifier("uq_users_email"),
                action: .update(assignments: [SQLColumnAssignment(settingExcludedValueFor: "email")], predicate: nil)
            ))
            == #"ON CONFLICT ON CONSTRAINT "uq_users_email" DO UPDATE SET "email" = EXCLUDED."email""#
        )

        #expect(
            serialize(PostgreSQLConflictResolutionStrategy(
                constraint: "uq_users_email",
                action: .update(
                    assignments: [SQLColumnAssignment(settingExcludedValueFor: "email")],
                    predicate: SQLBinaryExpression(left: SQLColumn("active"), op: SQLBinaryOperator.equal, right: SQLLiteral.boolean(true))
                )
            ))
            == #"ON CONFLICT ON CONSTRAINT "uq_users_email" DO UPDATE SET "email" = EXCLUDED."email" WHERE "active" = true"#
        )

        #expect(
            serialize(PostgreSQLConflictResolutionStrategy(
                constraint: .identifier("uq_users_email"),
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
                .psql_ignoringConflicts(withConstraint: .identifier("uq_users_email"))
            )
            == #"INSERT INTO "users" ("id", "email") VALUES ($1, $2) ON CONFLICT ON CONSTRAINT "uq_users_email" DO NOTHING"#
        )

        #expect(
            serialize(MockSQLDatabase()
                .insert(into: "users")
                .columns("id", "email")
                .values(SQLBind(1), SQLBind("alice@example.com"))
                .psql_onConflict(withConstraint: .identifier("uq_users_email")) { $0
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
                .psql_ignoringConflicts(withConstraint: .identifier("uq_users_email"))
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

        @Test
        func binaryStringOperatorExpression() {
            #expect(serialize(selectBuilder().where(\FooModel.$field, .caseInsensitiveLike, "foo")) == #"SELECT WHERE "foos"."field" ILIKE $1"#)
            #expect(serialize(selectBuilder().where(\FooModel.$field, .caseInsensitiveLike, \FooModel.$optionalField)) == #"SELECT WHERE "foos"."field" ILIKE "foos"."optional_field""#)
            #expect(serialize(selectBuilder().where(\FooModel.$field, .ilike, "foo")) == #"SELECT WHERE "foos"."field" ILIKE $1"#)
            #expect(serialize(selectBuilder().where(\FooModel.$field, .ilike, \FooModel.$optionalField)) == #"SELECT WHERE "foos"."field" ILIKE "foos"."optional_field""#)
            #expect(serialize(selectBuilder().where(\FooModel.$field, .caseInsensitiveNotLike, "foo")) == #"SELECT WHERE "foos"."field" NOT ILIKE $1"#)
            #expect(serialize(selectBuilder().where(\FooModel.$field, .caseInsensitiveNotLike, \FooModel.$optionalField)) == #"SELECT WHERE "foos"."field" NOT ILIKE "foos"."optional_field""#)
            #expect(serialize(selectBuilder().where(\FooModel.$field, .notILike, "foo")) == #"SELECT WHERE "foos"."field" NOT ILIKE $1"#)
            #expect(serialize(selectBuilder().where(\FooModel.$field, .notILike, \FooModel.$optionalField)) == #"SELECT WHERE "foos"."field" NOT ILIKE "foos"."optional_field""#)
            #expect(serialize(selectBuilder().where(\FooModel.$field, .similarTo, "foo")) == #"SELECT WHERE "foos"."field" SIMILAR TO $1"#)
            #expect(serialize(selectBuilder().where(\FooModel.$field, .similarTo, \FooModel.$optionalField)) == #"SELECT WHERE "foos"."field" SIMILAR TO "foos"."optional_field""#)
            #expect(serialize(selectBuilder().where(\FooModel.$field, .notSimilarTo, "foo")) == #"SELECT WHERE "foos"."field" NOT SIMILAR TO $1"#)
            #expect(serialize(selectBuilder().where(\FooModel.$field, .notSimilarTo, \FooModel.$optionalField)) == #"SELECT WHERE "foos"."field" NOT SIMILAR TO "foos"."optional_field""#)

            #expect(serialize(selectBuilder().orWhere(\FooModel.$field, .caseInsensitiveLike, "foo")) == #"SELECT WHERE "foos"."field" ILIKE $1"#)
            #expect(serialize(selectBuilder().orWhere(\FooModel.$field, .caseInsensitiveLike, \FooModel.$optionalField)) == #"SELECT WHERE "foos"."field" ILIKE "foos"."optional_field""#)
            #expect(serialize(selectBuilder().orWhere(\FooModel.$field, .ilike, "foo")) == #"SELECT WHERE "foos"."field" ILIKE $1"#)
            #expect(serialize(selectBuilder().orWhere(\FooModel.$field, .ilike, \FooModel.$optionalField)) == #"SELECT WHERE "foos"."field" ILIKE "foos"."optional_field""#)
            #expect(serialize(selectBuilder().orWhere(\FooModel.$field, .caseInsensitiveNotLike, "foo")) == #"SELECT WHERE "foos"."field" NOT ILIKE $1"#)
            #expect(serialize(selectBuilder().orWhere(\FooModel.$field, .caseInsensitiveNotLike, \FooModel.$optionalField)) == #"SELECT WHERE "foos"."field" NOT ILIKE "foos"."optional_field""#)
            #expect(serialize(selectBuilder().orWhere(\FooModel.$field, .notILike, "foo")) == #"SELECT WHERE "foos"."field" NOT ILIKE $1"#)
            #expect(serialize(selectBuilder().orWhere(\FooModel.$field, .notILike, \FooModel.$optionalField)) == #"SELECT WHERE "foos"."field" NOT ILIKE "foos"."optional_field""#)
            #expect(serialize(selectBuilder().orWhere(\FooModel.$field, .similarTo, "foo")) == #"SELECT WHERE "foos"."field" SIMILAR TO $1"#)
            #expect(serialize(selectBuilder().orWhere(\FooModel.$field, .similarTo, \FooModel.$optionalField)) == #"SELECT WHERE "foos"."field" SIMILAR TO "foos"."optional_field""#)
            #expect(serialize(selectBuilder().orWhere(\FooModel.$field, .notSimilarTo, "foo")) == #"SELECT WHERE "foos"."field" NOT SIMILAR TO $1"#)
            #expect(serialize(selectBuilder().orWhere(\FooModel.$field, .notSimilarTo, \FooModel.$optionalField)) == #"SELECT WHERE "foos"."field" NOT SIMILAR TO "foos"."optional_field""#)

            #expect(serialize(selectBuilder().having(\FooModel.$field, .caseInsensitiveLike, "foo")) == #"SELECT HAVING "foos"."field" ILIKE $1"#)
            #expect(serialize(selectBuilder().having(\FooModel.$field, .caseInsensitiveLike, \FooModel.$optionalField)) == #"SELECT HAVING "foos"."field" ILIKE "foos"."optional_field""#)
            #expect(serialize(selectBuilder().having(\FooModel.$field, .ilike, "foo")) == #"SELECT HAVING "foos"."field" ILIKE $1"#)
            #expect(serialize(selectBuilder().having(\FooModel.$field, .ilike, \FooModel.$optionalField)) == #"SELECT HAVING "foos"."field" ILIKE "foos"."optional_field""#)
            #expect(serialize(selectBuilder().having(\FooModel.$field, .caseInsensitiveNotLike, "foo")) == #"SELECT HAVING "foos"."field" NOT ILIKE $1"#)
            #expect(serialize(selectBuilder().having(\FooModel.$field, .caseInsensitiveNotLike, \FooModel.$optionalField)) == #"SELECT HAVING "foos"."field" NOT ILIKE "foos"."optional_field""#)
            #expect(serialize(selectBuilder().having(\FooModel.$field, .notILike, "foo")) == #"SELECT HAVING "foos"."field" NOT ILIKE $1"#)
            #expect(serialize(selectBuilder().having(\FooModel.$field, .notILike, \FooModel.$optionalField)) == #"SELECT HAVING "foos"."field" NOT ILIKE "foos"."optional_field""#)
            #expect(serialize(selectBuilder().having(\FooModel.$field, .similarTo, "foo")) == #"SELECT HAVING "foos"."field" SIMILAR TO $1"#)
            #expect(serialize(selectBuilder().having(\FooModel.$field, .similarTo, \FooModel.$optionalField)) == #"SELECT HAVING "foos"."field" SIMILAR TO "foos"."optional_field""#)
            #expect(serialize(selectBuilder().having(\FooModel.$field, .notSimilarTo, "foo")) == #"SELECT HAVING "foos"."field" NOT SIMILAR TO $1"#)
            #expect(serialize(selectBuilder().having(\FooModel.$field, .notSimilarTo, \FooModel.$optionalField)) == #"SELECT HAVING "foos"."field" NOT SIMILAR TO "foos"."optional_field""#)

            #expect(serialize(selectBuilder().orHaving(\FooModel.$field, .caseInsensitiveLike, "foo")) == #"SELECT HAVING "foos"."field" ILIKE $1"#)
            #expect(serialize(selectBuilder().orHaving(\FooModel.$field, .caseInsensitiveLike, \FooModel.$optionalField)) == #"SELECT HAVING "foos"."field" ILIKE "foos"."optional_field""#)
            #expect(serialize(selectBuilder().orHaving(\FooModel.$field, .ilike, "foo")) == #"SELECT HAVING "foos"."field" ILIKE $1"#)
            #expect(serialize(selectBuilder().orHaving(\FooModel.$field, .ilike, \FooModel.$optionalField)) == #"SELECT HAVING "foos"."field" ILIKE "foos"."optional_field""#)
            #expect(serialize(selectBuilder().orHaving(\FooModel.$field, .caseInsensitiveNotLike, "foo")) == #"SELECT HAVING "foos"."field" NOT ILIKE $1"#)
            #expect(serialize(selectBuilder().orHaving(\FooModel.$field, .caseInsensitiveNotLike, \FooModel.$optionalField)) == #"SELECT HAVING "foos"."field" NOT ILIKE "foos"."optional_field""#)
            #expect(serialize(selectBuilder().orHaving(\FooModel.$field, .notILike, "foo")) == #"SELECT HAVING "foos"."field" NOT ILIKE $1"#)
            #expect(serialize(selectBuilder().orHaving(\FooModel.$field, .notILike, \FooModel.$optionalField)) == #"SELECT HAVING "foos"."field" NOT ILIKE "foos"."optional_field""#)
            #expect(serialize(selectBuilder().orHaving(\FooModel.$field, .similarTo, "foo")) == #"SELECT HAVING "foos"."field" SIMILAR TO $1"#)
            #expect(serialize(selectBuilder().orHaving(\FooModel.$field, .similarTo, \FooModel.$optionalField)) == #"SELECT HAVING "foos"."field" SIMILAR TO "foos"."optional_field""#)
            #expect(serialize(selectBuilder().orHaving(\FooModel.$field, .notSimilarTo, "foo")) == #"SELECT HAVING "foos"."field" NOT SIMILAR TO $1"#)
            #expect(serialize(selectBuilder().orHaving(\FooModel.$field, .notSimilarTo, \FooModel.$optionalField)) == #"SELECT HAVING "foos"."field" NOT SIMILAR TO "foos"."optional_field""#)
        }
    }
    #endif
}
#endif
