import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:musee/core/common/widgets/floating_player_panel.dart';

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
      padding: EdgeInsets.all(4),
      height: 180,
      child: SizedBox(
        height: 200,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            FloatingPlayerPanel(),
            Row(
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
                _buildNavItem(
                  context,
                  Icons.library_books_outlined,
                  Icons.library_books,
                  2,
                  'Your Library',
                  '/library',
                ),
                _buildNavItem(
                  context,
                  Icons.money_outlined,
                  Icons.money,
                  3,
                  'Premium',
                  '/premium',
                ),
                _buildNavItem(
                  context,
                  Icons.add_outlined,
                  Icons.add,
                  4,
                  'Create',
                  '/create',
                ),
              ],
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
