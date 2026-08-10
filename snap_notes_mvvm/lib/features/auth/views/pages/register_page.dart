import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:provider/provider.dart';
import 'package:snap_notes_mvvm/core/utils/toast_formatter.dart';
import 'package:snap_notes_mvvm/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:snap_notes_mvvm/features/auth/viewmodels/register_viewmodel.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _namaKey = const TextFieldKey('namaLengkap');
  final _emailKey = const TextFieldKey('email');
  final _passwordKey = const TextFieldKey('password');
  final _konfirmasiPasswordKey = const TextFieldKey('konfirmasiPassword');

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

  Future<void> _onDaftar(String nama, String email, String password) async {
    final viewModel = context.read<RegisterViewModel>();
    await viewModel.register(
      email: email.trim(),
      password: password,
      namaLengkap: nama.trim(),
    );

    if (!mounted) return;

    if (viewModel.errorMessage != null) {
      _showToastError(viewModel.errorMessage!);
    } else if (viewModel.pengguna != null) {
      _showToastSuccess(
        'Selamat datang, ${viewModel.pengguna!.namaLengkap}',
      );
      context.read<AuthViewModel>().checkAuth();
      Navigator.of(context).pop();
    }
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
                child: Form(
                  onSubmit: (context, values) async {
                    final nama = _namaKey[values] ?? _namaController.text;
                    final email = _emailKey[values] ?? _emailController.text;
                    final password = _passwordKey[values] ?? _passwordController.text;
                    await _onDaftar(nama, email, password);
                  },
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
                      FormField<String>(
                        key: _namaKey,
                        label: const Text('Nama Lengkap'),
                        showErrors: const {
                          FormValidationMode.changed,
                          FormValidationMode.submitted,
                        },
                        validator: const NotEmptyValidator(message: 'Nama lengkap wajib diisi'),
                        child: TextField(
                          controller: _namaController,
                          placeholder: const Text('Masukkan nama lengkap'),
                          features: const [InputFeature.leading(Icon(LucideIcons.user))],
                        ),
                      ),
                      const Gap(16),
                      FormField<String>(
                        key: _emailKey,
                        label: const Text('Email'),
                        showErrors: const {
                          FormValidationMode.changed,
                          FormValidationMode.submitted,
                        },
                        validator: const EmailValidator(message: 'Format email tidak valid') &
                            const NotEmptyValidator(message: 'Email wajib diisi') &
                            ValidationMode(
                              ConditionalValidator((value) async {
                                if (value == null || value.isEmpty) return true;
                                return value.contains('@');
                              }, message: 'Format email tidak valid'),
                              mode: {FormValidationMode.submitted},
                            ),
                        child: TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          placeholder: const Text('contoh@email.com'),
                          features: const [InputFeature.leading(Icon(LucideIcons.mail))],
                        ),
                      ),
                      const Gap(16),
                      FormField<String>(
                        key: _passwordKey,
                        label: const Text('Password'),
                        showErrors: const {
                          FormValidationMode.changed,
                          FormValidationMode.submitted,
                        },
                        validator: const LengthValidator(min: 6, message: 'Password minimal 6 karakter') &
                            const NotEmptyValidator(message: 'Password wajib diisi'),
                        child: TextField(
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
                                onPressed: () =>
                                    setState(() => _obscurePassword = !_obscurePassword),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Gap(16),
                      FormField<String>(
                        key: _konfirmasiPasswordKey,
                        label: const Text('Konfirmasi Password'),
                        showErrors: const {
                          FormValidationMode.changed,
                          FormValidationMode.submitted,
                        },
                        validator: CompareWith.equal(_passwordKey,
                                message: 'Password dan konfirmasi password tidak cocok') &
                            const NotEmptyValidator(message: 'Konfirmasi password wajib diisi'),
                        child: TextField(
                          controller: _konfirmasiPasswordController,
                          obscureText: _obscureKonfirmasi,
                          placeholder: const Text('Masukkan ulang password'),
                          features: [
                            const InputFeature.leading(Icon(LucideIcons.lock)),
                            InputFeature.trailing(
                              IconButton.ghost(
                                density: ButtonDensity.compact,
                                icon: Icon(
                                  _obscureKonfirmasi ? LucideIcons.eyeOff : LucideIcons.eye,
                                ),
                                onPressed: () => setState(
                                  () => _obscureKonfirmasi = !_obscureKonfirmasi,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Gap(32),
                      FormErrorBuilder(
                        builder: (context, errors, child) {
                          return PrimaryButton(
                            onPressed: (errors.isEmpty && !viewModel.isLoading)
                                ? () => context.submitForm()
                                : null,
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
                          );
                        },
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
      ),
    );
  }
}
