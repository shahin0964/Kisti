import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/customer.dart';
import '../services/kisti_storage.dart';
import '../theme/liquid_glass_theme.dart';
import '../widgets/liquid_glass.dart';
import 'dashboard_screen.dart';
import 'customers_screen.dart';
import 'collection_screen.dart';
import 'more_screen.dart';

class MainScreen extends StatefulWidget {
  final KistiStorage storage;

  const MainScreen({super.key, required this.storage});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  Customer? _quickCollectCustomer;

  void _navigateToTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onQuickCollect(Customer customer) {
    setState(() {
      _quickCollectCustomer = customer;
      _currentIndex = 2; // Collection tab
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      DashboardScreen(
        storage: widget.storage,
        onNavigateTab: _navigateToTab,
        onQuickCollect: _onQuickCollect,
      ),
      CustomersScreen(storage: widget.storage),
      CollectionScreen(
        storage: widget.storage,
        preselectedCustomer: _quickCollectCustomer,
      ),
      MoreScreen(storage: widget.storage),
    ];

    return Scaffold(
      backgroundColor: LiquidGlassTheme.bgDarkVoid,
      body: LiquidBackground(
        child: Stack(
          children: [
            // Active Tab View
            IndexedStack(
              index: _currentIndex,
              children: screens,
            ),

            // Floating Liquid Glass Navigation Bar
            Positioned(
              left: 16,
              right: 16,
              bottom: 20,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.20),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.4),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildNavItem(0, Icons.dashboard_rounded, 'ড্যাশবোর্ড'),
                        _buildNavItem(1, Icons.people_alt_rounded, 'গ্রাহক'),
                        _buildNavItem(2, Icons.account_balance_wallet_rounded, 'আদায়'),
                        _buildNavItem(3, Icons.grid_view_rounded, 'অন্যান্য'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
          if (index != 2) {
            _quickCollectCustomer = null;
          }
        });
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? LiquidGlassTheme.neonEmerald.withOpacity(0.18)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(22),
          border: isSelected
              ? Border.all(
                  color: LiquidGlassTheme.neonEmerald.withOpacity(0.45),
                  width: 1,
                )
              : null,
          boxShadow: isSelected
              ? LiquidGlassTheme.neonGlow(
                  LiquidGlassTheme.neonEmerald,
                  intensity: 0.25,
                  blur: 14,
                )
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: isSelected ? LiquidGlassTheme.neonEmerald : Colors.white60,
            ),
            if (isSelected) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: LiquidGlassTheme.neonEmerald,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
