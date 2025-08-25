import FluentKit
import NIOCore

extension Model {
    public typealias OptionalReference<To, FromProp> = OptionalReferenceProperty<Self, To, FromProp>
        where
            To: FluentKit.Model,
            FromProp: FluentKit.QueryableProperty & _SQLKitExtrasSendableMetatype, FromProp.Model == Self, FromProp.Value: Hashable
}

// MARK: Type

/// A Fluent property wrapper which represents the _referenced_ side of a one-to-one relation between two models.
///
/// This property wrapper does not represent any column in a database table; it creates a "virtual" property suitable
/// for accessing the model (if any) on the far side of the relation.
///
/// This property wrapper differs from Fluent's built in `OptionalChildProperty` and `CompositeOptionalChildProperty`
/// wrappers in that it is used for relations provided by ``PointerProperty`` and ``OptionalPointerProperty`` properties
/// on the other side of the relation, rather than by `ParentProperty` or `OptionalParentProperty`. It can _not_ be used
/// to refer to `ParentProperty` relations.
@propertyWrapper
public final class OptionalReferenceProperty<From, To, FromProp>: @unchecked Sendable
    where From: FluentKit.Model, To: FluentKit.Model,
    FromProp: FluentKit.QueryableProperty & _SQLKitExtrasSendableMetatype, FromProp.Model == From, FromProp.Value: Hashable
{
    public let parentKey: RelationPointerKey<From, To, FromProp>
    let fromKeypath: KeyPath<From, FromProp>
    var idValue: FromProp.Value?

    public var value: To??

    public convenience init(for parent: KeyPath<To, To.Pointer<From, FromProp>>) {
        self.init(for: .required(parent), referencedBy: To()[keyPath: parent].toKeypath)
    }

    /// Use this initializer when an ``OptionalReferenceProperty`` refers to a ``PointerProperty`` on the same model which
    /// contains it; to avoid an infinite recursion in the model's initializer, the key path provided to the `pointsTo` parameter
    /// of the pointer property must be repeated here.
    public convenience init(
        forRecursive parent: KeyPath<To, To.Pointer<From, FromProp>>,
        referencedBy relatedKeypath: KeyPath<From, FromProp>
    )
        where From == To
    {
        self.init(for: .required(parent), referencedBy: relatedKeypath)
    }

    public convenience init(for optionalParent: KeyPath<To, To.OptionalPointer<From, FromProp>>) {
        self.init(for: .optional(optionalParent), referencedBy: To()[keyPath: optionalParent].toKeypath)
    }
    
    /// Use this initializer when an ``OptionalReferenceProperty`` refers to an ``OptionalPointerProperty`` on the same model
    /// which contains it; to avoid an infinite recursion in the model's initializer, the key path provided to the `pointsTo`
    /// parameter of the pointer property must be repeated here.
    public convenience init(
        forRecursive parent: KeyPath<To, To.OptionalPointer<From, FromProp>>,
        referencedBy relatedKeypath: KeyPath<From, FromProp>
    )
        where From == To
    {
        self.init(for: .optional(parent), referencedBy: relatedKeypath)
    }

    private init(
        for parentKey: RelationPointerKey<From, To, FromProp>,
        referencedBy relatedKeypath: KeyPath<From, FromProp>
    ) {
        self.parentKey = parentKey
        self.fromKeypath = relatedKeypath
    }

    public var wrappedValue: To? {
        get {
            guard let value = self.value else {
                fatalError("Reference relation not eager loaded, use $ prefix to access: \(name)")
            }
            return value
        }
        set {
            fatalError("Reference relation \(self.name) is get-only.")
        }
    }

    public var projectedValue: OptionalReferenceProperty<From, To, FromProp> {
        self
    }
    
    public var fromValue: FromProp.Value? {
        get { self.idValue }
        set { self.idValue = newValue }
    }

    public func query(on database: any Database) -> QueryBuilder<To> {
        guard let id = self.idValue else {
            fatalError("Cannot query reference relation \(self.name) from unsaved model.")
        }
        let builder = To.query(on: database)
        switch self.parentKey {
        case .optional(let optional):
            builder.filter(optional.appending(path: \.$ref) == id)
        case .required(let required):
            builder.filter(required.appending(path: \.$ref) == id)
        }
        return builder
    }

    public func create(_ to: To, on database: any Database) -> EventLoopFuture<Void> {
        guard let id = self.idValue else {
            fatalError("Cannot save reference in \(self.name) to unsaved model in.")
        }
        switch self.parentKey {
        case .required(let keyPath):
            to[keyPath: keyPath].ref = id
        case .optional(let keyPath):
            to[keyPath: keyPath].ref = id
        }
        return to.create(on: database)
    }
}

extension OptionalReferenceProperty: CustomStringConvertible {
    public var description: String {
        self.name
    }
}

// MARK: Property

extension OptionalReferenceProperty: AnyProperty { }

extension OptionalReferenceProperty: Property {
    public typealias Model = From
    public typealias Value = To?
}

// MARK: Database

extension OptionalReferenceProperty: AnyDatabaseProperty {
    public var keys: [FieldKey] {
        []
    }

    public func input(to input: any DatabaseInput) {
        // reference never has input
    }

    public func output(from output: any DatabaseOutput) throws {
        let key = switch self.parentKey {
            case .required(let required): From()[keyPath: To()[keyPath: required].toKeypath].path[0]
            case .optional(let optional): From()[keyPath: To()[keyPath: optional].toKeypath].path[0]
        }
        if output.contains(key) {
            self.idValue = try output.decode(key, as: FromProp.Value.self)
        }
    }
}

// MARK: Codable

extension OptionalReferenceProperty: AnyCodableProperty {
    public func encode(to encoder: any Encoder) throws {
        if let reference = self.value {
            var container = encoder.singleValueContainer()
            try container.encode(reference)
        }
    }

    public func decode(from decoder: any Decoder) throws {
        // don't decode
    }

    public var skipPropertyEncoding: Bool {
        self.value == nil // Avoids leaving an empty JSON object lying around in some cases.
    }
}

// MARK: Relation

extension OptionalReferenceProperty: Relation {
    public var name: String {
        "@OptionalReference<\(From.self), \(To.self)>(for: \(self.parentKey))"
    }

    public func load(on database: any Database) -> EventLoopFuture<Void> {
        self.query(on: database).first().map {
            self.value = $0
        }
    }
}

// MARK: Eager Loadable

extension OptionalReferenceProperty: EagerLoadable {
    public static func eagerLoad<Builder>(
        _ relationKey: KeyPath<From, OptionalReferenceProperty<From, To, FromProp>>,
        to builder: Builder
    )
        where Builder: EagerLoadBuilder, Builder.Model == From 
    {
        self.eagerLoad(relationKey, withDeleted: false, to: builder)
    }
    
    public static func eagerLoad<Builder>(
        _ relationKey: KeyPath<From, From.OptionalReference<To, FromProp>>,
        withDeleted: Bool,
        to builder: Builder
    )
        where Builder: EagerLoadBuilder, Builder.Model == From
    {
        let loader = OptionalReferenceEagerLoader(relationKey: relationKey, withDeleted: withDeleted)
        builder.add(loader: loader)
    }


    public static func eagerLoad<Loader, Builder>(
        _ loader: Loader,
        through: KeyPath<From, From.OptionalReference<To, FromProp>>,
        to builder: Builder
    ) where
        Loader: EagerLoader, Loader.Model == To,
        Builder: EagerLoadBuilder, Builder.Model == From
    {
        let loader = ThroughReferenceEagerLoader(relationKey: through, loader: loader)
        builder.add(loader: loader)
    }
}

private struct OptionalReferenceEagerLoader<From, To, FromProp>: EagerLoader
    where
        From: FluentKit.Model, To: FluentKit.Model,
        FromProp: FluentKit.QueryableProperty & _SQLKitExtrasSendableMetatype,
        FromProp.Model == From, FromProp.Value: Hashable
{
    // Needed because the extension that normally adds this inside FluentKit is not public.
    func anyRun(models: [any AnyModel], on database: any Database) -> EventLoopFuture<Void> {
        self.run(models: models.map { $0 as! Model }, on: database)
    }

    let relationKey: KeyPath<From, From.OptionalReference<To, FromProp>>
    let withDeleted: Bool

    func run(models: [From], on database: any Database) -> EventLoopFuture<Void> {
        let ids = models.map { $0[keyPath: $0[keyPath: self.relationKey].fromKeypath].value! }

        let builder = To.query(on: database)
        let parentKey = From()[keyPath: self.relationKey].parentKey
        switch parentKey {
        case .optional(let optional): builder.filter(optional.appending(path: \.$ref) ~~ Set(ids))
        case .required(let required): builder.filter(required.appending(path: \.$ref) ~~ Set(ids))
        }
        if self.withDeleted {
            builder.withDeleted()
        }
        let models = models
        return builder.all().map {
            for model in models {
                let id = model[keyPath: self.relationKey].idValue!
                let children = $0.filter { child in
                    switch parentKey {
                    case .optional(let optional): child[keyPath: optional].ref == id
                    case .required(let required): child[keyPath: required].ref == id
                    }
                }
                model[keyPath: self.relationKey].value = children.first
            }
        }
    }
}

private struct ThroughReferenceEagerLoader<From, Through, FromProp, Loader>: EagerLoader
    where
        From: FluentKit.Model,
        Loader: EagerLoader, Loader.Model == Through, FromProp: FluentKit.QueryableProperty & _SQLKitExtrasSendableMetatype,
        FromProp.Model == From, FromProp.Value: Hashable
{
    // Needed because the extension that normally adds this inside FluentKit is not public.
    func anyRun(models: [any AnyModel], on database: any Database) -> EventLoopFuture<Void> {
        self.run(models: models.map { $0 as! Model }, on: database)
    }

    let relationKey: KeyPath<From, From.OptionalReference<Through, FromProp>>
    let loader: Loader

    func run(models: [From], on database: any Database) -> EventLoopFuture<Void> {
        let throughs = models.compactMap {
            $0[keyPath: self.relationKey].value!
        }
        return self.loader.run(models: throughs, on: database)
    }
}

extension OptionalReferenceProperty: AliasableProperty {}
