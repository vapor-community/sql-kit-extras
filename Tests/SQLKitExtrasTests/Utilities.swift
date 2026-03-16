import Logging
import NIOCore
import NIOPosix
import SQLKit

struct TestingSQLDialect: SQLDialect {
    let name: String

    init(_ name: String = "testing") {
        self.name = name
    }

    var identifierQuote: any SQLExpression { SQLRaw("\"") }
    var supportsAutoIncrement: Bool { false }
    var autoIncrementClause: any SQLExpression { SQLRaw("") }
    var supportsReturning: Bool { true }
    var upsertSyntax: SQLUpsertSyntax { .standard }
    var triggerSyntax: SQLTriggerSyntax { .init(create: .init(), drop: [.supportsTableName]) }
    func bindPlaceholder(at position: Int) -> any SQLExpression { SQLRaw("$\(position)") }
    func literalBoolean(_ value: Bool) -> any SQLExpression { SQLRaw("\(value)") }
}

struct MockSQLDatabase: SQLDatabase {
    let logger: Logger = .init(label: "", factory: SwiftLogNoOpLogHandler.init(_:))
    let eventLoop: any EventLoop = NIOSingletons.posixEventLoopGroup.any()
    let dialect: any SQLDialect

    let resultSet: [ThinSQLRow]

    init(resultSet: [ThinSQLRow] = [], dialect: String = "testing") {
        self.resultSet = resultSet
        self.dialect = TestingSQLDialect(dialect)
    }

    func execute(sql _: any SQLExpression, _ onRow: @escaping @Sendable (any SQLRow) -> ()) -> EventLoopFuture<Void> {
        self.resultSet.forEach(onRow)
        return self.eventLoop.makeSucceededVoidFuture()
    }

    func execute(sql _: any SQLExpression, _ onRow: @escaping (any SQLRow) -> ()) async throws {
        self.resultSet.forEach(onRow)
    }
}

struct ThinSQLRow: SQLRow, ExpressibleByDictionaryLiteral {
    let content: [String: any Sendable]

    init(_ content: [String: any Sendable]) { self.content = content }
    init(dictionaryLiteral elements: (String, any Sendable)...) { self.init(.init(elements, uniquingKeysWith: { $1 })) }

    var allColumns: [String] { Array(self.content.keys) }
    func contains(column: String) -> Bool { self.content.keys.contains(column) }
    func decodeNil(column: String) throws -> Bool { !self.contains(column: column) || (self.content[column]! as? SQLLiteral).map(serialize(_:)) == "NULL" }
    func decode<D: Decodable>(column: String, as: D.Type) throws -> D {
        guard let result = self.content[column].flatMap({ $0 as? D }) else {
            throw CancellationError()
        }
        return result
    }
}

func serialize(_ expr: some SQLExpression) -> String {
    MockSQLDatabase().serialize(expr).sql
}

func serialize(_ builder: some SQLQueryBuilder) -> String {
    builder.database.serialize(builder.query).sql
}

func selectBuilder() -> SQLSelectBuilder {
    MockSQLDatabase().select()
}
