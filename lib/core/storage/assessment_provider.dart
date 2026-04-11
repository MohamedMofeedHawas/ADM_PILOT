// lib/core/storage/assessment_provider.dart
// ══════════════════════════════════════════════════════════════
// ChangeNotifier — bridges HiveService with the UI
// NO demo data — 100% real pilot assessments only
// ══════════════════════════════════════════════════════════════

import 'package:flutter/foundation.dart';
import 'assessment_record.dart';
import 'hive_service.dart';

class AssessmentProvider extends ChangeNotifier {
  final _svc = HiveService.instance;

  List<AssessmentRecord> _records = [];
  List<AssessmentRecord> get records => _records;

  String _filterDecision = 'all';
  String get filterDecision => _filterDecision;

  // ── Load all records from Hive ────────────────────────────
  void load() {
    _records = _svc.getAll();
    notifyListeners();
  }

  // ── Save one complete pilot assessment ────────────────────
  Future<void> saveCurrentAssessment({
    required double imsafeTotal,
    required double paveTotal,
    required double totalRisk,
    required String decision,
    double illness      = 0,
    double medication   = 0,
    double stress       = 0,
    double alcohol      = 0,
    double fatigue      = 0,
    double emotion      = 0,
    double pilotScore   = 0,
    double aircraftScore = 0,
    double envScore     = 0,
    double extScore     = 0,
    double arousal      = 5.0,
    String pilotName    = '',
    String flightId     = '',
    String notes        = '',
    String phase        = 'pre_flight',
  }) async {
    await _svc.saveAssessment(
      totalRiskScore: totalRisk,
      decision:       decision,
      imsafe: ImsafeScores(
        illness:    illness,
        medication: medication,
        stress:     stress,
        alcohol:    alcohol,
        fatigue:    fatigue,
        emotion:    emotion,
      ),
      pave: PaveScores(
        pilot:       pilotScore,
        aircraft:    aircraftScore,
        environment: envScore,
        external:    extScore,
      ),
      arousalLevel: arousal,
      pilotName:    pilotName,
      flightId:     flightId,
      decideNotes:  notes,
      flightPhase:  phase,
    );
    load();
  }

  // ── Filter ────────────────────────────────────────────────
  void setFilter(String f) {
    _filterDecision = f;
    notifyListeners();
  }

  List<AssessmentRecord> get filtered {
    if (_filterDecision == 'all') return _records;
    return _records.where((r) => r.decision == _filterDecision).toList();
  }

  // ── Delete ────────────────────────────────────────────────
  Future<void> delete(String id) async {
    await _svc.deleteById(id);
    load();
  }

  Future<void> clearAll() async {
    await _svc.clearAll();
    load();
  }

  // ── Stats (real data only) ────────────────────────────────
  int    get totalCount   => _svc.totalCount;
  int    get goCount      => _svc.countByDecision('go');
  int    get cautionCount => _svc.countByDecision('caution');
  int    get noGoCount    => _svc.countByDecision('no_go');
  double get avgRisk      => _svc.averageRisk;

  List<MapEntry<DateTime, double>> get dailyTrend =>
      _svc.dailyTrend(days: 30);

  List<AssessmentRecord> getLast(int n) => _svc.getLast(n);
  AssessmentRecord?      getById(String id) => _svc.getById(id);
}
