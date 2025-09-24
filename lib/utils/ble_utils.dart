import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

/// BLE utility functions for contact tracing
class BLEUtils {
  /// Calculate estimated distance from RSSI value
  /// Formula: Distance = 10^((Tx Power - RSSI) / (10 * N))
  /// Where Tx Power = -59 dBm (typical), N = 2 (path loss exponent)
  static double calculateDistance(int rssi) {
    if (rssi == 0) return -1.0;

    const double txPower = -59; // Typical Tx power at 1 meter
    const double pathLoss = 2.0; // Path loss exponent for free space

    if (rssi < txPower) {
      return pow(10, (txPower - rssi) / (10 * pathLoss)).toDouble();
    } else {
      return pow(10, (txPower - rssi) / (10 * pathLoss)).toDouble();
    }
  }

  /// Generate anonymized device ID
  /// Creates a hash-based anonymized ID that changes daily
  static String generateAnonymizedId() {
    final now = DateTime.now();
    final dateString = '${now.year}-${now.month}-${now.day}';
    final deviceInfo = '${DateTime.now().millisecondsSinceEpoch}';

    // Create a seed that changes daily
    final seed = '$dateString-$deviceInfo';
    final bytes = utf8.encode(seed);
    final digest = sha256.convert(bytes);

    // Return first 16 characters of the hash
    return digest.toString().substring(0, 16);
  }

  /// Generate daily rotating ID for privacy
  static String generateDailyRotatingId(String baseId) {
    final now = DateTime.now();
    final dateString = '${now.year}-${now.month}-${now.day}';

    final combined = '$baseId-$dateString';
    final bytes = utf8.encode(combined);
    final digest = sha256.convert(bytes);

    return digest.toString().substring(0, 16);
  }

  /// Convert RSSI to proximity category
  static ProximityCategory getRSSIProximity(int rssi) {
    if (rssi >= -50) return ProximityCategory.immediate;
    if (rssi >= -60) return ProximityCategory.near;
    if (rssi >= -70) return ProximityCategory.far;
    return ProximityCategory.unknown;
  }

  /// Calculate signal strength percentage (0-100)
  static int calculateSignalStrength(int rssi) {
    // Convert RSSI to percentage
    // RSSI typically ranges from -30 (excellent) to -90 (poor)
    const int minRSSI = -90;
    const int maxRSSI = -30;

    if (rssi >= maxRSSI) return 100;
    if (rssi <= minRSSI) return 0;

    return ((rssi - minRSSI) * 100 / (maxRSSI - minRSSI)).round();
  }

  /// Validate UUID format
  static bool isValidUUID(String uuid) {
    final uuidRegex = RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
    );
    return uuidRegex.hasMatch(uuid);
  }

  /// Convert bytes to hex string
  static String bytesToHex(List<int> bytes) {
    return bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
  }

  /// Convert hex string to bytes
  static List<int> hexToBytes(String hex) {
    final result = <int>[];
    for (int i = 0; i < hex.length; i += 2) {
      result.add(int.parse(hex.substring(i, i + 2), radix: 16));
    }
    return result;
  }

  /// Get exposure risk based on distance and duration
  static ExposureRisk calculateExposureRisk(
    double distance,
    int durationMinutes,
  ) {
    // CDC guidelines: Close contact = within 6 feet (1.8m) for 15+ minutes
    if (distance <= 1.8 && durationMinutes >= 15) {
      return ExposureRisk.high;
    } else if (distance <= 2.0 && durationMinutes >= 10) {
      return ExposureRisk.medium;
    } else if (distance <= 3.0 && durationMinutes >= 5) {
      return ExposureRisk.low;
    }
    return ExposureRisk.minimal;
  }

  /// Format duration for display
  static String formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}d ${duration.inHours % 24}h';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m';
    } else {
      return '${duration.inSeconds}s';
    }
  }

  /// Get readable proximity description
  static String getProximityDescription(double distance) {
    if (distance <= 0.5) return 'Very Close (<0.5m)';
    if (distance <= 1.0) return 'Close (0.5-1.0m)';
    if (distance <= 2.0) return 'Nearby (1.0-2.0m)';
    if (distance <= 5.0) return 'Far (2.0-5.0m)';
    return 'Very Far (>5.0m)';
  }

  /// Generate secure random bytes
  static List<int> generateRandomBytes(int length) {
    final random = Random.secure();
    return List<int>.generate(length, (i) => random.nextInt(256));
  }
}

/// Proximity categories based on RSSI
enum ProximityCategory { immediate, near, far, unknown }

/// Exposure risk levels
enum ExposureRisk { minimal, low, medium, high }
