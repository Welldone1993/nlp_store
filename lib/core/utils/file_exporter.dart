import 'dart:convert';
import 'file_exporter_mobile.dart' if (dart.library.html) 'file_exporter_web.dart';

abstract class FileExporter {
  static Future<void> exportAndShareJson({
    required Map<String, dynamic> data,
    required String fileName,
  }) async {
    final jsonString = const JsonEncoder.withIndent('  ').convert(data);
    await saveOrShareFile(jsonString, fileName);
  }
}
