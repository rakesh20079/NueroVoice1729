import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? leading;
  final List<Widget>? actions;
  final bool centerTitle;

  const CustomAppBar({
    super.key,
    required this.title,
    this.leading,
    this.actions,
    this.centerTitle = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.outlineVariant, width: 1),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Center Title (when centerTitle is true)
              if (centerTitle)
                Center(
                  child: Text(
                    title,
                    style: AppTypography.headlineMd,
                    textAlign: TextAlign.center,
                  ),
                ),

              // Normal flow: Leading & Trailing
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Leading or left-aligned Title
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (leading != null) ...[
                        leading!,
                        const SizedBox(width: 8),
                      ],
                      if (!centerTitle)
                        Text(
                          title,
                          style: AppTypography.headlineMd,
                        ),
                    ],
                  ),

                  // Trailing actions if any
                  if (actions != null)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: actions!,
                    )
                  else
                    const SizedBox.shrink(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
