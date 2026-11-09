import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

Future<void> saveOrShareFile(String content, String fileName) async {
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/$fileName');
  await file.writeAsString(content);

  await Share.shareXFiles(
    [XFile(file.path, mimeType: 'application/json')],
    text: 'خروجی انبارداری',
  );
}
