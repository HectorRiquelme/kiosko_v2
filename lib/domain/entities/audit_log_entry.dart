enum AuditAction { create, update, delete, sale, login, logout }

enum AuditEntityType { product, category, promo, user, order }

class AuditLogEntry {
  final int? id;
  final String userId;
  final String userName;
  final AuditAction action;
  final AuditEntityType entityType;
  final String entityId;
  final String entityName;
  final String details;
  final DateTime createdAt;

  const AuditLogEntry({
    this.id,
    required this.userId,
    required this.userName,
    required this.action,
    required this.entityType,
    required this.entityId,
    required this.entityName,
    this.details = '',
    required this.createdAt,
  });

  String get actionLabel {
    switch (action) {
      case AuditAction.create:
        return 'Creado';
      case AuditAction.update:
        return 'Editado';
      case AuditAction.delete:
        return 'Eliminado';
      case AuditAction.sale:
        return 'Venta';
      case AuditAction.login:
        return 'Inicio sesion';
      case AuditAction.logout:
        return 'Cerro sesion';
    }
  }

  String get entityTypeLabel {
    switch (entityType) {
      case AuditEntityType.product:
        return 'Producto';
      case AuditEntityType.category:
        return 'Categoria';
      case AuditEntityType.promo:
        return 'Oferta';
      case AuditEntityType.user:
        return 'Usuario';
      case AuditEntityType.order:
        return 'Pedido';
    }
  }
}
