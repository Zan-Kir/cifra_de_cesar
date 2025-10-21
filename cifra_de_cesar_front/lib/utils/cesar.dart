class Cesar {
  // Normaliza shift para 0..25
  static int _normShift(int shift) {
    final s = shift % 26;
    return s < 0 ? s + 26 : s;
  }

  static String encode(String input, int shift) {
    final s = _normShift(shift);
    final buffer = StringBuffer();
    for (var i = 0; i < input.length; i++) {
      final code = input.codeUnitAt(i);
      if (code >= 65 && code <= 90) {
        // A-Z
        final base = 65;
        buffer.writeCharCode(((code - base + s) % 26) + base);
      } else if (code >= 97 && code <= 122) {
        // a-z
        final base = 97;
        buffer.writeCharCode(((code - base + s) % 26) + base);
      } else {
        buffer.writeCharCode(code);
      }
    }
    return buffer.toString();
  }

  static String decode(String input, int shift) {
    return encode(input, -shift);
  }
}
