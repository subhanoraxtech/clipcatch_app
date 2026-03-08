import 'package:flutter/material.dart';
import 'package:video_downloader/theme/app_theme.dart';

/// A header divider for sections in the resolution modal (e.g. "FREE", "PREMIUM").
class SectionHeader extends StatelessWidget {
  final String title;
  final Color? accentColor;

  const SectionHeader({
    super.key,
    required this.title,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        if (accentColor != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: accentColor!.withValues(alpha: 0.1),
              border: Border.all(color: accentColor!.withValues(alpha: 0.2)),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(Icons.workspace_premium, color: accentColor, size: 14),
                const SizedBox(width: 4),
                Text(
                  title.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    color: accentColor,
                  ),
                ),
              ],
            ),
          ),
        ] else ...[
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
            ),
          ),
        ],
        const SizedBox(width: 12),
        Expanded(
          child: Divider(
            color: accentColor?.withValues(alpha: 0.2) ??
                (isDark ? AppTheme.surfaceDark : const Color(0xFFE2E8F0)),
            height: 1,
          ),
        ),
      ],
    );
  }
}

/// A tappable quality option card used in the resolution selection modal.
class QualityOptionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isPremium;
  final bool isSelected;
  final VoidCallback onTap;

  const QualityOptionCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.isPremium = false,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isPremium ? Colors.amber : AppTheme.primaryColor;
    final borderColor = isDark ? AppTheme.surfaceDark : const Color(0xFFE2E8F0);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: isSelected ? primary : borderColor),
          borderRadius: BorderRadius.circular(12),
          color: isDark ? AppTheme.backgroundDark : Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppTheme.textDark : AppTheme.textLight,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                if (isPremium) ...[
                  Icon(Icons.workspace_premium, color: primary.withValues(alpha: 0.6), size: 20),
                  const SizedBox(width: 12),
                ],
                _RadioDot(isSelected: isSelected, color: primary, isDark: isDark),
              ],
            )
          ],
        ),
      ),
    );
  }
}

/// A highlighted premium quality option with badge and glow effect.
class PremiumQualityCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String badgeText;
  final bool isSelected;
  final VoidCallback onTap;

  const PremiumQualityCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.badgeText,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const primary = Colors.amber;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: primary.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(12),
          color: primary.withValues(alpha: 0.05),
          boxShadow: isSelected
              ? [BoxShadow(color: primary.withValues(alpha: 0.1), blurRadius: 15)]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppTheme.textDark : AppTheme.textLight,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: primary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        badgeText.toUpperCase(),
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Colors.black),
                      ),
                    )
                  ],
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                const Icon(Icons.star, color: primary, size: 20),
                const SizedBox(width: 12),
                _RadioDot(
                  isSelected: isSelected,
                  color: primary,
                  isDark: isDark,
                  unselectedColor: primary.withValues(alpha: 0.5),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

/// A small pill-shaped toggle button for quick resolution picks.
class QualityPill extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const QualityPill({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor
              : (isDark ? AppTheme.surfaceDark : const Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isSelected
                ? Colors.white
                : (isDark ? AppTheme.textDark : AppTheme.textLight),
          ),
        ),
      ),
    );
  }
}

// ── Private helper ──────────────────────────────────────────────────────────

class _RadioDot extends StatelessWidget {
  final bool isSelected;
  final Color color;
  final bool isDark;
  final Color? unselectedColor;

  const _RadioDot({
    required this.isSelected,
    required this.color,
    required this.isDark,
    this.unselectedColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected
              ? color
              : (unselectedColor ??
                  (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1))),
          width: 2,
        ),
        color: isSelected ? color : Colors.transparent,
      ),
      child: isSelected
          ? const Center(child: Icon(Icons.circle, size: 8, color: Colors.white))
          : null,
    );
  }
}
