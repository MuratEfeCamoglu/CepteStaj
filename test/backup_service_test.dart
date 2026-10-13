import 'dart:io';

import 'package:cepte_staj/core/backup_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory tmp;

  setUp(() async {
    tmp = await Directory.systemTemp.createTemp('cepte_backup_test');
  });

  tearDown(() async {
    await tmp.delete(recursive: true);
  });

  test('zip backup round-trips the state and carries photo files along', () async {
    final photo = File('${tmp.path}/orig/123.jpg');
    await photo.create(recursive: true);
    await photo.writeAsBytes([1, 2, 3, 4]);

    final state = {
      'internship': {'name': 'Yazılım Stajı'},
      'photos': [
        {'id': 'p1', 'date': '2026-10-13', 'filePath': photo.path, 'caption': 'masam', 'includeInExport': true},
        {'id': 'p2', 'date': '2026-10-14', 'filePath': '${tmp.path}/gone.jpg', 'caption': '', 'includeInExport': false},
      ],
    };
    final zipPath = '${tmp.path}/yedek.zip';
    await BackupService.writeBackupZip(state, zipPath);

    // Restore as if on a new phone: the original photo is gone.
    await photo.delete();
    final restoreDir = Directory('${tmp.path}/restored_photos');
    final restored = await BackupService.readBackupZip(File(zipPath).readAsBytesSync(), restoreDir);

    expect(restored, isNotNull);
    expect((restored!['internship'] as Map)['name'], 'Yazılım Stajı');
    final photos = restored['photos'] as List;
    expect(photos, hasLength(2));

    final p1 = photos[0] as Map;
    expect(p1['caption'], 'masam');
    expect(p1['includeInExport'], isTrue);
    expect(p1['filePath'], startsWith(restoreDir.path));
    expect(await File(p1['filePath'] as String).readAsBytes(), [1, 2, 3, 4]);

    // A photo whose file was already missing keeps its entry and old path.
    expect((photos[1] as Map)['filePath'], '${tmp.path}/gone.jpg');
  });

  test('a file that is not a backup zip fails to read', () async {
    final zipPath = '${tmp.path}/bos.zip';
    await BackupService.writeBackupZip({'photos': []}, zipPath);
    // Sanity: the valid one reads back…
    expect(await BackupService.readBackupZip(File(zipPath).readAsBytesSync(), Directory('${tmp.path}/p')), isNotNull);
    // …while an arbitrary non-backup file does not.
    final junk = File('${tmp.path}/junk.zip')..writeAsBytesSync([0, 1, 2, 3]);
    expect(await BackupService.readBackupZip(junk.readAsBytesSync(), Directory('${tmp.path}/p')), isNull);
  });
}
