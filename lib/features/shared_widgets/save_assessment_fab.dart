// lib/features/shared_widgets/save_assessment_fab.dart
// ══════════════════════════════════════════════════════════════
// Drop-in FAB — add to any existing screen's Scaffold
// ══════════════════════════════════════════════════════════════
//
// USAGE — add to your ImsafeScreen or DecideScreen Scaffold:
//
//   floatingActionButton: SaveAssessmentFab(
//     totalRisk: myProvider.totalScore,
//     decision:  myProvider.decision,    // 'go'|'caution'|'no_go'
//     illness:   illnessProvider.score,
//     medication: medicationProvider.score,
//     stress:    stressProvider.baseScore,
//     alcohol:   alcoholProvider.score,
//     fatigue:   fatigueProvider.score,
//     emotion:   emotionProvider.score,
//     pilotScore:   paveProvider.pilotScore,
//     aircraftScore: paveProvider.aircraftScore,
//     envScore:  paveProvider.envScore,
//     extScore:  paveProvider.externalScore,
//   ),
// ══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'save_assessment_sheet.dart';

const _kGo      = Color(0xFF00C853);
const _kCaution = Color(0xFFFFAA00);
const _kNoGo    = Color(0xFFFF1744);

class SaveAssessmentFab extends StatelessWidget {
  final double totalRisk;
  final String decision;
  final double illness, medication, stress, alcohol, fatigue, emotion;
  final double pilotScore, aircraftScore, envScore, extScore;
  final double arousal;
  final String notes;

  const SaveAssessmentFab({
    super.key,
    required this.totalRisk,
    required this.decision,
    this.illness    = 0,
    this.medication = 0,
    this.stress     = 0,
    this.alcohol    = 0,
    this.fatigue    = 0,
    this.emotion    = 0,
    this.pilotScore    = 0,
    this.aircraftScore = 0,
    this.envScore      = 0,
    this.extScore      = 0,
    this.arousal = 5.0,
    this.notes   = '',
  });

  @override
  Widget build(BuildContext context) {
    final color = decision == 'go'     ? _kGo
                : decision == 'caution' ? _kCaution
                : _kNoGo;

    return FloatingActionButton.extended(
      onPressed: () => showSaveSheet(
        context:      context,
        totalRisk:    totalRisk,
        decision:     decision,
        illness:      illness,
        medication:   medication,
        stress:       stress,
        alcohol:      alcohol,
        fatigue:      fatigue,
        emotion:      emotion,
        pilotScore:   pilotScore,
        aircraftScore: aircraftScore,
        envScore:     envScore,
        extScore:     extScope,
        arousal:      arousal,
        notes:        notes,
      ),
      backgroundColor: color.withOpacity(0.15),
      foregroundColor: color,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: color.withOpacity(0.5)),
      ),
      icon: const Icon(Icons.save_outlined, size: 18),
      label: Text('SAVE',
          style: GoogleFonts.shareTechMono(
              fontSize: 11, letterSpacing: 1.5)),
    );
  }

  // typo fix helper
  double get extScope => extScore;
}
