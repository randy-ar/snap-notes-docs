import 'package:flutter/foundation.dart';
import 'package:snap_notes_mvvm/features/auth/models/auth_service.dart';
import 'package:snap_notes_mvvm/features/auth/models/pengguna.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService;

  AuthViewModel({required this._authService});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isAuthenticated = false;
  bool get isAuthenticated => _isAuthenticated;

  Pengguna? _pengguna;
  Pengguna? get pengguna => _pengguna;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> checkAuth() async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final penggunaData = await _authService.getProfile();
      _pengguna = penggunaData;
      _isAuthenticated = true;
    } catch (e) {
      _isAuthenticated = false;
      _pengguna = null;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    _errorMessage = null;
    try {
      await _authService.logout();
      _isAuthenticated = false;
      _pengguna = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  void updateUser(dynamic penggunaData) {
    if (penggunaData != null && penggunaData is Pengguna) {
      _pengguna = penggunaData;
      _isAuthenticated = true;
      notifyListeners();
    }
  }
}
