import '../../domain/models/inventory_item.dart';
import '../../domain/repositories/inventory_repository.dart';
import '../datasources/hardcoded_data_source.dart';

class InventoryRepositoryImpl implements InventoryRepository {
  final HardcodedDataSource _dataSource;

  InventoryRepositoryImpl(this._dataSource);

  @override
  List<InventoryItem> getInitialInventory() {
    return _dataSource.getInitialItems().map((e) {
      return InventoryItem(
        category: e['category'] as String,
        code: e['code'] as String,
        count: e['count'] as int,
      );
    }).toList();
  }
}
