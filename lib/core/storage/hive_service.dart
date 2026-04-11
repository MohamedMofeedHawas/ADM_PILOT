// lib/core/storage/hive_service.dart
// ══════════════════════════════════════════════════════════════
// Singleton service — wraps Hive box with typed helpers
// ══════════════════════════════════════════════════════════════

import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import 'assessment_record.dart';

class HiveService {
  HiveService._();
  static final HiveService instance = HiveService._();

  late Box<AssessmentRecord> _box;
  bool _ready = false;

  // ── Init (call once in main()) ────────────────────────────
  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(ImsafeScoresAdapter());
    Hive.registerAdapter(PaveScoresAdapter());
    Hive.registerAdapter(AssessmentRecordAdapter());
    instance._box = await Hive.openBox<AssessmentRecord>(kAssessmentBox);
    instance._ready = true;
  }

  Box<AssessmentRecord> get box {
    assert(_ready, 'Call HiveService.init() before using HiveService');
    return _box;
  }

  // ── Save ──────────────────────────────────────────────────
  Future<AssessmentRecord> saveAssessment({
    required double totalRiskScore,
    required String decision,
    required ImsafeScores imsafe,
    required PaveScores   pave,
    double  arousalLevel = 5.0,
    String  pilotName    = '',
    String  flightId     = '',
    String  decideNotes  = '',
    String  flightPhase  = 'pre_flight',
  }) async {
    final record = AssessmentRecord(
      id:             const Uuid().v4(),
      timestamp:      DateTime.now(),
      totalRiskScore: totalRiskScore,
      decision:       decision,
      imsafe:         imsafe,
      pave:           pave,
      arousalLevel:   arousalLevel,
      pilotName:      pilotName,
      flightId:       flightId,
      decideNotes:    decideNotes,
      flightPhase:    flightPhase,
    );
    await box.put(record.id, record);
    return record;
  }

  // ── Query ─────────────────────────────────────────────────
  List<AssessmentRecord> getAll() =>
      box.values.toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

  List<AssessmentRecord> getLast(int n) => getAll().take(n).toList();

  AssessmentRecord? getById(String id) => box.get(id);

  // ── Stats ─────────────────────────────────────────────────
  int get totalCount => box.length;

  int countByDecision(String d) =>
      box.values.where((r) => r.decision == d).length;

  double get averageRisk {
    if (box.isEmpty) return 0;
    final sum = box.values.fold(0.0, (s, r) => s + r.totalRiskScore);
    return sum / box.length;
  }

  /// Returns daily average risk for the last [days] days
  /// Result: list of (date, avgScore) sorted oldest→newest
  List<MapEntry<DateTime, double>> dailyTrend({int days = 14}) {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    final grouped = <String, List<double>>{};
    for (final r in box.values) {
      if (r.timestamp.isBefore(cutoff)) continue;
      final key =
          '${r.timestamp.year}-${r.timestamp.month.toString().padLeft(2,'0')}-'
          '${r.timestamp.day.toString().padLeft(2,'0')}';
      (grouped[key] ??= []).add(r.totalRiskScore);
    }
    return grouped.entries
        .map((e) {
          final parts = e.key.split('-');
          final dt    = DateTime(int.parse(parts[0]),
                                  int.parse(parts[1]),
                                  int.parse(parts[2]));
          final avg   = e.value.fold(0.0, (s, v) => s + v) / e.value.length;
          return MapEntry(dt, avg);
        })
        .toList()
        ..sort((a, b) => a.key.compareTo(b.key));
  }

  // ── Delete ────────────────────────────────────────────────
  Future<void> deleteById(String id) async => box.delete(id);
  Future<void> clearAll()              async => box.clear();
}
