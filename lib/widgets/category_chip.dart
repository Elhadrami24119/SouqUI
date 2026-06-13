import 'package:flutter/material.dart';
import '../l10n/app_strings.dart';
import '../utils/theme.dart';

class CategoryChip extends StatelessWidget {
  /// The French key stored in DataService.categories (e.g. 'Téléphones').
  final String label;
  final String emoji;
  final bool selected;
  final VoidCallback onTap;

  const CategoryChip({
    super.key,
    required this.label,
    required this.emoji,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Translate the category name based on current locale
    final displayLabel = S.of(context).translateCategory(label);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        width: 72,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: selected ? AppTheme.primaryGradient : null,
                color: selected ? null : AppTheme.surface,
                shape: BoxShape.circle,
                boxShadow: selected
                    ? AppTheme.primaryShadow
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
              ),
              child: Center(
                child: Text(emoji,
                    style: TextStyle(fontSize: selected ? 24 : 22)),
              ),
            ),
            const SizedBox(height: 7),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 220),
              style: TextStyle(
                fontSize: 10,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? AppTheme.primary : AppTheme.textGrey,
                letterSpacing: -0.1,
              ),
              child: Text(
                displayLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
