import 'package:flutter/foundation.dart';
import 'package:snap_notes_mvvm/features/auth/models/auth_service.dart';
import 'package:snap_notes_mvvm/features/auth/models/auth_token.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthService _authService;

  LoginViewModel({required this._authService});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isGoogleLoading = false;
  bool get isGoogleLoading => _isGoogleLoading;

  AuthToken? _token;
  AuthToken? get token => _token;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setGoogleLoading(bool value) {
    _isGoogleLoading = value;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final tokenData = await _authService.login(email, password);
      _token = tokenData;
    } catch (e) {
      if (e is Exception) {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      } else {
        _errorMessage = e.toString();
      }
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loginWithGoogle() async {
    _setGoogleLoading(true);
    _errorMessage = null;
    try {
      final tokenData = await _authService.loginWithGoogle();
      _token = tokenData;
    } catch (e) {
      if (e is Exception) {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      } else {
        _errorMessage = e.toString();
      }
    } finally {
      _setGoogleLoading(false);
    }
  }

  void reset() {
    _isLoading = false;
    _isGoogleLoading = false;
    _token = null;
    _errorMessage = null;
    notifyListeners();
  }
}
