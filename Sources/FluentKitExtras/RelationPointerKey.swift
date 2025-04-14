import FluentKit

public enum RelationPointerKey<From, To, FromProp>: Sendable
    where
        From: FluentKit.Model, To: FluentKit.Model,
        FromProp: QueryableProperty, FromProp.Model == From, FromProp.Value: Hashable
{
    case required(KeyPath<To, To.Pointer<From, FromProp>>)
    case optional(KeyPath<To, To.OptionalPointer<From, FromProp>>)
}
