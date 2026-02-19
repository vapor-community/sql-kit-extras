#if FluentSQLKitExtras
import FluentKit
import SQLKit

extension SQLDatabase {
    /// Allow specifying a table for a `CREATE TABLE` query using a Fluent model.
    public func create(table model: (some Schema).Type) -> SQLCreateTableBuilder {
        self.create(table: model.sqlTable)
    }
}

extension SQLCreateTableBuilder {
    @inlinable
    @discardableResult
    public func column(
        _ keypath: KeyPath<some Schema, some QueryAddressableProperty>,
        type dataType: SQLDataType,
        _ constraints: SQLColumnConstraintAlgorithm...
    ) -> Self {
        self.column(.identifier(keypath), type: dataType, constraints)
    }

    @inlinable
    @discardableResult
    public func column(
        _ keypath: KeyPath<some Schema, some QueryAddressableProperty>,
        type dataType: SQLDataType,
        _ constraints: [SQLColumnConstraintAlgorithm]
    ) -> Self {
        self.column(.identifier(keypath), type: dataType, constraints)
    }
}

extension SQLColumnConstraintAlgorithm {
    @inlinable
    public static func references<S: Schema>(
        _ column: KeyPath<S, some QueryAddressableProperty>,
        onDelete: SQLForeignKeyAction? = nil,
        onUpdate: SQLForeignKeyAction? = nil
    ) -> SQLColumnConstraintAlgorithm {
        .foreignKey(
            references: SQLForeignKey(
                table: S.sqlTable,
                columns: [.identifier(column)],
                onDelete: onDelete,
                onUpdate: onUpdate
            )
        )
    }

    @inlinable
    public static func references<S: Schema>(
        _ column: KeyPath<S, some QueryAddressableProperty>,
        onDelete: (any SQLExpression)? = nil,
        onUpdate: (any SQLExpression)? = nil
    ) -> SQLColumnConstraintAlgorithm {
        .foreignKey(
            references: SQLForeignKey(
                table: S.sqlTable,
                columns: [.identifier(column)],
                onDelete: onDelete,
                onUpdate: onUpdate
            )
        )
    }
}
#endif
