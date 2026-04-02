import 'dart:convert';
import 'package:crypto/crypto.dart';

class PinHasher {
  static const _salt = 'kiosko_v2_pos_salt';

  static String hash(String pin) {
    final bytes = utf8.encode('$_salt$pin');
    return sha256.convert(bytes).toString();
  }

  static bool verify(String pin, String hashedPin) {
    return hash(pin) == hashedPin;
  }
}
