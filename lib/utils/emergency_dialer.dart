import 'package:url_launcher/url_launcher.dart';

class EmergencyDialer {
  /// Dials the given [phoneNumber] using the platform dialer.
  /// On mobile, this will open the dialer and start the call automatically.
  /// On web, this will open a tel: link (user must confirm).
  static Future<void> dial(String phoneNumber) async {
    final telUrl = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(telUrl)) {
      await launchUrl(telUrl, mode: LaunchMode.externalApplication);
    } else {
      throw Exception('Could not launch dialer for $phoneNumber');
    }
  }
}
