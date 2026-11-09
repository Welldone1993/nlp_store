class InventoryItem {
  final String category;
  final String code;
  final int count;

  const InventoryItem({
    required this.category,
    required this.code,
    this.count = 0,
  });

  InventoryItem copyWith({int? count}) {
    return InventoryItem(
      category: category,
      code: code,
      count: count ?? this.count,
    );
  }

  Map<String, dynamic> toJson() => {
    'category': category,
    'code': code,
    'count': count,
  };
}
