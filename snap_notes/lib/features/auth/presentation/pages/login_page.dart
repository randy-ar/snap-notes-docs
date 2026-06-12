import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:snap_notes/features/auth/presentation/cubit/login_cubit.dart';
import 'package:snap_notes/features/auth/presentation/cubit/login_state.dart';
import 'package:snap_notes/features/auth/presentation/cubit/register_cubit.dart';
import 'package:snap_notes/features/auth/presentation/pages/register_page.dart';
import 'package:snap_notes/features/main/presentation/pages/main_page.dart';
import 'package:snap_notes/injection_container.dart' as di;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      child: BlocConsumer<LoginCubit, LoginState>(
        listener: (context, state) {
          if (state is LoginSuccess) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (_) => const MainPage(),
              ),
              (route) => false,
            );
          } else if (state is LoginError) {
            showToast(
              context: context,
              builder: (context, overlay) {
                return SurfaceCard(
                  child: Basic(
                    title: const Text('Gagal Masuk'),
                    subtitle: Text(state.message),
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
        },
        builder: (context, state) {
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Gap(48),
                  _buildHeader(),
                  const Gap(40),
                  _buildEmailField(),
                  const Gap(16),
                  _buildPasswordField(),
                  const Gap(24),
                  _buildLoginButton(context, state),
                  const Gap(16),
                  _buildDivider(),
                  const Gap(16),
                  _buildGoogleLoginButton(context, state),
                  const Gap(24),
                  _buildRegisterLink(context),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        const Icon(Icons.receipt_long, size: 64),
        const Gap(16),
        const Text(
          'Snap Notes',
          textAlign: TextAlign.center,
        ).h1(),
        const Gap(8),
        const Text(
          'Catat pengeluaran dari struk belanja',
          textAlign: TextAlign.center,
        ).muted(),
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
            InputFeature.leading(Icon(Icons.email_outlined)),
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
            const InputFeature.leading(Icon(Icons.lock_outlined)),
            InputFeature.trailing(
              IconButton.ghost(
                density: ButtonDensity.compact,
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLoginButton(BuildContext context, LoginState state) {
    final isLoading = state is LoginLoading;
    return PrimaryButton(
      onPressed: isLoading
          ? null
          : () => context.read<LoginCubit>().login(
                _emailController.text.trim(),
                _passwordController.text,
              ),
      child: isLoading
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

  Widget _buildGoogleLoginButton(BuildContext context, LoginState state) {
    final isLoading = state is LoginGoogleLoading;
    return OutlineButton(
      onPressed: isLoading
          ? null
          : () => context.read<LoginCubit>().loginDenganGoogle(),
      leading: isLoading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Image.network(
              'https://www.google.com/favicon.ico',
              width: 20,
              height: 20,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.g_mobiledata),
            ),
      child: Text(
        isLoading ? 'Menghubungi Google...' : 'Masuk dengan Google',
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
                builder: (_) => BlocProvider(
                  create: (_) => di.sl<RegisterCubit>(),
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
