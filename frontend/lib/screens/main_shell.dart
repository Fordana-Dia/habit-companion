import 'package:flutter/material.dart';
import '../theme.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'progress_screen.dart';
import 'fitness_screen.dart';

class MainShell extends StatefulWidget {
  final String token;

  const MainShell({super.key, required this.token});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  late final List<Widget> _screens = [
    HomeScreen(token: widget.token),
    ProgressScreen(token: widget.token),
    FitnessScreen(token: widget.token),
    ProfileScreen(token: widget.token),
  ];

  final List<_NavItem> _navItems = const [
    _NavItem(icon: Icons.home_outlined, activeIcon: Icons.home, label: "Accueil"),
    _NavItem(icon: Icons.bar_chart_outlined, activeIcon: Icons.bar_chart, label: "Efforts"),
    _NavItem(icon: Icons.fitness_center_outlined, activeIcon: Icons.fitness_center, label: "Programme"),
    _NavItem(icon: Icons.person_outline, activeIcon: Icons.person, label: "Compte"),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppTheme.cardBorder, width: 0.5)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: SafeArea(
          top: false,
          child: Row(
            children: List.generate(_navItems.length, (index) {
              final isActive = index == _currentIndex;
              final item = _navItems[index];
              return Expanded(
                child: InkWell(
                  onTap: () => setState(() => _currentIndex = index),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isActive ? item.activeIcon : item.icon,
                        color: isActive ? AppTheme.primary : AppTheme.navInactive,
                        size: 22,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 11,
                          color: isActive ? AppTheme.primary : AppTheme.navInactive,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _NavItem({required this.icon, required this.activeIcon, required this.label});
}
