import 'package:snap_notes/core/error/exceptions.dart';
import 'package:snap_notes/features/auth/data/models/auth_token_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AuthSupabaseDataSource {
  /// Login dengan Google OAuth via Supabase
  Future<AuthTokenModel> signInWithGoogle();

  /// Logout dari Supabase session
  Future<void> signOut();

  /// Cek apakah ada session Supabase yang aktif
  Future<AuthTokenModel?> getCurrentSession();
}

class AuthSupabaseDataSourceImpl implements AuthSupabaseDataSource {
  final SupabaseClient supabaseClient;

  AuthSupabaseDataSourceImpl({required this.supabaseClient});

  @override
  Future<AuthTokenModel> signInWithGoogle() async {
    try {
      await supabaseClient.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'snapnotes://auth',
        authScreenLaunchMode: LaunchMode.externalApplication,
      );

      // Tunggu hingga auth state berubah menjadi authenticated
      final session = await _waitForSession();

      if (session == null) {
        throw OAuthException('Login Google dibatalkan atau gagal');
      }

      return _sessionToTokenModel(session);
    } on OAuthException {
      rethrow;
    } catch (e) {
      throw OAuthException('Login Google gagal: ${e.toString()}');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await supabaseClient.auth.signOut();
    } catch (e) {
      throw OAuthException('Logout Supabase gagal: ${e.toString()}');
    }
  }

  @override
  Future<AuthTokenModel?> getCurrentSession() async {
    final session = supabaseClient.auth.currentSession;
    if (session == null) return null;
    return _sessionToTokenModel(session);
  }

  /// Menunggu perubahan auth state setelah OAuth redirect
  Future<Session?> _waitForSession() async {
    // Cek session yang sudah ada terlebih dahulu
    final currentSession = supabaseClient.auth.currentSession;
    if (currentSession != null) return currentSession;

    // Tunggu event dari onAuthStateChange (timeout 60 detik)
    try {
      final session = await supabaseClient.auth.onAuthStateChange
          .where((event) => event.event == AuthChangeEvent.signedIn)
          .map((event) => event.session)
          .first
          .timeout(const Duration(seconds: 60));
      return session;
    } catch (_) {
      return null;
    }
  }

  AuthTokenModel _sessionToTokenModel(Session session) {
    final user = session.user;
    return AuthTokenModel(
      accessToken: session.accessToken,
      refreshToken: session.refreshToken ?? '',
      userId: user.id,
      email: user.email ?? '',
    );
  }
}
