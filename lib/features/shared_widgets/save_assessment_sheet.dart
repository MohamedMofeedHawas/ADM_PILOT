// lib/features/shared_widgets/save_assessment_sheet.dart
// ══════════════════════════════════════════════════════════════
// Drop-in bottom sheet — call showSaveSheet() from any screen
// to save the current assessment to Hive history
// ══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../profile/profile_provider.dart';
import '../../core/storage/assessment_provider.dart';
import '../history/history_screen.dart';

const _kGo      = Color(0xFF00C853);
const _kCaution = Color(0xFFFFAA00);
const _kNoGo    = Color(0xFFFF1744);
const _kCyan    = Color(0xFF00BCD4);
const _kSurface = Color(0xFF0D1520);
const _kBorder  = Color(0xFF1A3A2A);
const _kText1   = Color(0xFFE0E0E0);
const _kText2   = Color(0xFF558866);

// ── Public helper — call this anywhere ───────────────────────
/// Shows a bottom sheet and saves the assessment when confirmed.
///
/// Example from your ImsafeScreen:
/// ```dart
/// showSaveSheet(
///   context: context,
///   totalRisk: myRiskScore,
///   decision: 'go',         // 'go' | 'caution' | 'no_go'
///   imsafeScores: {...},    // see params below
/// );
/// ```
Future<void> showSaveSheet({
  required BuildContext context,
  required double totalRisk,
  required String decision,
  // IMSAFE
  double illness    = 0,
  double medication = 0,
  double stress     = 0,
  double alcohol    = 0,
  double fatigue    = 0,
  double emotion    = 0,
  // PAVE
  double pilotScore    = 0,
  double aircraftScore = 0,
  double envScore      = 0,
  double extScore      = 0,
  // Arousal
  double arousal = 5.0,
  // Notes
  String notes = '',
}) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: _kSurface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _SaveSheet(
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
      extScore:     extScore,
      arousal:      arousal,
      notes:        notes,
    ),
  );
}

// ── Internal bottom sheet ─────────────────────────────────────
class _SaveSheet extends StatefulWidget {
  final double totalRisk, illness, medication, stress, alcohol,
      fatigue, emotion, pilotScore, aircraftScore, envScore, extScore, arousal;
  final String decision, notes;

  const _SaveSheet({
    required this.totalRisk,  required this.decision,
    required this.illness,    required this.medication,
    required this.stress,     required this.alcohol,
    required this.fatigue,    required this.emotion,
    required this.pilotScore, required this.aircraftScore,
    required this.envScore,   required this.extScore,
    required this.arousal,    required this.notes,
  });

  @override State<_SaveSheet> createState() => _SaveSheetState();
}

class _SaveSheetState extends State<_SaveSheet> {
  bool _saving = false;
  bool _saved  = false;

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>();
    final color   = widget.decision == 'go'      ? _kGo
                  : widget.decision == 'caution'  ? _kCaution
                  : _kNoGo;
    final label   = widget.decision == 'go'      ? 'GO'
                  : widget.decision == 'caution'  ? 'CAUTION'
                  : 'NO-GO';

    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        child: Column(mainAxisSize: MainAxisSize.min, children: [

          // ── Handle ────────────────────────────────────────
          Center(child: Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: _kBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          )),
          const SizedBox(height: 16),

          // ── Decision badge ────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color.withOpacity(0.4)),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withOpacity(0.12),
                  border: Border.all(color: color.withOpacity(0.4)),
                ),
                child: Center(child: Text(
                  '${widget.totalRisk.toStringAsFixed(0)}',
                  style: GoogleFonts.shareTechMono(
                      fontSize: 14, color: color,
                      fontWeight: FontWeight.w700),
                )),
              ),
              const SizedBox(width: 12),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('FLIGHT DECISION',
                    style: GoogleFonts.shareTechMono(
                        fontSize: 9, color: _kText2, letterSpacing: 1.5)),
                Text(label,
                    style: GoogleFonts.shareTechMono(
                        fontSize: 22, color: color,
                        fontWeight: FontWeight.w700, letterSpacing: 2)),
              ]),
            ]),
          ),
          const SizedBox(height: 16),

          // ── Pilot info preview ─────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: _kSurface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _kBorder),
            ),
            child: Row(children: [
              const Icon(Icons.person_outline, color: _kCyan, size: 16),
              const SizedBox(width: 10),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                  profile.pilotName.isNotEmpty
                      ? profile.pilotName : 'No pilot name set',
                  style: TextStyle(
                      fontSize: 13, color: _kText1,
                      fontWeight: profile.pilotName.isNotEmpty
                          ? FontWeight.w600 : FontWeight.w400),
                ),
                if (profile.flightId.isNotEmpty)
                  Text(profile.flightId,
                      style: GoogleFonts.shareTechMono(
                          fontSize: 10, color: _kCyan)),
              ])),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(
                    builder: (_) => const _ProfileScreenInline(),
                  ));
                },
                child: Text('EDIT',
                    style: GoogleFonts.shareTechMono(
                        fontSize: 10, color: _kText2)),
              ),
            ]),
          ),
          const SizedBox(height: 20),

          // ── Action buttons ────────────────────────────────
          if (!_saved) ...[
            SizedBox(
              height: 52, width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _saving ? null : () => _doSave(context),
                icon: _saving
                    ? const SizedBox(width: 16, height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.save_outlined, size: 18),
                label: Text(
                  _saving ? 'SAVING...' : 'SAVE TO HISTORY',
                  style: GoogleFonts.shareTechMono(
                      fontSize: 13, letterSpacing: 1.5),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: color.withOpacity(0.15),
                  foregroundColor: color,
                  side: BorderSide(color: color),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 44, width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('CANCEL',
                    style: GoogleFonts.shareTechMono(
                        fontSize: 12, color: _kText2, letterSpacing: 1)),
              ),
            ),
          ] else ...[
            // ── Saved confirmation ─────────────────────────
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _kGo.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _kGo.withOpacity(0.4)),
              ),
              child: Row(children: [
                const Icon(Icons.check_circle, color: _kGo, size: 20),
                const SizedBox(width: 12),
                Expanded(child: Text('Assessment saved to history',
                    style: GoogleFonts.shareTechMono(
                        fontSize: 12, color: _kGo))),
              ]),
            ),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('CLOSE',
                    style: GoogleFonts.shareTechMono(
                        fontSize: 11, color: _kText2)),
              )),
              const SizedBox(width: 8),
              Expanded(child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(
                      builder: (_) => const HistoryScreen()));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kCyan.withOpacity(0.12),
                  foregroundColor: _kCyan,
                  side: const BorderSide(color: _kCyan),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                child: Text('VIEW HISTORY',
                    style: GoogleFonts.shareTechMono(fontSize: 11)),
              )),
            ]),
          ],
        ]),
      ),
    );
  }

  Future<void> _doSave(BuildContext ctx) async {
    setState(() => _saving = true);
    final profile = ctx.read<ProfileProvider>();
    await ctx.read<AssessmentProvider>().saveCurrentAssessment(
      imsafeTotal:   widget.illness + widget.medication + widget.stress +
                     widget.alcohol + widget.fatigue + widget.emotion,
      paveTotal:     widget.pilotScore + widget.aircraftScore +
                     widget.envScore + widget.extScore,
      totalRisk:     widget.totalRisk,
      decision:      widget.decision,
      illness:       widget.illness,
      medication:    widget.medication,
      stress:        widget.stress,
      alcohol:       widget.alcohol,
      fatigue:       widget.fatigue,
      emotion:       widget.emotion,
      pilotScore:    widget.pilotScore,
      aircraftScore: widget.aircraftScore,
      envScore:      widget.envScore,
      extScore:      widget.extScore,
      arousal:       widget.arousal,
      pilotName:     profile.pilotName,
      flightId:      profile.flightId,
      notes:         widget.notes,
      phase:         profile.flightPhase,
    );
    setState(() { _saving = false; _saved = true; });
  }
}

// ── Inline profile screen for sheet redirect ──────────────────
class _ProfileScreenInline extends StatefulWidget {
  const _ProfileScreenInline();
  @override State<_ProfileScreenInline> createState() =>
      _ProfileScreenInlineState();
}

class _ProfileScreenInlineState extends State<_ProfileScreenInline> {
  late TextEditingController _nameCtrl;
  late TextEditingController _flightCtrl;

  @override
  void initState() {
    super.initState();
    final p   = context.read<ProfileProvider>();
    _nameCtrl = TextEditingController(text: p.pilotName);
    _flightCtrl = TextEditingController(text: p.flightId);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _flightCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFF0A0E14),
    appBar: AppBar(
      backgroundColor: _kSurface,
      title: Text('PROFILE',
          style: GoogleFonts.shareTechMono(
              fontSize: 14, color: _kCyan, letterSpacing: 2)),
      actions: [
        TextButton(
          onPressed: () {
            final p = context.read<ProfileProvider>();
            p.setPilotName(_nameCtrl.text.trim());
            p.setFlightId(_flightCtrl.text.trim());
            Navigator.pop(context);
          },
          child: Text('SAVE',
              style: GoogleFonts.shareTechMono(
                  fontSize: 12, color: _kGo)),
        ),
      ],
    ),
    body: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        TextField(
          controller: _nameCtrl,
          style: const TextStyle(color: _kText1),
          decoration: const InputDecoration(labelText: 'Pilot Name'),
          textCapitalization: TextCapitalization.words,
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _flightCtrl,
          style: const TextStyle(color: _kText1),
          decoration: const InputDecoration(labelText: 'Flight ID'),
          textCapitalization: TextCapitalization.characters,
        ),
      ]),
    ),
  );
}
