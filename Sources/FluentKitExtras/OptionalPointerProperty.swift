import FluentKit
import NIOCore
import struct SQLKit.SomeCodingKey

extension Model {
    public typealias OptionalPointer<To, ToProp> = OptionalPointerProperty<Self, To, ToProp>
        where
            To: FluentKit.Model,
            ToProp: QueryableProperty, ToProp.Model == To, ToProp.Value: Hashable
}

// MARK: Type

/// A Fluent property wrapper which represents the _referencing_ side of a `NULL`-able many-to-one or one-to-one
/// relation between two models.
///
/// This property wrapper represents a single column in the database table corresponding to its containing model;
/// that column contains the value which references the other side of the relation.
///
/// This property wrapper differs from Fluent's built in `OptionalParentProperty` and `OptionalCompositeParentProperty`
/// wrappers in that it does _not_ assume that the referencing value is the primary key of the other side of the relation.
/// Additionally, the underlying field is referred to in Swift as `$ref` rather than `$id`. Use of this property to refer
/// to another model's `$id` property is valid but otherwise identical to using `OptionalParentProperty`, and the latter
/// is strongly recommended in such cases.
///
/// The field referenced by this property wrapper may be any queryable property of the referenced model. It may not
/// reference non-queryable properties such as `@Children` or `@Group`. It _may_ be used to reference another relation
/// by chaining the key path, e.g. `@OptionalPointer(key: "...", pointsTo: \.$foo.$ref)`.
@propertyWrapper
public final class OptionalPointerProperty<From, To, ToProp>: @unchecked Sendable
    where
        From: FluentKit.Model, To: FluentKit.Model,
        ToProp: QueryableProperty, ToProp.Model == To, ToProp.Value: Hashable
{
    @OptionalFieldProperty<From, ToProp.Value>
    public var ref: ToProp.Value?

    public var wrappedValue: To? {
        get { self.value ?? nil }
        set { fatalError("use $ prefix to access \(self.name)") }
    }

    public var projectedValue: OptionalPointerProperty<From, To, ToProp> {
        self
    }

    let toKeypath: KeyPath<To, ToProp>
    public var value: To??

    public init(key: FieldKey, pointsTo relatedKeypath: KeyPath<To, ToProp>) {
        self._ref = .init(key: key)
        self.toKeypath = relatedKeypath
    }

    public func query(on database: any Database) -> QueryBuilder<To> {
        let builder = To.query(on: database)
        if let ref = self.ref {
            builder.filter(self.toKeypath == ref)
        } else {
            builder.filter(self.toKeypath == .null)
        }
        return builder
    }
}

extension OptionalPointerProperty: CustomStringConvertible {
    public var description: String {
        self.name
    }
}

// MARK: Relation

extension OptionalPointerProperty: Relation {
    public var name: String {
        "OptionalPointer<\(From.self), \(To.self), \(To()[keyPath: self.toKeypath].path[0].description)>(key: \(self.$ref.key))"
    }

    public func load(on database: any Database) -> EventLoopFuture<Void> {
        self.query(on: database).first().map {
            self.value = $0
        }
    }
}

// MARK: Property

extension OptionalPointerProperty: AnyProperty { }

extension OptionalPointerProperty: Property {
    public typealias Model = From
    public typealias Value = To?
}

// MARK: Query-addressable

extension OptionalPointerProperty: AnyQueryAddressableProperty {
    public var anyQueryableProperty: any AnyQueryableProperty {
        self.$ref.anyQueryableProperty
    }

    public var queryablePath: [FieldKey] {
        self.$ref.queryablePath
    }
}

extension OptionalPointerProperty: QueryAddressableProperty {
    public var queryableProperty: OptionalFieldProperty<From, ToProp.Value> {
        self.$ref.queryableProperty
    }
}

// MARK: Database

extension OptionalPointerProperty: AnyDatabaseProperty {
    public var keys: [FieldKey] {
        self.$ref.keys
    }

    public func input(to input: any DatabaseInput) {
        self.$ref.input(to: input)
    }

    public func output(from output: any DatabaseOutput) throws {
        try self.$ref.output(from: output)
    }
}

extension OptionalPointerProperty: AnyCodableProperty {
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()

        if case .some(.some(let pointer)) = self.value {
            try container.encode(pointer)
        } else {
            try container.encode([
                "ref": self.ref
            ])
        }
    }

    public func decode(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: SQLKit.SomeCodingKey.self)
        try self.$ref.decode(from: container.superDecoder(forKey: .init(stringValue: "ref")))
    }
}

// MARK: Eager Loadable

extension OptionalPointerProperty: EagerLoadable {
    public static func eagerLoad<Builder>(
        _ relationKey: KeyPath<From, OptionalPointerProperty<From, To, ToProp>>,
        to builder: Builder
    )
        where Builder: EagerLoadBuilder, From == Builder.Model
    {
        self.eagerLoad(relationKey, withDeleted: false, to: builder)
    }

    public static func eagerLoad<Builder>(
        _ relationKey: KeyPath<From, From.OptionalPointer<To, ToProp>>,
        withDeleted: Bool,
        to builder: Builder
    )
        where Builder: EagerLoadBuilder, Builder.Model == From
    {
        let loader = OptionalPointerEagerLoader(relationKey: relationKey, withDeleted: withDeleted)
        builder.add(loader: loader)
    }


    public static func eagerLoad<Loader, Builder>(
        _ loader: Loader,
        through: KeyPath<From, From.OptionalPointer<To, ToProp>>,
        to builder: Builder
    ) where
        Loader: EagerLoader, Loader.Model == To,
        Builder: EagerLoadBuilder, Builder.Model == From
    {
        let loader = ThroughOptionalPointerEagerLoader(relationKey: through, loader: loader)
        builder.add(loader: loader)
    }
}

private struct OptionalPointerEagerLoader<From, To, ToProp>: EagerLoader
    where
        From: FluentKit.Model, To: FluentKit.Model,
        ToProp: FluentKit.QueryableProperty, ToProp.Model == To, ToProp.Value: Hashable
{
    // Needed because the extension that normally adds this inside FluentKit is not public.
    func anyRun(models: [any AnyModel], on database: any Database) -> EventLoopFuture<Void> {
        self.run(models: models.map { $0 as! Model }, on: database)
    }

    let relationKey: KeyPath<From, OptionalPointerProperty<From, To, ToProp>>
    let withDeleted: Bool

    func run(models: [From], on database: any Database) -> EventLoopFuture<Void> {
        let toKeypath = From()[keyPath: self.relationKey].toKeypath
        var _sets = Dictionary(grouping: models, by: { $0[keyPath: self.relationKey].ref })
        let nilPointerModels = _sets.removeValue(forKey: nil) ?? []
        let sets = _sets
        if sets.isEmpty {
            // Fetching "To" objects is unnecessary when no models have an id for "To".
            nilPointerModels.forEach { $0[keyPath: self.relationKey].value = .some(.none) }
            return database.eventLoop.makeSucceededVoidFuture()
        }
        let builder = To.query(on: database).filter(toKeypath ~~ Set(sets.keys.compactMap { $0 }))
        if self.withDeleted {
            builder.withDeleted()
        }
        return builder.all().flatMapThrowing {
            let pointers = Dictionary(uniqueKeysWithValues: $0.map { ($0[keyPath: toKeypath].value!, $0) })

            for (pointerRef, models) in sets {
                guard let pointer = pointers[pointerRef!] else {
                    database.logger.debug(
                        "Missing pointer-referred model in eager-load lookup results.",
                        metadata: ["pointer": .string("\(To.self)"), "ref": .string("\(pointerRef!)")]
                    )
                    throw FluentError.missingParent(
                        from: "\(From.self)",
                        to: "\(To.self)",
                        key: From.path(for: self.relationKey.appending(path: \.$ref))[0].description,
                        id: "\(pointerRef!)"
                    )
                }
                models.forEach { $0[keyPath: self.relationKey].value = .some(.some(pointer)) }
            }
            nilPointerModels.forEach { $0[keyPath: self.relationKey].value = .some(.none) }
        }
    }
}

private struct ThroughOptionalPointerEagerLoader<From, Through, ThroughProp, Loader>: EagerLoader
    where
        From: FluentKit.Model,
        Loader: EagerLoader, Loader.Model == Through,
        ThroughProp: QueryableProperty, ThroughProp.Model == Through, ThroughProp.Value: Hashable
{
    // Needed because the extension that normally adds this inside FluentKit is not public.
    func anyRun(models: [any AnyModel], on database: any Database) -> EventLoopFuture<Void> {
        self.run(models: models.map { $0 as! Model }, on: database)
    }

    let relationKey: KeyPath<From, From.OptionalPointer<Through, ThroughProp>>
    let loader: Loader

    func run(models: [From], on database: any Database) -> EventLoopFuture<Void> {
        self.loader.run(models: models.compactMap { $0[keyPath: self.relationKey].value! }, on: database)
    }
}

extension OptionalPointerProperty: AliasableProperty {}
