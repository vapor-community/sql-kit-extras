import FluentKit
import struct Foundation.Date

extension Model {
    public typealias RequiredTimestamp<Format> = RequiredTimestampProperty<Self, Format>
        where
            Format: TimestampFormat
}

/// A Fluent property wrapper which provides the same functionality as the built-in `TimestampProperty` wrapper,
/// except that its value is not optional.
@propertyWrapper
public final class RequiredTimestampProperty<Model, Format>
    where
        Model: FluentKit.Model,
        Format: TimestampFormat
{
    @FieldProperty<Model, Format.Value>
    public var timestamp: Format.Value

    let format: Format

    public var projectedValue: RequiredTimestampProperty<Model, Format> {
        self
    }

    public var wrappedValue: Date {
        get {
            guard let value = self.value else {
                fatalError("Cannot access field before it is initialized or fetched: \(self.$timestamp.key)")
            }
            return value
        }
        set { self.value = newValue }
    }

    public convenience init(key: FieldKey) where Format == DefaultTimestampFormat {
        self.init(key: key, format: .default)
    }

    public convenience init(key: FieldKey, format: TimestampFormatFactory<Format>) {
        self.init(key: key, format: format.makeFormat())
    }

    public init(key: FieldKey, format: Format) {
        self._timestamp = .init(key: key)
        self.format = format
    }
}

extension RequiredTimestampProperty:
    CustomStringConvertible,
    QueryableProperty,
    AnyCodableProperty,
    AnyDatabaseProperty,
    QueryAddressableProperty
{
    // CustomStringConvertible
    public var description: String {
        "@\(Model.self).RequiredTimestamp(key: \(self.$timestamp.key))"
    }

    // Property
    public var value: Date? {
        get { self.$timestamp.value.flatMap(self.format.parse(_:)) }
        set { self.$timestamp.value = newValue.flatMap(self.format.serialize(_:)) }
    }
    
    // QueryableProperty
    public var path: [FieldKey] {
        self.$timestamp.path
    }

    // AnyDatabaseProperty
    public var keys: [FieldKey] {
        self.$timestamp.keys
    }

    public func input(to input: any DatabaseInput) {
        self.$timestamp.input(to: input)
    }

    public func output(from output: any DatabaseOutput) throws {
        try self.$timestamp.output(from: output)
    }

    // AnyCodableProperty
    public func encode(to encoder: any Encoder) throws {
        try self.$timestamp.encode(to: encoder)
    }

    public func decode(from decoder: any Decoder) throws {
        try self.$timestamp.decode(from: decoder)
    }

    // QueryAddressableProperty
    public var anyQueryableProperty: any AnyQueryableProperty {
        self
    }

    public var queryablePath: [FieldKey] {
        self.path
    }

    public var queryableProperty: RequiredTimestampProperty<Model, Format> {
        self
    }
}

extension RequiredTimestampProperty: AliasableProperty {}
