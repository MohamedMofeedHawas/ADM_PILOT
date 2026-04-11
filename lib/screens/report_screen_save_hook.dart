// lib/screens/report_screen_save_hook.dart
// ══════════════════════════════════════════════════════════════
// PASTE THIS CODE into your existing report_screen.dart
//
// 1. Add the import at the top of report_screen.dart:
//       import 'package:provider/provider.dart';
//       import '../core/storage/assessment_provider.dart';
//
// 2. If your ReportScreen is a StatefulWidget, add this mixin:
//       class _ReportScreenState extends State<ReportScreen>
//           with _AutoSaveMixin {
//
//    Then call _autoSave(context) inside initState():
//       @override
//       void initState() {
//         super.initState();
//         WidgetsBinding.instance.addPostFrameCallback((_) =>
//             _autoSave(context));
//       }
//
// 3. If your ReportScreen is a StatelessWidget, add this call
//    inside build() — wrapped in a WidgetsBinding callback:
//
//       @override
//       Widget build(BuildContext context) {
//         WidgetsBinding.instance.addPostFrameCallback((_) =>
//             _saveOnce(context));
//         return Scaffold(...);
//       }
//
// ══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/storage/assessment_provider.dart';
import '../models/models.dart';         // ImsafeItem, PaveItem, DecideStep
import '../features/profile/profile_provider.dart';

// ── Standalone save function — call from anywhere ─────────────
/// Call once when the report is first displayed.
/// Saves the full assessment result to Hive history.
Future<void> saveAssessmentToHistory({
  required BuildContext context,
  required List<ImsafeItem> imsafe,
  required List<PaveItem>   pave,
  required List<DecideStep> decide,
  String? pilotName,
  String? flightId,
}) async {
  // ── Compute IMSAFE individual scores ──────────────────────
  // Assumes ImsafeItem.rating: 'LOW'=0, 'MEDIUM'=50, 'HIGH'=100
  double _imsafeScore(String rating) => switch (rating) {
    'HIGH'   => 100.0,
    'MEDIUM' => 50.0,
    _        => 0.0,
  };

  final illness    = imsafe.length > 0 ? _imsafeScore(imsafe[0].rating) : 0.0;
  final medication = imsafe.length > 1 ? _imsafeScore(imsafe[1].rating) : 0.0;
  final stress     = imsafe.length > 2 ? _imsafeScore(imsafe[2].rating) : 0.0;
  final alcohol    = imsafe.length > 3 ? _imsafeScore(imsafe[3].rating) : 0.0;
  final fatigue    = imsafe.length > 4 ? _imsafeScore(imsafe[4].rating) : 0.0;
  final emotion    = imsafe.length > 5 ? _imsafeScore(imsafe[5].rating) : 0.0;
  final imsafeAvg  = (illness + medication + stress + alcohol + fatigue + emotion) / 6;

  // ── Compute PAVE completion scores ────────────────────────
  double _pavePct(PaveItem item) {
    if (item.checkpoints.isEmpty) return 0;
    final checked = item.checkpoints.where((c) => c.checked).length;
    // Invert: unchecked checkpoints = higher risk
    return (1 - checked / item.checkpoints.length) * 100;
  }

  final pilotScore    = pave.length > 0 ? _pavePct(pave[0]) : 0.0;
  final aircraftScore = pave.length > 1 ? _pavePct(pave[1]) : 0.0;
  final envScore      = pave.length > 2 ? _pavePct(pave[2]) : 0.0;
  final extScore      = pave.length > 3 ? _pavePct(pave[3]) : 0.0;
  final paveAvg       = (pilotScore + aircraftScore + envScore + extScore) / 4;

  // ── Combined total risk score ──────────────────────────────
  final totalRisk = (imsafeAvg * 0.5 + paveAvg * 0.5).clamp(0.0, 100.0);

  // ── Decision ──────────────────────────────────────────────
  final decision = totalRisk >= 75 ? 'no_go'
                 : totalRisk >= 40 ? 'caution'
                 : 'go';

  // ── DECIDE notes ──────────────────────────────────────────
  final notes = decide
      .where((s) => s.completed && s.userInput.isNotEmpty)
      .map((s) => '${s.key}: ${s.userInput}')
      .join('\n');

  // ── Pilot profile (from ProfileProvider if available) ─────
  String name = pilotName ?? '';
  String fid  = flightId  ?? '';
  try {
    final profile = context.read<ProfileProvider>();
    if (name.isEmpty) name = profile.pilotName;
    if (fid.isEmpty)  fid  = profile.flightId;
  } catch (_) {}

  // ── Save ──────────────────────────────────────────────────
  await context.read<AssessmentProvider>().saveCurrentAssessment(
    imsafeTotal:   imsafeAvg,
    paveTotal:     paveAvg,
    totalRisk:     totalRisk,
    decision:      decision,
    illness:       illness,
    medication:    medication,
    stress:        stress,
    alcohol:       alcohol,
    fatigue:       fatigue,
    emotion:       emotion,
    pilotScore:    pilotScore,
    aircraftScore: aircraftScore,
    envScore:      envScore,
    extScore:      extScore,
    pilotName:     name,
    flightId:      fid,
    notes:         notes,
    phase:         'pre_flight',
  );
}
