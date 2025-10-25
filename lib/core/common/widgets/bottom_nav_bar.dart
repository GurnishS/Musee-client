import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  const BottomNavBar({super.key, required this.selectedIndex});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      color: colorScheme.surface,
      elevation: 8,
      child: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            _buildNavItem(
              context,
              Icons.home_outlined,
              Icons.home,
              0,
              'Home',
              '/dashboard',
            ),
            _buildNavItem(
              context,
              Icons.search_outlined,
              Icons.search,
              1,
              'Search',
              '/search',
            ),
            const SizedBox(width: 64), // Space for FAB
            _buildNavItem(
              context,
              Icons.menu_outlined,
              Icons.menu,
              2,
              'Downloads',
              '/downloads',
            ),
            _buildNavItem(
              context,
              Icons.person_outline,
              Icons.person,
              3,
              'Profile',
              '/profile',
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget to build each navigation item to avoid code repetition.
  Widget _buildNavItem(
    BuildContext context,
    IconData unselectedIcon,
    IconData selectedIcon,
    int index,
    String tooltip,
    String route,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSelected = selectedIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () => context.push(route),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 60,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isSelected ? selectedIcon : unselectedIcon,
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.onSurface.withAlpha(153),
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                tooltip,
                style: TextStyle(
                  fontSize: 12,
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.onSurface.withAlpha(153),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
