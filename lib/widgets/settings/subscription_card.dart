import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_downloader/theme/app_theme.dart';
import 'package:video_downloader/theme/subscription_notifier.dart';

class SubscriptionCard extends StatelessWidget {
  const SubscriptionCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isPro = subscriptionNotifier.isPro;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: isPro
            ? const LinearGradient(
                colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : LinearGradient(
                colors: [AppTheme.primaryColor, AppTheme.primaryColor.withOpacity01(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        boxShadow: [
          BoxShadow(
            color: (isPro ? const Color(0xFFEAB308) : AppTheme.primaryColor).withOpacity01(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Icon(
              isPro ? Icons.diamond_rounded : Icons.star_rounded,
              size: 120,
              color: Colors.white.withOpacity01(0.1),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity01(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isPro ? 'PREMIUM MEMBER' : 'FREE PLAN',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    if (isPro)
                      const Icon(Icons.verified_rounded, color: Color(0xFFEAB308), size: 24),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  isPro ? 'Pro Subscription' : 'Upgrade to Pro',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isPro ? 'Enjoy unlimited 4K downloads & zero ads' : 'Unlock 4K downloads and premium features',
                  style: TextStyle(
                    color: Colors.white.withOpacity01(0.8),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 24),
                if (!isPro)
                  _buildUpgradeButton(context)
                else
                  _buildManageButton(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpgradeButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        HapticFeedback.mediumImpact();
        // Trigger upgrade modal logic (will be handled by parent or notifier)
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.primaryColor,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: const Text('Upgrade Now', style: TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildManageButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity01(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity01(0.2)),
      ),
      child: const Text(
        'Manage Subscription',
        style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
      ),
    );
  }
}
