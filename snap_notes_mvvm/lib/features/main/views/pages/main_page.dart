import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:provider/provider.dart';
import 'package:snap_notes_mvvm/core/di/injection.dart';
import 'package:snap_notes_mvvm/features/receipt/viewmodels/receipt_viewmodel.dart';
import 'package:snap_notes_mvvm/features/dashboard/views/pages/dashboard_page.dart';
import 'package:snap_notes_mvvm/features/pemasukan/views/pages/pemasukan_page.dart';
import 'package:snap_notes_mvvm/features/pengeluaran/views/pages/pengeluaran_page.dart';
import 'package:snap_notes_mvvm/features/receipt/views/pages/receipt_scan_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 1; // Default to Dashboard

  final List<Widget> _pages = [
    const PengeluaranPage(),
    const DashboardPage(),
    const PemasukanPage(),
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
              _buildNavItem(0, LucideIcons.shoppingCart, 'Pengeluaran'),
              _buildNavItem(1, LucideIcons.chartPie, 'Dashboard'),
              _buildNavItem(2, LucideIcons.piggyBank, 'Pemasukan'),
            ],
          ),
        ),
      ],
      child: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: _pages,
          ),
          Positioned(
            bottom: 24,
            right: 24,
            child: PrimaryButton(
              shape: ButtonShape.circle,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ChangeNotifierProvider(
                      create: (_) => getIt<ReceiptViewModel>(),
                      child: const ReceiptScanPage(),
                    ),
                  ),
                );
              },
              child: const Icon(LucideIcons.scanLine),
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
