// lib/core/storage/INTEGRATION_GUIDE.dart
// ══════════════════════════════════════════════════════════════
// HOW TO HOOK YOUR EXISTING SCREENS INTO THE NEW SYSTEM
// ══════════════════════════════════════════════════════════════
//
// ── STEP 1: Save when pilot reaches ReportScreen ─────────────
//
// In ReportScreen initState() or first build, call once:
//
//   context.read<AssessmentProvider>().saveCurrentAssessment(
//     totalRisk:     _computedTotal,
//     decision:      _decision,        // 'go' | 'caution' | 'no_go'
//     illness:       _imsafe[0].riskScore,
//     medication:    _imsafe[1].riskScore,
//     stress:        _imsafe[2].riskScore,
//     alcohol:       _imsafe[3].riskScore,
//     fatigue:       _imsafe[4].riskScore,
//     emotion:       _imsafe[5].riskScore,
//     pilotScore:    _pave[0].completionPct * 100,
//     aircraftScore: _pave[1].completionPct * 100,
//     envScore:      _pave[2].completionPct * 100,
//     extScore:      _pave[3].completionPct * 100,
//     pilotName:     pilotInfo?.pilotName ?? '',
//     flightId:      pilotInfo?.flightId  ?? '',
//     notes:         _decide.map((s) => s.userInput).join('\n'),
//   );
//
// ── STEP 2: Navigate to Dashboard / History ───────────────────
//
//   // Via bottom nav tabs (pages 4 and 5 in main.dart) — automatic
//
//   // Or push directly:
//   Navigator.push(context, MaterialPageRoute(
//       builder: (_) => const DashboardScreen()));
//
//   Navigator.push(context, MaterialPageRoute(
//       builder: (_) => const HistoryScreen()));
//
// ── Page index map ─────────────────────────────────────────────
//   -2 = Welcome
//   -1 = PilotInfo
//    0 = IMSAFE
//    1 = PAVE
//    2 = DECIDE
//    3 = REPORT
//    4 = DASHBOARD  ← new (DASH tab)
//    5 = HISTORY    ← new (LOG tab)
//
// ignore_for_file: unused_import, file_names
