import 'package:flutter/material.dart';
import 'package:nestify/core/constants/app_colors.dart';
import 'package:nestify/core/localization/app_localizations.dart';
import 'package:nestify/features/explore_feed/domain/entities/property_entity.dart';

/// DirectConnectButtons provides instant high-converting lead actions:
/// 1-click WhatsApp chat and Direct Call to authorized developer representatives.
class DirectConnectButtons extends StatelessWidget {
  final PropertyEntity property;
  final bool isCompact;

  const DirectConnectButtons({
    super.key,
    required this.property,
    this.isCompact = false,
  });

  void _onWhatsApp(BuildContext context) {
    final l10n = context.l10n;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF1E3A2B),
        content: Row(
          children: [
            const Icon(
              Icons.chat_bubble_rounded,
              color: Color(0xFF25D366),
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${l10n.translate('chat_initiated')} (${property.developerName})',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onCall(BuildContext context) {
    final l10n = context.l10n;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.surfaceDarkElevated,
        content: Row(
          children: [
            const Icon(
              Icons.phone_in_talk_rounded,
              color: AppColors.neonCyan,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${l10n.translate('call_initiated')} (${property.contactPhone})',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    final primaryColor = Theme.of(context).colorScheme.primary;

    if (isCompact) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // WhatsApp Icon Button
          GestureDetector(
            onTap: () => _onWhatsApp(context),
            child: Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: const Color(0xFF25D366).withValues(alpha: 0.18),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF25D366).withValues(alpha: 0.5),
                ),
              ),
              child: const Icon(
                Icons.chat_bubble_outline_rounded,
                color: Color(0xFF25D366),
                size: 15,
              ),
            ),
          ),
          const SizedBox(width: 6),
          // Direct Call Icon Button
          GestureDetector(
            onTap: () => _onCall(context),
            child: Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.18),
                shape: BoxShape.circle,
                border: Border.all(
                  color: primaryColor.withValues(alpha: 0.5),
                ),
              ),
              child: Icon(
                Icons.phone_in_talk_rounded,
                color: primaryColor,
                size: 15,
              ),
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        // WhatsApp Action
        Expanded(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF25D366),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: () => _onWhatsApp(context),
            icon: const Icon(Icons.chat_bubble_rounded, size: 16),
            label: Text(
              l10n.translate('whatsapp_chat'),
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ),
        ),
        const SizedBox(width: 10),
        // Direct Call Action
        Expanded(
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: primaryColor,
              side: BorderSide(color: primaryColor, width: 1.2),
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: () => _onCall(context),
            icon: const Icon(Icons.phone_in_talk_rounded, size: 16),
            label: Text(
              l10n.translate('call_now'),
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }
}
