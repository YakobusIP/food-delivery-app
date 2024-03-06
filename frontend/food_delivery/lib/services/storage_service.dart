import "package:flutter_secure_storage/flutter_secure_storage.dart";

class SecureStorageService {
  static final SecureStorageService _instance =
      SecureStorageService._internal();
  factory SecureStorageService() => _instance;
  SecureStorageService._internal();

  final _storage = const FlutterSecureStorage();

  void storeAuthResponse(
    String username,
    String role,
    String accessToken,
    String refreshToken,
  ) async {
    await _storage.write(key: "username", value: username);
    await _storage.write(key: "role", value: role);
    await _storage.write(key: "accessToken", value: accessToken);
    await _storage.write(key: "refreshToken", value: refreshToken);
  }

  Future<String?> get(String key) async {
    return await _storage.read(key: key);
  }

  Future<void> set(String key, String value) async {
    return await _storage.write(key: key, value: value);
  }

  Future<void> delete(String key) async {
    return await _storage.delete(key: key);
  }

  Future<void> deleteAll() async {
    return await _storage.deleteAll();
  }
}
