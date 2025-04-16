#if FluentSQLKitExtras
import FluentKit
import Foundation
import SQLKit
import SQLKitExtras
import Testing

@Suite("FluentSQLKit Extras")
struct FluentSQLKitExtrasTests {
    @Suite("Basics")
    struct BaseTests {
        @Test
        func fieldsAndSchemaExtensions() {
            #expect(FooModel.fieldKey(for: \.$id) == .id)
            #expect(FooModel.fieldKey(for: \.$field) == .string("field"))
            #expect(FooModel.fieldKey(for: \.$optionalField) == .string("optional_field"))
            #expect(FooModel.fieldKey(for: \.$boolean) == .string("boolean"))
            #expect(FooModel.fieldKey(for: \.$optionalBoolean) == .string("optional_boolean"))
            #expect(FooModel.fieldKey(for: \.$timestamp) == .string("timestamp"))
            #expect(FooModel.fieldKey(for: \.$enumeration) == .string("enumeration"))
            #expect(FooModel.fieldKey(for: \.$optionalEnumeration) == .string("optional_enumeration"))
            #expect(FooModel.fieldKey(for: \.$parent) == .string("parent_id"))
            #expect(FooModel.fieldKey(for: \.$optionalParent) == .string("optional_parent_id"))

            #expect(serialize(FooModel.sqlIdentifier(for: \.$id)) == #""id""#)
            #expect(serialize(FooModel.sqlIdentifier(for: \.$field)) == #""field""#)
            #expect(serialize(FooModel.sqlIdentifier(for: \.$optionalField)) == #""optional_field""#)
            #expect(serialize(FooModel.sqlIdentifier(for: \.$boolean)) == #""boolean""#)
            #expect(serialize(FooModel.sqlIdentifier(for: \.$optionalBoolean)) == #""optional_boolean""#)
            #expect(serialize(FooModel.sqlIdentifier(for: \.$timestamp)) == #""timestamp""#)
            #expect(serialize(FooModel.sqlIdentifier(for: \.$enumeration)) == #""enumeration""#)
            #expect(serialize(FooModel.sqlIdentifier(for: \.$optionalEnumeration)) == #""optional_enumeration""#)
            #expect(serialize(FooModel.sqlIdentifier(for: \.$parent)) == #""parent_id""#)
            #expect(serialize(FooModel.sqlIdentifier(for: \.$optionalParent)) == #""optional_parent_id""#)

            #expect(FooModel.key(for: \.$id) == "id")
            #expect(FooModel.key(for: \.$field) == "field")
            #expect(FooModel.key(for: \.$optionalField) == "optional_field")
            #expect(FooModel.key(for: \.$boolean) == "boolean")
            #expect(FooModel.key(for: \.$optionalBoolean) == "optional_boolean")
            #expect(FooModel.key(for: \.$timestamp) == "timestamp")
            #expect(FooModel.key(for: \.$enumeration) == "enumeration")
            #expect(FooModel.key(for: \.$optionalEnumeration) == "optional_enumeration")
            #expect(FooModel.key(for: \.$parent) == "parent_id")
            #expect(FooModel.key(for: \.$optionalParent) == "optional_parent_id")

            #expect(serialize(FooModel.sqlTable) == #""foos""#)
            #expect(serialize(FooModelAlias.sqlTable) == #""foo_alias""#)

            #expect(serialize(FooModel.sqlColumn(for: \.$id)) == #""foos"."id""#)
            #expect(serialize(FooModel.sqlColumn(for: \.$field)) == #""foos"."field""#)
            #expect(serialize(FooModel.sqlColumn(for: \.$optionalField)) == #""foos"."optional_field""#)
            #expect(serialize(FooModel.sqlColumn(for: \.$boolean)) == #""foos"."boolean""#)
            #expect(serialize(FooModel.sqlColumn(for: \.$optionalBoolean)) == #""foos"."optional_boolean""#)
            #expect(serialize(FooModel.sqlColumn(for: \.$timestamp)) == #""foos"."timestamp""#)
            #expect(serialize(FooModel.sqlColumn(for: \.$enumeration)) == #""foos"."enumeration""#)
            #expect(serialize(FooModel.sqlColumn(for: \.$optionalEnumeration)) == #""foos"."optional_enumeration""#)
            #expect(serialize(FooModel.sqlColumn(for: \.$parent)) == #""foos"."parent_id""#)
            #expect(serialize(FooModel.sqlColumn(for: \.$optionalParent)) == #""foos"."optional_parent_id""#)

            FooModel.$space.withValue("public") {
                #expect(serialize(FooModel.sqlTable) == #""public"."foos""#)
                #expect(serialize(FooModelAlias.sqlTable) == #""foo_alias""#)

                #expect(serialize(FooModel.sqlColumn(for: \.$id)) == #""public"."foos"."id""#)
                #expect(serialize(FooModel.sqlColumn(for: \.$field)) == #""public"."foos"."field""#)
                #expect(serialize(FooModel.sqlColumn(for: \.$optionalField)) == #""public"."foos"."optional_field""#)
                #expect(serialize(FooModel.sqlColumn(for: \.$boolean)) == #""public"."foos"."boolean""#)
                #expect(serialize(FooModel.sqlColumn(for: \.$optionalBoolean)) == #""public"."foos"."optional_boolean""#)
                #expect(serialize(FooModel.sqlColumn(for: \.$timestamp)) == #""public"."foos"."timestamp""#)
                #expect(serialize(FooModel.sqlColumn(for: \.$enumeration)) == #""public"."foos"."enumeration""#)
                #expect(serialize(FooModel.sqlColumn(for: \.$optionalEnumeration)) == #""public"."foos"."optional_enumeration""#)
                #expect(serialize(FooModel.sqlColumn(for: \.$parent)) == #""public"."foos"."parent_id""#)
                #expect(serialize(FooModel.sqlColumn(for: \.$optionalParent)) == #""public"."foos"."optional_parent_id""#)
            }
        }

        @Test
        func rowExtensions() {
            #expect((["field": ""] as ThinSQLRow).contains(column: \FooModel.$field))
            #expect(throws: Never.self) { () throws in #expect(try ([:] as ThinSQLRow).decodeNil(column: \FooModel.$id)) }
            #expect(throws: Never.self) { () throws in #expect(try (["field": "foo"] as ThinSQLRow).decode(column: \FooModel.$field) == "foo") }
            #expect(throws: Never.self) { () throws in #expect(try (["field": "", "parent_id": 1] as ThinSQLRow).decode(columns: \FooModel.$field, \FooModel.$parent) == ("", 1)) }
        }

        @Test
        func queryFetcherExtensions() async {
            await #expect(throws: Never.self) { () async throws in
                #expect(try await MockSQLDatabase(resultSet: [["field": "foo"]]).select().first(decodingColumn: \FooModel.$field) == "foo")
            }
            await #expect(throws: Never.self) { () async throws in
                #expect(try await MockSQLDatabase(resultSet: [["field": "a", "parent_id": 1]]).select()
                    .first(decodingColumns: \FooModel.$field, \FooModel.$parent) ?? ("", 0) == ("a", 1))
            }

            await #expect(throws: Never.self) { () async throws in
                #expect(try await MockSQLDatabase(resultSet: [["field": "a"], ["field": "b"]]).select().all(decodingColumn: \FooModel.$field) == ["a", "b"])
            }
            await #expect(throws: Never.self) { () async throws in
                #expect(try await MockSQLDatabase(resultSet: [["field": "a"], ["field": "b"]]).select().all(decodingColumns: \FooModel.$field) == ["a", "b"])
            }
        }
    }

    @Suite("Buildlers")
    struct BuildersTests {
        @Test
        func aliasedColumnListBuilderExtensions() {
            #expect(serialize(selectBuilder().column(\FooModel.$field, as: "not_field")) == #"SELECT "foos"."field" AS "not_field""#)
        }

        @Test
        func alterTableBuilderExtensions() {
            #expect(serialize(MockSQLDatabase().alter(table: FooModel.self)) == #"ALTER TABLE "foos""#)
        }

        @Test
        func columnUpdateBuilderExtensions() {
            #expect(serialize(MockSQLDatabase().update(FooModel.self).set(\FooModel.$field, to: "a")) == #"UPDATE "foos" SET "field" = $1"#)
            #expect(serialize(MockSQLDatabase().update(FooModel.self).set(\FooModel.$field, to: .literal("a"))) == #"UPDATE "foos" SET "field" = 'a'"#)
        }

        @Test
        func conflictUpdateBuilderExtensions() {
            #expect(serialize(MockSQLDatabase().insert(into: FooModel.self).onConflict { $0.set(excludedValueOf: \FooModel.$field) }) == #"INSERT INTO "foos" () ON CONFLICT DO UPDATE SET "field" = EXCLUDED."field""#)
        }

        @Test
        func createIndexBuidlerExtensions() {
            #expect(serialize(MockSQLDatabase().create(index: "foo").on(FooModel.self)) == #"CREATE INDEX "foo" ON "foos" ()"#)
        }

        @Test
        func createTableBuilderExtensions() {
            #expect(serialize(MockSQLDatabase().create(table: FooModel.self)) == #"CREATE TABLE "foos""#)
        }

        @Test
        func createTriggerBuilderExtensions() {
            #expect(serialize(MockSQLDatabase().create(trigger: "foo", table: FooModel.self, when: .before, event: .insert)) == #"CREATE TRIGGER "foo" BEFORE INSERT ON "foos""#)
            #expect(serialize(MockSQLDatabase().create(trigger: .identifier("foo"), table: FooModel.self, when: .unsafeRaw("BAR"), event: .unsafeRaw("BAZ"))) == #"CREATE TRIGGER "foo" BAR BAZ ON "foos""#)
        }

        @Test
        func deleteBuilderExtensions() {
            #expect(serialize(MockSQLDatabase().delete(from: FooModel.self)) == #"DELETE FROM "foos""#)
        }

        @Test
        func dropIndexBuilderExtensions() {
            #expect(serialize(MockSQLDatabase().drop(index: "foo").on(FooModel.self)) == #"DROP INDEX "foo" ON "foos""#)
        }

        @Test
        func dropTableBuilderExtensions() {
            #expect(serialize(MockSQLDatabase().drop(table: FooModel.self)) == #"DROP TABLE "foos""#)
        }

        @Test
        func dropTriggerBuilderExtensions() {
            #expect(serialize(MockSQLDatabase().drop(trigger: "foo").table(FooModel.self)) == #"DROP TRIGGER "foo" ON "foos""#)
        }

        @Test
        func insertBuilderExtensions() {
            #expect(serialize(MockSQLDatabase().insert(into: FooModel.self).columns(\FooModel.$field, \FooModel.$parent)) == #"INSERT INTO "foos" ("field", "parent_id")"#)
        }

        @Test
        func joinBuilderExtensions() {
            #expect(serialize(selectBuilder().join(FooModel.self, on: \FooModel.$field, .equal, \FooModel.$id)) == #"SELECT INNER JOIN "foos" ON "foos"."field" = "foos"."id""#)
            #expect(serialize(selectBuilder().join(FooModel.self, as: "bar", on: \FooModel.$field, .equal, \FooModel.$id)) == #"SELECT INNER JOIN "foos" AS "bar" ON "foos"."field" = "foos"."id""#)
            #expect(serialize(selectBuilder().join(FooModel.self, method: .left, on: \FooModel.$field, .equal, \FooModel.$id)) == #"SELECT LEFT JOIN "foos" ON "foos"."field" = "foos"."id""#)
            #expect(serialize(selectBuilder().join(FooModel.self, as: "bar", method: .left, on: \FooModel.$field, .equal, \FooModel.$id)) == #"SELECT LEFT JOIN "foos" AS "bar" ON "foos"."field" = "foos"."id""#)
            #expect(serialize(selectBuilder().join(FooModel.self, on: \FooModel.$field, .equal, .literal(""))) == #"SELECT INNER JOIN "foos" ON "foos"."field" = ''"#)
            #expect(serialize(selectBuilder().join(FooModel.self, as: "bar", on: \FooModel.$field, .equal, .literal(""))) == #"SELECT INNER JOIN "foos" AS "bar" ON "foos"."field" = ''"#)
            #expect(serialize(selectBuilder().join(FooModel.self, method: .left, on: \FooModel.$field, .equal, .literal(""))) == #"SELECT LEFT JOIN "foos" ON "foos"."field" = ''"#)
            #expect(serialize(selectBuilder().join(FooModel.self, as: "bar", method: .left, on: \FooModel.$field, .equal, .literal(""))) == #"SELECT LEFT JOIN "foos" AS "bar" ON "foos"."field" = ''"#)
            #expect(serialize(selectBuilder().join(FooModel.self, on: .column("foo"), .equal, .literal(""))) == #"SELECT INNER JOIN "foos" ON "foo" = ''"#)
            #expect(serialize(selectBuilder().join(FooModel.self, as: "bar", on: .column("foo"), .equal, .literal(""))) == #"SELECT INNER JOIN "foos" AS "bar" ON "foo" = ''"#)
            #expect(serialize(selectBuilder().join(FooModel.self, method: .left, on: .column("foo"), .equal, .literal(""))) == #"SELECT LEFT JOIN "foos" ON "foo" = ''"#)
            #expect(serialize(selectBuilder().join(FooModel.self, as: "bar", method: .left, on: .column("foo"), .equal, .literal(""))) == #"SELECT LEFT JOIN "foos" AS "bar" ON "foo" = ''"#)
            #expect(serialize(selectBuilder().join(FooModel.self, on: .literal(true))) == #"SELECT INNER JOIN "foos" ON true"#)
            #expect(serialize(selectBuilder().join(FooModel.self, as: "bar", on: .literal(true))) == #"SELECT INNER JOIN "foos" AS "bar" ON true"#)
            #expect(serialize(selectBuilder().join(FooModel.self, method: .left, on: .literal(true))) == #"SELECT LEFT JOIN "foos" ON true"#)
            #expect(serialize(selectBuilder().join(FooModel.self, as: "bar", method: .left, on: .literal(true))) == #"SELECT LEFT JOIN "foos" AS "bar" ON true"#)

            #expect(serialize(selectBuilder().join(FooModel.self, using: .column("a"))) == #"SELECT INNER JOIN "foos" USING ("a")"#)
            #expect(serialize(selectBuilder().join(FooModel.self, as: "bar", using: .column("a"))) == #"SELECT INNER JOIN "foos" AS "bar" USING ("a")"#)
            #expect(serialize(selectBuilder().join(FooModel.self, method: .left, using: .column("a"))) == #"SELECT LEFT JOIN "foos" USING ("a")"#)
            #expect(serialize(selectBuilder().join(FooModel.self, as: "bar", method: .left, using: .column("a"))) == #"SELECT LEFT JOIN "foos" AS "bar" USING ("a")"#)

            #expect(serialize(selectBuilder().join(FooModel.self, using: [.column("a")])) == #"SELECT INNER JOIN "foos" USING ("a")"#)
            #expect(serialize(selectBuilder().join(FooModel.self, as: "bar", using: [.column("a")])) == #"SELECT INNER JOIN "foos" AS "bar" USING ("a")"#)
            #expect(serialize(selectBuilder().join(FooModel.self, method: .left, using: [.column("a")])) == #"SELECT LEFT JOIN "foos" USING ("a")"#)
            #expect(serialize(selectBuilder().join(FooModel.self, as: "bar", method: .left, using: [.column("a")])) == #"SELECT LEFT JOIN "foos" AS "bar" USING ("a")"#)
        }

        @Test
        func partialResultBuilderExtensions() {
            #expect(serialize(selectBuilder().orderBy(\FooModel.$field)) == #"SELECT ORDER BY "foos"."field" ASC"#)
            #expect(serialize(selectBuilder().orderBy(\FooModel.$field, .descending)) == #"SELECT ORDER BY "foos"."field" DESC"#)
        }

        @Test
        func predicateBuilderExtensions() {
            #expect(serialize(selectBuilder().where(.literal(true)).where(\FooModel.$field, .equal, 0)) == #"SELECT WHERE true AND "foos"."field" = $1"#)
            #expect(serialize(selectBuilder().where(.literal(true)).where(\FooModel.$field, .equal, \FooModel.$id)) == #"SELECT WHERE true AND "foos"."field" = "foos"."id""#)
            #expect(serialize(selectBuilder().where(.literal(true)).where(\FooModel.$field, .equal, .literal(0))) == #"SELECT WHERE true AND "foos"."field" = 0"#)
            #expect(serialize(selectBuilder().where(.literal(true)).where(\FooModel.$field, .AND(), .literal(0))) == #"SELECT WHERE true AND "foos"."field" & 0"#)
            #expect(serialize(selectBuilder().where(.literal(true)).where(\FooModel.$boolean)) == #"SELECT WHERE true AND "foos"."boolean""#)

            #expect(serialize(selectBuilder().orWhere(.literal(true)).orWhere(\FooModel.$field, .equal, 0)) == #"SELECT WHERE true OR "foos"."field" = $1"#)
            #expect(serialize(selectBuilder().orWhere(.literal(true)).orWhere(\FooModel.$field, .equal, \FooModel.$id)) == #"SELECT WHERE true OR "foos"."field" = "foos"."id""#)
            #expect(serialize(selectBuilder().orWhere(.literal(true)).orWhere(\FooModel.$field, .equal, .literal(0))) == #"SELECT WHERE true OR "foos"."field" = 0"#)
            #expect(serialize(selectBuilder().orWhere(.literal(true)).orWhere(\FooModel.$field, .AND(), .literal(0))) == #"SELECT WHERE true OR "foos"."field" & 0"#)
            #expect(serialize(selectBuilder().orWhere(.literal(true)).orWhere(\FooModel.$boolean)) == #"SELECT WHERE true OR "foos"."boolean""#)
        }

        @Test
        func returningBuilderExtensions() {
            #expect(serialize(MockSQLDatabase().insert(into: FooModel.self).returning(\FooModel.$field, \FooModel.$id)) == #"INSERT INTO "foos" () RETURNING "foos"."field", "foos"."id""#)
        }

        @Test
        func secondaryPredicateBuilderExtensions() {
            #expect(serialize(selectBuilder().having(.literal(true)).having(\FooModel.$field, .equal, 0)) == #"SELECT HAVING true AND "foos"."field" = $1"#)
            #expect(serialize(selectBuilder().having(.literal(true)).having(\FooModel.$field, .equal, \FooModel.$id)) == #"SELECT HAVING true AND "foos"."field" = "foos"."id""#)
            #expect(serialize(selectBuilder().having(.literal(true)).having(\FooModel.$field, .equal, .literal(0))) == #"SELECT HAVING true AND "foos"."field" = 0"#)
            #expect(serialize(selectBuilder().having(.literal(true)).having(\FooModel.$field, .AND(), .literal(0))) == #"SELECT HAVING true AND "foos"."field" & 0"#)
            #expect(serialize(selectBuilder().having(.literal(true)).having(\FooModel.$boolean)) == #"SELECT HAVING true AND "foos"."boolean""#)

            #expect(serialize(selectBuilder().orHaving(.literal(true)).orHaving(\FooModel.$field, .equal, 0)) == #"SELECT HAVING true OR "foos"."field" = $1"#)
            #expect(serialize(selectBuilder().orHaving(.literal(true)).orHaving(\FooModel.$field, .equal, \FooModel.$id)) == #"SELECT HAVING true OR "foos"."field" = "foos"."id""#)
            #expect(serialize(selectBuilder().orHaving(.literal(true)).orHaving(\FooModel.$field, .equal, .literal(0))) == #"SELECT HAVING true OR "foos"."field" = 0"#)
            #expect(serialize(selectBuilder().orHaving(.literal(true)).orHaving(\FooModel.$field, .AND(), .literal(0))) == #"SELECT HAVING true OR "foos"."field" & 0"#)
            #expect(serialize(selectBuilder().orHaving(.literal(true)).orHaving(\FooModel.$boolean)) == #"SELECT HAVING true OR "foos"."boolean""#)
        }

        @Test
        func subqueryClauseBuilderExtensions() {
            #expect(serialize(selectBuilder().from(FooModel.self)) == #"SELECT FROM "foos""#)
            #expect(serialize(selectBuilder().from(FooModel.self, as: "bar")) == #"SELECT FROM "foos" AS "bar""#)

            #expect(serialize(selectBuilder().groupBy(\FooModel.$field, \FooModel.$parent)) == #"SELECT GROUP BY "foos"."field", "foos"."parent_id""#)
        }

        @Test
        func unqualifiedColumnListBuilderExtensions() {
            #expect(serialize(selectBuilder().column(\FooModel.$field)) == #"SELECT "foos"."field""#)
            #expect(serialize(selectBuilder().columns(\FooModel.$field, \FooModel.$id)) == #"SELECT "foos"."field", "foos"."id""#)
        }

        @Test
        func updateBuilderExtensions() {
            #expect(serialize(MockSQLDatabase().update(FooModel.self)) == #"UPDATE "foos" SET"#)
        }
    }

    @Suite("Expressions")
    struct ExpressionsTests {
        @Test
        func aliasExpressionExtensions() {
            #expect(serialize(.alias(\FooModel.$field, as: "foo")) == #""foos"."field" AS "foo""#)
            #expect(serialize(.alias(\FooModel.$field, as: .identifier("foo"))) == #""foos"."field" AS "foo""#)
        }

        @Test
        func binaryExpressionExtensions() {
            #expect(serialize(.expr(\FooModel.$field, .equal, \FooModel.$id)) == #""foos"."field" = "foos"."id""#)
            #expect(serialize(.expr(\FooModel.$field, .equal, .literal(""))) == #""foos"."field" = ''"#)
        }

        @Test
        func columnExpressionExtensions() {
            #expect(serialize(.column(\FooModel.$field)) == #""foos"."field""#)
        }

        @Test
        func functionExpressionExtensions() {
            #expect(serialize(.length(\FooModel.$field)) == #"length("foos"."field")"#)
            #expect(serialize(.count(\FooModel.$field)) == #"count("foos"."field")"#)
            #expect(serialize(.count(\FooModel.$field, distinct: true)) == #"count(DISTINCT "foos"."field")"#)
            #expect(serialize(.sum(\FooModel.$field)) == #"sum("foos"."field")"#)
            #expect(serialize(.sum(\FooModel.$field, distinct: true)) == #"sum(DISTINCT "foos"."field")"#)
        }

        @Test
        func identifierExpressionExtensions() {
            #expect(serialize(.identifier(\FooModel.$field)) == #""field""#)
        }

        @Test
        func unaryExpressionExtensions() {
            #expect(serialize(.expr(.not, \FooModel.$field)) == #"NOT "foos"."field""#)
            #expect(serialize(.not(\FooModel.$field)) == #"NOT "foos"."field""#)
        }

        @Test
        func castExpression() {
            #expect(serialize(.cast(\FooModel.$field, to: "text")) == #"CAST("foos"."field" AS "text")"#)
            #expect(serialize(.cast(\FooModel.$field, to: .unsafeRaw("text"))) == #"CAST("foos"."field" AS text)"#)
        }
        
        @Test
        func lagExpression() {
            #expect(serialize(.lag(\FooModel.$field, offset: .literal(1))) == #"LAG("foos"."field") OVER (ORDER BY 1)"#)
            #expect(serialize(.lag(\FooModel.$field, offset: .literal(1), defaultValue: SQLLiteral.literal(0))) == #"LAG("foos"."field") OVER (ORDER BY 1) DEFAULT 0"#)
            
            #expect(serialize(.lag(\FooModel.$field, offset: \FooModel.$id)) == #"LAG("foos"."field") OVER (ORDER BY "foos"."id")"#)
            #expect(serialize(.lag(\FooModel.$field, offset: \FooModel.$id, defaultValue: SQLLiteral.literal(0))) == #"LAG("foos"."field") OVER (ORDER BY "foos"."id") DEFAULT 0"#)
            
            #expect(serialize(.lag(.column("field", table: "foos"), offset: \FooModel.$id)) == #"LAG("foos"."field") OVER (ORDER BY "foos"."id")"#)
            #expect(serialize(.lag(.column("field", table: "foos"), offset: \FooModel.$id, defaultValue: SQLLiteral.literal(0))) == #"LAG("foos"."field") OVER (ORDER BY "foos"."id") DEFAULT 0"#)
        }
    }
}

final class FooModel: FluentKit.Model, @unchecked Sendable {
    static let schema = "foos"
    @TaskLocal static var space: String? = nil

    enum Enumeration: String, Codable {
        case a, b
    }

    @ID(custom: .id)
    var id: Int?

    @Field(key: "field")
    var field: String

    @OptionalField(key: "optional_field")
    var optionalField: String?

    @Boolean(key: "boolean")
    var boolean: Bool

    @OptionalBoolean(key: "optional_boolean")
    var optionalBoolean: Bool?

    @Timestamp(key: "timestamp", on: .none)
    var timestamp: Date?

    @Enum(key: "enumeration")
    var enumeration: Enumeration

    @OptionalEnum(key: "optional_enumeration")
    var optionalEnumeration: Enumeration?

    @Parent(key: "parent_id")
    var parent: FooModel

    @OptionalParent(key: "optional_parent_id")
    var optionalParent: FooModel?

    init() {}
}

final class FooModelAlias: ModelAlias {
    static let name = "foo_alias"

    let model = FooModel()
}

#endif
