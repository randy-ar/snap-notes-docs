import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:provider/provider.dart';
import 'package:snap_notes_mvvm/core/di/injection.dart';
import 'package:snap_notes_mvvm/features/auth/viewmodels/login_viewmodel.dart';
import 'package:snap_notes_mvvm/features/auth/viewmodels/register_viewmodel.dart';
import 'package:snap_notes_mvvm/features/auth/views/pages/register_page.dart';
import 'package:snap_notes_mvvm/features/main/views/pages/main_page.dart';
import 'package:snap_notes_mvvm/features/auth/viewmodels/auth_viewmodel.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final viewModel = context.read<LoginViewModel>();
    await viewModel.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) return;

    if (viewModel.errorMessage != null) {
      _showErrorToast(viewModel.errorMessage!);
    } else if (viewModel.token != null) {
      await context.read<AuthViewModel>().checkAuth();
    }
  }

  Future<void> _handleGoogleLogin() async {
    final viewModel = context.read<LoginViewModel>();
    await viewModel.loginWithGoogle();

    if (!mounted) return;

    if (viewModel.errorMessage != null) {
      _showErrorToast(viewModel.errorMessage!);
    } else if (viewModel.token != null) {
      await context.read<AuthViewModel>().checkAuth();
    }
  }

  void _showErrorToast(String message) {
    showToast(
      context: context,
      builder: (context, overlay) {
        return SurfaceCard(
          child: Basic(
            title: const Text('Gagal Masuk'),
            subtitle: Text(message),
            trailing: PrimaryButton(
              size: ButtonSize.small,
              onPressed: () => overlay.close(),
              child: const Text('Tutup'),
            ),
            trailingAlignment: Alignment.center,
          ),
        );
      },
      location: ToastLocation.bottomRight,
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<LoginViewModel>();
    
    return Scaffold(
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Card(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeader(),
                    const Gap(32),
                    _buildEmailField(),
                    const Gap(16),
                    _buildPasswordField(),
                    const Gap(24),
                    _buildLoginButton(viewModel),
                    const Gap(16),
                    _buildDivider(),
                    const Gap(16),
                    _buildGoogleLoginButton(viewModel),
                    const Gap(24),
                    _buildRegisterLink(context),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Masuk').h2(),
        const Gap(8),
        const Text('Masukkan email dan password untuk melanjutkan').muted(),
      ],
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Email').medium(),
        const Gap(8),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          placeholder: const Text('contoh@email.com'),
          features: const [
            InputFeature.leading(Icon(LucideIcons.mail)),
          ],
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Password').medium(),
        const Gap(8),
        TextField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          placeholder: const Text('Masukkan password'),
          features: [
            const InputFeature.leading(Icon(LucideIcons.lock)),
            InputFeature.trailing(
              IconButton.ghost(
                density: ButtonDensity.compact,
                icon: Icon(
                  _obscurePassword ? LucideIcons.eyeOff : LucideIcons.eye,
                ),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLoginButton(LoginViewModel viewModel) {
    return PrimaryButton(
      onPressed: viewModel.isLoading ? null : _handleLogin,
      child: viewModel.isLoading
          ? const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(),
                ),
                Gap(8),
                Text('Sedang masuk...'),
              ],
            )
          : const Text('Masuk'),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: const Text('atau').muted(),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }

  Widget _buildGoogleLoginButton(LoginViewModel viewModel) {
    return OutlineButton(
      onPressed: viewModel.isGoogleLoading ? null : _handleGoogleLogin,
      leading: viewModel.isGoogleLoading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Image.network(
              'https://www.google.com/favicon.ico',
              width: 20,
              height: 20,
              errorBuilder: (context, error, stackTrace) => const Icon(LucideIcons.chrome),
            ),
      child: Text(
        viewModel.isGoogleLoading ? 'Menghubungi Google...' : 'Masuk dengan Google',
      ),
    );
  }

  Widget _buildRegisterLink(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Belum punya akun? ').muted(),
        LinkButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ChangeNotifierProvider(
                  create: (_) => getIt<RegisterViewModel>(),
                  child: const RegisterPage(),
                ),
              ),
            );
          },
          child: const Text('Daftar sekarang'),
        ),
      ],
    );
  }
}

