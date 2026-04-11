// lib/features/export/medical_pdf_section.dart
// ══════════════════════════════════════════════════════════════
// Medical PDF section — call buildMedicalPdfSection() and add
// its result to your PDF page children list.
// ══════════════════════════════════════════════════════════════

import 'package:check_list_stress/screens/medical_model.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Builds a complete Medical Assessment section for PDF export.
/// [assessment] — the saved MedicalAssessment snapshot
/// [maxWidth]   — progress-bar width in PDF points (default 200)
pw.Widget buildMedicalPdfSection(
    MedicalAssessment assessment, {
      double maxWidth = 200,
    }) {
  final vitals = buildMedVitals();

  // ── Color helpers ─────────────────────────────────────────
  PdfColor _decColor() {
    if (assessment.isGo)      return PdfColors.green700;
    if (assessment.isCaution) return PdfColors.orange700;
    return PdfColors.red700;
  }

  PdfColor _levelColor(MedLevel lvl) => const {
    MedLevel.normal:        PdfColors.green600,
    MedLevel.low:           PdfColors.cyan700,
    MedLevel.medium:        PdfColors.orange600,
    MedLevel.high:          PdfColors.deepOrange700,
    MedLevel.veryDangerous: PdfColors.red700,
  }[lvl]!;

  final double barWidth =
  (assessment.overallScoreForPdf / 100 * maxWidth).clamp(0.0, maxWidth);

  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.stretch,
    children: [
      pw.SizedBox(height: 20),

      // ── Header ────────────────────────────────────────────
      pw.Container(
        color: PdfColor.fromHex('#0A1A2A'),
        padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: pw.Row(children: [
          pw.Text('MEDICAL FITNESS ASSESSMENT',
              style: pw.TextStyle(
                fontSize: 13,
                fontWeight: pw.FontWeight.bold,
                color: PdfColor.fromHex('#00C8F0'),
                letterSpacing: 1.5,
              )),
          pw.Spacer(),
          pw.Container(
            padding:
            const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: pw.BoxDecoration(
              color: _decColor().shade(0.3),
              borderRadius: pw.BorderRadius.circular(4),
            ),
            child: pw.Text(assessment.decisionLabel,
                style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                  color: _decColor(),
                  letterSpacing: 1,
                )),
          ),
        ]),
      ),
      pw.SizedBox(height: 12),

      // ── Vital results table ───────────────────────────────
      pw.Table(
        border: pw.TableBorder.all(
            color: PdfColor.fromHex('#1E2D45'), width: 0.5),
        columnWidths: {
          0: const pw.FlexColumnWidth(3),
          1: const pw.FlexColumnWidth(2),
          2: const pw.FlexColumnWidth(2),
          3: const pw.FlexColumnWidth(2),
        },
        children: [
          // Header row
          pw.TableRow(
            decoration: const pw.BoxDecoration(
                color: PdfColor.fromInt(0xFF0E1219)),
            children: ['VITAL SIGN', 'VALUE', 'NORMAL RANGE', 'LEVEL']
                .map((h) => pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(h,
                  style: pw.TextStyle(
                    fontSize: 9,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColor.fromHex('#6B8CAE'),
                    letterSpacing: 0.5,
                  )),
            ))
                .toList(),
          ),
          // Data rows
          ...assessment.results.map((r) {
            final vital = vitals.firstWhere((v) => v.id == r.id,
                orElse: () => vitals.first);
            final normalRow = vital.ranges.firstWhere(
                    (row) => row.level == MedLevel.normal,
                orElse: () => vital.ranges.first);
            final valStr = r.value2 != null
                ? '${r.value.toStringAsFixed(0)} / ${r.value2!.toStringAsFixed(0)}'
                : r.id == 'temp'
                ? r.value.toStringAsFixed(1)
                : r.value.toStringAsFixed(0);

            return pw.TableRow(children: [
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(
                  '${vital.iconEmoji}  ${vital.title} (${vital.unit})',
                  style: pw.TextStyle(
                    fontSize: 10,
                    color: PdfColors.grey200,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(valStr,
                    style: pw.TextStyle(
                        fontSize: 11,
                        fontWeight: pw.FontWeight.bold,
                        color: _levelColor(r.level))),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(normalRow.rangeText,
                    style: const pw.TextStyle(
                        fontSize: 9, color: PdfColors.grey400)),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(6),
                child: pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                      horizontal: 6, vertical: 3),
                  decoration: pw.BoxDecoration(
                    color: _levelColor(r.level).shade(0.4),
                    borderRadius: pw.BorderRadius.circular(3),
                  ),
                  child: pw.Text(r.level.label,
                      style: pw.TextStyle(
                        fontSize: 8,
                        fontWeight: pw.FontWeight.bold,
                        color: _levelColor(r.level),
                      )),
                ),
              ),
            ]);
          }),
        ],
      ),
      pw.SizedBox(height: 12),

      // ── Overall risk bar ──────────────────────────────────
      pw.Row(children: [
        pw.Text('OVERALL MEDICAL RISK: ',
            style: pw.TextStyle(
              fontSize: 10,
              color: PdfColor.fromHex('#6B8CAE'),
              letterSpacing: 0.5,
            )),
        pw.Text(
          '${assessment.overallScoreForPdf.toStringAsFixed(0)}%',
          style: pw.TextStyle(
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
            color: _decColor(),
          ),
        ),
        pw.SizedBox(width: 12),
        pw.Stack(children: [
          pw.Container(
            width: maxWidth, height: 8,
            color: PdfColor.fromHex('#1E2D45'),
          ),
          pw.Container(
            width: barWidth, height: 8,
            color: _decColor(),
          ),
        ]),
      ]),
      pw.SizedBox(height: 8),

      // ── Disclaimer ────────────────────────────────────────
      pw.Text(
        '⚠ This medical assessment is a decision-support tool only. '
            'It does not replace an official Aviation Medical Examiner (AME) certification.',
        style: pw.TextStyle(
          fontSize: 8,
          color: PdfColors.orange400,
          fontStyle: pw.FontStyle.italic,
        ),
      ),
      pw.SizedBox(height: 16),
    ],
  );
}

// Extension — overall score for PDF (separate from model to avoid conflict)
extension MedPdfExt on MedicalAssessment {
  double get overallScoreForPdf {
    if (results.isEmpty) return 0;
    final total = results.fold(0, (s, r) => s + r.level.riskPoints);
    final max   = results.length * MedLevel.veryDangerous.riskPoints;
    return (total / max * 100).clamp(0, 100);
  }
}