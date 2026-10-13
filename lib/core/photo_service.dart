import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

/// Picks a photo (camera or gallery) and copies it into the app's own
/// documents folder, per claude.md: "dosya uygulama dizinine kopyalanır
/// (galeriden silinirse kaybolmasın)".
class PhotoService {
  PhotoService._();
  static final _picker = ImagePicker();

  static Future<String?> pickAndStore({required bool fromCamera}) async {
    final XFile? picked = await _picker.pickImage(
      source: fromCamera ? ImageSource.camera : ImageSource.gallery,
      maxWidth: 2000,
      imageQuality: 85,
    );
    if (picked == null) return null;

    final docsDir = await getApplicationDocumentsDirectory();
    final photosDir = Directory('${docsDir.path}/photos');
    if (!await photosDir.exists()) {
      await photosDir.create(recursive: true);
    }
    final ext = picked.path.contains('.') ? picked.path.split('.').last : 'jpg';
    final destPath = '${photosDir.path}/${DateTime.now().microsecondsSinceEpoch}.$ext';
    await File(picked.path).copy(destPath);
    return destPath;
  }

  /// Removes every stored photo file — used by "Tüm verileri sıfırla",
  /// which promises the photos are gone, not just unlinked.
  static Future<void> deleteAll() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final photosDir = Directory('${docsDir.path}/photos');
    if (await photosDir.exists()) {
      await photosDir.delete(recursive: true);
    }
  }

  /// Deletes files in the photos folder that [keepPaths] no longer points
  /// at — after a restore, the replaced state's photos are orphans.
  static Future<void> deleteUnreferenced(Set<String> keepPaths) async {
    final docsDir = await getApplicationDocumentsDirectory();
    final photosDir = Directory('${docsDir.path}/photos');
    if (!await photosDir.exists()) return;
    await for (final f in photosDir.list()) {
      if (f is File && !keepPaths.contains(f.path)) {
        await f.delete();
      }
    }
  }
}
