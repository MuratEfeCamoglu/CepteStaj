import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Full-state backup/restore — unlike [PdfExportService], this intentionally
/// includes the personal layer too, since it's a device-to-device backup
/// the user makes for themselves, not something shown to a supervisor.
///
/// Format: a `.zip` holding `data.json` (the state, with each photo's
/// `filePath` rewritten to its path inside the zip) plus a `photos/` folder
/// with the image files themselves — so a restore on a new phone brings the
/// photos along, not just dangling paths. Older plain `.json` backups (no
/// photo files) can still be restored.
class BackupService {
  BackupService._();

  static const _dataEntry = 'data.json';
  static const _photosPrefix = 'photos/';

  static Future<void> exportAndShare(Map<String, dynamic> stateJson) async {
    // Temp dir, not documents: the share sheet only needs the file briefly,
    // and a copy left in documents would survive "Tüm verileri sıfırla".
    final dir = await getTemporaryDirectory();
    final zipPath = '${dir.path}/cepte_staj_yedek_${DateTime.now().millisecondsSinceEpoch}.zip';

    await writeBackupZip(stateJson, zipPath);

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(zipPath, mimeType: 'application/zip')],
        subject: 'Cepte Staj yedek dosyası',
        text: 'Cepte Staj — veri yedeği',
      ),
    );
  }

  /// Writes [stateJson] plus every photo file it references into a zip at
  /// [zipPath]. Photos whose file is gone are kept as entries (caption etc.)
  /// with their old path.
  @visibleForTesting
  static Future<void> writeBackupZip(Map<String, dynamic> stateJson, String zipPath) async {
    final json = Map<String, dynamic>.from(stateJson);
    final photos = <Map<String, dynamic>>[];
    final encoder = ZipFileEncoder()..create(zipPath);
    try {
      for (final raw in (json['photos'] as List? ?? const [])) {
        final photo = Map<String, dynamic>.from(raw as Map);
        final file = File(photo['filePath'] as String);
        if (await file.exists()) {
          final name = '$_photosPrefix${photo['id']}${_extensionOf(file.path)}';
          await encoder.addFile(file, name);
          photo['filePath'] = name;
        }
        photos.add(photo);
      }
      json['photos'] = photos;
      encoder.addArchiveFile(ArchiveFile.string(_dataEntry, jsonEncode(json)));
    } finally {
      await encoder.close();
    }
  }

  /// Lets the user pick a backup (`.zip`, or a legacy `.json`) and returns
  /// its decoded state, or null if they cancelled / the file was invalid.
  /// For a zip, the photos are copied into the app's photos folder first and
  /// their paths in the returned state point at those copies.
  static Future<Map<String, dynamic>?> pickAndReadBackup() async {
    final picked = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: ['zip', 'json'],
    );
    if (picked == null) return null;
    // Read bytes rather than `path`: on Android the pick can be a
    // content:// URI with no local file path at all.
    final bytes = await picked.readAsBytes();

    if (picked.name.toLowerCase().endsWith('.json')) {
      final decoded = jsonDecode(utf8.decode(bytes));
      return decoded is Map<String, dynamic> ? decoded : null;
    }
    final docsDir = await getApplicationDocumentsDirectory();
    return readBackupZip(bytes, Directory('${docsDir.path}/photos'));
  }

  /// Reads a zip made by [writeBackupZip], copying its photos into
  /// [photosDir] and pointing the returned state's photo paths at them.
  @visibleForTesting
  static Future<Map<String, dynamic>?> readBackupZip(List<int> zipBytes, Directory photosDir) async {
    try {
      final archive = ZipDecoder().decodeBytes(zipBytes);
      final dataBytes = archive.findFile(_dataEntry)?.readBytes();
      if (dataBytes == null) return null;
      final decoded = jsonDecode(utf8.decode(dataBytes));
      if (decoded is! Map<String, dynamic>) return null;

      await photosDir.create(recursive: true);
      // Unique prefix so restoring the same backup twice never overwrites
      // a file the current state still points at.
      final stamp = DateTime.now().microsecondsSinceEpoch;

      final photos = <Map<String, dynamic>>[];
      for (final raw in (decoded['photos'] as List? ?? const [])) {
        final photo = Map<String, dynamic>.from(raw as Map);
        final inZip = photo['filePath'] as String? ?? '';
        final bytes = inZip.startsWith(_photosPrefix) ? archive.findFile(inZip)?.readBytes() : null;
        if (bytes != null) {
          // Basename only — a crafted path like `photos/../x` must not
          // escape the photos folder.
          final name = inZip.split(RegExp(r'[/\\]')).last;
          final dest = File('${photosDir.path}/${stamp}_$name');
          await dest.writeAsBytes(bytes, flush: true);
          photo['filePath'] = dest.path;
        }
        photos.add(photo);
      }
      decoded['photos'] = photos;
      return decoded;
    } on FormatException {
      // Not a zip / not our JSON (ArchiveException is a FormatException).
      return null;
    }
  }

  static String _extensionOf(String path) {
    final slash = path.lastIndexOf(RegExp(r'[/\\]'));
    final dot = path.lastIndexOf('.');
    return dot > slash ? path.substring(dot) : '.jpg';
  }
}
