import 'package:flutter/material.dart';
import 'package:pitstop/features/auth/data/auth_model.dart';
import 'package:pitstop/features/auth/data/auth_repository.dart';

// All possible states during any auth operation
enum AuthStatus { idle, loading, success, error }

// Manages auth state and connects UI to AuthRepository
class AuthProvider extends ChangeNotifier {
  final _repo = AuthRepository();

  AuthStatus _status       = AuthStatus.idle;
  String     _errorMessage = '';
  UserModel? _currentUser;

  AuthStatus get status       => _status;
  String     get errorMessage => _errorMessage;
  UserModel? get currentUser  => _currentUser;
  bool       get isLoading    => _status == AuthStatus.loading;

  // ── LOGIN ──────────────────────────────────────────────────────────────────
  Future<bool> login(String email, String password) async {
    _setLoading();
    try {
      final result = await _repo.login(
        LoginRequest(email: email, password: password),
      );
      _currentUser = result.user;
      _setSuccess();
      return true;
    } catch (e) {
      _setError(e.toString().replaceFirst('Exception: ', ''));
      return false;
    }
  }

  // ── CHANGE PASSWORD ────────────────────────────────────────────────────────
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _setLoading();
    try {
      await _repo.changePassword(
        currentPassword: currentPassword,
        newPassword:     newPassword,
      );
      _setSuccess();
      return true;
    } catch (e) {
      _setError(e.toString().replaceFirst('Exception: ', ''));
      return false;
    }
  }

  // ── GET PROFILE ────────────────────────────────────────────────────────────
  Future<void> loadProfile() async {
    try {
      _currentUser = await _repo.getProfile();
      notifyListeners();
    } catch (_) {
      // Silently fail — user stays on current data
    }
  }

  // ── LOGOUT ─────────────────────────────────────────────────────────────────
  Future<void> logout() async {
    await _repo.logout();
    _currentUser = null;
    _status = AuthStatus.idle;
    notifyListeners();
  }

  // ── CHECK SESSION on app startup ───────────────────────────────────────────
  Future<bool> checkLoginStatus() async {
    return await _repo.isLoggedIn();
  }

  // ── Reset error before next attempt ───────────────────────────────────────
  void resetError() {
    _status = AuthStatus.idle;
    _errorMessage = '';
    notifyListeners();
  }

  void _setLoading() {
    _status = AuthStatus.loading;
    _errorMessage = '';
    notifyListeners();
  }

  void _setSuccess() {
    _status = AuthStatus.success;
    notifyListeners();
  }

  void _setError(String message) {
    _status = AuthStatus.error;
    _errorMessage = message;
    notifyListeners();
  }
}