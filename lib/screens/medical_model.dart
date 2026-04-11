// lib/features/medical/medical_models.dart
// ══════════════════════════════════════════════════════════════
// Medical Assessment — data models & reference ranges
// ══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

// ── Risk Level enum ────────────────────────────────────────────
enum MedLevel { low, normal, medium, high, veryDangerous }

extension MedLevelExt on MedLevel {
  String get label => const {
    MedLevel.low:           'LOW',
    MedLevel.normal:        'NORMAL',
    MedLevel.medium:        'MEDIUM',
    MedLevel.high:          'HIGH',
    MedLevel.veryDangerous: 'VERY DANGEROUS',
  }[this]!;

  String get arabicLabel => const {
    MedLevel.low:           'منخفض',
    MedLevel.normal:        'طبيعي',
    MedLevel.medium:        'متوسط',
    MedLevel.high:          'مرتفع',
    MedLevel.veryDangerous: 'خطر جداً',
  }[this]!;

  Color get color => const {
    MedLevel.low:           Color(0xFF00BCD4),
    MedLevel.normal:        Color(0xFF00E676),
    MedLevel.medium:        Color(0xFFFFB020),
    MedLevel.high:          Color(0xFFFF6B35),
    MedLevel.veryDangerous: Color(0xFFFF3D57),
  }[this]!;

  Color get dimColor => const {
    MedLevel.low:           Color(0xFF0A3A4A),
    MedLevel.normal:        Color(0xFF003A1A),
    MedLevel.medium:        Color(0xFF4A3000),
    MedLevel.high:          Color(0xFF4A1800),
    MedLevel.veryDangerous: Color(0xFF3A0010),
  }[this]!;

  IconData get icon => const {
    MedLevel.low:           Icons.arrow_downward_rounded,
    MedLevel.normal:        Icons.check_circle_outline,
    MedLevel.medium:        Icons.warning_amber_outlined,
    MedLevel.high:          Icons.error_outline,
    MedLevel.veryDangerous: Icons.dangerous_outlined,
  }[this]!;

  int get riskPoints => const {
    MedLevel.low:           1,
    MedLevel.normal:        0,
    MedLevel.medium:        2,
    MedLevel.high:          4,
    MedLevel.veryDangerous: 10,
  }[this]!;

  bool get blocksGo => this == MedLevel.veryDangerous || this == MedLevel.high;
}

// ── Reference Range entry ─────────────────────────────────────
class MedRangeRow {
  final String rangeText;
  final String arabicRangeText;
  final MedLevel level;
  const MedRangeRow(this.rangeText, this.arabicRangeText, this.level);
}

// ── Medical Vital definition ──────────────────────────────────
class MedVital {
  final String id;
  final String title;
  final String arabicTitle;
  final String unit;
  final String iconEmoji;
  final String hint;
  final String arabicHint;
  final List<MedRangeRow> ranges;
  final MedLevel Function(double value) classify;

  // For dual-value (systolic/diastolic)
  final bool isDual;
  final String? unit2;
  final String? hint2;
  final String? arabicHint2;
  final MedLevel Function(double v1, double v2)? classifyDual;

  const MedVital({
    required this.id,
    required this.title,
    required this.arabicTitle,
    required this.unit,
    required this.iconEmoji,
    required this.hint,
    required this.arabicHint,
    required this.ranges,
    required this.classify,
    this.isDual = false,
    this.unit2,
    this.hint2,
    this.arabicHint2,
    this.classifyDual,
  });
}

// ── All vitals definition ─────────────────────────────────────
List<MedVital> buildMedVitals() => [
  // ── Heart Rate ────────────────────────────────────────────
  MedVital(
    id: 'hr',
    title: 'Heart Rate',
    arabicTitle: 'معدل ضربات القلب',
    unit: 'bpm',
    iconEmoji: '❤️',
    hint: '75',
    arabicHint: ' 75',
    ranges: const [
      MedRangeRow('< 40',        '< 40',      MedLevel.veryDangerous),
      MedRangeRow('40 – 59',     '40 – 59',   MedLevel.low),
      MedRangeRow('60 – 100',    '60 – 100',  MedLevel.normal),
      MedRangeRow('101 – 130',   '101 – 130', MedLevel.medium),
      MedRangeRow('131 – 160',   '131 – 160', MedLevel.high),
      MedRangeRow('> 160',       '> 160',     MedLevel.veryDangerous),
    ],
    classify: (v) {
      if (v < 40 || v > 160) return MedLevel.veryDangerous;
      if (v < 60)  return MedLevel.low;
      if (v <= 100) return MedLevel.normal;
      if (v <= 130) return MedLevel.medium;
      return MedLevel.high;
    },
  ),

  // ── Blood Pressure ────────────────────────────────────────
  MedVital(
    id: 'bp',
    title: 'Blood Pressure',
    arabicTitle: 'ضغط الدم',
    unit: 'mmHg',
    iconEmoji: '🩺',
    hint: '120',
    arabicHint: 'الضغط الانقباضي',
    isDual: true,
    unit2: 'mmHg',
    hint2: '80',
    arabicHint2: 'الضغط الانبساطي',
    ranges: const [
      MedRangeRow('Sys < 90  or Dia < 60',      'انقباضي < 90  أو انبساطي < 60',   MedLevel.low),
      MedRangeRow('Sys 90–120 / Dia 60–80',      'انقباضي 90–120 / انبساطي 60–80',  MedLevel.normal),
      MedRangeRow('Sys 121–139 / Dia 81–89',     'انقباضي 121–139 / انبساطي 81–89', MedLevel.medium),
      MedRangeRow('Sys 140–179 / Dia 90–109',    'انقباضي 140–179 / انبساطي 90–109',MedLevel.high),
      MedRangeRow('Sys ≥ 180  or Dia ≥ 110',     'انقباضي ≥ 180  أو انبساطي ≥ 110', MedLevel.veryDangerous),
    ],
    classify: (v) => MedLevel.normal,
    classifyDual: (sys, dia) {
      if (sys >= 180 || dia >= 110) return MedLevel.veryDangerous;
      if (sys < 90 || dia < 60)    return MedLevel.low;
      if (sys <= 120 && dia <= 80)  return MedLevel.normal;
      if (sys <= 139 || dia <= 89)  return MedLevel.medium;
      return MedLevel.high;
    },
  ),

  // ── Blood Sugar ───────────────────────────────────────────
  MedVital(
    id: 'bs',
    title: 'Blood Sugar',
    arabicTitle: 'مستوى السكر في الدم',
    unit: 'mg/dL',
    iconEmoji: '🩸',
    hint: '95',
    arabicHint: ' 95',
    ranges: const [
      MedRangeRow('< 50',       '< 50',        MedLevel.veryDangerous),
      MedRangeRow('50 – 69',    '50 – 69',     MedLevel.low),
      MedRangeRow('70 – 99',    '70 – 99',     MedLevel.normal),
      MedRangeRow('100 – 125',  '100 – 125',   MedLevel.medium),
      MedRangeRow('126 – 199',  '126 – 199',   MedLevel.high),
      MedRangeRow('≥ 200',      '≥ 200',       MedLevel.veryDangerous),
    ],
    classify: (v) {
      if (v < 50 || v >= 200) return MedLevel.veryDangerous;
      if (v < 70)   return MedLevel.low;
      if (v <= 99)  return MedLevel.normal;
      if (v <= 125) return MedLevel.medium;
      return MedLevel.high;
    },
  ),

  // ── Body Temperature ──────────────────────────────────────
  MedVital(
    id: 'temp',
    title: 'Body Temperature',
    arabicTitle: 'درجة حرارة الجسم',
    unit: '°C',
    iconEmoji: '🌡️',
    hint: ' 36.8',
    arabicHint: ' 36.8',
    ranges: const [
      MedRangeRow('< 35.0',      '< 35.0',      MedLevel.veryDangerous),
      MedRangeRow('35.0 – 36.0', '35.0 – 36.0', MedLevel.low),
      MedRangeRow('36.1 – 37.2', '36.1 – 37.2', MedLevel.normal),
      MedRangeRow('37.3 – 37.9', '37.3 – 37.9', MedLevel.medium),
      MedRangeRow('38.0 – 39.4', '38.0 – 39.4', MedLevel.high),
      MedRangeRow('≥ 39.5',      '≥ 39.5',      MedLevel.veryDangerous),
    ],
    classify: (v) {
      if (v < 35.0 || v >= 39.5) return MedLevel.veryDangerous;
      if (v < 36.1)  return MedLevel.low;
      if (v <= 37.2) return MedLevel.normal;
      if (v <= 37.9) return MedLevel.medium;
      return MedLevel.high;
    },
  ),
  MedVital(
    id: 'spo2',
    title: 'Oxygen Saturation',
    arabicTitle: 'تشبع الأكسجين',
    unit: '%',
    iconEmoji: '💨',
    hint: ' 97',
    arabicHint: ' 97',
    ranges: const [
      MedRangeRow('< 88',     '< 88',     MedLevel.veryDangerous),
      MedRangeRow('88 – 91',  '88 – 91',  MedLevel.high),
      MedRangeRow('92 – 94',  '92 – 94',  MedLevel.medium),
      MedRangeRow('95 – 100', '95 – 100', MedLevel.normal),
    ],
    classify: (v) {
      if (v < 88) return MedLevel.veryDangerous;
      if (v <= 91) return MedLevel.high;
      if (v <= 94) return MedLevel.medium;
      return MedLevel.normal;
    },
  ),
  MedVital(
    id: 'hydration',
    title: 'Hydration Level',
    arabicTitle: 'مستوى الترطيب',
    unit: '%',
    iconEmoji: '💧',
    hint: ' 70',
    arabicHint: ' 70',
    ranges: const [
      MedRangeRow('< 40',     '< 40',     MedLevel.veryDangerous),
      MedRangeRow('40 – 49',  '40 – 49',  MedLevel.high),
      MedRangeRow('50 – 59',  '50 – 59',  MedLevel.medium),
      MedRangeRow('60 – 100', '60 – 100', MedLevel.normal),
    ],
    classify: (v) {
      if (v < 40) return MedLevel.veryDangerous;
      if (v <= 49) return MedLevel.high;
      if (v <= 59) return MedLevel.medium;
      return MedLevel.normal;
    },
  ),
  MedVital(
    id: 'resp_rate',
    title: 'Respiratory Rate',
    arabicTitle: 'معدل التنفس',
    unit: 'breaths/min',
    iconEmoji: '🌬️',
    hint: '16',
    arabicHint: ' 16',
    ranges: const [

      MedRangeRow('< 8',        '< 8',        MedLevel.veryDangerous),
      MedRangeRow('8 – 9',      '8 – 9',      MedLevel.high),
      MedRangeRow('10 – 11',    '10 – 11',    MedLevel.medium),
      MedRangeRow('12 – 20',    '12 – 20',    MedLevel.normal),
      MedRangeRow('21 – 24',    '21 – 24',    MedLevel.medium),
      MedRangeRow('25 – 30',    '25 – 30',    MedLevel.high),
      MedRangeRow('> 30',       '> 30',       MedLevel.veryDangerous),
    ],
    classify: (v) {
      if (v < 8 || v > 30) return MedLevel.veryDangerous;
      if ((v >= 8 && v <= 9) || (v >= 25 && v <= 30)) return MedLevel.high;
      if ((v >= 10 && v <= 11) || (v >= 21 && v <= 24)) return MedLevel.medium;
      return MedLevel.normal;
    },
  ),
];

// ── Medical Result (stored per vital) ────────────────────────
class MedVitalResult {
  final String id;
  final double value;
  final double? value2; // for dual (BP diastolic)
  final MedLevel level;

  const MedVitalResult({
    required this.id,
    required this.value,
    this.value2,
    required this.level,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'value': value,
    if (value2 != null) 'value2': value2,
    'level': level.index,
  };

  factory MedVitalResult.fromJson(Map<String, dynamic> j) => MedVitalResult(
    id: j['id'] as String,
    value: (j['value'] as num).toDouble(),
    value2: j['value2'] != null ? (j['value2'] as num).toDouble() : null,
    level: MedLevel.values[j['level'] as int],
  );
}

// ── Full Medical Assessment snapshot ─────────────────────────
class MedicalAssessment {
  final DateTime timestamp;
  final List<MedVitalResult> results;
  final String decision; // 'go' | 'caution' | 'no_go'

  const MedicalAssessment({
    required this.timestamp,
    required this.results,
    required this.decision,
  });

  double get overallScore {
    if (results.isEmpty) return 0;
    final total = results.fold(0, (s, r) => s + r.level.riskPoints);
    final max   = results.length * MedLevel.veryDangerous.riskPoints;
    return (total / max * 100).clamp(0, 100);
  }

  bool get isGo      => decision == 'go';
  bool get isCaution => decision == 'caution';
  bool get isNoGo    => decision == 'no_go';

  String get decisionLabel => isGo ? 'GO' : isCaution ? 'CAUTION' : 'NO-GO';

  Color get decisionColor {
    if (isGo)      return const Color(0xFF00E676);
    if (isCaution) return const Color(0xFFFFB020);
    return const Color(0xFFFF3D57);
  }

  static String calcDecision(List<MedVitalResult> results) {
    final hasVeryDangerous = results.any((r) => r.level == MedLevel.veryDangerous);
    final highCount   = results.where((r) => r.level == MedLevel.high).length;
    final mediumCount = results.where((r) => r.level == MedLevel.medium).length;
    final lowCount    = results.where((r) => r.level == MedLevel.low).length;

    if (hasVeryDangerous || highCount >= 2) return 'no_go';
    if (highCount == 1 || mediumCount >= 2 || lowCount >= 2) return 'caution';
    return 'go';
  }

  Map<String, dynamic> toJson() => {
    'timestamp': timestamp.toIso8601String(),
    'results': results.map((r) => r.toJson()).toList(),
    'decision': decision,
  };

  factory MedicalAssessment.fromJson(Map<String, dynamic> j) => MedicalAssessment(
    timestamp: DateTime.parse(j['timestamp'] as String),
    results:   (j['results'] as List).map((e) => MedVitalResult.fromJson(e as Map<String, dynamic>)).toList(),
    decision:  j['decision'] as String,
  );
}