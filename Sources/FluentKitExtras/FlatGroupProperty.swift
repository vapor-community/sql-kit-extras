import FluentKit

// MARK: - @FlatGroup

extension Model {
    /// See ``FlatGroupProperty``.
    public typealias FlatGroup<Value> = FlatGroupProperty<Self, Value>
        where Value: Fields
}

// MARK: - FlatGroupProperty

/// `@FlatGroup` embeds the Fluent properties found on `Value` in `Model`, as if those
/// properties had been specified on `Model`. It is very similar to `@Group`, except
/// no prefix gets added to the properties.
///
/// Example:
/// ```swift
/// final class CommonData: Fields {
///     @Field(key: "a") var a: String
///     @Field(key: "b") var b: Int
///
///     init() {}
/// }
///
/// final class FirstModel: Model {
///     static let schema = "first_models"
///     @ID(custom: .id) var id: Int
///     @Group(key: "first") var data: CommonData
///
///     init() {}
/// }
///
/// final class SecondModel: Model {
///     static let schema = "second_models"
///     @ID(custom: .id) var id: Int
///     @FlatGroup var data: CommonData
///
///     init() {}
/// }
///
/// print(FirstModel.keys)
/// // ["id", "first_a", "first_b"]
///
/// print(SecondModel.keys)
/// // ["id", "a", "b"]
/// ```
///
/// - Warning: It is easier than usual to accidentally end up with duplicate key names in
///   a model when using `@FlatGroup`. If this happens, don't let it stay that way! Even if
///   everything appears to work correctly at first, it will eventually cause enough confusion
///   in Fluent to have unpredictable results.
@propertyWrapper @dynamicMemberLookup
public final class FlatGroupProperty<Model, Value>
    where Model: FluentKit.Fields, Value: FluentKit.Fields
{
    /// The underlying storage of the properties nested on ``Value``. It is optional
    /// only because ``FluentKit/Property``'s ``value`` requirement must always be
    /// optional. It will never actually be `nil` in practice at runtime.
    public var value: Value?

    /// Fluent property wrappers must return `self` as their ``projectedValue``.
    public var projectedValue: FlatGroupProperty<Model, Value> { self }

    /// The accessor invoked by the compiler when the wrapped property is read or set
    /// by calling code. As noted on ``value`` above, the actual value is never supposed
    /// to be `nil`, so the wrapped value type is non-optional, and encountering `nil`
    /// anyway immediately results in a fatal runtime error.
    public var wrappedValue: Value {
        get { self.value! } // If you crash here, you've misused this property; this should never be nil
        set { self.value = newValue }
    }

    /// `@FlatGroup` has no parameters, so the initializer is pretty simple.
    public init() {
        self.value = .init()
    }

    /// Enable accessing the projected values of properties defined on `Value` via our own projected value.
    ///
    /// Example:
    /// ```swift
    /// final class CommonFields: Fields {
    ///     @Field(key: "a")
    ///     var a: String
    ///
    ///     @Parent(key: "b")
    ///     var b: BModel
    ///
    ///     init() {}
    /// }
    ///
    /// final class AModel: Model {
    ///     static let schema = "amodels"
    ///
    ///     @ID(custom: .id)
    ///     var id: Int?
    ///
    ///     @FlatGroup
    ///     var commonFields: CommonFields
    ///
    ///     init() {}
    /// }
    ///
    /// let models = try await AModel.query(on: database)
    ///     .filter(\.$commonFields.$a == "a")
    ///     .all()
    /// ```
    ///
    /// Unlike `@Group`, `@FlatGroup` does not perform any transformations on the keys of its nested
    /// properties. Thus, while `\.commonFields.$a` and `\.$commonFields.$a` would mean two different
    /// things if `commonFields` was a `@Group`, they are effectively identical when using `@FlatGroup`.
    ///
    /// - Tip: For the sake of consistency and clarity, it is considered best practice for calling code
    ///   to use the same syntax that would otherwise be required for a `@Group`. (Short short version:
    ///   `\.$foo.$bar` and `\.foo.bar` are good, `\.foo.$bar` is bad.)
    public subscript<Nested>(dynamicMember keyPath: KeyPath<Value, Nested>) -> Nested where Nested: Property {
        self.value![keyPath: keyPath]
    }
}

// MARK: - CustomStringConvertible

/// Provide `@FlatGroup` properties with a description which includes all of the relevant types in the result.
extension FlatGroupProperty: CustomStringConvertible {
    /// See ``Swift/CustomStringConvertible/description``.
    public var description: String {
        "@\(Model.self).FlatGroup<\(Value.self)>()"
    }
}

// MARK: - [Any]Property

/// `@FlatGroup` is intended for use with properties of ``FluentKit/Fields`` et al.
extension FlatGroupProperty: AnyProperty, Property {}

// MARK: - AnyDatabaseProperty

/// `@FlatGroup` has content that interacts with database queries (i.e. the properties it contains).
extension FlatGroupProperty: AnyDatabaseProperty {
    /// See ``FluentKit/AnyDatabaseProperty/keys``.
    public var keys: [FieldKey] {
        Value.keys
    }

    /// See ``FluentKit/AnyDatabaseProperty/input(to:)``.
    public func input(to input: any DatabaseInput) {
        self.value!.input(to: input)
    }

    /// See ``FluentKit/AnyDatabaseProperty/output(from:)``.
    public func output(from output: any DatabaseOutput) throws {
        try self.value!.output(from: output)
    }
}

// MARK: - AnyCodableProperty

/// `@FlatGroup` participates in ``FluentKit/Fields``'s ``Swift/Codable`` conformance (i.e. by
/// passing it on to its contained properties).
extension FlatGroupProperty: AnyCodableProperty {
    /// See ``FluentKit/AnyCodableProperty/encode(to:)``.
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.value!)
    }

    /// See ``FluentKit/AnyCodableProperty/decode(from:)``.
    public func decode(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.value = try .some(container.decode(Value.self))
    }
}

extension FlatGroupProperty: AliasableProperty {}
