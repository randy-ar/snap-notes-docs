import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:snap_notes/features/receipt/presentation/bloc/receipt_bloc.dart';
import 'package:snap_notes/features/receipt/presentation/pages/scanner_page.dart';
import 'package:snap_notes/injection_container.dart' as di;

import 'package:snap_notes/features/pengeluaran/presentation/pages/pengeluaran_list_page.dart';
import 'package:snap_notes/features/pemasukan/presentation/pages/pemasukan_list_page.dart';
import 'package:snap_notes/features/dashboard/presentation/pages/dashboard_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 1; // Default to Dashboard

  final List<Widget> _pages = [
    const PengeluaranListPage(),
    const DashboardPage(),
    const PemasukanListPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      footers: [
        Divider(height: 1, color: theme.colorScheme.border),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          color: theme.colorScheme.background,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(0, Icons.arrow_upward, 'Pengeluaran'),
              _buildNavItem(1, Icons.dashboard, 'Dashboard'),
              _buildNavItem(2, Icons.arrow_downward, 'Pemasukan'),
            ],
          ),
        ),
      ],
      child: Stack(
        children: [
          _pages[_currentIndex],
          Positioned(
            bottom: 24,
            right: 24,
            child: PrimaryButton(
              shape: ButtonShape.circle,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => BlocProvider(
                      create: (_) => di.sl<ReceiptBloc>(),
                      child: const ScannerPage(),
                    ),
                  ),
                );
              },
              child: const Icon(Icons.document_scanner),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    final color = isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.mutedForeground;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color),
          const Gap(4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
