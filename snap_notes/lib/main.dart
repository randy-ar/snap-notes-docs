import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:snap_notes/features/auth/presentation/cubit/login_cubit.dart';
import 'package:snap_notes/features/auth/presentation/cubit/register_cubit.dart';
import 'package:snap_notes/features/auth/presentation/pages/login_page.dart';
import 'package:snap_notes/features/notifikasi/data/datasources/local_notification_data_source.dart';
import 'package:snap_notes/injection_container.dart' as di;
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );

  await di.init();
  await di.sl<LocalNotificationDataSource>().init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Widget _buildLoginPage() {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => di.sl<LoginCubit>()),
        BlocProvider(create: (_) => di.sl<RegisterCubit>()),
      ],
      child: const LoginPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ShadcnApp(
      title: 'Snap Notes',
      theme: ThemeData(radius: 0.5),
      home: _buildLoginPage(),
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => _buildLoginPage(),
          settings: settings,
        );
      },
    );
  }
}
