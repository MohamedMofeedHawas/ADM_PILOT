import 'dart:typed_data';
import 'package:flutter/material.dart' show BuildContext;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../core/storage/assessment_record.dart';
import '../../models/models.dart';
import '../../models/pilot_eval_model.dart';
import '../../models/scoring.dart';
import '../../screens/decide_screen.dart';
import '../../screens/pilot_eval_controller.dart';
import '../../screens/pilot_info_screen.dart';

// ═══════════════════════════════════════════════════════════════
// PALETTE
// All colours are explicit — no text is white-on-white
// ═══════════════════════════════════════════════════════════════
const _pageBg    = PdfColors.white;
const _bandBg    = PdfColor(0.08, 0.16, 0.30);       // #142850 navy
const _cardBg    = PdfColors.white;
const _rowAlt    = PdfColor(0.96, 0.97, 0.99);       // alternate row
const _barTrack  = PdfColor(0.86, 0.89, 0.93);       // progress track
const _border    = PdfColor(0.78, 0.83, 0.90);       // borders

// Text — always dark on light, white on dark
const _txtOnDark  = PdfColors.white;
const _txtPrimary = PdfColor(0.08, 0.13, 0.22);      // near-black
const _txtMid     = PdfColor(0.25, 0.35, 0.48);      // slate
const _txtMuted   = PdfColor(0.50, 0.58, 0.68);      // muted

// Semantic
const _kGo       = PdfColor(0.00, 0.62, 0.31);       // green
const _kCaution  = PdfColor(0.82, 0.50, 0.00);       // amber
const _kNoGo     = PdfColor(0.75, 0.07, 0.07);       // red
const _kIcao     = PdfColor(0.00, 0.36, 0.61);       // ICAO blue
const _kNavy     = PdfColor(0.08, 0.16, 0.30);
const _kSlate    = PdfColor(0.25, 0.35, 0.48);
const _kLightBlu = PdfColor(0.88, 0.93, 0.98);       // photo bg

// ═══════════════════════════════════════════════════════════════
class PdfExportService {
  PdfExportService._();
  static final PdfExportService instance = PdfExportService._();

  late pw.Font _base;
  late pw.Font _bold;
  late pw.Font _italic;
  late pw.Font _mono;
  late pw.Font _monoBold;

  Future<void> _loadFonts() async {
    _base     = await PdfGoogleFonts.robotoRegular();
    _bold     = await PdfGoogleFonts.robotoBold();
    _italic   = await PdfGoogleFonts.robotoItalic();
    _mono     = await PdfGoogleFonts.robotoMonoRegular();
    _monoBold = await PdfGoogleFonts.robotoMonoBold();
  }

  // ── Public: from Hive AssessmentRecord ───────────────────
  Future<void> exportAndShare(
      BuildContext context,
      AssessmentRecord r, {
        Uint8List? photoBytes,
      }) async {
    await _loadFonts();
    final bytes = await _buildFromRecord(r, photoBytes: photoBytes);
    await Printing.sharePdf(
      bytes: bytes,
      filename: _filename(r.flightId, r.timestamp),
    );
  }

  // ── Public: from report_screen.dart (legacy API) ─────────
  static Future<void> generateAndPrint({
    required List<ImsafeItem>      imsafe,
    required List<PaveItem>        pave,
    required List<DecideStep>      decide,
    required PilotScore            score,
    required List<HazardEntry>     hazards,
    required Map<String, dynamic>? faceAnalysis,
    required bool                  showArabic,
    PilotInfo?                     pilotInfo,
    PilotEvalController? pilotEvalController,
  }) async {
    final svc = PdfExportService.instance;
    await svc._loadFonts();
    final bytes = await svc._buildFromLegacy(
      imsafe: imsafe, pave: pave, decide: decide,
      score: score, hazards: hazards, pilotInfo: pilotInfo,
        pilotEvalController: pilotEvalController,

    );

    await Printing.layoutPdf(
      onLayout: (_) async => bytes,
      name: _filename(
        pilotInfo?.flightNumber ?? '',
        DateTime.now(),
        pilotInfo?.pilotName,
      ),
    );
  }

  static String _filename(String fid, DateTime dt, [String? name]) {
    final n = name?.replaceAll(' ', '_') ?? 'PILOT';
    final f = fid.isNotEmpty ? fid : n;
    return 'ADM_${f}_${DateFormat('yyyyMMdd_HHmm').format(dt)}.pdf';
  }

  // ═══════════════════════════════════════════════════════════
  // BUILD FROM AssessmentRecord
  // ═══════════════════════════════════════════════════════════
  Future<Uint8List> _buildFromRecord(
      AssessmentRecord r, {Uint8List? photoBytes}) async {
    final decColor =
    r.isGo ? _kGo : r.isCaution ? _kCaution : _kNoGo;
    final photo =
    photoBytes != null ? pw.MemoryImage(photoBytes) : null;
    return _compile(
      pilotName:    r.pilotName,
      flightId:     r.flightId,
      phase:        r.flightPhase.replaceAll('_', ' ').toUpperCase(),
      ts:           r.timestamp,
      totalRisk:    r.totalRiskScore,
      decision:     r.decisionLabel,
      imsafeTotal:  r.imsafe.total,
      paveTotal:    r.pave.total,
      arousal:      r.arousalLevel,
      imsafeLabels: ImsafeScores.fullLabels,
      imsafeVals:   r.imsafe.asList,
      paveLabels:   PaveScores.fullLabels,
      paveVals:     r.pave.asList,
      notes:        r.decideNotes,
      decColor:     decColor,
      photo:        photo,
    );
  }

  // ═══════════════════════════════════════════════════════════
  // BUILD FROM LEGACY
  // ═══════════════════════════════════════════════════════════
  Future<Uint8List> _buildFromLegacy({
    required List<ImsafeItem>  imsafe,
    required List<PaveItem>    pave,
    required List<DecideStep>  decide,
    required PilotScore        score,
    required List<HazardEntry> hazards,
    PilotInfo?                 pilotInfo,
    PilotEvalController? pilotEvalController,
  }) async {
    double rs(String r) =>
        r == 'HIGH' ? 100.0 : r == 'MEDIUM' ? 50.0 : 0.0;
    double pv(PaveItem item) {
      if (item.checkpoints.isEmpty) return 0;
      final done = item.checkpoints.where((c) => c.checked).length;
      return (1 - done / item.checkpoints.length) * 100;
    }

    final iv = List.generate(6, (i) =>
    i < imsafe.length ? rs(imsafe[i].rating) : 0.0);
    final pv2 = List.generate(4, (i) =>
    i < pave.length ? pv(pave[i]) : 0.0);

    final iAvg = iv.fold(0.0, (a, b) => a + b) / iv.length;
    final pAvg = pv2.fold(0.0, (a, b) => a + b) / pv2.length;
    final total = (iAvg * 0.5 + pAvg * 0.5).clamp(0.0, 100.0);

    final decColor = score.finalDecision == FlightDecision.go
        ? _kGo
        : score.finalDecision == FlightDecision.caution
        ? _kCaution
        : _kNoGo;
    final decLabel = score.finalDecision == FlightDecision.go
        ? 'GO'
        : score.finalDecision == FlightDecision.caution
        ? 'CAUTION'
        : 'NO-GO';

    final decideNotes = decide
        .where((s) => s.completed && s.userInput.trim().isNotEmpty)
        .map((s) => '${s.key}: ${s.userInput.trim()}')
        .join('\n');
    final hazardNotes = hazards.isNotEmpty
        ? hazards.map((h) => '• ${h.hazard}').join('\n')
        : '';
    final allNotes = [decideNotes, hazardNotes]
        .where((s) => s.isNotEmpty).join('\n\n');

    pw.ImageProvider? photo;
    if (pilotInfo?.photoBytes != null) {
      photo = pw.MemoryImage(pilotInfo!.photoBytes!);
    }

    return _compile(
      pilotName:    pilotInfo?.pilotName   ?? '',
      flightId:     pilotInfo?.flightNumber ?? '',
      phase:        'PRE FLIGHT',
      ts:           DateTime.now(),
      totalRisk:    total,
      decision:     decLabel,
      imsafeTotal:  iAvg,
      paveTotal:    pAvg,
      arousal:      5.0,
      imsafeLabels: ImsafeScores.fullLabels,
      imsafeVals:   iv,
      paveLabels:   PaveScores.fullLabels,
      paveVals:     pv2,
      notes:        allNotes,
      decColor:     decColor,
      photo:        photo,
      pilotEvalSections: pilotEvalController?.sections,
      pilotEvalPct: pilotEvalController?.overallPct,
    );
  }
  pw.Widget _pilotEvalTable(
      List<PilotEvalSection> sections, double overallPct) {
    final overallColor = overallPct >= 0.8 ? _kGo
        : overallPct >= 0.6 ? _kCaution
        : _kNoGo;

    return _card(pw.Column(children: [
      // Overall row
      pw.Row(children: [
        pw.Text('Overall Average',
            style: pw.TextStyle(font: _bold, fontSize: 10, color: _txtMid)),
        pw.Spacer(),
        pw.Text('${(overallPct * 100).toInt()}%',
            style: pw.TextStyle(
                font: _monoBold, fontSize: 14, color: overallColor)),
      ]),
      pw.SizedBox(height: 8),
      // per-section mini bars
      for (final sec in sections) ...[
        pw.Row(children: [
          pw.Container(width: 8, height: 8,
              decoration: pw.BoxDecoration(
                color: PdfColor(
                    sec.color.red / 255, sec.color.green / 255, sec.color.blue / 255),
                shape: pw.BoxShape.circle,
              )),
          pw.SizedBox(width: 6),
          pw.Expanded(child: pw.Text(sec.titleEn,
              style: pw.TextStyle(font: _base, fontSize: 9, color: _txtPrimary))),
          pw.Text(sec.ratedCount == 0
              ? '--'
              : '${(sec.averagePct * 100).toInt()}%',
              style: pw.TextStyle(font: _monoBold, fontSize: 9,
                  color: PdfColor(
                      sec.color.red / 255, sec.color.green / 255, sec.color.blue / 255))),
        ]),
        pw.SizedBox(height: 4),
        pw.Stack(children: [
          pw.Container(height: 6,
              decoration: pw.BoxDecoration(
                  color: _barTrack, borderRadius: pw.BorderRadius.circular(3))),
          pw.LayoutBuilder(builder: (ctx, cs) => pw.Container(
            height: 6,
            width: ((cs?.maxWidth ?? 200) * sec.averagePct).clamp(0.0, cs?.maxWidth ?? 200),
            decoration: pw.BoxDecoration(
                color: PdfColor(
                    sec.color.red / 255, sec.color.green / 255, sec.color.blue / 255),
                borderRadius: pw.BorderRadius.circular(3)),
          )),
        ]),
        pw.SizedBox(height: 8),
      ],
    ]));
  }


  // ═══════════════════════════════════════════════════════════
  // COMPILE PDF
  // ═══════════════════════════════════════════════════════════
  Future<Uint8List> _compile({
    required String pilotName, required String flightId,
    required String phase,     required DateTime ts,
    required double totalRisk, required String decision,
    required double imsafeTotal, required double paveTotal,
    required double arousal,
    required List<String> imsafeLabels, required List<double> imsafeVals,
    required List<String> paveLabels,   required List<double> paveVals,
    required String notes,
    required PdfColor decColor,
    List<PilotEvalSection>? pilotEvalSections,
    double? pilotEvalPct,
    pw.ImageProvider? photo,
  }) async {
    final doc = pw.Document(
        title: 'ADM Pilot Assessment Report', author: 'ADM PILOT');

    doc.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin:     pw.EdgeInsets.zero,
      theme:      pw.ThemeData.withFont(base: _base, bold: _bold),
      header:     (_) => _hdr(pilotName, flightId, ts, decColor, decision),
      footer:     (c) => _ftr(c, pilotName, flightId, ts),
      build: (_) => [
        pw.Padding(
          padding: const pw.EdgeInsets.fromLTRB(30, 18, 30, 14),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [

              // 1 — Pilot card
              _pilotCard(pilotName, flightId, phase,
                  ts, totalRisk, decColor, photo),
              pw.SizedBox(height: 14),

              // 2 — Decision banner
              _banner(decision, totalRisk,
                  imsafeTotal, paveTotal, decColor),
              pw.SizedBox(height: 16),
              if (pilotEvalSections != null && pilotEvalPct != null) ...[
                _sh('PILOT LEVEL ASSESSMENT', _kIcao),
                pw.SizedBox(height: 7),
                _pilotEvalTable(pilotEvalSections, pilotEvalPct),
                pw.SizedBox(height: 16),
              ],

              // 3 — Summary table
              _sh('ASSESSMENT SUMMARY', _kNavy),
              pw.SizedBox(height: 7),
              _summaryTable(pilotName, flightId, phase, ts,
                  totalRisk, decision, imsafeTotal, paveTotal, arousal),
              pw.SizedBox(height: 16),

              // 4 — IMSAFE
              _sh('IMSAFE BREAKDOWN', _kCaution),
              pw.SizedBox(height: 7),
              _bars(imsafeLabels, imsafeVals),
              pw.SizedBox(height: 16),

              // 5 — PAVE
              _sh('PAVE BREAKDOWN', _kIcao),
              pw.SizedBox(height: 7),
              _bars(paveLabels, paveVals),
              pw.SizedBox(height: 16),

              // 6 — DECIDE notes
              if (notes.trim().isNotEmpty) ...[
                _sh('DECIDE — PILOT NOTES', _kSlate),
                pw.SizedBox(height: 7),
                _notesCard(notes),
                pw.SizedBox(height: 16),
              ],

              // 7 — Arousal
              _sh('AROUSAL LEVEL  (Yerkes-Dodson)', _kSlate),
              pw.SizedBox(height: 7),
              _arousalCard(arousal),
              pw.SizedBox(height: 16),

              // 8 — ICAO disclaimer
              _icaoBlock(),
            ],
          ),
        ),
      ],
    ));

    return doc.save();
  }

  // ═══════════════════════════════════════════════════════════
  // PAGE HEADER
  // ═══════════════════════════════════════════════════════════
  pw.Widget _hdr(String pilotName, String flightId,
      DateTime ts, PdfColor dec, String decLabel) {
    return pw.Column(children: [
      // Top colour stripe
      pw.Container(height: 5, color: dec),
      // Navy band — white text, explicit
      pw.Container(
        color: _bandBg,
        padding: const pw.EdgeInsets.symmetric(
            horizontal: 30, vertical: 10),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('ADM PILOT ASSESSMENT REPORT',
                    style: pw.TextStyle(
                        font:          _monoBold,
                        fontSize:      13,
                        color:         _txtOnDark,   // WHITE — always visible
                        letterSpacing: 1.2)),
                pw.SizedBox(height: 2),
                pw.Text('IMSAFE  •  PAVE  •  DECIDE  —  FAASTeam ADM',
                    style: pw.TextStyle(
                        font:    _base,
                        fontSize: 8,
                        color:   const PdfColor(0.66, 0.76, 0.90))),
              ],
            ),
            pw.Spacer(),
            // Decision badge — white text on solid colour
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(
                  horizontal: 16, vertical: 7),
              decoration: pw.BoxDecoration(
                color:        dec,
                borderRadius: pw.BorderRadius.circular(5),
              ),
              child: pw.Text(decLabel,
                  style: pw.TextStyle(
                      font:          _monoBold,
                      fontSize:      13,
                      color:         PdfColors.white,   // always white
                      letterSpacing: 2)),
            ),
          ],
        ),
      ),
    ]);
  }

  // ═══════════════════════════════════════════════════════════
  // PAGE FOOTER
  // ═══════════════════════════════════════════════════════════
  pw.Widget _ftr(pw.Context ctx, String pilot,
      String fid, DateTime ts) {
    return pw.Column(children: [
      pw.Container(height: 0.5, color: _border),
      pw.Container(
        color: _rowAlt,
        padding: const pw.EdgeInsets.symmetric(
            horizontal: 30, vertical: 5),
        child: pw.Row(
          children: [
            pw.Text(
                '${pilot.isNotEmpty ? pilot : "—"}'
                    '${fid.isNotEmpty ? "  ·  $fid" : ""}',
                style: pw.TextStyle(
                    font: _base, fontSize: 7.5, color: _txtMuted)),
            pw.Spacer(),
            pw.Text(
                'Page ${ctx.pageNumber} / ${ctx.pagesCount}'
                    '  ·  ${DateFormat('dd MMM yyyy').format(ts)}',
                style: pw.TextStyle(
                    font: _mono, fontSize: 7.5, color: _txtMuted)),
          ],
        ),
      ),
    ]);
  }

  // ═══════════════════════════════════════════════════════════
  // PILOT CARD
  // ═══════════════════════════════════════════════════════════
  pw.Widget _pilotCard(
      String pilotName, String flightId, String phase,
      DateTime ts, double risk, PdfColor dec,
      pw.ImageProvider? photo,
      ) {
    final initial = pilotName.isNotEmpty
        ? pilotName.substring(0, 1).toUpperCase()
        : '?';

    return _card(pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        // ── Photo circle — DecorationImage is the only reliable
        //    way to clip images to circle in the pdf package.
        //    pw.ClipOval + pw.Image does NOT work reliably.
        pw.Container(
          width: 68, height: 68,
          decoration: pw.BoxDecoration(
            shape: pw.BoxShape.circle,
            color:  _kLightBlu,
            border: pw.Border.all(color: _kIcao, width: 2),
            // ← photo embedded directly in the decoration
            image: photo != null
                ? pw.DecorationImage(
                image: photo,
                fit:   pw.BoxFit.cover)
                : null,
          ),
          // Initial letter shown only when no photo
          child: photo == null
              ? pw.Center(child: pw.Text(initial,
              style: pw.TextStyle(
                  font: _monoBold, fontSize: 26,
                  color: _kIcao)))
              : null,
        ),
        pw.SizedBox(width: 16),

        // Info
        pw.Expanded(child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
                pilotName.isNotEmpty ? pilotName : 'Anonymous Pilot',
                style: pw.TextStyle(
                    font: _bold, fontSize: 16, color: _txtPrimary)),
            pw.SizedBox(height: 5),
            pw.Row(children: [
              if (flightId.isNotEmpty) ...[
                _pill(flightId, _kIcao),
                pw.SizedBox(width: 6),
              ],
              _pill(phase.isNotEmpty ? phase : 'PRE FLIGHT', _kSlate),
            ]),
            pw.SizedBox(height: 7),
            pw.Text(
                DateFormat('EEEE, dd MMMM yyyy  •  HH:mm').format(ts),
                style: pw.TextStyle(
                    font: _base, fontSize: 9, color: _txtMuted)),
          ],
        )),

        // Risk circle
        pw.Column(mainAxisAlignment: pw.MainAxisAlignment.center, children: [
          pw.Container(
            width: 62, height: 62,
            decoration: pw.BoxDecoration(
              shape:  pw.BoxShape.circle,
              color:  _pageBg,
              border: pw.Border.all(color: dec, width: 2.5),
            ),
            child: pw.Center(child: pw.Text(
                risk.toStringAsFixed(0),
                style: pw.TextStyle(
                    font: _monoBold, fontSize: 22, color: dec))),
          ),
          pw.SizedBox(height: 3),
          pw.Text('RISK',
              style: pw.TextStyle(
                  font: _mono, fontSize: 7, color: _txtMuted,
                  letterSpacing: 1.5)),
        ]),
      ],
    ));
  }

  // ═══════════════════════════════════════════════════════════
  // DECISION BANNER
  // ═══════════════════════════════════════════════════════════
  pw.Widget _banner(String decision, double total,
      double imsafe, double pave, PdfColor c) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        color:        _rowAlt,
        borderRadius: pw.BorderRadius.circular(7),
        border:       pw.Border.all(color: c, width: 2),
      ),
      padding: const pw.EdgeInsets.symmetric(
          horizontal: 18, vertical: 13),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            pw.Text('FLIGHT DECISION',
                style: pw.TextStyle(
                    font: _mono, fontSize: 8,
                    color: _txtMuted, letterSpacing: 2)),
            pw.SizedBox(height: 3),
            pw.Text(decision,
                style: pw.TextStyle(
                    font: _monoBold, fontSize: 28,
                    color: c, letterSpacing: 4)),
          ]),
          pw.Spacer(),
          pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.end, children: [
            _srow('TOTAL RISK',
                '${total.toStringAsFixed(1)} / 100', c),
            pw.SizedBox(height: 4),
            _srow('IMSAFE',
                '${imsafe.toStringAsFixed(1)} / 100', _kCaution),
            pw.SizedBox(height: 4),
            _srow('PAVE',
                '${pave.toStringAsFixed(1)} / 100', _kIcao),
          ]),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // SUMMARY TABLE
  // ═══════════════════════════════════════════════════════════
  pw.Widget _summaryTable(
      String pilotName, String flightId, String phase,
      DateTime ts, double total, String decision,
      double imsafe, double pave, double arousal) {
    final rows = [
      ['Pilot Name',    pilotName.isNotEmpty ? pilotName : '—'],
      ['Flight ID',     flightId.isNotEmpty  ? flightId  : '—'],
      ['Date / Time',
        DateFormat('dd MMM yyyy  •  HH:mm').format(ts)],
      ['Flight Phase',  phase],
      ['Total Risk',    '${total.toStringAsFixed(1)} / 100'],
      ['Decision',      decision],
      ['IMSAFE Score',  '${imsafe.toStringAsFixed(1)} / 100'],
      ['PAVE Score',    '${pave.toStringAsFixed(1)} / 100'],
      ['Arousal Level', '${arousal.toStringAsFixed(1)} / 10'],
    ];
    return pw.Table(
      border: pw.TableBorder.all(color: _border, width: 0.6),
      columnWidths: {
        0: const pw.FixedColumnWidth(112),
        1: const pw.FlexColumnWidth(),
      },
      children: rows.asMap().entries.map((e) => pw.TableRow(
        decoration: pw.BoxDecoration(
            color: e.key.isEven ? _rowAlt : _cardBg),
        children: [
          _tc(e.value[0], _bold,  _txtMid,     9),
          _tc(e.value[1], _base, _txtPrimary, 9),
        ],
      )).toList(),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // BREAKDOWN BARS
  // ═══════════════════════════════════════════════════════════
  pw.Widget _bars(List<String> labels, List<double> vals) {
    return _card(pw.Column(
      children: vals.asMap().entries.map((e) {
        final pct   = (e.value / 100).clamp(0.0, 1.0);
        final color = e.value >= 75 ? _kNoGo
            : e.value >= 40 ? _kCaution : _kGo;
        final isLast = e.key == vals.length - 1;
        return pw.Column(children: [
          pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.center, children: [
            pw.SizedBox(width: 102,
                child: pw.Text(labels[e.key],
                    style: pw.TextStyle(
                        font: _base, fontSize: 9.5,
                        color: _txtPrimary))),
            pw.Expanded(child: pw.Stack(children: [
              // track
              pw.Container(
                height: 10,
                decoration: pw.BoxDecoration(
                  color: _barTrack,
                  borderRadius: pw.BorderRadius.circular(5),
                ),
              ),
              // fill
              pw.LayoutBuilder(builder: (ctx, cs) => pw.Container(
                height: 10,
                width: ((cs?.maxWidth ?? 200) * pct)
                    .clamp(0.0, cs?.maxWidth ?? 200),
                decoration: pw.BoxDecoration(
                  color: color,
                  borderRadius: pw.BorderRadius.circular(5),
                ),
              )),
            ])),
            pw.SizedBox(width: 10),
            pw.SizedBox(width: 40,
                child: pw.Text(
                    '${e.value.toStringAsFixed(0)}%',
                    textAlign: pw.TextAlign.right,
                    style: pw.TextStyle(
                        font: _monoBold, fontSize: 9.5,
                        color: color))),
          ]),
          if (!isLast) ...[
            pw.SizedBox(height: 9),
            pw.Container(height: 0.5, color: _border),
            pw.SizedBox(height: 9),
          ],
        ]);
      }).toList(),
    ));
  }

  // ═══════════════════════════════════════════════════════════
  // DECIDE NOTES
  // ═══════════════════════════════════════════════════════════
  pw.Widget _notesCard(String notes) {
    final lines = notes.split('\n')
        .where((l) => l.trim().isNotEmpty).toList();
    return _card(pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: lines.map((line) {
        final parts  = line.split(':');
        final hasKey = parts.length > 1 && parts[0].trim().length <= 2;
        final key    = hasKey ? parts[0].trim() : '';
        final text   = hasKey
            ? parts.sublist(1).join(':').trim()
            : line.trim();
        final display = text.isNotEmpty ? text : '—';

        return pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 9),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              if (key.isNotEmpty) ...[
                pw.Container(
                  width: 20, height: 20,
                  decoration: pw.BoxDecoration(
                    shape: pw.BoxShape.circle,
                    color: _kLightBlu,
                    border: pw.Border.all(color: _kIcao, width: 0.8),
                  ),
                  child: pw.Center(child: pw.Text(key,
                      style: pw.TextStyle(
                          font: _monoBold, fontSize: 8,
                          color: _kIcao))),
                ),
                pw.SizedBox(width: 9),
              ] else ...[
                pw.Container(
                  width: 3, height: 20, color: _kSlate,
                ),
                pw.SizedBox(width: 9),
              ],
              pw.Expanded(child: pw.Text(display,
                  style: pw.TextStyle(
                      font: _base, fontSize: 9.5,
                      color: _txtPrimary, lineSpacing: 2))),
            ],
          ),
        );
      }).toList(),
    ));
  }

  // ═══════════════════════════════════════════════════════════
  // AROUSAL CARD
  // ═══════════════════════════════════════════════════════════
  pw.Widget _arousalCard(double level) {
    final pct   = (level / 10).clamp(0.0, 1.0);
    final color = level < 3 ? _kIcao : level <= 7 ? _kGo : _kNoGo;
    final zone  = level < 3 ? 'LOW — Under-stimulated'
        : level <= 7 ? 'OPTIMAL — Peak performance zone'
        : 'HIGH — Over-arousal / stress';

    return _card(pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(children: [
          pw.Text('LOW',     style: pw.TextStyle(font: _mono, fontSize: 8, color: _kIcao)),
          pw.Spacer(),
          pw.Text('OPTIMAL', style: pw.TextStyle(font: _mono, fontSize: 8, color: _kGo)),
          pw.Spacer(),
          pw.Text('HIGH',    style: pw.TextStyle(font: _mono, fontSize: 8, color: _kNoGo)),
        ]),
        pw.SizedBox(height: 5),
        pw.Stack(children: [
          pw.Container(height: 14,
              decoration: pw.BoxDecoration(
                color: _barTrack,
                borderRadius: pw.BorderRadius.circular(7),
              )),
          pw.LayoutBuilder(builder: (ctx, cs) => pw.Container(
            height: 14,
            width: ((cs?.maxWidth ?? 300) * pct)
                .clamp(0.0, cs?.maxWidth ?? 300),
            decoration: pw.BoxDecoration(
              color: color,
              borderRadius: pw.BorderRadius.circular(7),
            ),
          )),
        ]),
        pw.SizedBox(height: 9),
        pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
          pw.Text(zone,
              style: pw.TextStyle(
                  font: _bold, fontSize: 9.5, color: color)),
          pw.Text('${level.toStringAsFixed(1)} / 10',
              style: pw.TextStyle(
                  font: _monoBold, fontSize: 14, color: color)),
        ]),
        pw.SizedBox(height: 7),
        pw.Container(height: 0.5, color: _border),
        pw.SizedBox(height: 7),
        pw.Text(
            'Yerkes-Dodson Law: Cognitive performance peaks at moderate '
                'arousal. Both under- and over-stimulation degrade '
                'decision-making quality.',
            style: pw.TextStyle(
                font: _italic, fontSize: 8, color: _txtMuted,
                lineSpacing: 1.5)),
      ],
    ));
  }

  // ═══════════════════════════════════════════════════════════
  // ICAO DISCLAIMER BLOCK
  // ═══════════════════════════════════════════════════════════
  pw.Widget _icaoBlock() {
    return pw.Container(
      decoration: pw.BoxDecoration(
        color: const PdfColor(0.94, 0.97, 1.00),
        borderRadius: pw.BorderRadius.circular(7),
        border: pw.Border.all(color: _kIcao, width: 1.2),
      ),
      padding: const pw.EdgeInsets.all(14),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // ICAO header row
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              // ICAO badge
              pw.Container(
                width: 52, height: 28,
                decoration: pw.BoxDecoration(
                  color: _kIcao,
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Center(child: pw.Text('ICAO',
                    style: pw.TextStyle(
                        font: _monoBold, fontSize: 14,
                        color: PdfColors.white, letterSpacing: 2))),
              ),
              pw.SizedBox(width: 10),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('International Civil Aviation Organization',
                      style: pw.TextStyle(
                          font: _bold, fontSize: 8.5, color: _kIcao)),
                  pw.Text('Doc 9835 — Human Factors in Aviation Medicine',
                      style: pw.TextStyle(
                          font: _base, fontSize: 7.5, color: _txtMuted)),
                ],
              ),
              pw.Spacer(),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text('ADM PILOT SYSTEM  v2.0',
                      style: pw.TextStyle(
                          font: _mono, fontSize: 7.5, color: _txtMuted)),
                  pw.Text('FAASTeam ADM Framework',
                      style: pw.TextStyle(
                          font: _base, fontSize: 7.5, color: _txtMuted)),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 10),
          pw.Container(height: 0.5, color: _kIcao),
          pw.SizedBox(height: 10),

          // Disclaimer
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Container(
                  width: 3, height: 52, color: _kCaution),
              pw.SizedBox(width: 10),
              pw.Expanded(child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('MEDICAL DISCLAIMER',
                      style: pw.TextStyle(
                          font: _monoBold, fontSize: 8.5,
                          color: _kCaution, letterSpacing: 1.2)),
                  pw.SizedBox(height: 4),
                  pw.Text(
                      'This report is a decision-support tool ONLY and does NOT '
                          'replace a professional Aviation Medical Examination (AME). '
                          'Pilots must comply with all FAA / EASA / ICAO applicable '
                          'regulations. When in doubt — consult a certified Aviation '
                          'Medical Examiner before flight.',
                      style: pw.TextStyle(
                          font: _italic, fontSize: 8.5,
                          color: _txtMid, lineSpacing: 2.5)),
                ],
              )),
            ],
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // TINY HELPERS
  // ═══════════════════════════════════════════════════════════

  /// White card with border
  pw.Widget _card(pw.Widget child, {pw.EdgeInsets? pad}) =>
      pw.Container(
        decoration: pw.BoxDecoration(
          color: _cardBg,
          borderRadius: pw.BorderRadius.circular(7),
          border: pw.Border.all(color: _border, width: 0.7),
        ),
        padding: pad ?? const pw.EdgeInsets.all(14),
        child: child,
      );

  /// Section header: left bar + mono title + divider
  pw.Widget _sh(String title, PdfColor accent) =>
      pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.center, children: [
        pw.Container(width: 4, height: 15,
            decoration: pw.BoxDecoration(
                color: accent, borderRadius: pw.BorderRadius.circular(2))),
        pw.SizedBox(width: 8),
        pw.Text(title, style: pw.TextStyle(
            font: _monoBold, fontSize: 10,
            color: accent, letterSpacing: 1.5)),
        pw.SizedBox(width: 12),
        pw.Expanded(child: pw.Container(height: 0.6, color: _border)),
      ]);

  /// Pill chip
  pw.Widget _pill(String text, PdfColor color) => pw.Container(
    padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: pw.BoxDecoration(
      color:        _kLightBlu,
      borderRadius: pw.BorderRadius.circular(4),
      border:       pw.Border.all(color: color, width: 0.8),
    ),
    child: pw.Text(text, style: pw.TextStyle(
        font: _mono, fontSize: 7.5, color: color)),
  );

  /// Score label row in banner
  pw.Widget _srow(String label, String value, PdfColor color) =>
      pw.Row(children: [
        pw.Text('$label: ',
            style: pw.TextStyle(
                font: _mono, fontSize: 8, color: _txtMuted)),
        pw.Text(value, style: pw.TextStyle(
            font: _monoBold, fontSize: 9, color: color)),
      ]);

  /// Table cell helper
  pw.Widget _tc(String t, pw.Font f, PdfColor c, double sz) =>
      pw.Padding(
        padding: const pw.EdgeInsets.symmetric(
            horizontal: 10, vertical: 8),
        child: pw.Text(t,
            style: pw.TextStyle(font: f, fontSize: sz, color: c)),
      );
}