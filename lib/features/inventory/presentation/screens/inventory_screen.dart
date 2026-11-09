import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/shamsi_date.dart';
import '../controllers/inventory_controller.dart';
import '../../domain/models/inventory_item.dart';

class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen> {
  final Map<String, TextEditingController> _controllers = {};
  final TextEditingController _branchController = TextEditingController();
  late final String _todayDate;

  @override
  void initState() {
    super.initState();
    _todayDate = ShamsiDate.getTodayFormatted();
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    _branchController.dispose();
    super.dispose();
  }

  TextEditingController _getController(String key, int initialCount) {
    return _controllers.putIfAbsent(
      key,
      () => TextEditingController(
        text: initialCount > 0 ? initialCount.toString() : '',
      ),
    );
  }

  void _showSummaryDialog(BuildContext context, String jsonContent) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('خلاصه ثبت شده', textAlign: TextAlign.right),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: SelectableText(
                jsonContent,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('بستن'),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black87,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.copy_rounded, size: 18),
            label: const Text('کپی به کلیپ‌بورد'),
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: jsonContent));
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('متن JSON با موفقیت کپی شد'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(inventoryControllerProvider);

    final Map<String, List<InventoryItem>> groupedItems = {};
    for (var item in items) {
      groupedItems.putIfAbsent(item.category, () => []).add(item);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'فروش روز',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(height: 1, thickness: 1, color: Colors.black26),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // بخش وسط‌چین هدر: پلاک شعبه + تاریخ شمسی
          Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 240),
              child: Column(
                children: [
                  TextField(
                    controller: _branchController,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    decoration: InputDecoration(
                      hintText: 'پلاک شعبه',
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.black45),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: Colors.black,
                          width: 1.8,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'تاریخ: $_todayDate',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Divider(thickness: 1.5, color: Colors.black87),

          // اقلام و کدهای جدول بر اساس دسته‌بندی
          ...groupedItems.entries.map((entry) {
            final categoryName = entry.key;
            final categoryList = entry.value;

            return Column(
              children: [
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        flex: 7,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: categoryList.map((item) {
                            final key = '${item.category}_${item.code}';
                            final controller = _getController(key, item.count);

                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 6.0,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  SizedBox(
                                    width: 90,
                                    height: 42,
                                    child: TextField(
                                      controller: controller,
                                      keyboardType: TextInputType.number,
                                      textAlign: TextAlign.center,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                      ],
                                      decoration: InputDecoration(
                                        contentPadding: EdgeInsets.zero,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                          borderSide: const BorderSide(
                                            color: Colors.black87,
                                            width: 1.2,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                          borderSide: const BorderSide(
                                            color: Colors.blueAccent,
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                      onChanged: (val) {
                                        final count = int.tryParse(val) ?? 0;
                                        ref
                                            .read(
                                              inventoryControllerProvider
                                                  .notifier,
                                            )
                                            .setCount(
                                              item.category,
                                              item.code,
                                              count,
                                            );
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  SizedBox(
                                    width: 90,
                                    height: 42,
                                    child: Text(
                                      ': ${item.code}',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      // خط عمودی جداکننده دسته
                      const VerticalDivider(
                        thickness: 1.2,
                        color: Colors.black45,
                        width: 24,
                      ),
                      Expanded(
                        flex: 3,
                        child: Center(
                          child: Text(
                            categoryName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(thickness: 1.5, color: Colors.black38),
                ),
              ],
            );
          }),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black87,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: const Icon(Icons.check_circle_outline),
            label: const Text(
              'ثبت نهایی و نمایش خروجی',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            onPressed: () {
              if (_branchController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('لطفاً ابتدا پلاک شعبه را وارد کنید'),
                    backgroundColor: Colors.redAccent,
                  ),
                );
                return;
              }

              FocusScope.of(context).unfocus();
              final jsonString = ref
                  .read(inventoryControllerProvider.notifier)
                  .getSummaryJson(branchCode: _branchController.text);

              _showSummaryDialog(context, jsonString);
            },
          ),
        ),
      ),
    );
  }
}
