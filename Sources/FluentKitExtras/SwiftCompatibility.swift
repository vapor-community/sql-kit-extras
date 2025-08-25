import FluentKit

#if compiler(>=6.2)
@_marker public protocol _SQLKitExtrasSendableMetatype: SendableMetatype {}
#else
@_marker public protocol _SQLKitExtrasSendableMetatype {}
#endif

extension FluentKit.FieldProperty: _SQLKitExtrasSendableMetatype {}
