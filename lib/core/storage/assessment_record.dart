// lib/core/storage/assessment_record.dart
// ══════════════════════════════════════════════════════════════
// Hive model — stores one complete ADM session result
// Run: flutter pub run build_runner build --delete-conflicting-outputs
// ══════════════════════════════════════════════════════════════

import 'package:hive/hive.dart';

part 'assessment_record.g.dart';

// ── Type IDs ─────────────────────────────────────────────────
// Keep unique across entire app — never reuse a deleted ID
const int kAssessmentRecordTypeId = 0;
const int kImsafeScoresTypeId     = 1;
const int kPaveScoresTypeId       = 2;

// ── Box name ─────────────────────────────────────────────────
const String kAssessmentBox = 'assessments';

// ─────────────────────────────────────────────────────────────
// Top-level Assessment Record
// ─────────────────────────────────────────────────────────────
@HiveType(typeId: kAssessmentRecordTypeId)
class AssessmentRecord extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime timestamp;

  @HiveField(2)
  final String pilotName;   // optional — set from profile

  @HiveField(3)
  final String flightId;    // optional — e.g. "AA101"

  // ── Scores ──────────────────────────────────────────────────
  @HiveField(4)
  final double totalRiskScore;   // 0–100

  @HiveField(5)
  final String decision;         // 'go' | 'caution' | 'no_go'

  @HiveField(6)
  final ImsafeScores imsafe;

  @HiveField(7)
  final PaveScores pave;

  // ── Arousal ─────────────────────────────────────────────────
  @HiveField(8)
  final double arousalLevel;     // 0–10 (Yerkes-Dodson)

  // ── DECIDE notes ────────────────────────────────────────────
  @HiveField(9)
  final String decideNotes;

  // ── Phase context ───────────────────────────────────────────
  @HiveField(10)
  final String flightPhase;      // 'pre_flight' | 'in_flight' | 'post_flight'

   AssessmentRecord({
    required this.id,
    required this.timestamp,
    this.pilotName   = '',
    this.flightId    = '',
    required this.totalRiskScore,
    required this.decision,
    required this.imsafe,
    required this.pave,
    this.arousalLevel  = 5.0,
    this.decideNotes   = '',
    this.flightPhase   = 'pre_flight',
  });

  // ── Helpers ─────────────────────────────────────────────────
  bool get isNoGo     => decision == 'no_go';
  bool get isCaution  => decision == 'caution';
  bool get isGo       => decision == 'go';

  String get decisionLabel => switch (decision) {
    'go'      => 'GO',
    'caution' => 'CAUTION',
    'no_go'   => 'NO-GO',
    _         => decision.toUpperCase(),
  };
}

// ─────────────────────────────────────────────────────────────
// IMSAFE individual scores
// ─────────────────────────────────────────────────────────────
@HiveType(typeId: kImsafeScoresTypeId)
class ImsafeScores {
  @HiveField(0) final double illness;
  @HiveField(1) final double medication;
  @HiveField(2) final double stress;
  @HiveField(3) final double alcohol;
  @HiveField(4) final double fatigue;
  @HiveField(5) final double emotion;

  const ImsafeScores({
    this.illness    = 0,
    this.medication = 0,
    this.stress     = 0,
    this.alcohol    = 0,
    this.fatigue    = 0,
    this.emotion    = 0,
  });

  double get total =>
      (illness + medication + stress + alcohol + fatigue + emotion) / 6;

  List<double> get asList =>
      [illness, medication, stress, alcohol, fatigue, emotion];

  static const labels = ['I', 'M', 'S', 'A', 'F', 'E'];
  static const fullLabels = [
    'Illness', 'Medication', 'Stress', 'Alcohol', 'Fatigue', 'Emotion'
  ];
}

// ─────────────────────────────────────────────────────────────
// PAVE individual scores
// ─────────────────────────────────────────────────────────────
@HiveType(typeId: kPaveScoresTypeId)
class PaveScores {
  @HiveField(0) final double pilot;
  @HiveField(1) final double aircraft;
  @HiveField(2) final double environment;
  @HiveField(3) final double external;

  const PaveScores({
    this.pilot       = 0,
    this.aircraft    = 0,
    this.environment = 0,
    this.external    = 0,
  });

  double get total =>
      (pilot + aircraft + environment + external) / 4;

  List<double> get asList => [pilot, aircraft, environment, external];

  static const labels     = ['P', 'A', 'V', 'E'];
  static const fullLabels = ['Pilot', 'Aircraft', 'enVironment', 'External'];
}
