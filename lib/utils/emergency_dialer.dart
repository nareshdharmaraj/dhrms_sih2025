import 'package:url_launcher/url_launcher.dart';

class EmergencyDialer {
  /// Dials the given [phoneNumber] using the platform dialer.
  /// This will bypass app chooser and dial directly without confirmation.
  static Future<void> dial(String phoneNumber) async {
    // Clean the phone number (remove any spaces, dashes, etc.)
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    final telUrl = Uri(scheme: 'tel', path: cleanNumber);

    try {
      if (await canLaunchUrl(telUrl)) {
        // Use externalNonBrowserApplication to bypass app chooser
        // and dial directly without confirmation
        await launchUrl(telUrl, mode: LaunchMode.externalNonBrowserApplication);
      } else {
        throw Exception('Could not launch dialer for $cleanNumber');
      }
    } catch (e) {
      // Fallback to external application mode if the first method fails
      try {
        await launchUrl(telUrl, mode: LaunchMode.externalApplication);
      } catch (fallbackError) {
        throw Exception(
          'Could not launch dialer for $cleanNumber: $fallbackError',
        );
      }
    }
  }
}
