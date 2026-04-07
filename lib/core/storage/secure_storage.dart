import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Saves and reads auth tokens and user info securely on the device.
class SecureStorage {
  static const _storage = FlutterSecureStorage(
    webOptions: WebOptions(
      dbName: 'pitstop_secure_storage',
      publicKey: 'pitstop_web',
    ),
  );

  static const _tokenKey        = 'auth_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _userIdKey       = 'user_id';
  static const _userNameKey     = 'user_name';
  static const _userEmailKey    = 'user_email';
  static const _firstNameKey    = 'first_name';
  static const _lastNameKey     = 'last_name';
  static const _crmIdKey        = 'crm_id';
  static const _loggedOutKey    = 'logged_out';
  static const _hasLoggedInKey  = 'has_logged_in';

  // ── Access Token ───────────────────────────────────────────────────────────

  static Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  static Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }

  // ── Refresh Token ──────────────────────────────────────────────────────────

  static Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: _refreshTokenKey, value: token);
  }

  static Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  // ── User Info ──────────────────────────────────────────────────────────────

  static Future<void> saveUserInfo({
    required String userId,
    required String name,
    required String email,
    required String firstName,
    required String lastName,
    String? crmId,
  }) async {
    await _storage.write(key: _userIdKey,    value: userId);
    await _storage.write(key: _userNameKey,  value: name);
    await _storage.write(key: _userEmailKey, value: email);
    await _storage.write(key: _firstNameKey, value: firstName);
    await _storage.write(key: _lastNameKey,  value: lastName);
    if (crmId != null && crmId.isNotEmpty) {
      await _storage.write(key: _crmIdKey, value: crmId);
    }
  }

  static Future<Map<String, String?>> getUserInfo() async {
    return {
      'id':        await _storage.read(key: _userIdKey),
      'name':      await _storage.read(key: _userNameKey),
      'email':     await _storage.read(key: _userEmailKey),
      'firstName': await _storage.read(key: _firstNameKey),
      'lastName':  await _storage.read(key: _lastNameKey),
      'crmId':     await _storage.read(key: _crmIdKey),
    };
  }

  static Future<String?> getCrmId() async {
    return await _storage.read(key: _crmIdKey);
  }

  // ── Clear everything on logout ─────────────────────────────────────────────

  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  // ── Logged-out flag (force login on next launch) ───────────────────────────
  static Future<void> setLoggedOut(bool value) async {
    await _storage.write(key: _loggedOutKey, value: value ? '1' : '0');
  }

  static Future<bool> getLoggedOut() async {
    final value = await _storage.read(key: _loggedOutKey);
    return value == '1';
  }

  static Future<void> clearLoggedOut() async {
    await _storage.delete(key: _loggedOutKey);
  }

  // ── First-time login flag ──────────────────────────────────────────────────
  static Future<void> setHasLoggedIn(bool value) async {
    await _storage.write(key: _hasLoggedInKey, value: value ? '1' : '0');
  }

  static Future<bool> getHasLoggedIn() async {
    final value = await _storage.read(key: _hasLoggedInKey);
    return value == '1';
  }
}