import FluentKit

#if compiler(>=6.2)
public typealias _SQLKitExtrasSendableMetatype = SendableMetatype
#else
public typealias _SQLKitExtrasSendableMetatype = Any
#endif

extension FluentKit.BooleanProperty: _SQLKitExtrasSendableMetatype {}
extension FluentKit.OptionalBooleanProperty: _SQLKitExtrasSendableMetatype {}

extension FlatGroupProperty: _SQLKitExtrasSendableMetatype {}
extension OptionalPointerProperty: _SQLKitExtrasSendableMetatype {}
extension OptionalReferenceProperty: _SQLKitExtrasSendableMetatype {}
extension PointerProperty: _SQLKitExtrasSendableMetatype {}
extension ReferencesProperty: _SQLKitExtrasSendableMetatype {}
extension RequiredTimestampProperty: _SQLKitExtrasSendableMetatype {}

