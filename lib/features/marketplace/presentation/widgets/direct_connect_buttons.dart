import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:nestify/core/localization/app_localizations.dart';
import 'package:nestify/features/explore_feed/domain/entities/property_entity.dart';

/// DirectConnectButtons provides instant high-converting lead actions:
/// 1-click WhatsApp chat with pre-filled property details and Direct Call to the broker/developer.
class DirectConnectButtons extends StatelessWidget {
  final PropertyEntity property;
  final bool isCompact;

  const DirectConnectButtons({
    super.key,
    required this.property,
    this.isCompact = false,
  });

  Future<void> _onWhatsApp(BuildContext context) async {
    final l10n = context.l10n;
    final propTitle = property.title.trim();
    final message = l10n.isArabic
        ? (propTitle.isNotEmpty
            ? 'السلام عليكم، مهتم بالاستفسار عن $propTitle في ${property.neighborhood} المعروضة في Nestify'
            : 'السلام عليكم، مهتم بالاستفسار عن عقار معروض في Nestify')
        : (propTitle.isNotEmpty
            ? 'Hello, I am inquiring about $propTitle in ${property.neighborhood} listed on Nestify'
            : 'Hello, I am interested in inquiring about a property listed on Nestify');

    final cleanPhone = property.contactWhatsApp.replaceAll('+', '').replaceAll(' ', '').trim();
    final phone = cleanPhone.isEmpty ? '201206667376' : cleanPhone;
    final encodedMsg = Uri.encodeComponent(message);
    final whatsappUri = Uri.parse('https://wa.me/$phone?text=$encodedMsg');

    try {
      final launched = await launchUrl(
        whatsappUri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && context.mounted) {
        _showFallback(
          context,
          '${l10n.isArabic ? "واتساب المستشار" : "WhatsApp"}: +$phone',
        );
      }
    } catch (_) {
      if (context.mounted) {
        _showFallback(
          context,
          '${l10n.isArabic ? "واتساب المستشار" : "WhatsApp"}: +$phone',
        );
      }
    }
  }

  Future<void> _onCall(BuildContext context) async {
    final l10n = context.l10n;
    final cleanPhone = property.contactPhone.replaceAll(' ', '').trim();
    final phone = cleanPhone.isEmpty ? '+201206667376' : cleanPhone;
    final callUri = Uri.parse('tel:$phone');

    try {
      final launched = await launchUrl(callUri);
      if (!launched && context.mounted) {
        _showFallback(
          context,
          '${l10n.isArabic ? "الاتصال المباشر" : "Direct Call"}: $phone',
        );
      }
    } catch (_) {
      if (context.mounted) {
        _showFallback(
          context,
          '${l10n.isArabic ? "الاتصال المباشر" : "Direct Call"}: $phone',
        );
      }
    }
  }

  void _showFallback(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF1E3A2B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Color(0xFF25D366), size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
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
              padding: const EdgeInsets.all(8),
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
                size: 16,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Direct Call Icon Button
          GestureDetector(
            onTap: () => _onCall(context),
            child: Container(
              padding: const EdgeInsets.all(8),
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
                size: 16,
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
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: () => _onWhatsApp(context),
            icon: const Icon(Icons.chat_bubble_rounded, size: 18),
            label: Text(
              l10n.translate('instant_whatsapp'),
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        const SizedBox(width: 10),
        // Direct Call Action
        Expanded(
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: primaryColor,
              side: BorderSide(color: primaryColor, width: 1.5),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: () => _onCall(context),
            icon: const Icon(Icons.phone_in_talk_rounded, size: 18),
            label: Text(
              l10n.translate('direct_call'),
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }
}
