enum ShelfStatus {
  fresh,
  expiringSoon,
  expired,
  outOfStock;

  // Convert to database string
  String get name {
    switch (this) {
      case ShelfStatus.fresh:
        return 'fresh';
      case ShelfStatus.expiringSoon:
        return 'expiring_soon';
      case ShelfStatus.expired:
        return 'expired';
      case ShelfStatus.outOfStock:
        return 'out_of_stock';
    }
  }
}