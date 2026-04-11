// ─── SCORING ENGINE ───────────────────────────────────────────────────────────
// نظام تسجيل واقعي — كل عامل HIGH يؤثر على القرار النهائي

import 'package:flutter/material.dart';
import 'models.dart';

class PilotScore {
  // ── Raw scores ──
  final int imsafeScore;      // 0–12  (6 items × 0/1/2)
  final int paveScore;        // 0–20  (20 checkpoints)
  final int decideScore;      // 0–6   (6 steps)

  // ── Risk flags (instant NO-GO triggers) ──
  final bool hasAlcohol;      // A = HIGH → immediate NO-GO
  final bool hasCriticalIllness; // I = HIGH → NO-GO
  final bool hasMedication;   // M = HIGH → CAUTION min
  final bool hasFatigue;      // F = HIGH → NO-GO
  final bool hasStress;       // S = HIGH → CAUTION min
  final bool hasEmotions;     // E = HIGH → CAUTION min

  // ── Individual ratings ──
  final Map<String, String> imsafeRatings; // key → 'LOW'/'MEDIUM'/'HIGH'

  // ── PAVE gaps ──
  final int paveMissedChecks;

  // ── DECIDE completion ──
  final int decideCompletedSteps;

  const PilotScore({
    required this.imsafeScore,
    required this.paveScore,
    required this.decideScore,
    required this.hasAlcohol,
    required this.hasCriticalIllness,
    required this.hasMedication,
    required this.hasFatigue,
    required this.hasStress,
    required this.hasEmotions,
    required this.imsafeRatings,
    required this.paveMissedChecks,
    required this.decideCompletedSteps,
  });

  // ── Weighted performance score 0–100 ──
  double get performanceScore {
    // IMSAFE: 40% weight (lower risk = higher score)
    // final imsafePct = 1.0 - (imsafeScore / 56.0);
    final imsafePct =  1.0 - (imsafeScore / 6.0);
    // PAVE: 35% weight (more checks = higher score)
    final totalPave = 20;
    final pavePct = paveScore / totalPave;
    // DECIDE: 25% weight (more steps done = higher score)
    final decidePct = decideScore / 6.0;

    double raw = (imsafePct * 40) + (pavePct * 35) + (decidePct * 25);

    // Penalties for critical flags
    if (hasAlcohol) raw -= 30;
    if (hasCriticalIllness) raw -= 25;
    if (hasFatigue) raw -= 20;
    if (hasMedication) raw -= 10;
    if (hasStress) raw -= 8;
    if (hasEmotions) raw -= 6;

    return raw.clamp(0.0, 100.0);
  }

  // ── FINAL DECISION — realistic logic ──
  FlightDecision get finalDecision {
    // ── Immediate NO-GO conditions ──
    if (hasAlcohol) return FlightDecision.noGo;
    if (hasCriticalIllness) return FlightDecision.noGo;
    if (hasFatigue) return FlightDecision.noGo;

    // ── Count HIGH ratings ──
    final highCount = imsafeRatings.values.where((r) => r == 'HIGH').length;
    final mediumCount = imsafeRatings.values.where((r) => r == 'MEDIUM').length;

    if (highCount >= 2) return FlightDecision.noGo;
    if (highCount == 1) return FlightDecision.caution;
    if (mediumCount >= 3) return FlightDecision.caution;

    // ── PAVE gaps ──
    if (paveMissedChecks >= 8) return FlightDecision.noGo;
    if (paveMissedChecks >= 4) return FlightDecision.caution;

    // ── DECIDE incomplete ──
    if (decideCompletedSteps == 0) return FlightDecision.caution;

    // ── Performance score threshold ──
    if (performanceScore < 40) return FlightDecision.noGo;
    if (performanceScore < 65) return FlightDecision.caution;

    return FlightDecision.go;
  }

  // ── Performance category label ──
  String get performanceLabel {
    final s = performanceScore;
    if (s >= 85) return 'EXCELLENT';
    if (s >= 70) return 'GOOD';
    if (s >= 55) return 'MARGINAL';
    if (s >= 35) return 'POOR';
    return 'CRITICAL';
  }

  Color get performanceColor {
    final s = performanceScore;
    if (s >= 85) return const Color(0xFF00E676);
    if (s >= 70) return const Color(0xFF00C8F0);
    if (s >= 55) return const Color(0xFFFFB020);
    if (s >= 35) return const Color(0xFFFF6B35);
    return const Color(0xFFFF3D57);
  }

  // ── Reason list for NO-GO / CAUTION ──
  List<String> get decisionReasons {
    final reasons = <String>[];
    if (hasAlcohol) reasons.add('🍺 Alcohol — Immediate NO-GO: 8-hour rule violated');
    if (hasCriticalIllness) reasons.add('🤒 Illness rated HIGH — Medical clearance required');
    if (hasFatigue) reasons.add('😴 Fatigue HIGH — Rest period mandatory before flight');
    if (hasMedication) reasons.add('💊 Medication HIGH — Adverse effects risk');
    if (hasStress) reasons.add('🧠 Stress HIGH — Cognitive impairment likely');
    if (hasEmotions) reasons.add('💭 Emotions HIGH — Decision-making compromised');
    if (paveMissedChecks >= 4) reasons.add('✈️ PAVE: $paveMissedChecks critical checks incomplete');
    if (decideCompletedSteps < 3) reasons.add('🎯 DECIDE: Only $decideCompletedSteps/6 steps completed');
    return reasons;
  }

  // ── Radar chart data (0.0–1.0 per axis) ──
  // Higher = better performance on that axis
  Map<String, double> get radarData => {
    // 'IMSAFE':  1.0 - (imsafeScore / 56.0),
    'IMSAFE': 1.0- (imsafeScore / 6.0),
    'PAVE':    paveScore / 20.0,
    'DECIDE':  decideScore / 6.0,
    'Mental':  hasStress || hasEmotions ? 0.2 : 0.9,
    'Physical': hasAlcohol || hasCriticalIllness || hasFatigue ? 0.1 : 0.85,
  };

  // ── Timeline chart — score breakdown per component ──
  List<BarData> get barChartData => [
    // BarData(label: 'IMSAFE\nSafety', value: (1.0 - imsafeScore / 56.0) * 100,
    //     color: const Color(0xFF00C8F0)),
    BarData(label: 'IMSAFE\nSafety', value: (1.0- imsafeScore / 6.0) * 100,
        color: const Color(0xFF00C8F0)),
    BarData(label: 'PAVE\nReadiness', value: (paveScore / 20.0) * 100,
        color: const Color(0xFF00E676)),
    BarData(label: 'DECIDE\nProcess', value: (decideScore / 6.0) * 100,
        color: const Color(0xFFFFB020)),
    BarData(label: 'Mental\nFitness', value: hasStress || hasEmotions ? 20 : 90,
        color: const Color(0xFFB060FF)),
    BarData(label: 'Physical\nFitness', value: hasAlcohol || hasCriticalIllness || hasFatigue ? 10 : 85,
        color: const Color(0xFFFF6B35)),
  ];

  // ── Factory from assessment data ──
  factory PilotScore.fromAssessment({
    required List<ImsafeItem> imsafe,
    required List<PaveItem> pave,
    required List<DecideStep> decide,
  }) {
    final ratings = {for (final i in imsafe) i.key: i.rating};
    // final imsafeScore = imsafe.fold(0, (s, i) => s + i.riskScore);
    final imsafeScore = imsafe.where((i) => i.rating != 'LOW').length;

    final paveChecked = pave.fold(0, (s, i) => s + i.checkpoints.where((c) => c.checked).length);
    final paveTotal = pave.fold(0, (s, i) => s + i.checkpoints.length);
    final decideCompleted = decide.where((s) => s.completed).length;

    return PilotScore(
      imsafeScore: imsafeScore,
      paveScore: paveChecked,
      decideScore: decideCompleted,
      hasAlcohol: ratings['A'] == 'HIGH',
      hasCriticalIllness: ratings['I'] == 'HIGH',
      hasMedication: ratings['M'] == 'HIGH',
      hasFatigue: ratings['F'] == 'HIGH',
      hasStress: ratings['S'] == 'HIGH',
      hasEmotions: ratings['E'] == 'HIGH',
      imsafeRatings: ratings,
      paveMissedChecks: paveTotal - paveChecked,
      decideCompletedSteps: decideCompleted,
    );
  }
}

enum FlightDecision { go, caution, noGo }

extension FlightDecisionExt on FlightDecision {
  String get label {
    switch (this) {
      case FlightDecision.go: return 'GO';
      case FlightDecision.caution: return 'CAUTION';
      case FlightDecision.noGo: return 'NO-GO';
    }
  }
  String get arabicLabel {
    switch (this) {
      case FlightDecision.go: return 'طيران مسموح';
      case FlightDecision.caution: return 'تحذير';
      case FlightDecision.noGo: return 'ممنوع الطيران';
    }
  }
  String get emoji {
    switch (this) {
      case FlightDecision.go: return '✅';
      case FlightDecision.caution: return '⚠️';
      case FlightDecision.noGo: return '🛑';
    }
  }
  Color get color {
    switch (this) {
      case FlightDecision.go: return const Color(0xFF00E676);
      case FlightDecision.caution: return const Color(0xFFFFB020);
      case FlightDecision.noGo: return const Color(0xFFFF3D57);
    }
  }
}

class BarData {
  final String label;
  final double value; // 0–100
  final Color color;
  const BarData({required this.label, required this.value, required this.color});
}
