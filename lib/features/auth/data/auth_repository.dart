import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pitstop/core/network/api_constants.dart';
import 'package:pitstop/core/storage/secure_storage.dart';
import 'auth_model.dart';

// Only file that makes direct HTTP calls for authentication.
class AuthRepository {

  // ── LOGIN ──────────────────────────────────────────────────────────────────
  Future<AuthResponse> login(LoginRequest request) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.baseUrl + ApiConstants.signIn),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      ).timeout(ApiConstants.timeout);

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        final result = AuthResponse.fromJson(data);
        // Save both tokens and user info
        await SecureStorage.saveToken(result.accessToken);
        await SecureStorage.saveRefreshToken(result.refreshToken);
        await SecureStorage.clearLoggedOut();
        await SecureStorage.setHasLoggedIn(true);
        await SecureStorage.saveUserInfo(
          userId:    result.user.id,
          name:      result.user.fullName,
          email:     result.user.email,
          firstName: result.user.firstName,
          lastName:  result.user.lastName,
          crmId:     result.user.crmId,
        );
        return result;
      } else {
        final message = data['message']?.toString()
            ?? data['error']?.toString()
            ?? 'Login failed. Please try again.';
        throw Exception(message);
      }
    } on Exception {
      rethrow;
    } catch (_) {
      throw Exception('Connection error. Please check your internet.');
    }
  }

  // ── LOGOUT ─────────────────────────────────────────────────────────────────
  Future<void> logout() async {
    try {
      final token = await SecureStorage.getToken();
      if (token != null) {
        await http.post(
          Uri.parse(ApiConstants.baseUrl + ApiConstants.signOut),
          headers: {
            'Content-Type':  'application/json',
            'Authorization': 'Bearer $token',
          },
        ).timeout(ApiConstants.timeout);
      }
    } catch (_) {
      // Even if API call fails, still clear local data
    } finally {
      await SecureStorage.clearAll();
      await SecureStorage.setLoggedOut(true);
    }
  }

  // ── REFRESH TOKEN ──────────────────────────────────────────────────────────
  Future<void> refreshToken() async {
    try {
      final refreshToken = await SecureStorage.getRefreshToken();
      if (refreshToken == null) throw Exception('No refresh token found.');

      final response = await http.post(
        Uri.parse(ApiConstants.baseUrl + ApiConstants.refreshToken),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      ).timeout(ApiConstants.timeout);

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        // Save new access token
        final newToken = data['data']?['accessToken']?.toString() ?? '';
        await SecureStorage.saveToken(newToken);
      } else {
        // Refresh failed — force logout
        await SecureStorage.clearAll();
        throw Exception('Session expired. Please login again.');
      }
    } catch (_) {
      await SecureStorage.clearAll();
      rethrow;
    }
  }

  // ── GET PROFILE ────────────────────────────────────────────────────────────
  Future<UserModel> getProfile() async {
    final token = await SecureStorage.getToken();
    if (token == null) throw Exception('Not authenticated.');

    final response = await http.get(
      Uri.parse(ApiConstants.baseUrl + ApiConstants.getProfile),
      headers: {
        'Content-Type':  'application/json',
        'Authorization': 'Bearer $token',
      },
    ).timeout(ApiConstants.timeout);

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200) {
      return UserModel.fromJson(
        data['data'] as Map<String, dynamic>? ?? {},
      );
    } else {
      throw Exception(data['message']?.toString() ?? 'Failed to load profile.');
    }
  }

  // ── UPDATE PROFILE AVATAR ──────────────────────────────────────────────────
  Future<void> updateAvatar(String avatarBase64) async {
    final token = await SecureStorage.getToken();
    if (token == null) throw Exception('Not authenticated.');

    final response = await http.patch(
      Uri.parse(ApiConstants.baseUrl + ApiConstants.updateAvatar),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'avatarBase64': avatarBase64}),
    ).timeout(ApiConstants.timeout);

    Map<String, dynamic>? data;
    try {
      data = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      data = null;
    }

    final successFlag = data?['success'] as bool?;
    if (response.statusCode < 200 ||
        response.statusCode >= 300 ||
        successFlag == false) {
      final message = data?['message']?.toString()
          ?? data?['error']?.toString()
          ?? 'Failed to update avatar. (${response.statusCode})';
      throw Exception(message);
    }
  }

  // ── UPDATE PROFILE ─────────────────────────────────────────────────────────
  Future<UserModel> updateProfile(Map<String, dynamic> payload) async {
    final token = await SecureStorage.getToken();
    if (token == null) throw Exception('Not authenticated.');

    final response = await http.patch(
      Uri.parse(ApiConstants.baseUrl + ApiConstants.updateProfile),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(payload),
    ).timeout(ApiConstants.timeout);

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode == 200) {
      return UserModel.fromJson(
        data['data'] as Map<String, dynamic>? ?? {},
      );
    }

    final message = data['message']?.toString()
        ?? data['error']?.toString()
        ?? 'Failed to update profile.';
    throw Exception(message);
  }

  // ── CHANGE PASSWORD ────────────────────────────────────────────────────────
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final token = await SecureStorage.getToken();
    if (token == null) throw Exception('Not authenticated.');

    final response = await http.post(
      Uri.parse(ApiConstants.baseUrl + ApiConstants.changePassword),
      headers: {
        'Content-Type':  'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'currentPassword': currentPassword,
        'newPassword':     newPassword,
        'confirmPassword': confirmPassword,
      }),
    ).timeout(ApiConstants.timeout);

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200) {
      final message = data['message']?.toString()
          ?? data['error']?.toString()
          ?? 'Failed to change password.';
      throw Exception(message);
    }
  }

  // ── CHECK SESSION ──────────────────────────────────────────────────────────
  Future<bool> isLoggedIn() async {
    final token = await SecureStorage.getToken();
    return token != null && token.isNotEmpty;
  }
}