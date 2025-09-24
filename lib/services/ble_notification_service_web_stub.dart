// Web stub for Firebase Messaging
// This file provides no-op implementations for web platform

class FirebaseMessaging {
  static FirebaseMessaging get instance => FirebaseMessaging();

  Future<void> requestPermission({
    bool? alert,
    bool? announcement,
    bool? badge,
    bool? carPlay,
    bool? criticalAlert,
    bool? provisional,
    bool? sound,
  }) async {
    // No-op for web
  }

  Future<String?> getToken() async {
    return null; // No FCM token on web
  }

  static Stream<dynamic> get onMessage => Stream.empty();
  static Stream<dynamic> get onMessageOpenedApp => Stream.empty();

  static Future<void> Function(dynamic)? onBackgroundMessage(
    Future<void> Function(dynamic) handler,
  ) {
    return null; // No background messages on web
  }
}
