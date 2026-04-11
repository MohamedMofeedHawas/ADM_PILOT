// lib/features/medical/medical_provider.dart
// ══════════════════════════════════════════════════════════════
// Manages medical assessment state + Hive persistence
// ══════════════════════════════════════════════════════════════

import 'dart:convert';
import 'package:check_list_stress/screens/medical_model.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

const _kBox        = 'medical_history';
const _kHistoryKey = 'medical_records';

class MedicalProvider extends ChangeNotifier {
  late Box _box;
  bool _ready = false;

  // Current session inputs: vitalId → (value, value2?)
  final Map<String, double>  _values  = {};
  final Map<String, double>  _values2 = {}; // for dual (BP diastolic)
  final Map<String, MedLevel> _levels  = {};

  List<MedicalAssessment> _history = [];

  // ── Getters ───────────────────────────────────────────────
  double?   getValue(String id)  => _values[id];
  double?   getValue2(String id) => _values2[id];
  MedLevel? getLevel(String id)  => _levels[id];

  bool get allFilled {
    final vitals = buildMedVitals();
    for (final v in vitals) {
      if (!_values.containsKey(v.id)) return false;
      if (v.isDual && !_values2.containsKey(v.id)) return false;
    }
    return true;
  }
  // ── Aviation Weights (IMPORTANT) ─────────────────────────
  static const Map<String, int> _weights = {
    'bp': 3,
    'temp': 3,
    'spo2': 4,       // 🫁 أهم حاجة للطيران
    'hr': 2,
    'sugar': 2,
    'resp_rate': 2,
    'hydration': 2,
  };

// ── Weighted Risk ────────────────────────────────────────
  double get overallRisk {
    final results = currentResults;
    if (results.isEmpty) return 0;

    double total = 0;
    double max = 0;

    for (var r in results) {
      final w = _weights[r.id] ?? 1;
      total += r.level.riskPoints * w;
      max += MedLevel.veryDangerous.riskPoints * w;
    }

    return (total / max * 100).clamp(0, 100);
  }
  // 🫁 Hypoxia detection
  bool get isHypoxic {
    final spo2 = _values['spo2'];
    if (spo2 == null) return false;
    return spo2 < 90;
  }

// 💧 Dehydration detection (advanced)
  bool get isDehydratedAdvanced {
    final hr = _values['hr'];
    final temp = _values['temp'];

    if (hr == null || temp == null) return false;

    return hr > 100 && temp > 37.5;
  }

  List<MedVitalResult> get currentResults {
    final vitals = buildMedVitals();
    final out = <MedVitalResult>[];
    for (final v in vitals) {
      final val = _values[v.id];
      if (val == null) continue;
      final val2 = _values2[v.id];
      MedLevel lvl;
      if (v.isDual && val2 != null && v.classifyDual != null) {
        lvl = v.classifyDual!(val, val2);
      } else {
        lvl = v.classify(val);
      }
      out.add(MedVitalResult(id: v.id, value: val, value2: val2, level: lvl));
    }
    return out;
  }

  // String get currentDecision =>
  //     allFilled ? MedicalAssessment.calcDecision(currentResults) : 'caution';
  String get currentDecision {
    if (!allFilled) return 'caution';

    final results = currentResults;

    // 🛑 Rule 1: أي Very Dangerous = NO FLY
    if (results.any((r) => r.level == MedLevel.veryDangerous)) {
      return 'no-go';
    }

    // 🛑 Rule 2: Hypoxia مباشر
    if (isHypoxic) {
      return 'no-go';
    }

    // 🛑 Rule 3: dehydration شديد
    final hydrationLevel = _levels['hydration'];
    if (hydrationLevel == MedLevel.veryDangerous) {
      return 'no-go';
    }

    // ⚠️ Rule 4: dehydration + stress combo
    if (isDehydratedAdvanced) {
      return 'caution';
    }

    // 🛑 Rule 5: multiple high
    if (results.where((r) => r.level == MedLevel.high).length >= 2) {
      return 'no-go';
    }

    final risk = overallRisk;

    if (risk < 30) return 'go';
    if (risk < 60) return 'caution';

    return 'no-go';
  }
  List<MedicalAssessment> get history => List.unmodifiable(_history);

  // ── Init ──────────────────────────────────────────────────
  Future<void> init() async {
    _box   = await Hive.openBox(_kBox);
    _ready = true;
    _loadHistory();
    notifyListeners();
  }

  void _loadHistory() {
    final raw = _box.get(_kHistoryKey, defaultValue: '[]') as String;
    try {
      final list = jsonDecode(raw) as List;
      _history = list.map((e) => MedicalAssessment.fromJson(e as Map<String, dynamic>)).toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    } catch (_) {
      _history = [];
    }
  }

  // ── Input handlers ────────────────────────────────────────
  void setValue(String id, double value) {
    _values[id] = value;
    final vitals = buildMedVitals();
    final vital = vitals.firstWhere((v) => v.id == id, orElse: () => vitals.first);
    final val2 = _values2[id];
    if (vital.isDual && val2 != null && vital.classifyDual != null) {
      _levels[id] = vital.classifyDual!(value, val2);
    } else {
      _levels[id] = vital.classify(value);
    }
    notifyListeners();
  }

  void setValue2(String id, double value) {
    _values2[id] = value;
    final val = _values[id];
    if (val != null) setValue(id, val); // recompute level with dual
    notifyListeners();
  }

  void clearValue(String id) {
    _values.remove(id);
    _values2.remove(id);
    _levels.remove(id);
    notifyListeners();
  }

  void resetAll() {
    _values.clear();
    _values2.clear();
    _levels.clear();
    notifyListeners();
  }

  // ── Save to history ───────────────────────────────────────
  Future<MedicalAssessment> saveAssessment() async {
    final assessment = MedicalAssessment(
      timestamp: DateTime.now(),
      results:   currentResults,
      decision:  currentDecision,
    );
    _history.insert(0, assessment);
    await _persist();
    notifyListeners();
    return assessment;
  }

  Future<void> deleteRecord(int index) async {
    if (index < 0 || index >= _history.length) return;
    _history.removeAt(index);
    await _persist();
    notifyListeners();
  }

  Future<void> clearHistory() async {
    _history.clear();
    await _persist();
    notifyListeners();
  }

  Future<void> _persist() async {
    if (!_ready) return;
    final json = jsonEncode(_history.map((a) => a.toJson()).toList());
    await _box.put(_kHistoryKey, json);
  }

  // ── Latest result (for dashboard) ─────────────────────────
  MedicalAssessment? get latest => _history.isEmpty ? null : _history.first;
}