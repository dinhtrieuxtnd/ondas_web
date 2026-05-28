import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ondas_web/core/constants/app_constants.dart';

class SecureStorage {
  final FlutterSecureStorage _storage;

  const SecureStorage(this._storage);

  Future<void> saveAccessToken(String token) =>
      _storage.write(key: AppConstants.accessTokenKey, value: token);

  Future<void> saveRefreshToken(String token) =>
      _storage.write(key: AppConstants.refreshTokenKey, value: token);

  Future<String?> getAccessToken() =>
      _storage.read(key: AppConstants.accessTokenKey);

  Future<String?> getRefreshToken() =>
      _storage.read(key: AppConstants.refreshTokenKey);

  Future<void> saveUserRole(String role) =>
      _storage.write(key: AppConstants.userRoleKey, value: role);

  Future<String?> getUserRole() =>
      _storage.read(key: AppConstants.userRoleKey);

  Future<void> saveUserDisplayName(String displayName) =>
      _storage.write(key: AppConstants.userDisplayNameKey, value: displayName);

  Future<String?> getUserDisplayName() =>
      _storage.read(key: AppConstants.userDisplayNameKey);

  Future<void> saveUserEmail(String email) =>
      _storage.write(key: AppConstants.userEmailKey, value: email);

  Future<String?> getUserEmail() =>
      _storage.read(key: AppConstants.userEmailKey);

  Future<void> saveLanguageCode(String languageCode) =>
      _storage.write(key: AppConstants.languageCodeKey, value: languageCode);

  Future<String?> getLanguageCode() =>
      _storage.read(key: AppConstants.languageCodeKey);

  Future<void> clearAll() => _storage.deleteAll();
}
