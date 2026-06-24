import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:provider/provider.dart';
import 'package:snap_notes_mvvm/core/utils/toast_formatter.dart';
import 'package:snap_notes_mvvm/features/auth/viewmodels/register_viewmodel.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _konfirmasiPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureKonfirmasi = true;

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _konfirmasiPasswordController.dispose();
    super.dispose();
  }

  Future<void> _onDaftar() async {
    if (_passwordController.text != _konfirmasiPasswordController.text) {
      _showToastValidation('Password dan konfirmasi password tidak cocok');
      return;
    }

    final viewModel = context.read<RegisterViewModel>();
    await viewModel.register(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      namaLengkap: _namaController.text.trim(),
    );

    if (!mounted) return;

    if (viewModel.errorMessage != null) {
      _showToastError(viewModel.errorMessage!);
    } else if (viewModel.pengguna != null) {
      _showToastSuccess(
        'Akun berhasil dibuat! Selamat datang, ${viewModel.pengguna!.namaLengkap}',
      );
      Navigator.of(context).pop();
    }
  }

  void _showToastValidation(String message) {
    showToast(
      context: context,
      builder: (context, overlay) => ToastFormatter.validation(message),
      location: ToastLocation.bottomRight,
    );
  }

  void _showToastError(String message) {
    showToast(
      context: context,
      builder: (context, overlay) => ToastFormatter.error('Gagal Mendaftar', message),
      location: ToastLocation.bottomRight,
    );
  }

  void _showToastSuccess(String message) {
    showToast(
      context: context,
      builder: (context, overlay) => ToastFormatter.success('Akun berhasil dibuat', message),
      location: ToastLocation.bottomRight,
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<RegisterViewModel>();

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
                    const Text('Daftar').h2(),
                    const Gap(8),
                    const Text(
                      'Isi data berikut untuk membuat akun baru',
                    ).muted(),
                    const Gap(32),
                    _buildField(
                      label: 'Nama Lengkap',
                      controller: _namaController,
                      hint: 'Masukkan nama lengkap',
                      icon: LucideIcons.user,
                    ),
                    const Gap(16),
                    _buildField(
                      label: 'Email',
                      controller: _emailController,
                      hint: 'contoh@email.com',
                      icon: LucideIcons.mail,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const Gap(16),
                    _buildPasswordField(
                      label: 'Password',
                      controller: _passwordController,
                      obscure: _obscurePassword,
                      onToggle: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    const Gap(16),
                    _buildPasswordField(
                      label: 'Konfirmasi Password',
                      controller: _konfirmasiPasswordController,
                      obscure: _obscureKonfirmasi,
                      onToggle: () => setState(
                        () => _obscureKonfirmasi = !_obscureKonfirmasi,
                      ),
                    ),
                    const Gap(32),
                    PrimaryButton(
                      onPressed: viewModel.isLoading ? null : _onDaftar,
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
                                Text('Membuat akun...'),
                              ],
                            )
                          : const Text('Buat Akun'),
                    ),
                    const Gap(16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Sudah punya akun? ').muted(),
                        LinkButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Masuk'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label).medium(),
        const Gap(8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          placeholder: Text(hint),
          features: [InputFeature.leading(Icon(icon))],
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label).medium(),
        const Gap(8),
        TextField(
          controller: controller,
          obscureText: obscure,
          placeholder: const Text('Masukkan password'),
          features: [
            const InputFeature.leading(Icon(LucideIcons.lock)),
            InputFeature.trailing(
              IconButton.ghost(
                density: ButtonDensity.compact,
                icon: Icon(obscure ? LucideIcons.eyeOff : LucideIcons.eye),
                onPressed: onToggle,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
