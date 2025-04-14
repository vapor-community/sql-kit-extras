import FluentKit

// MARK: - "Can be aliased" property capability

/// For the sake of excessive completeness (and, as an excuse, for consistency with Fluent's existing
/// plethora of "this property supports ..." protocols), this protocol provides the type-erased
/// version of ``AliasableProperty``, in the same way that `AnyProperty` is the type-erased
/// form of `Property`.
///
/// It is decidedly questionable whether this protocol serves any purpose whatsoever other than to
/// allow generically checking whether a given property can be aliased (which is itself of questionable
/// value, for that matter). Certainly the type-erased value accessors are pointless, as best I can
/// figure at the time of this writing (hopefully, I will be proven wrong eventually).
public protocol AnyAliasableProperty: FluentKit.AnyProperty {
    /// Type-erased form of ``AliasableProperty/wrappedValue``.
    var anyWrappedValue: Any { get }

    /// Type-erased form of ``AliasableProperty/projectedValue``.
    var anyProjectedValue: any AnyAliasableProperty { get }
}

/// A simple protocol to make a `Property`'s `projectedValue` and `wrappedValue` accessors
/// available generically.
///
/// The need for this is unfortunate, especially given that it's technically impossible for there
/// to be a property type that _isn't_ aliasable, but in a particularly convoluted twist of the rules
/// governing API breakage, `Property` can't be safely extended to add these accessors, with or without
/// FluentKit's cooperation - doing it from inside Fluent would be an API break due to the change in
/// conformance requirements, and extending it from outside Fluent doesn't correctly call into the
/// property's accessors (the generic defaulted implementations are always called) - and that in turn
/// bypasses the checks many property types perform in their `wrappedValue` getters, which makes some of
/// them behave unexpectedly. The only way out of this would be to have the ability to recognize property
/// wrappers via the typesystem (e.g. an implicit `PropertyWrapper` protocol, similar to `GlobalActor`),
/// which isn't going to happen, or to break public Fluent API.
public protocol AliasableProperty: FluentKit.Property {
    /// A few of the property types don't follow the usual convention of returning `Value?` from their
    /// `value` accessors and `Value` from their ``wrappedValue`` accessors - in particular, `IDProperty`
    /// and `CompositeIDProperty` return the same type (with the same optionality) in both places, due to
    /// the convoluted semantics of a model's ID always being optional on the Swift side. Therefore we
    /// provide an `associatedtype` on the protocol, allowing the actual return type of the accessor,
    /// including the correct amount of optionality, to be inferred automatically by the compiler. The
    /// protocol is already non-existential anyhow, and aliasing only cares about knowing what the correct
    /// type is, not whether it matches up, so nothing is lost with this approach.
    associatedtype AliasedValueType: Codable

    /// An ``AliasableProperty``, like any property wrapper, has a ``wrappedValue``. The property wrapper's
    /// own `wrappedValue` accessor will automatically fulfill this protocol requirement, and the compiler
    /// will automatically infer ``AliasedValueType`` to be whatever the wrapper's accessor returned.
    var wrappedValue: AliasedValueType { get set }

    /// All Fluent property types are required to return `self` as their projected value, so we just require
    /// that ``projectedValue`` have `Self` as its type, which will always be correct for each property type.
    var projectedValue: Self { get }
}

// MARK: - "Alias another property" property wrapper

extension Fields {
    /// See ``AliasProperty`` for description and usage.
    public typealias Alias<Original> = AliasProperty<Self, Original>
        where Original: AliasableProperty
}

/// A property wrapper which aliases a property to an existing FluentKit property
/// elsewhere on (or deeper within) the same model. Primarily useful for simplfying
/// access to the ID properties of a model using `@CompositeID`.
///
/// Example (with some boilerplate omitted):
/// ```swift
/// final class CompositeModel: Model, @unchecked Sendable {
///     final class IDValue: Fields, Hashable, @unchecked Sendable {
///         @Parent(key: "id") var parent: ParentModel
///         @Field(key: "index") var index: Int
///     }
///
///     @CompositeID var id: IDValue?
///
///     @Alias(of: \.$id.$parent) var parent: ParentModel
///     @Alias(of: \.$id.$index) var index: Int
/// }
/// ```
///
/// > Note: ``AliasProperty`` is unique among property wrappers intended for use with Fluent models
/// > in that it does not itself conform to `Property`, or even `AnyProperty`. This is a deliberate
/// > choice which prevents the presence of aliases from confusing Fluent's internal behavior, as it
/// > means they don't appear even in a model's `properties` array.
@propertyWrapper
public struct AliasProperty<Model, Original>: Sendable
    where Model: FluentKit.Fields, Original: AliasableProperty
{
    /// A key path pointing to the targeted property.
    public typealias TargetKeyPath = KeyPath<Model, Original>

    /// A key path pointing to this property's backing storage property.
    public typealias StorageKeyPath = ReferenceWritableKeyPath<Model, Self>

    /// The key path of the targeted property.
    public let targetKeyPath: TargetKeyPath

    /// Forward `wrappedValue` accesses through the owner object using the target keypath.
    ///
    /// The generic `Value` parameter allows the wrapped value access to nest into the
    /// targeted property.
    ///
    /// - Parameters:
    ///   - owner: The object which contains the property wrapper being accessed.
    ///   - wrapped: A key path pointing to the synthesized value property for the property wrapper.
    ///   - storage: A key path pointing to the backing store property for the property wrapper.
    /// - Returns: The result of forwarding the access to the target property's `wrappedValue` property.
    public static subscript<Value>(
        _enclosingInstance owner: Model,
        wrapped wrapped: ReferenceWritableKeyPath<Model, Value>,
        storage storage: StorageKeyPath
    ) -> Original.AliasedValueType {
        get { owner[keyPath: owner[keyPath: storage].targetKeyPath].wrappedValue }
        set { owner[keyPath: owner[keyPath: storage].targetKeyPath].wrappedValue = newValue }
    }

    /// Forward `projectedValue` reads through the owner object using the target keypath.
    ///
    /// - Parameters:
    ///   - owner: The object which contains the property wrapper being accessed.
    ///   - projected: A key path pointing to the synthesized projected value property for the property wrapper.
    ///   - storage: A key path pointing to the backing store property for the property wrapper.
    /// - Returns: The result of forwarding the access to the target property's `projectedValue` property.
    public static subscript(
        _enclosingInstance owner: Model,
        projected projected: TargetKeyPath,
        storage storage: StorageKeyPath
    ) -> Original {
        owner[keyPath: owner[keyPath: storage].targetKeyPath].projectedValue
    }

    /// Create an ``AliasProperty`` targeting the property at the given key path on the same model.
    public init(of targetKeyPath: KeyPath<Model, Original>) {
        self.targetKeyPath = targetKeyPath
    }

    /// The `wrappedValue` accessors must be present in order to enable usage of the the
    /// ``subscript(_enclosingInstance:wrapped:storage:)`` subscript. It is both a compile
    /// and runtime error for these accessors to be referenced or invoked. This also ensures
    /// that this property wrapper can only be applied to reference types.
    @available(*, unavailable, message: "Only usable within reference types")
    public var wrappedValue: Original.AliasedValueType {
        get { fatalError() }
        set { fatalError() }
    }

    /// The `projectedValue` accessor must be present in order to enable usage of the the
    /// ``subscript(_enclosingInstance:projected:storage:)`` subscript. It is both a compile
    /// and runtime error for this accessor to be referenced or invoked. This also ensures
    /// that this property wrapper can only be applied to reference types.
    @available(*, unavailable, message: "Only usable within reference types")
    public var projectedValue: Original {
        fatalError()
    }
}

// MARK: - Add aliasability to existing property types

/// Extend all of the existing FluentKit property types with conformance to the new protocol.
///
/// Having to explicitly add the conformance to any additional property types anyone else might
/// have implemented elsewhere is another reason it's unfortunate that we need the protocol.
///
/// > Note: ``AliasProperty`` and ``UnwrappingAliasProperty`` are omitted from this list deliberately;
/// > they are the only properties which are _not_ aliasable, partially due to their lack of conformance
/// > the `Property` protocol. (It's probably possible to make aliases that can be chained, but it doesn't
/// > seem worth the effort.)

extension FluentKit.IDProperty: AliasableProperty {}
extension FluentKit.CompositeIDProperty: AliasableProperty {}

extension FluentKit.FieldProperty: AliasableProperty {}
extension FluentKit.OptionalFieldProperty: AliasableProperty {}

extension FluentKit.BooleanProperty: AliasableProperty {}
extension FluentKit.OptionalBooleanProperty: AliasableProperty {}

extension FluentKit.EnumProperty: AliasableProperty {}
extension FluentKit.OptionalEnumProperty: AliasableProperty {}

extension FluentKit.TimestampProperty: AliasableProperty {}

extension FluentKit.ParentProperty: AliasableProperty {}
extension FluentKit.OptionalParentProperty: AliasableProperty {}
extension FluentKit.CompositeParentProperty: AliasableProperty {}
extension FluentKit.CompositeOptionalParentProperty: AliasableProperty {}

extension FluentKit.ChildrenProperty: AliasableProperty {}
extension FluentKit.OptionalChildProperty: AliasableProperty {}
extension FluentKit.CompositeChildrenProperty: AliasableProperty {}
extension FluentKit.CompositeOptionalChildProperty: AliasableProperty {}

extension FluentKit.SiblingsProperty: AliasableProperty {}

extension FluentKit.GroupProperty: AliasableProperty {}
