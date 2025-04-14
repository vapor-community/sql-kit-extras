import FluentKit
import FluentKitExtras
import Foundation
import NIOCore
import Testing

@Suite("FluentKit Extras")
struct FluentKitExtrasTests {
    @Test
    func aliasProperty() {
        let model = BarModel()

        model.identifier = "foo"
        #expect(model.baridentifier == "foo")
        model.baridentifier = "bar"
        #expect(model.identifier == "bar")

        model.group.phooey = "whooey"
        #expect(model.phooey == "whooey")
        model.phooey = "plooey"
        #expect(model.group.phooey == "plooey")
        model.blooey = "glooey"
        #expect(model.group.blooey == "glooey")
        model.group.blooey = "flooey"
        #expect(model.blooey == "flooey")
    }

    @Test
    func flatGroupProperty() {
        let model = BarModel()
        model.group = .init()

        #expect(model.$group.description == "@BarModel.FlatGroup<BopFields>()")
        #expect(model.$group.keys == [.string("phooey"), .string("blooey")])

        model.group.phooey = "phooey"
        model.group.blooey = "blooey"

        let input = QuickInput()
        model.$group.input(to: input)

        // The intent here is to test that @FlatGroup keeps its specified field keys intact, without @Group's prefixing.
        #expect(input.content == ["phooey": "phooey", "blooey": "blooey"])

        #expect(throws: Never.self) { try model.$group.output(from: ["phooey": "phooey", "blooey": "blooey"] as QuickOutput) }

        model.identifier = "a"
        model.$bar.ref = "b"
        model.timestamp = .init()
        model.another = .init()
        #expect(throws: Never.self) { try JSONEncoder().encode(model) }
        #expect(throws: Never.self) { _ = try JSONDecoder().decode(BarModel.self, from: JSONEncoder().encode(model)) }
    }

    @Test
    func requiredTimestampProperty() {
        let model = BarModel()
        let now = Date()
        model.timestamp = now

        #expect(model.timestamp == TimestampFormatFactory<ISO8601TimestampFormat>.iso8601.makeFormat().parse(TimestampFormatFactory<ISO8601TimestampFormat>.iso8601.makeFormat().serialize(now)!))
        #expect(model.$timestamp.description == "@BarModel.RequiredTimestamp(key: timestamp)")
        #expect(model.$timestamp.path == [.string("timestamp")])
        #expect(model.$timestamp.keys == [.string("timestamp")])
        model.$timestamp.input(to: QuickInput())
        #expect(throws: Never.self) { try model.$timestamp.output(from: ["timestamp": "\(now)"] as QuickOutput) }
        #expect(model.$timestamp.anyQueryableProperty === model.$timestamp)
        #expect(model.$timestamp.queryablePath == [.string("timestamp")])
        #expect(model.$timestamp.queryableProperty === model.$timestamp)
    }

    @Test
    func pointerProperties() throws {
        let model = BazModel()
        model.$bar.ref = "a"
        model.$optionalBar.ref = "b"
        let query1 = model.$bar.query(on: MockFluentDatabase())
        let filter1 = try #require(query1.query.filters.first)
        switch filter1 {
        case .value(.extendedPath(let path, let schema, let space), .equality(let inverse), .bind(let bind)):
            #expect(path == [.string("identifier")])
            #expect(schema == "bars")
            #expect(space == nil)
            #expect(!inverse)
            #expect(String(describing: bind) == "a")
        case let filter:
            Issue.record("Incorrect filter for model.$bar.query(on:): \(String(describing: filter))")
        }
        let query2 = model.$optionalBar.query(on: MockFluentDatabase())
        let filter2 = try #require(query2.query.filters.first)
        switch filter2 {
        case .value(.extendedPath(let path, let schema, let space), .equality(let inverse), .bind(let bind)):
            #expect(path == [.string("identifier")])
            #expect(schema == "bars")
            #expect(space == nil)
            #expect(!inverse)
            #expect(String(describing: bind) == "b")
        case let filter:
            Issue.record("Incorrect filter for model.$bar.query(on:): \(String(describing: filter))")
        }
    }

    @Test
    func referenceProperties() throws {
        let model = BarModel()
        #expect(throws: Never.self) { try model.$bazs.output(from: ["identifier": "a"] as QuickOutput) }
        #expect(throws: Never.self) { try model.$optionalBaz.output(from: ["identifier": "b"] as QuickOutput) }
        #expect(throws: Never.self) { try model.$recursiveBars.output(from: ["identifier": "c"] as QuickOutput) }
        #expect(throws: Never.self) { try model.$optionalRecursiveBar.output(from: ["identifier": "d"] as QuickOutput) }
        let query1 = model.$bazs.query(on: MockFluentDatabase()), filter1 = try #require(query1.query.filters.first)
        switch filter1 {
        case .value(.extendedPath(let path, "bazs", nil), .equality(false), .bind(let bind)):
            #expect(path == [.string("baridentifier")])
            #expect(String(describing: bind) == "a")
        case let filter: Issue.record("Incorrect filter for model.$bazs.query(on:): \(String(describing: filter))")
        }
        let query2 = model.$optionalBaz.query(on: MockFluentDatabase()), filter2 = try #require(query2.query.filters.first)
        switch filter2 {
        case .value(.extendedPath(let path, "bazs", nil), .equality(false), .bind(let bind)):
            #expect(path == [.string("optional_baridentifier")])
            #expect(String(describing: bind) == #"Optional("b")"#)
        case let filter: Issue.record("Incorrect filter for model.$optionalBaz.query(on:): \(String(describing: filter))")
        }
        let query3 = model.$recursiveBars.query(on: MockFluentDatabase()), filter3 = try #require(query3.query.filters.first)
        switch filter3 {
        case .value(.extendedPath(let path, "bars", nil), .equality(false), .bind(let bind)):
            #expect(path == [.string("recursive_baridentifier")])
            #expect(String(describing: bind) == "c")
        case let filter: Issue.record("Incorrect filter for model.$recursiveBars.query(on:): \(String(describing: filter))")
        }
        let query4 = model.$optionalRecursiveBar.query(on: MockFluentDatabase()), filter4 = try #require(query4.query.filters.first)
        switch filter4 {
        case .value(.extendedPath(let path, "bars", nil), .equality(false), .bind(let bind)):
            #expect(path == [.string("optional_recursive_baridentifier")])
            #expect(String(describing: bind) == #"Optional("d")"#)
        case let filter: Issue.record("Incorrect filter for model.$optionalRecursiveBar.query(on:): \(String(describing: filter))")
        }
    }
}

final class BarModel: FluentKit.Model, @unchecked Sendable {
    static let schema = "bars"

    @ID(custom: .id)
    var id: Int?

    @Field(key: "identifier")
    var identifier: String

    @Alias(of: \.$identifier)
    var baridentifier

    @RequiredTimestamp(key: "timestamp", format: .iso8601)
    var timestamp: Date

    @RequiredTimestamp(key: "another")
    var another: Date

    @FlatGroup
    var group: BopFields

    @Alias(of: \.$group.$phooey)
    var phooey

    @Alias(of: \.$group.$blooey)
    var blooey

    @OptionalField(key: "miscellaneous")
    var miscellaneous: String?

    @Pointer(key: "recursive_baridentifier", pointsTo: \.$identifier)
    var bar: BarModel

    @OptionalPointer(key: "optional_recursive_baridentifier", pointsTo: \.$baridentifier)
    var optionalBar: BarModel?

    @References(for: \.$bar)
    var bazs: [BazModel]

    @OptionalReference(for: \.$optionalBar)
    var optionalBaz: BazModel?

    @References(forRecursive: \.$bar, referencedBy: \.$identifier)
    var recursiveBars: [BarModel]

    @OptionalReference(forRecursive: \.$optionalBar, referencedBy: \.$baridentifier)
    var optionalRecursiveBar: BarModel?

    init() {}
}

final class BazModel: FluentKit.Model, @unchecked Sendable {
    static let schema = "bazs"

    @ID(custom: .id)
    var id: Int?

    @Pointer(key: "baridentifier", pointsTo: \.$identifier)
    var bar: BarModel

    @OptionalPointer(key: "optional_baridentifier", pointsTo: \.$baridentifier)
    var optionalBar: BarModel?

    init() {}
}

final class BopFields: FluentKit.Fields, @unchecked Sendable {
    @Field(key: "phooey")
    var phooey: String

    @Field(key: "blooey")
    var blooey: String

    init() {}
}

struct MockFluentDatabase: Database {
    struct MockConfiguration: DatabaseConfiguration {
        var middleware: [any AnyModelMiddleware] = []
        func makeDriver(for databases: Databases) -> any DatabaseDriver { fatalError() }
    }

    let context: DatabaseContext = .init(
        configuration: MockConfiguration(),
        logger: .init(label: "", factory: SwiftLogNoOpLogHandler.init(_:)),
        eventLoop: NIOSingletons.posixEventLoopGroup.any()
    )
    let inTransaction = false

    func execute(query: DatabaseQuery, onOutput: @escaping @Sendable (any DatabaseOutput) -> ()) -> EventLoopFuture<Void> { self.eventLoop.makeSucceededVoidFuture() }
    func execute(schema: DatabaseSchema) -> EventLoopFuture<Void> { self.eventLoop.makeSucceededVoidFuture() }
    func execute(enum: DatabaseEnum) -> EventLoopFuture<Void> { self.eventLoop.makeSucceededVoidFuture() }
    func transaction<T>(_ closure: @escaping @Sendable (any Database) -> EventLoopFuture<T>) -> EventLoopFuture<T> { closure(self) }
    func withConnection<T>(_ closure: @escaping @Sendable (any Database) -> EventLoopFuture<T>) -> EventLoopFuture<T> { closure(self) }
}

final class QuickOutput: DatabaseOutput, ExpressibleByDictionaryLiteral {
    let content: [String: String]
    init(_ content: [String: String]) { self.content = content }
    convenience init(dictionaryLiteral elements: (String, String)...) { self.init(.init(elements, uniquingKeysWith: { $1 })) }
    var description: String { self.content.description }
    func schema(_ schema: String) -> any DatabaseOutput { self }
    func contains(_ key: FieldKey) -> Bool { self.content[key.description] != nil }
    func decodeNil(_ key: FieldKey) throws -> Bool { self.content[key.description] == nil }
    func decode<T: Decodable>(_ key: FieldKey, as type: T.Type) throws -> T {
        guard let value = self.content[key.description] as? T else { throw FluentError.missingField(name: key.description) }
        return value
    }
}

final class QuickInput: DatabaseInput {
    var content: [String: String] = [:]

    func set(_ value: DatabaseQuery.Value, at key: FieldKey) {
        let str = switch value {
        case .bind(let value): String(describing: value)
        case .enumCase(let string): string
        default: ""
        }
        self.content[key.description] = str
    }
}
