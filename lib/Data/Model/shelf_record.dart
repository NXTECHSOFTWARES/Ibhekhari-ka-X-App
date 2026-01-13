import 'enum/shelf_status.dart';

class ShelfRecord {
  final int? id;
  final String lastRestockedDate;
  final int currentStock;
  final int quantityAdded;
  final int shelfLife;
  final int pastryId;
  final bool isAvailable;
  final String pastryName;
  final ShelfStatus status;

  ShelfRecord({
    this.id,
    required this.lastRestockedDate,
    required this.currentStock,
    required this.quantityAdded,
    required this.shelfLife,
    required this.pastryId,
    required this.isAvailable,
    required this.pastryName,
    required this.status,
  });

  // Calculate expiry date based on last restocked date and shelf life
  DateTime get expiryDate {
    DateTime restockedDate = DateTime.parse(lastRestockedDate);
    return restockedDate.add(Duration(days: shelfLife));
  }

  // Calculate days until expiry
  int get daysUntilExpiry {
    DateTime now = DateTime.now();
    return expiryDate.difference(now).inDays;
  }

  // Check if expired
  bool get isExpired {
    return DateTime.now().isAfter(expiryDate);
  }

  // Check if expiring soon (within 2 days)
  bool get isExpiringSoon {
    int days = daysUntilExpiry;
    return days >= 0 && days <= 2;
  }

  // Check if out of stock
  bool get isOutOfStock {
    return currentStock <= 0;
  }

  // Get formatted expiry date
  String get formattedExpiryDate {
    return '${expiryDate.day}/${expiryDate.month}/${expiryDate.year}';
  }

  // Get status text for display
  String get statusText {
    switch (status) {
      case ShelfStatus.fresh:
        return 'Fresh';
      case ShelfStatus.expiringSoon:
        return 'Expiring Soon';
      case ShelfStatus.expired:
        return 'Expired';
      case ShelfStatus.outOfStock:
        return 'Out of Stock';
    }
  }

  // Convert from database map to model
  factory ShelfRecord.fromMap(Map<String, dynamic> map) {
    return ShelfRecord(
      id: map['id'] as int?,
      lastRestockedDate: map['last_restocked_date'] as String,
      currentStock: map['current_stock'] as int,
      quantityAdded: map['quantity_added'] as int,
      shelfLife: map['shelf_life'] as int,
      pastryId: map['pastry_id'] as int,
      isAvailable: (map['is_available'] as int) == 1,
      pastryName: map['pastry_name'] as String,
      status: _parseStatus(map['status'] as String),
    );
  }

  // Convert model to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'last_restocked_date': lastRestockedDate,
      'current_stock': currentStock,
      'quantity_added': quantityAdded,
      'shelf_life': shelfLife,
      'pastry_id': pastryId,
      'is_available': isAvailable ? 1 : 0,
      'pastry_name': pastryName,
      'status': status.name,
    };
  }

  // Convert for database insert (without id and createdAt)
  Map<String, dynamic> toMapForInsert() {
    return {
      'last_restocked_date': lastRestockedDate,
      'current_stock': currentStock,
      'quantity_added': quantityAdded,
      'shelf_life': shelfLife,
      'pastry_id': pastryId,
      'is_available': isAvailable ? 1 : 0,
      'pastry_name': pastryName,
      'status': status.name,
    };
  }

  // Parse status from string
  static ShelfStatus _parseStatus(String status) {
    switch (status.toLowerCase()) {
      case 'fresh':
        return ShelfStatus.fresh;
      case 'expiring_soon':
        return ShelfStatus.expiringSoon;
      case 'expired':
        return ShelfStatus.expired;
      case 'out_of_stock':
        return ShelfStatus.outOfStock;
      default:
        return ShelfStatus.fresh;
    }
  }

  // Create a copy with updated fields
  ShelfRecord copyWith({
    int? id,
    String? lastRestockedDate,
    int? currentStock,
    int? quantityAdded,
    int? shelfLife,
    int? pastryId,
    bool? isAvailable,
    String? pastryName,
    ShelfStatus? status,
  }) {
    DateTime restockedDate = DateTime.parse(lastRestockedDate ??  this.lastRestockedDate);
    DateTime expiryDate = restockedDate.add(Duration(days: shelfLife ?? this.shelfLife));
    int daysUntilExpiry = expiryDate.difference(DateTime.now()).inDays;
    return ShelfRecord(
      id: id ?? this.id,
      lastRestockedDate: lastRestockedDate ?? this.lastRestockedDate,
      currentStock: currentStock ?? this.currentStock,
      quantityAdded: quantityAdded ?? this.quantityAdded,
      shelfLife: shelfLife ?? this.shelfLife,
      pastryId: pastryId ?? this.pastryId,
      isAvailable: isAvailable ?? (currentStock! > 0 && daysUntilExpiry >= 0),
      pastryName: pastryName ?? this.pastryName,
      status: status ?? this.status,
    );
  }

  // Automatically determine status based on current state
  static ShelfStatus determineStatus(
      int currentStock,
      int daysUntilExpiry,
      ) {
    if (currentStock <= 0) {
      return ShelfStatus.outOfStock;
    } else if (daysUntilExpiry < 0) {
      return ShelfStatus.expired;
    } else if (daysUntilExpiry <= 2) {
      return ShelfStatus.expiringSoon;
    } else {
      return ShelfStatus.fresh;
    }
  }

  // Create ShelfRecord with auto-calculated status
  factory ShelfRecord.create({
    required String lastRestockedDate,
    required int currentStock,
    required int quantityAdded,
    required int shelfLife,
    required int pastryId,
    required String pastryName,
    bool? isAvailable,
  }) {
    DateTime restockedDate = DateTime.parse(lastRestockedDate);
    DateTime expiryDate = restockedDate.add(Duration(days: shelfLife));
    int daysUntilExpiry = expiryDate.difference(DateTime.now()).inDays;

    ShelfStatus status = determineStatus(currentStock, daysUntilExpiry);

    return ShelfRecord(
      lastRestockedDate: lastRestockedDate,
      currentStock: currentStock,
      quantityAdded: quantityAdded,
      shelfLife: shelfLife,
      pastryId: pastryId,
      isAvailable: isAvailable ?? (currentStock > 0 && daysUntilExpiry >= 0),
      pastryName: pastryName,
      status: status,
    );
  }

  @override
  String toString() {
    return 'ShelfRecord(id: $id, pastryName: $pastryName, currentStock: $currentStock, '
        'status: ${status.name}, daysUntilExpiry: $daysUntilExpiry)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ShelfRecord &&
        other.id == id &&
        other.lastRestockedDate == lastRestockedDate &&
        other.currentStock == currentStock &&
        other.quantityAdded == quantityAdded &&
        other.shelfLife == shelfLife &&
        other.pastryId == pastryId &&
        other.isAvailable == isAvailable &&
        other.pastryName == pastryName &&
        other.status == status;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      lastRestockedDate,
      currentStock,
      quantityAdded,
      shelfLife,
      pastryId,
      isAvailable,
      pastryName,
      status,
    );
  }
}