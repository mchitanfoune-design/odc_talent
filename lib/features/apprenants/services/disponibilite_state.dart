import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DisponibiliteState {
  static const _storageKey = 'apprenant_disponibilite';
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static final ValueNotifier<bool> notifier = ValueNotifier<bool>(true);

  static Future<void> load() async {
    final value = await _storage.read(key: _storageKey);
    notifier.value = value == 'false' ? false : true;
  }

  static Future<void> set(bool value) async {
    notifier.value = value;
    await _storage.write(key: _storageKey, value: value ? 'true' : 'false');
  }

  static bool get current => notifier.value;
}
