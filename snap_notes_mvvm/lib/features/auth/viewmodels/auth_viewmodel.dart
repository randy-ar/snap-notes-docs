import 'package:flutter/foundation.dart';
import 'package:snap_notes_mvvm/features/auth/models/auth_service.dart';
import 'package:snap_notes_mvvm/features/auth/models/pengguna.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService;

  AuthViewModel({required this._authService});

  bool _isCheckingAuth = false; // Set initial ke false, hindari skeleton muncul jika tidak perlu
  bool get isLoading => _isCheckingAuth;

  bool _isAuthenticated = false;
  bool get isAuthenticated => _isAuthenticated;

  Pengguna? _pengguna;
  Pengguna? get pengguna => _pengguna;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void _setLoading(bool value) {
    _isCheckingAuth = value;
    notifyListeners();
  }

  Future<void> checkAuth() async {
    try {
      final isTokenExist = await _authService.isAuthenticated();
      if (!isTokenExist) {
        _isAuthenticated = false;
        _pengguna = null;
        notifyListeners();
        return;
      }

      // Optimistic authentication jika token lokal ada, langsung asumsikan terautentikasi
      _isAuthenticated = true;
      notifyListeners();

      // Pengecekan profil / refresh token berjalan di latar belakang (background)
      final penggunaData = await _authService.getProfile();
      _pengguna = penggunaData;
      notifyListeners();
    } catch (e) {
      _isAuthenticated = false;
      _pengguna = null;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isCheckingAuth = true;
    notifyListeners();
    _errorMessage = null;
    try {
      await _authService.logout();
      _isAuthenticated = false;
      _pengguna = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isCheckingAuth = false;
      notifyListeners();
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
