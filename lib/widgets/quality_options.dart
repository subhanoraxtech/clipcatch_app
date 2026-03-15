import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
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
              color: accentColor!.withOpacity01(0.1),
              border: Border.all(color: accentColor!.withOpacity01(0.2)),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(LucideIcons.gem, color: accentColor, size: 14),
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
            color: accentColor?.withOpacity01(0.2) ??
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
    final primary = isPremium ? AppTheme.accentColor : AppTheme.primaryColor;
    final borderColor = isSelected 
        ? primary 
        : (isDark ? AppTheme.borderDark : AppTheme.borderLight);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: borderColor, width: isSelected ? 1.5 : 1),
            borderRadius: BorderRadius.circular(16),
            color: isDark ? AppTheme.surfaceDark : Colors.white,
            boxShadow: isSelected
              ? [BoxShadow(color: primary.withOpacity01(0.1), blurRadius: 10, offset: const Offset(0, 4))]
              : [],
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
                      fontSize: 15,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                      color: isDark ? AppTheme.textDark : AppTheme.textLight,
                    ),
                  ),
                  const SizedBox(height: 2),
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
                  if (isSelected) 
                    Icon(LucideIcons.circleCheck, color: primary, size: 20)
                  else
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: isDark ? AppTheme.borderDark : AppTheme.borderLight, width: 2),
                      ),
                    ),
                ],
              )
            ],
          ),
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
    const primary = AppTheme.accentColor;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? primary : (isDark ? AppTheme.borderDark : AppTheme.borderLight),
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(20),
            gradient: isSelected ? LinearGradient(
              colors: [primary.withOpacity01(0.15), primary.withOpacity01(0.05)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ) : null,
            color: isDark ? AppTheme.surfaceDark : Colors.white,
            boxShadow: isSelected
                ? [BoxShadow(color: primary.withOpacity01(0.2), blurRadius: 20, offset: const Offset(0, 8))]
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
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppTheme.textDark : AppTheme.textLight,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: primary,
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: [BoxShadow(color: primary.withOpacity01(0.3), blurRadius: 8)],
                        ),
                        child: Text(
                          badgeText.toUpperCase(),
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Colors.black, letterSpacing: 0.5),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                    ),
                  ),
                ],
              ),
              Icon(
                isSelected ? LucideIcons.badgeCheck : LucideIcons.gem,
                color: isSelected ? primary : primary.withOpacity01(0.4),
                size: 28,
              ),
            ],
          ),
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
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor
              : (isDark ? AppTheme.surfaceDark : Colors.white),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : (isDark ? AppTheme.borderDark : AppTheme.borderLight),
          ),
          boxShadow: isSelected ? [BoxShadow(color: AppTheme.primaryColor.withOpacity01(0.2), blurRadius: 8)] : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            color: isSelected
                ? Colors.white
                : (isDark ? AppTheme.textDark : AppTheme.textLight),
          ),
        ),
      ),
    );
  }
}
