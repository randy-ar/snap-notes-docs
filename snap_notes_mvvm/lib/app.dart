import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:provider/provider.dart';
import 'package:snap_notes_mvvm/core/di/injection.dart';
import 'package:snap_notes_mvvm/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:snap_notes_mvvm/features/auth/viewmodels/login_viewmodel.dart';
import 'package:snap_notes_mvvm/features/auth/views/pages/login_page.dart';
import 'package:snap_notes_mvvm/features/main/views/pages/main_page.dart';

class SnapNotesApp extends StatelessWidget {
  const SnapNotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ShadcnApp(
      title: 'Snap Notes',
      theme: ThemeData(radius: 0.5),
      home: ChangeNotifierProvider(
        create: (context) => getIt<AuthViewModel>()..checkAuth(),
        child: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();
    
    if (authViewModel.isLoading) {
      return const Scaffold(
        child: Center(child: CircularProgressIndicator()),
      );
    } else if (authViewModel.isAuthenticated) {
      return const MainPage();
    } else {
      return ChangeNotifierProvider(
        create: (context) => getIt<LoginViewModel>(),
        child: const LoginPage(),
      );
    }
  }
}

