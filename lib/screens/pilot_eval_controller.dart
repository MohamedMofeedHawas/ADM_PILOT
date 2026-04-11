// lib/models/pilot_eval_controller.dart
// ══════════════════════════════════════════════════════════════
// PilotEvalController — ChangeNotifier that owns all 17 criteria
// Create it ONCE in parent (HomeScreen/MainScreen) so state
// survives Navigator.push / pop.
// ══════════════════════════════════════════════════════════════

import 'package:flutter/foundation.dart';
import '../models/pilot_eval_model.dart';

class PilotEvalController extends ChangeNotifier {
  final List<PilotEvalSection> sections;

  PilotEvalController() : sections = buildPilotEvalSections();

  // ── Totals ─────────────────────────────────────────────────
  int get totalCriteria =>
      sections.fold(0, (s, sec) => s + sec.criteria.length);

  int get totalRated =>
      sections.fold(0, (s, sec) => s + sec.ratedCount);

  bool get allRated => totalRated == totalCriteria;

  double get overallPct {
    final rated = sections
        .expand((s) => s.criteria)
        .where((c) => c.isRated)
        .toList();
    if (rated.isEmpty) return 0;
    return rated.fold(0.0, (s, c) => s + c.ratingPct) / rated.length;
  }

  // ── Mutators ────────────────────────────────────────────────
  void setRating(
      String sectionId, String criterionId, EvalRating rating) {
    final sec = sections.firstWhere((s) => s.id == sectionId,
        orElse: () => sections.first);
    final crit = sec.criteria.firstWhere((c) => c.id == criterionId,
        orElse: () => sec.criteria.first);
    // toggle off if same rating tapped again
    crit.rating = crit.rating == rating ? null : rating;
    notifyListeners();
  }

  void resetAll() {
    for (final sec in sections) {
      for (final c in sec.criteria) {
        c.rating = null;
      }
    }
    notifyListeners();
  }

  // ── Summary string for Dashboard ───────────────────────────
  /// e.g. "12 / 17  •  71%"
  String get summaryText {
    final pct = (overallPct * 100).toInt();
    return '$totalRated / $totalCriteria  •  $pct%';
  }

  /// Colour reflecting current average
  /// Returns raw int so callers can convert however they need
  double get averagePct => overallPct;
}