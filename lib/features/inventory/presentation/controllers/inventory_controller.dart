
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../../core/utils/file_exporter.dart';
import '../../../../core/utils/shamsi_date.dart';
import '../../data/datasources/hardcoded_data_source.dart';
import '../../data/repositories/inventory_repository_impl.dart';
import '../../domain/models/inventory_item.dart';
import '../../domain/repositories/inventory_repository.dart';

final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) {
  return InventoryRepositoryImpl(HardcodedDataSource());
});

final inventoryControllerProvider =
StateNotifierProvider<InventoryController, List<InventoryItem>>((ref) {
  final repository = ref.watch(inventoryRepositoryProvider);
  return InventoryController(repository);
});

class InventoryController extends StateNotifier<List<InventoryItem>> {
  final InventoryRepository _repository;

  InventoryController(this._repository) : super([]) {
    loadItems();
  }

  void loadItems() {
    state = _repository.getInitialInventory();
  }

  void updateCount(String category, String code, int delta) {
    state = [
      for (final item in state)
        if (item.category == category && item.code == code)
          item.copyWith(count: (item.count + delta).clamp(0, 99999))
        else
          item,
    ];
  }

  void setCount(String category, String code, int count) {
    state = [
      for (final item in state)
        if (item.category == category && item.code == code)
          item.copyWith(count: count.clamp(0, 99999))
        else
          item,
    ];
  }

  Future<void> exportJson() async {
    final Map<String, dynamic> result = {
      'exported_at': DateTime.now().toIso8601String(),
      'items': state.map((e) => e.toJson()).toList(),
    };

    final fileName = 'inventory_${DateTime
        .now()
        .millisecondsSinceEpoch}.json';
    await FileExporter.exportAndShareJson(data: result, fileName: fileName);
  }

  String getSummaryJson({required String branchCode}) {
    final activeItems = state.where((item) => item.count > 0).toList();
    final todayShamsi = ShamsiDate.getTodayFormatted();

    final branchFormatted =
    branchCode.trim().isNotEmpty ? branchCode.trim() : '0000';
    final exportedTag = '#$branchFormatted - $todayShamsi';

    // ۱. گروه‌بندی اقلام بر اساس نام دسته‌بندی
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (final item in activeItems) {
      grouped.putIfAbsent(item.category, () => []).add({
        'code': item.code,
        'count': item.count,
      });
    }

    // ۲. تبدیل به لیستی از مپ‌ها (کلید: نام دسته، مقدار: لیست کدها و تعداد)
    final List<Map<String, dynamic>> itemsList = grouped.entries.map((entry) {
      return {
        entry.key: entry.value,
      };
    }).toList();

    final Map<String, dynamic> result = {
      'exported_at': exportedTag,
      'items': itemsList,
    };

    return const JsonEncoder.withIndent('  ').convert(result);
  }

}