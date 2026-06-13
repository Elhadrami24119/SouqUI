import 'package:flutter/material.dart';
import '../l10n/app_strings.dart';
import '../utils/theme.dart';

/// Small pill button to toggle FR ↔ AR.
/// Place it in AppBar actions or menu.
class LangToggle extends StatelessWidget {
  const LangToggle({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: AppLocale(),
      builder: (_, locale, __) {
        final isAr = locale.languageCode == 'ar';
        return GestureDetector(
          onTap: () => AppLocale().toggle(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: AppTheme.primary.withOpacity(0.3), width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isAr ? 'FR' : 'ع',
                  style: const TextStyle(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.translate_rounded,
                    color: AppTheme.primary, size: 14),
              ],
            ),
          ),
        );
      },
    );
  }
}
