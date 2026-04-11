// lib/features/profile/profile_provider.dart
// ══════════════════════════════════════════════════════════════
// Stores pilot name + flight ID in a separate Hive box
// Used when saving assessment records
// ══════════════════════════════════════════════════════════════

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

const String _kProfileBox  = 'profile';
const String _kPilotName   = 'pilot_name';
const String _kFlightId    = 'flight_id';
const String _kFlightPhase = 'flight_phase';

class ProfileProvider extends ChangeNotifier {
  late Box _box;
  bool _ready = false;

  String get pilotName   => _ready ? (_box.get(_kPilotName,   defaultValue: '') as String) : '';
  String get flightId    => _ready ? (_box.get(_kFlightId,    defaultValue: '') as String) : '';
  String get flightPhase => _ready ? (_box.get(_kFlightPhase, defaultValue: 'pre_flight') as String) : 'pre_flight';

  Future<void> init() async {
    _box   = await Hive.openBox(_kProfileBox);
    _ready = true;
    notifyListeners();
  }

  Future<void> setPilotName(String v) async {
    await _box.put(_kPilotName, v);
    notifyListeners();
  }

  Future<void> setFlightId(String v) async {
    await _box.put(_kFlightId, v);
    notifyListeners();
  }

  Future<void> setFlightPhase(String v) async {
    await _box.put(_kFlightPhase, v);
    notifyListeners();
  }
}
