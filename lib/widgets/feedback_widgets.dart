import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:faurecia/core/theme/app_theme.dart';

enum ScanResultType { success, error, warning }

class ScanResultWidget extends StatelessWidget {
  final ScanResultType type;
  final String message;
  final VoidCallback? onDismiss;

  const ScanResultWidget({
    super.key,
    required this.type,
    required this.message,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final (color, icon) = switch (type) {
      ScanResultType.success => (AppTheme.successGreen, Icons.check_circle_rounded),
      ScanResultType.error => (AppTheme.errorRed, Icons.error_rounded),
      ScanResultType.warning => (AppTheme.warningYellow, Icons.warning_rounded),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.4), width: 1.2),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (onDismiss != null)
            GestureDetector(
              onTap: onDismiss,
              child: Icon(Icons.close, color: color, size: 18),
            ),
        ],
      ),
    )
        .animate()
        .slideY(begin: -0.3, duration: 250.ms, curve: Curves.easeOut)
        .fadeIn(duration: 250.ms);
  }
}

/// Dashboard özet istatistik kartı
class SummaryCardWidget extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String? subtitle;

  const SummaryCardWidget({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.25)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.08),
            AppTheme.cardDark,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
              if (subtitle != null)
                Text(subtitle!, style: Theme.of(context).textTheme.labelSmall),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2, duration: 400.ms);
  }
}
