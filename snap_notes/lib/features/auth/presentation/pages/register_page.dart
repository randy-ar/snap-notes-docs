import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:snap_notes/features/auth/presentation/cubit/register_cubit.dart';
import 'package:snap_notes/features/auth/presentation/cubit/register_state.dart';

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

  void _onDaftar(BuildContext context) {
    if (_passwordController.text != _konfirmasiPasswordController.text) {
      showToast(
        context: context,
        builder: (context, overlay) {
          return SurfaceCard(
            child: Basic(
              title: const Text('Error'),
              subtitle: const Text('Password dan konfirmasi password tidak cocok'),
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
      return;
    }
    context.read<RegisterCubit>().daftar(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          namaLengkap: _namaController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      headers: [
        AppBar(
          title: const Text('Buat Akun'),
          leading: [
            IconButton.ghost(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ],
      child: BlocConsumer<RegisterCubit, RegisterState>(
        listener: (context, state) {
          if (state is RegisterSuccess) {
            showToast(
              context: context,
              builder: (context, overlay) {
                return SurfaceCard(
                  child: Basic(
                    title: const Text('Berhasil'),
                    subtitle: Text('Akun berhasil dibuat! Selamat datang, ${state.pengguna.namaLengkap}'),
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
            Navigator.of(context).pop();
          } else if (state is RegisterError) {
            showToast(
              context: context,
              builder: (context, overlay) {
                return SurfaceCard(
                  child: Basic(
                    title: const Text('Error'),
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
          final isLoading = state is RegisterLoading;
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Daftar ke Snap Notes',
                  ).h2(),
                  const Gap(8),
                  const Text(
                    'Isi data berikut untuk membuat akun baru',
                  ).muted(),
                  const Gap(32),
                  _buildField(
                    label: 'Nama Lengkap',
                    controller: _namaController,
                    hint: 'Masukkan nama lengkap',
                    icon: Icons.person_outlined,
                  ),
                  const Gap(16),
                  _buildField(
                    label: 'Email',
                    controller: _emailController,
                    hint: 'contoh@email.com',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const Gap(16),
                  _buildPasswordField(
                    label: 'Password',
                    controller: _passwordController,
                    obscure: _obscurePassword,
                    onToggle: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  const Gap(16),
                  _buildPasswordField(
                    label: 'Konfirmasi Password',
                    controller: _konfirmasiPasswordController,
                    obscure: _obscureKonfirmasi,
                    onToggle: () => setState(() => _obscureKonfirmasi = !_obscureKonfirmasi),
                  ),
                  const Gap(32),
                  PrimaryButton(
                    onPressed: isLoading ? null : () => _onDaftar(context),
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
                              Text('Membuat akun...'),
                            ],
                          )
                        : const Text('Buat Akun'),
                  ),
                  const Gap(16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Sudah punya akun? ',
                      ).muted(),
                      LinkButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Masuk'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
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
          features: [
            InputFeature.leading(Icon(icon)),
          ],
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
            const InputFeature.leading(Icon(Icons.lock_outlined)),
            InputFeature.trailing(
              IconButton.ghost(
                density: ButtonDensity.compact,
                icon: Icon(
                  obscure ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: onToggle,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
