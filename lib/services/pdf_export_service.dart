// lib/features/export/pdf_export_service.dart
// ══════════════════════════════════════════════════════════════
// Professional Light-Theme PDF — ADM Pilot Assessment Report
// Clean white layout + pilot photo + accent bars + full breakdown
// ══════════════════════════════════════════════════════════════

import 'dart:typed_data';
import 'package:flutter/material.dart' show BuildContext;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../core/storage/assessment_record.dart';

// ═══════════════════════════════════════════════════════════════
// LIGHT PALETTE
// ═══════════════════════════════════════════════════════════════
const _white      = PdfColors.white;
const _pageGrey   = PdfColor.fromInt(0xFFF5F7FA);   // page bg
const _cardGrey   = PdfColor.fromInt(0xFFFFFFFF);   // card bg
const _borderClr  = PdfColor.fromInt(0xFFDDE3EC);   // borders
const _headBg     = PdfColor.fromInt(0xFF1A2B4A);   // header band
const _headText   = PdfColors.white;
const _txtPrimary = PdfColor.fromInt(0xFF1A2035);
const _txtMid     = PdfColor.fromInt(0xFF4A5568);
const _txtMuted   = PdfColor.fromInt(0xFF8A99B0);

// Semantic
const _go         = PdfColor.fromInt(0xFF00A650);
const _caution    = PdfColor.fromInt(0xFFE68900);
const _noGo       = PdfColor.fromInt(0xFFCC1F1F);
const _cyan       = PdfColor.fromInt(0xFF0091B5);
const _purple     = PdfColor.fromInt(0xFF6B3FA0);

// ═══════════════════════════════════════════════════════════════
class PdfExportService {
  PdfExportService._();
  static final PdfExportService instance = PdfExportService._();

  // ── Fonts ─────────────────────────────────────────────────
  late pw.Font _base;
  late pw.Font _bold;
  late pw.Font _mono;

  Future<void> _loadFonts() async {
    _base = await PdfGoogleFonts.robotoRegular();
    _bold = await PdfGoogleFonts.robotoBold();
    _mono = await PdfGoogleFonts.robotoMonoRegular();
  }

  // ── Entry points ──────────────────────────────────────────
  Future<void> exportAndShare(
      BuildContext context, AssessmentRecord r,
      {Uint8List? photoBytes}) async {
    await _loadFonts();
    final bytes = await _buildPdf(r, photoBytes: photoBytes);
    await Printing.sharePdf(
      bytes: bytes,
      filename: 'ADM_${r.flightId.isNotEmpty ? r.flightId : r.id.substring(0, 8)}'
          '_${DateFormat('yyyyMMdd_HHmm').format(r.timestamp)}.pdf',
    );
  }

  Future<void> preview(
      BuildContext context, AssessmentRecord r,
      {Uint8List? photoBytes}) async {
    await _loadFonts();
    await Printing.layoutPdf(
        onLayout: (_) async => _buildPdf(r, photoBytes: photoBytes));
  }

  // ═══════════════════════════════════════════════════════════
  // BUILD DOCUMENT
  // ═══════════════════════════════════════════════════════════
  Future<Uint8List> _buildPdf(AssessmentRecord r,
      {Uint8List? photoBytes}) async {
    final doc      = pw.Document(title: 'ADM Pilot Assessment Report');
    final decColor = r.isGo ? _go : r.isCaution ? _caution : _noGo;
    final photo    = photoBytes != null ? pw.MemoryImage(photoBytes) : null;
    final dateStr  = DateFormat('EEEE, dd MMMM yyyy  •  HH:mm')
        .format(r.timestamp);

    doc.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin:     pw.EdgeInsets.zero,
      theme:      pw.ThemeData.withFont(base: _base, bold: _bold),
      header:     (_) => _pageHeader(r, decColor),
      footer:     (ctx) => _pageFooter(ctx, r),
      build: (_) => [
        // ── Content padding wrapper ──────────────────────────
        pw.Padding(
          padding: const pw.EdgeInsets.fromLTRB(28, 20, 28, 8),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [

              // 1. Pilot identity card
              _pilotCard(r, photo, decColor),
              pw.SizedBox(height: 18),

              // 2. Decision banner
              _decisionBanner(r, decColor),
              pw.SizedBox(height: 18),

              // 3. Assessment summary table
              _sectionTitle('ASSESSMENT SUMMARY', _cyan),
              pw.SizedBox(height: 8),
              _summaryTable(r),
              pw.SizedBox(height: 18),

              // 4. IMSAFE breakdown
              _sectionTitle('IMSAFE BREAKDOWN', _caution),
              pw.SizedBox(height: 8),
              _breakdownTable(
                  ImsafeScores.fullLabels, r.imsafe.asList),
              pw.SizedBox(height: 18),

              // 5. PAVE breakdown
              _sectionTitle('PAVE BREAKDOWN', _cyan),
              pw.SizedBox(height: 8),
              _breakdownTable(
                  PaveScores.fullLabels, r.pave.asList),
              pw.SizedBox(height: 18),

              // 6. DECIDE notes (if any)
              if (r.decideNotes.isNotEmpty) ...[
                _sectionTitle('DECIDE — PILOT NOTES', _purple),
                pw.SizedBox(height: 8),
                _notesBox(r.decideNotes),
                pw.SizedBox(height: 18),
              ],

              // 7. Arousal
              _sectionTitle('AROUSAL LEVEL', _txtMid),
              pw.SizedBox(height: 8),
              _arousalSection(r.arousalLevel),
              pw.SizedBox(height: 18),

              // 8. Disclaimer
              _disclaimer(),
              pw.SizedBox(height: 8),
            ],
          ),
        ),
      ],
    ));

    return doc.save();
  }

  // ═══════════════════════════════════════════════════════════
  // PAGE HEADER  (repeats on every page)
  // ═══════════════════════════════════════════════════════════
  pw.Widget _pageHeader(AssessmentRecord r, PdfColor decColor) =>
      pw.Column(children: [
        // Top color bar
        pw.Container(height: 4, color: decColor),
        // Header band
        pw.Container(
          color: _headBg,
          padding: const pw.EdgeInsets.symmetric(
              horizontal: 28, vertical: 10),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('ADM PILOT ASSESSMENT REPORT',
                      style: pw.TextStyle(
                          font: _bold,
                          fontSize: 13,
                          color: _headText,
                          letterSpacing: 1)),
                  pw.SizedBox(height: 2),
                  pw.Text(
                      'IMSAFE  •  PAVE  •  DECIDE  —  FAASTeam ADM',
                      style: pw.TextStyle(
                          font: _base,
                          fontSize: 8,
                          color: const PdfColor(0.6, 0.7, 0.85))),
                ],
              ),
              // Decision badge
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(
                    horizontal: 14, vertical: 6),
                decoration: pw.BoxDecoration(
                  color: _alpha(decColor, 0.15),
                  borderRadius: pw.BorderRadius.circular(6),
                  border: pw.Border.all(color: decColor, width: 1.5),
                ),
                child: pw.Text(r.decisionLabel,
                    style: pw.TextStyle(
                        font: _bold,
                        fontSize: 13,
                        color: decColor,
                        letterSpacing: 2)),
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 0),
      ]);

  // ═══════════════════════════════════════════════════════════
  // PAGE FOOTER
  // ═══════════════════════════════════════════════════════════
  pw.Widget _pageFooter(pw.Context ctx, AssessmentRecord r) =>
      pw.Column(children: [
        pw.Container(height: 0.5, color: _borderClr),
        pw.Container(
          color: _pageGrey,
          padding: const pw.EdgeInsets.symmetric(
              horizontal: 28, vertical: 6),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                '${r.pilotName.isNotEmpty ? r.pilotName : "Pilot"}'
                    '${r.flightId.isNotEmpty ? "  ·  ${r.flightId}" : ""}',
                style: pw.TextStyle(
                    font: _base,
                    fontSize: 7.5,
                    color: _txtMuted),
              ),
              pw.Text(
                'Page ${ctx.pageNumber} / ${ctx.pagesCount}  ·  '
                    '${DateFormat('dd MMM yyyy').format(r.timestamp)}',
                style: pw.TextStyle(
                    font: _mono,
                    fontSize: 7.5,
                    color: _txtMuted),
              ),
            ],
          ),
        ),
      ]);

  // ═══════════════════════════════════════════════════════════
  // PILOT CARD  (with optional photo)
  // ═══════════════════════════════════════════════════════════
  pw.Widget _pilotCard(
      AssessmentRecord r, pw.ImageProvider? photo, PdfColor decColor) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        color: _cardGrey,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: _borderClr, width: 0.8),
      ),
      padding: const pw.EdgeInsets.all(14),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [

          // Photo or initials circle
          pw.Container(
            width: 60, height: 60,
            decoration: pw.BoxDecoration(
              shape: pw.BoxShape.circle,
              color: _alpha(_cyan, 0.12),
              border: pw.Border.all(color: _alpha(_cyan, 0.4), width: 1.5),
            ),
            child: pw.ClipOval(
              child: photo != null
                  ? pw.Image(photo, fit: pw.BoxFit.cover)
                  : pw.Center(
                      child: pw.Text(
                        r.pilotName.isNotEmpty
                            ? r.pilotName.substring(0, 1).toUpperCase()
                            : '✈',
                        style: pw.TextStyle(
                            font: _bold,
                            fontSize: 22,
                            color: _cyan),
                      ),
                    ),
            ),
          ),

          pw.SizedBox(width: 16),

          // Pilot info
          pw.Expanded(child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                r.pilotName.isNotEmpty ? r.pilotName : 'Anonymous Pilot',
                style: pw.TextStyle(
                    font: _bold, fontSize: 16, color: _txtPrimary),
              ),
              pw.SizedBox(height: 3),
              pw.Row(children: [
                if (r.flightId.isNotEmpty) ...[
                  _chip(r.flightId, _cyan),
                  pw.SizedBox(width: 6),
                ],
                _chip(
                  r.flightPhase.replaceAll('_', ' ').toUpperCase(),
                  _txtMid,
                ),
              ]),
              pw.SizedBox(height: 6),
              pw.Text(
                DateFormat('EEEE, dd MMMM yyyy  •  HH:mm')
                    .format(r.timestamp),
                style: pw.TextStyle(
                    font: _base, fontSize: 9, color: _txtMuted),
              ),
            ],
          )),

          // Score circle
          pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            children: [
              pw.Container(
                width: 56, height: 56,
                decoration: pw.BoxDecoration(
                  shape: pw.BoxShape.circle,
                  color: _alpha(decColor, 0.08),
                  border: pw.Border.all(color: decColor, width: 2),
                ),
                child: pw.Center(child: pw.Text(
                  r.totalRiskScore.toStringAsFixed(0),
                  style: pw.TextStyle(
                      font: _bold,
                      fontSize: 20,
                      color: decColor),
                )),
              ),
              pw.SizedBox(height: 4),
              pw.Text('RISK',
                  style: pw.TextStyle(
                      font: _mono,
                      fontSize: 7,
                      color: _txtMuted,
                      letterSpacing: 1.5)),
            ],
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // DECISION BANNER
  // ═══════════════════════════════════════════════════════════
  pw.Widget _decisionBanner(AssessmentRecord r, PdfColor decColor) =>
      pw.Container(
        decoration: pw.BoxDecoration(
          color: _alpha(decColor, 0.06),
          borderRadius: pw.BorderRadius.circular(8),
          border: pw.Border.all(color: decColor, width: 1.5),
        ),
        padding: const pw.EdgeInsets.symmetric(
            horizontal: 18, vertical: 12),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('FLIGHT DECISION',
                    style: pw.TextStyle(
                        font: _mono,
                        fontSize: 8,
                        color: _txtMuted,
                        letterSpacing: 2)),
                pw.SizedBox(height: 4),
                pw.Text(r.decisionLabel,
                    style: pw.TextStyle(
                        font: _bold,
                        fontSize: 26,
                        color: decColor,
                        letterSpacing: 3)),
              ],
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                _scoreChip('TOTAL RISK',
                    '${r.totalRiskScore.toStringAsFixed(1)} / 100',
                    decColor),
                pw.SizedBox(height: 5),
                _scoreChip('IMSAFE',
                    '${r.imsafe.total.toStringAsFixed(1)} / 100',
                    _caution),
                pw.SizedBox(height: 5),
                _scoreChip('PAVE',
                    '${r.pave.total.toStringAsFixed(1)} / 100',
                    _cyan),
              ],
            ),
          ],
        ),
      );

  // ═══════════════════════════════════════════════════════════
  // SUMMARY TABLE
  // ═══════════════════════════════════════════════════════════
  pw.Widget _summaryTable(AssessmentRecord r) {
    final rows = [
      ['Pilot Name',    r.pilotName.isNotEmpty ? r.pilotName : '—'],
      ['Flight ID',     r.flightId.isNotEmpty  ? r.flightId  : '—'],
      ['Date / Time',   DateFormat('dd MMM yyyy  •  HH:mm').format(r.timestamp)],
      ['Flight Phase',  r.flightPhase.replaceAll('_', ' ').toUpperCase()],
      ['Total Risk',    '${r.totalRiskScore.toStringAsFixed(1)} / 100'],
      ['Decision',      r.decisionLabel],
      ['IMSAFE Score',  '${r.imsafe.total.toStringAsFixed(1)} / 100'],
      ['PAVE Score',    '${r.pave.total.toStringAsFixed(1)} / 100'],
      ['Arousal Level', '${r.arousalLevel.toStringAsFixed(1)} / 10'],
    ];

    return pw.Table(
      border: pw.TableBorder.all(color: _borderClr, width: 0.5),
      columnWidths: {
        0: const pw.FixedColumnWidth(110),
        1: const pw.FlexColumnWidth(),
      },
      children: rows.asMap().entries.map((entry) {
        final isEven = entry.key.isEven;
        return pw.TableRow(
          decoration: pw.BoxDecoration(
            color: isEven ? _pageGrey : _cardGrey,
          ),
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(
                  horizontal: 10, vertical: 7),
              child: pw.Text(entry.value[0],
                  style: pw.TextStyle(
                      font: _bold, fontSize: 8.5, color: _txtMid)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(
                  horizontal: 10, vertical: 7),
              child: pw.Text(entry.value[1],
                  style: pw.TextStyle(
                      font: _base, fontSize: 8.5, color: _txtPrimary)),
            ),
          ],
        );
      }).toList(),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // BREAKDOWN TABLE  (IMSAFE / PAVE with progress bars)
  // ═══════════════════════════════════════════════════════════
  pw.Widget _breakdownTable(
      List<String> labels, List<double> values) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        color: _cardGrey,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: _borderClr, width: 0.8),
      ),
      padding: const pw.EdgeInsets.all(14),
      child: pw.Column(
        children: values.asMap().entries.map((e) {
          final pct   = (e.value.clamp(0.0, 100.0)) / 100.0;
          final color = e.value >= 75 ? _noGo
                      : e.value >= 40 ? _caution
                      : _go;
          final isLast = e.key == values.length - 1;

          return pw.Column(children: [
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                // Label
                pw.SizedBox(
                  width: 90,
                  child: pw.Text(labels[e.key],
                      style: pw.TextStyle(
                          font: _base,
                          fontSize: 9,
                          color: _txtMid)),
                ),
                // Bar background
                pw.Expanded(child: pw.Stack(children: [
                  pw.Container(
                    height: 8,
                    decoration: pw.BoxDecoration(
                      color: const PdfColor(0.9, 0.92, 0.95),
                      borderRadius: pw.BorderRadius.circular(4),
                    ),
                  ),
                  pw.LayoutBuilder(
                    builder: (ctx, constraints) => pw.Container(
                      height: 8,
                      width: (constraints!.maxWidth * pct)
                          .clamp(0.0, constraints.maxWidth),
                      decoration: pw.BoxDecoration(
                        color: color,
                        borderRadius: pw.BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ])),
                // Percentage
                pw.SizedBox(width: 8),
                pw.SizedBox(
                  width: 36,
                  child: pw.Text(
                    '${e.value.toStringAsFixed(0)}%',
                    style: pw.TextStyle(
                        font: _bold,
                        fontSize: 9,
                        color: color),
                    textAlign: pw.TextAlign.right,
                  ),
                ),
              ],
            ),
            if (!isLast) ...[
              pw.SizedBox(height: 8),
              pw.Container(height: 0.5, color: _borderClr),
              pw.SizedBox(height: 8),
            ],
          ]);
        }).toList(),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // DECIDE NOTES BOX
  // ═══════════════════════════════════════════════════════════
  pw.Widget _notesBox(String notes) => pw.Container(
    padding: const pw.EdgeInsets.all(14),
    decoration: pw.BoxDecoration(
      color: _alpha(_purple, 0.04),
      borderRadius: pw.BorderRadius.circular(8),
      border: pw.Border.all(color: _alpha(_purple, 0.25), width: 0.8),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: notes.split('\n').where((l) => l.trim().isNotEmpty).map((line) {
        final parts  = line.split(':');
        final letter = parts.length > 1 ? parts[0].trim() : '';
        final text   = parts.length > 1
            ? parts.sublist(1).join(':').trim()
            : line.trim();
        return pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 6),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              if (letter.isNotEmpty) ...[
                pw.Container(
                  width: 20, height: 20,
                  decoration: pw.BoxDecoration(
                    shape: pw.BoxShape.circle,
                    color: _alpha(_purple, 0.12),
                    border: pw.Border.all(
                        color: _alpha(_purple, 0.4), width: 0.8),
                  ),
                  child: pw.Center(child: pw.Text(letter,
                      style: pw.TextStyle(
                          font: _bold, fontSize: 8, color: _purple))),
                ),
                pw.SizedBox(width: 8),
              ],
              pw.Expanded(child: pw.Text(text,
                  style: pw.TextStyle(
                      font: _base,
                      fontSize: 9,
                      color: _txtPrimary,
                      lineSpacing: 2))),
            ],
          ),
        );
      }).toList(),
    ),
  );

  // ═══════════════════════════════════════════════════════════
  // AROUSAL SECTION
  // ═══════════════════════════════════════════════════════════
  pw.Widget _arousalSection(double level) {
    final pct   = (level / 10).clamp(0.0, 1.0);
    final color = level < 3 ? _cyan : level <= 7 ? _go : _noGo;
    final zone  = level < 3 ? 'LOW — Under-stimulated'
                : level <= 7 ? 'OPTIMAL — Peak performance zone'
                : 'HIGH — Over-arousal / stress';

    return pw.Container(
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        color: _cardGrey,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: _borderClr, width: 0.8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Zone labels row
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('LOW', style: pw.TextStyle(
                  font: _mono, fontSize: 8, color: _cyan)),
              pw.Text('OPTIMAL', style: pw.TextStyle(
                  font: _mono, fontSize: 8, color: _go)),
              pw.Text('HIGH', style: pw.TextStyle(
                  font: _mono, fontSize: 8, color: _noGo)),
            ],
          ),
          pw.SizedBox(height: 5),
          // Bar
          pw.Stack(children: [
            pw.Container(
              height: 12,
              decoration: pw.BoxDecoration(
                color: const PdfColor(0.9, 0.92, 0.95),
                borderRadius: pw.BorderRadius.circular(6),
              ),
            ),
            pw.LayoutBuilder(
              builder: (ctx, c) => pw.Container(
                height: 12,
                width: (c!.maxWidth * pct).clamp(0, c.maxWidth),
                decoration: pw.BoxDecoration(
                  color: color,
                  borderRadius: pw.BorderRadius.circular(6),
                ),
              ),
            ),
            // Optimal zone markers (dashed lines at 30% and 70%)
            pw.LayoutBuilder(builder: (ctx, c) => pw.Row(children: [
              pw.SizedBox(width: c!.maxWidth * 0.30),
              pw.Container(width: 0.8, height: 12,
                  color: const PdfColor(0.6, 0.6, 0.6, 0.5)),
              pw.SizedBox(width: c.maxWidth * 0.40 - 0.8),
              pw.Container(width: 0.8, height: 12,
                  color: const PdfColor(0.6, 0.6, 0.6, 0.5)),
            ])),
          ]),
          pw.SizedBox(height: 8),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(zone,
                  style: pw.TextStyle(
                      font: _base, fontSize: 9, color: color)),
              pw.Text('${level.toStringAsFixed(1)} / 10',
                  style: pw.TextStyle(
                      font: _bold, fontSize: 12, color: color)),
            ],
          ),
          pw.SizedBox(height: 6),
          pw.Text('Yerkes-Dodson Law: Performance peaks at moderate arousal.',
              style: pw.TextStyle(
                  font: _base, fontSize: 7.5, color: _txtMuted,
                  fontStyle: pw.FontStyle.italic)),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // DISCLAIMER
  // ═══════════════════════════════════════════════════════════
  pw.Widget _disclaimer() => pw.Container(
    padding: const pw.EdgeInsets.all(12),
    decoration: pw.BoxDecoration(
      color: _alpha(_caution, 0.05),
      borderRadius: pw.BorderRadius.circular(6),
      border: pw.Border.all(
          color: _alpha(_caution, 0.35), width: 0.8),
    ),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Warning icon replacement
        pw.Container(
          width: 3, height: 40,
          decoration: pw.BoxDecoration(
            color: _caution,
            borderRadius: pw.BorderRadius.circular(2),
          ),
        ),
        pw.SizedBox(width: 10),
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('MEDICAL DISCLAIMER',
                  style: pw.TextStyle(
                      font: _bold,
                      fontSize: 8.5,
                      color: _caution,
                      letterSpacing: 1)),
              pw.SizedBox(height: 4),
              pw.Text(
                'This report is a decision-support tool ONLY and does not replace a '
                    'professional Aviation Medical Examination (AME). Pilots must comply '
                    'with all FAA / EASA / ICAO applicable regulations. '
                    'When in doubt — consult a certified Aviation Medical Examiner '
                    'before flight.',
                style: pw.TextStyle(
                    font: _base,
                    fontSize: 8,
                    color: _txtMid,
                    height: 1.5,
                    fontStyle: pw.FontStyle.italic),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  // ═══════════════════════════════════════════════════════════
  // SHARED HELPERS
  // ═══════════════════════════════════════════════════════════

  /// Section header with left accent bar + full-width rule
  pw.Widget _sectionTitle(String title, PdfColor accent) =>
      pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.center, children: [
        pw.Container(
          width: 3, height: 14,
          decoration: pw.BoxDecoration(
            color: accent,
            borderRadius: pw.BorderRadius.circular(2),
          ),
        ),
        pw.SizedBox(width: 8),
        pw.Text(title,
            style: pw.TextStyle(
                font: _bold,
                fontSize: 10,
                color: accent,
                letterSpacing: 1.5)),
        pw.SizedBox(width: 12),
        pw.Expanded(child: pw.Container(
            height: 0.5, color: _borderClr)),
      ]);

  /// Small pill chip
  pw.Widget _chip(String text, PdfColor color) => pw.Container(
    padding: const pw.EdgeInsets.symmetric(horizontal: 7, vertical: 3),
    decoration: pw.BoxDecoration(
      color: _alpha(color, 0.10),
      borderRadius: pw.BorderRadius.circular(4),
      border: pw.Border.all(color: _alpha(color, 0.3), width: 0.6),
    ),
    child: pw.Text(text,
        style: pw.TextStyle(
            font: _mono, fontSize: 7.5, color: color,
            letterSpacing: 0.8)),
  );

  /// Score chip (label + value pair)
  pw.Widget _scoreChip(
      String label, String value, PdfColor color) =>
      pw.Row(children: [
        pw.Text('$label: ',
            style: pw.TextStyle(
                font: _mono, fontSize: 8, color: _txtMuted)),
        pw.Text(value,
            style: pw.TextStyle(
                font: _bold, fontSize: 8.5, color: color)),
      ]);

  // Alpha helper
  static PdfColor _alpha(PdfColor c, double a) =>
      PdfColor(c.red, c.green, c.blue, a);
}
