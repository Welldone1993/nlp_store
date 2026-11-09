import '../models/inventory_item.dart';

abstract class InventoryRepository {
  List<InventoryItem> getInitialInventory();
}
