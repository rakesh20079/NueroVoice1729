import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  const CustomBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.outlineVariant, width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                index: 0,
                icon: Icons.home_outlined,
                activeIcon: Icons.home,
                label: "Home",
              ),
              _buildNavItem(
                index: 1,
                icon: Icons.mic_none_outlined,
                activeIcon: Icons.mic,
                label: "Record",
              ),
              _buildNavItem(
                index: 2,
                icon: Icons.assignment_turned_in_outlined,
                activeIcon: Icons.assignment_turned_in,
                label: "Results",
              ),
              _buildNavItem(
                index: 3,
                icon: Icons.history_outlined,
                activeIcon: Icons.history,
                label: "History",
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final bool isSelected = selectedIndex == index;
    final color = isSelected ? AppColors.primaryContainer : AppColors.onSurfaceVariant;

    return InkWell(
      onTap: () => onItemSelected(index),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              size: 22,
              color: color,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: isSelected
                  ? AppTypography.labelSmBold.copyWith(
                      color: AppColors.primaryContainer,
                      fontSize: 11,
                    )
                  : AppTypography.labelSm.copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 11,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
