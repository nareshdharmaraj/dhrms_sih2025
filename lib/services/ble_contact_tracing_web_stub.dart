// Web stubs for BLE packages that don't support web

// FlutterReactiveBle stub
class FlutterReactiveBle {
  Stream<DiscoveredDevice> scanForDevices({
    List<Uuid>? withServices,
    ScanMode? scanMode,
  }) {
    return Stream.empty();
  }
}

class DiscoveredDevice {
  final String id;
  final String name;
  final int rssi;
  final Map<Uuid, List<int>> serviceData;

  DiscoveredDevice({
    required this.id,
    required this.name,
    required this.rssi,
    required this.serviceData,
  });
}

class Uuid {
  final String value;
  Uuid(this.value);

  static Uuid parse(String uuid) => Uuid(uuid);

  @override
  String toString() => value;
}

enum ScanMode { lowLatency, balanced, lowPowerMode }

// Permission Handler stubs
class Permission {
  static Permission get bluetooth => Permission._();
  static Permission get bluetoothScan => Permission._();
  static Permission get bluetoothAdvertise => Permission._();
  static Permission get locationWhenInUse => Permission._();
  static Permission get notification => Permission._();

  Permission._();

  Future<PermissionStatus> get status async => PermissionStatus.granted;
  Future<PermissionStatus> request() async => PermissionStatus.granted;
}

enum PermissionStatus {
  granted,
  denied,
  restricted,
  permanentlyDenied;

  bool get isGranted => this == PermissionStatus.granted;
}
