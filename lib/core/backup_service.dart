import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Full-state backup/restore — unlike [PdfExportService], this intentionally
/// includes the personal layer too, since it's a device-to-device backup
/// the user makes for themselves, not something shown to a supervisor.
class BackupService {
  BackupService._();

  static Future<void> exportAndShare(Map<String, dynamic> stateJson) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/cepte_staj_yedek_${DateTime.now().millisecondsSinceEpoch}.json');
    await file.writeAsString(jsonEncode(stateJson));
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
        subject: 'Cepte Staj yedek dosyası',
        text: 'Cepte Staj — veri yedeği',
      ),
    );
  }

  /// Lets the user pick a `.json` backup file and returns its decoded
  /// content, or null if they cancelled / the file was invalid.
  static Future<Map<String, dynamic>?> pickAndReadBackup() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (result == null || result.files.isEmpty) return null;
    final path = result.files.single.path;
    if (path == null) return null;
    final content = await File(path).readAsString();
    final decoded = jsonDecode(content);
    if (decoded is Map<String, dynamic>) return decoded;
    return null;
  }
}
