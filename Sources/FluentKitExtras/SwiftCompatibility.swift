import FluentKit

@available(*, deprecated, renamed: "SendableMetatype", message: "Use SendableMetatype instead.")
public typealias _SQLKitExtrasSendableMetatype = SendableMetatype

extension BooleanProperty: @retroactive SendableMetatype {}
extension OptionalBooleanProperty: @retroactive SendableMetatype {}
