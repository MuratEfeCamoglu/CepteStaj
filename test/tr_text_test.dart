import 'package:cepte_staj/core/tr_text.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Turkish uppercase keeps dotted and dotless i apart', () {
    expect('Bildirimler'.toUpperTr(), 'BİLDİRİMLER');
    expect('Çarşamba, 14 Ekim'.toUpperTr(), 'ÇARŞAMBA, 14 EKİM');
    expect('Hızlı sayaçlar'.toUpperTr(), 'HIZLI SAYAÇLAR');
    expect('gizlilik ığüşöç'.toUpperTr(), 'GİZLİLİK IĞÜŞÖÇ');
  });
}
