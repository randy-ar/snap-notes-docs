import 'package:flutter/foundation.dart';
import 'package:snap_notes_mvvm/features/auth/models/auth_service.dart';
import 'package:snap_notes_mvvm/features/auth/models/pengguna.dart';

class RegisterViewModel extends ChangeNotifier {
  final AuthService _authService;

  RegisterViewModel({required this._authService});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Pengguna? _pengguna;
  Pengguna? get pengguna => _pengguna;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> register({
    required String email,
    required String password,
    required String namaLengkap,
  }) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final penggunaData = await _authService.register(email, password, namaLengkap);
      _pengguna = penggunaData;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  void reset() {
    _isLoading = false;
    _pengguna = null;
    _errorMessage = null;
    notifyListeners();
  }
}
