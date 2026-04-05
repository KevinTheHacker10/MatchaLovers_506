/// Core constants for the application
class AppConstants {
  static const String appName = 'Matcha Lovers 506';
  static const String currency = '₡';
  
  // Storage keys
  static const String storageKeyUsers = 'users';
  static const String storageKeyProducts = 'products';
  static const String storageKeyOrders = 'orders';
  static const String storageKeyCurrentUser = 'current_user';
}

/// User roles
enum UserRole {
  admin,
  waiter;
  
  String get displayName {
    switch (this) {
      case UserRole.admin:
        return 'Administrador';
      case UserRole.waiter:
        return 'Mesero';
    }
  }
}

/// Product categories
enum ProductCategory {
  matcha,
  smoothies,
  healthyJuices,
  coldCoffee;
  
  String get displayName {
    switch (this) {
      case ProductCategory.matcha:
        return 'Matcha';
      case ProductCategory.smoothies:
        return 'Batidos';
      case ProductCategory.healthyJuices:
        return 'Jugos Saludables';
      case ProductCategory.coldCoffee:
        return 'Cafés Fríos';
    }
  }
  
  String get icon {
    switch (this) {
      case ProductCategory.matcha:
        return '🍵';
      case ProductCategory.smoothies:
        return '🥤';
      case ProductCategory.healthyJuices:
        return '🥗';
      case ProductCategory.coldCoffee:
        return '☕';
    }
  }
}

/// Order status
enum OrderStatus {
  pending,
  completed,
  cancelled;
  
  String get displayName {
    switch (this) {
      case OrderStatus.pending:
        return 'Pendiente';
      case OrderStatus.completed:
        return 'Completado';
      case OrderStatus.cancelled:
        return 'Cancelado';
    }
  }
}

/// Payment method
enum PaymentMethod {
  cash,
  card;
  
  String get displayName {
    switch (this) {
      case PaymentMethod.cash:
        return 'Efectivo';
      case PaymentMethod.card:
        return 'Tarjeta';
    }
  }
}
