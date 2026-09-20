import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage();
  static const String _tokenKey = 'api_token';
  Future<void> saveToken(String token) async {
    // TODO: ใช้ write()
    await _storage.write(key: _tokenKey, value: token);
  }
  Future<String?> getToken() async {
    // TODO: ใช้ read()
    return await _storage.read(key: _tokenKey);
  }

  Future<void> deleteToken() async {
    // TODO: ใช้ delete()
    await _storage.delete(key: _tokenKey);
  }
}
