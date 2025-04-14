import FluentKit
import FluentKitExtras
import Foundation
import Logging
import NIOCore
import NIOEmbedded
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

        #expect(model.timestamp == fluentIso8601Date(fluentIso8601String(now)))
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
    func pointerProperties() async throws {
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

        // Everything from here down is just code coverage junk
        model.$bar.ref = "b"
        model.$bar.value = .init()
        #expect(model.bar.id == nil)
        #expect(model.$bar.description == model.$bar.name)
        await #expect(throws: Never.self) { try await model.$bar.get(reload: true, on: MockFluentDatabase([[["id": "1", "identifier": "b", "timestamp": fluentIso8601String(), "another": fluentIso8601String(), "recursive_baridentifier": "b", "blooey": "", "phooey": ""] as QuickOutput]])) }
        #expect(model.$bar.anyQueryableProperty === model.$bar.$ref)
        #expect(model.$bar.queryablePath == [.string("baridentifier")])
        #expect(model.$bar.queryableProperty === model.$bar.$ref)
        model.$optionalBar.ref = "b"
        model.$optionalBar.value = .some(nil)
        #expect(model.optionalBar == nil)
        #expect(model.$optionalBar.description == model.$optionalBar.name)
        await #expect(throws: Never.self) { try await model.$optionalBar.get(reload: true, on: MockFluentDatabase()) }
        #expect(model.$optionalBar.anyQueryableProperty === model.$optionalBar.$ref)
        #expect(model.$optionalBar.queryablePath == [.string("optional_baridentifier")])
        #expect(model.$optionalBar.queryableProperty === model.$optionalBar.$ref)

        #expect(throws: Never.self) { try JSONEncoder().encode(model) }
    }

    @Test
    func referenceProperties() async throws {
        let model = BarModel()
        model.$bazs.fromValue = "a"
        model.$optionalBaz.fromValue = "b"
        model.$recursiveBars.fromValue = "c"
        model.$optionalRecursiveBar.fromValue = "d"
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

        // Everything from here down is just code coverage junk
        model.$bazs.value = []
        model.$optionalBaz.value = .some(nil)
        model.$baz.value = .some(nil)
        model.$baz.fromValue = "a"
        model.$optionalBazs.value = []
        model.$optionalBazs.fromValue = "b"
        #expect(model.$bazs.fromValue == "a")
        #expect(model.bazs.isEmpty)
        #expect(model.$bazs.description == model.$bazs.name)
        #expect(model.$bazs.keys == [])
        #expect(model.$optionalBaz.fromValue == "b")
        #expect(model.optionalBaz == nil)
        #expect(model.$optionalBaz.description == model.$optionalBaz.name)
        #expect(model.$optionalBaz.keys == [])
        #expect(model.$optionalBazs.query(on: MockFluentDatabase()).query.description == #"query read bazs filters=[bazs[optional_baridentifier] = Optional("b")]"#)
        #expect(model.$baz.query(on: MockFluentDatabase()).query.description == #"query read bazs filters=[bazs[baridentifier] = "a"]"#)
        model.$bazs.input(to: QuickInput())
        model.$optionalBaz.input(to: QuickInput())
        #expect(throws: Never.self) { try model.$bazs.output(from: ["identifier": "a", "baridentifier": "a"] as QuickOutput) }
        #expect(throws: Never.self) { try model.$optionalBazs.output(from: ["identifier": "b", "optional_baridentifier": "b"] as QuickOutput) }
        #expect(throws: Never.self) { try model.$optionalBaz.output(from: ["identifier": "b", "optional_baridentifier": "b"] as QuickOutput) }
        #expect(throws: Never.self) { try model.$baz.output(from: ["identifier": "a", "baridentifier": "a"] as QuickOutput) }
        model.identifier = "a"
        model.$bar.ref = "b"
        model.timestamp = .init()
        model.another = .init()
        model.group.phooey = "phooey"
        model.group.blooey = "blooey"
        #expect(throws: Never.self) { try JSONEncoder().encode(model) }
        await #expect(throws: Never.self) { try await model.$bazs.get(reload: true, on: MockFluentDatabase()) }
        await #expect(throws: Never.self) { try await model.$bazs.create(BazModel(), on: MockFluentDatabase([[["id": "1"] as QuickOutput]])).get() }
        await #expect(throws: Never.self) { try await model.$optionalBazs.create(BazModel(), on: MockFluentDatabase([[["id": "1"] as QuickOutput]])).get() }
        await #expect(throws: Never.self) { try await model.$bazs.create([.init(), .init()], on: MockFluentDatabase([[["id": "1"] as QuickOutput, ["id": "2"] as QuickOutput]])).get() }
        await #expect(throws: Never.self) { try await model.$optionalBazs.create([.init(), .init()], on: MockFluentDatabase([[["id": "1"] as QuickOutput, ["id": "2"] as QuickOutput]])).get() }
        await #expect(throws: Never.self) { try await model.$optionalBaz.get(reload: true, on: MockFluentDatabase()) }
        await #expect(throws: Never.self) { try await model.$baz.get(reload: true, on: MockFluentDatabase()) }
        await #expect(throws: Never.self) { try await model.$optionalBaz.create(.init(), on: MockFluentDatabase([[["id": "1"] as QuickOutput]])).get() }
        await #expect(throws: Never.self) { try await model.$baz.create(.init(), on: MockFluentDatabase([[["id": "1"] as QuickOutput]])).get() }
        await #expect(throws: Never.self) { try await BarModel.query(on: MockFluentDatabase([
                [["id": "1", "identifier": "a", "timestamp": fluentIso8601String(), "another": fluentIso8601String(), "phooey": "", "blooey": "", "recursive_baridentifier": "b"] as QuickOutput],
                [["id": "2", "identifier": "b", "timestamp": fluentIso8601String(), "another": fluentIso8601String(), "phooey": "", "blooey": "", "recursive_baridentifier": "a"] as QuickOutput],
                [["id": "1", "baridentifier": "a", "optional_baridentifier": "a"] as QuickOutput],
                [["id": "1", "baridentifier": "a", "optional_baridentifier": "a"] as QuickOutput],
                [["id": "1", "baridentifier": "a", "optional_baridentifier": "a"] as QuickOutput],
                [["id": "1", "baridentifier": "a", "optional_baridentifier": "a"] as QuickOutput],
                [["id": "1", "identifier": "a", "timestamp": fluentIso8601String(), "another": fluentIso8601String(), "phooey": "", "blooey": "", "recursive_baridentifier": "a"] as QuickOutput],
                [["id": "1", "identifier": "a", "timestamp": fluentIso8601String(), "another": fluentIso8601String(), "phooey": "", "blooey": "", "recursive_baridentifier": "a", "optional_recursive_baridentifier": "a"] as QuickOutput],
                [["id": "1", "identifier": "a", "timestamp": fluentIso8601String(), "another": fluentIso8601String(), "phooey": "", "blooey": "", "recursive_baridentifier": "a", "optional_recursive_baridentifier": "a"] as QuickOutput],
                [["id": "1", "identifier": "a", "timestamp": fluentIso8601String(), "another": fluentIso8601String(), "phooey": "", "blooey": "", "recursive_baridentifier": "a"] as QuickOutput],
                [["id": "2", "identifier": "b", "timestamp": fluentIso8601String(), "another": fluentIso8601String(), "phooey": "", "blooey": "", "recursive_baridentifier": "a"] as QuickOutput],
            ]))
            .withDeleted()
            .with(\.$bar).with(\.$optionalBar).with(\.$bazs).with(\.$optionalBazs).with(\.$optionalBaz).with(\.$baz).with(\.$recursiveBars).with(\.$optionalRecursiveBars).with(\.$optionalRecursiveBar).with(\.$recursiveBar)
            .with(\.$bar, withDeleted: true).with(\.$optionalBar, withDeleted: true).with(\.$bazs, withDeleted: true).with(\.$optionalBazs, withDeleted: true).with(\.$optionalBaz, withDeleted: true).with(\.$baz, withDeleted: true).with(\.$recursiveBars, withDeleted: true).with(\.$optionalRecursiveBars, withDeleted: true).with(\.$optionalRecursiveBar, withDeleted: true).with(\.$recursiveBar, withDeleted: true)
            .all()
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

    @References(for: \.$optionalBar)
    var optionalBazs: [BazModel]

    @OptionalReference(for: \.$optionalBar)
    var optionalBaz: BazModel?

    @OptionalReference(for: \.$bar)
    var baz: BazModel?

    @References(forRecursive: \.$bar, referencedBy: \.$identifier)
    var recursiveBars: [BarModel]

    @References(forRecursive: \.$optionalBar, referencedBy: \.$identifier)
    var optionalRecursiveBars: [BarModel]

    @OptionalReference(forRecursive: \.$optionalBar, referencedBy: \.$baridentifier)
    var optionalRecursiveBar: BarModel?

    @OptionalReference(forRecursive: \.$bar, referencedBy: \.$baridentifier)
    var recursiveBar: BarModel?

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

final class MockFluentDatabase: Database {
    struct MockConfiguration: DatabaseConfiguration {
        var middleware: [any AnyModelMiddleware] = []
        func makeDriver(for databases: Databases) -> any DatabaseDriver { fatalError() }
    }

    let context: DatabaseContext = .init(
        configuration: MockConfiguration(),
        logger: .init(label: "mockdb", factory: ModifiedStreamLogHandler.standardOutput(label:)),
        eventLoop: EmbeddedEventLoop()
    )
    let inTransaction = false

    nonisolated(unsafe) var outputs: [[any DatabaseOutput]]

    init(_ outputs: [[any DatabaseOutput]] = []) {
        self.outputs = outputs
    }

    func execute(query: DatabaseQuery, onOutput: @escaping @Sendable (any DatabaseOutput) -> ()) -> EventLoopFuture<Void> {
        if !self.outputs.isEmpty {
            for output in self.outputs.removeFirst() { onOutput(output) }
        }
        return self.eventLoop.makeSucceededVoidFuture()
    }
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
        switch type {
        case is String.Type:
            guard let rawValue = self.content[key.description] else { throw FluentError.missingField(name: key.description) }
            return rawValue as! T
        case is String?.Type:
            return self.content[key.description] as! T
        case is Int.Type:
            guard let rawValue = self.content[key.description] else { throw FluentError.missingField(name: key.description) }
            guard let result = Int(rawValue) else { throw FluentError.invalidField(name: key.description, valueType: type, error: CancellationError()) }
            return result as! T
        case is Int?.Type:
            guard let rawValue = self.content[key.description] else { return Int?.none as! T }
            guard let result = Int(rawValue) else { throw FluentError.invalidField(name: key.description, valueType: type, error: CancellationError()) }
            return result as! T
        case is Date.Type:
            guard let rawValue = self.content[key.description] else { throw FluentError.missingField(name: key.description) }
            guard let result = TimestampFormatFactory<ISO8601TimestampFormat>.iso8601.makeFormat().parse(rawValue) else { throw FluentError.invalidField(name: key.description, valueType: type, error: CancellationError()) }
            return result as! T
        case is Date?.Type:
            guard let rawValue = self.content[key.description] else { return Date?.none as! T }
            guard let result = TimestampFormatFactory<ISO8601TimestampFormat>.iso8601.makeFormat().parse(rawValue) else { throw FluentError.invalidField(name: key.description, valueType: type, error: CancellationError()) }
            return result as! T
        default:
            throw FluentError.invalidField(name: key.description, valueType: type, error: CancellationError())
        }
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

func fluentIso8601Date(_ str: String) -> Date? {
    TimestampFormatFactory<ISO8601TimestampFormat>.iso8601.makeFormat().parse(str)
}

func fluentIso8601String(_ date: Date = .init()) -> String {
    TimestampFormatFactory<ISO8601TimestampFormat>.iso8601.makeFormat().serialize(date)!
}

public struct ModifiedStreamLogHandler: LogHandler {
    public static func standardOutput(label: String) -> Self { .init(label: label) }
    private let label: String
    public var logLevel: Logger.Level = .info, metadataProvider = LoggingSystem.metadataProvider, metadata = Logger.Metadata()
    public subscript(metadataKey key: String) -> Logger.Metadata.Value? { get { self.metadata[key] } set { self.metadata[key] = newValue } }
    internal init(label: String) { self.label = label }
    public func log(level: Logger.Level, message: Logger.Message, metadata explicitMetadata: Logger.Metadata?, source: String, file: String, function: String, line: UInt) {
        let prettyMetadata = self.prettify(Self.prepareMetadata(base: self.metadata, provider: self.metadataProvider, explicit: explicitMetadata))
        print("\(self.timestamp()) \(level) \(self.label) :\(prettyMetadata.map { " \($0)" } ?? "") [\(source)] \(message)")
    }
    internal static func prepareMetadata(base: Logger.Metadata, provider: Logger.MetadataProvider?, explicit: Logger.Metadata?) -> Logger.Metadata {
        var metadata = base
        if let provided = provider?.get(), !provided.isEmpty { metadata.merge(provided, uniquingKeysWith: { $1 }) }
        if let explicit = explicit, !explicit.isEmpty { metadata.merge(explicit, uniquingKeysWith: { $1 }) }
        return metadata
    }
    private func prettify(_ metadata: Logger.Metadata) -> String? {
        metadata.isEmpty ? nil : metadata.lazy.sorted { $0.0 < $1.0 }.map { "\($0)=\($1.prettyDescription)" }.joined(separator: " ")
    }
    private func timestamp() -> String {
        .init(unsafeUninitializedCapacity: 255) { buffer in
            var timestamp = time(nil)
            guard let localTime = localtime(&timestamp) else { return buffer.initialize(fromContentsOf: "<unknown>".utf8) }
            return strftime(buffer.baseAddress!, buffer.count, "%Y-%m-%dT%H:%M:%S%z", localTime)
        }
    }
}
extension Logger.MetadataValue {
    public var prettyDescription: String {
        switch self {
        case .dictionary(let dict): "[\(dict.mapValues(\.prettyDescription).lazy.sorted { $0.0 < $1.0 }.map { "\($0): \($1)" }.joined(separator: ", "))]"
        case .array(let list): "[\(list.map(\.prettyDescription).joined(separator: ", "))]"
        case .string(let str): #""\#(str)""#
        case .stringConvertible(let repr):
            switch repr {
            case let repr as Bool: "\(repr)"
            case let repr as any FixedWidthInteger: "\(repr)"
            case let repr as any BinaryFloatingPoint: "\(repr)"
            default: #""\#(repr.description)""#
            }
        }
    }
}
