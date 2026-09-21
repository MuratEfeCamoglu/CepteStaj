/// Tiny local-only id generator — good enough for a single-device,
/// no-backend app where ids only need to be unique within this install.
class IdGen {
  IdGen._();
  static int _counter = 0;

  static String next() {
    _counter++;
    return '${DateTime.now().microsecondsSinceEpoch}_$_counter';
  }
}
