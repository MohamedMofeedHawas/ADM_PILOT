// lib/features/history/assessment_detail_screen.dart
// ══════════════════════════════════════════════════════════════
// Full session detail — IMSAFE + PAVE scores, DECIDE notes
// ══════════════════════════════════════════════════════════════

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/storage/assessment_provider.dart';
import '../../core/storage/assessment_record.dart';
import '../export/pdf_export_service.dart';

const _kGo      = Color(0xFF00C853);
const _kCaution = Color(0xFFFFAA00);
const _kNoGo    = Color(0xFFFF1744);
const _kCyan    = Color(0xFF00BCD4);
const _kBg      = Color(0xFF0A0E14);
const _kSurface = Color(0xFF0D1520);
const _kBorder  = Color(0xFF1A3A2A);
const _kText1   = Color(0xFFE0E0E0);
const _kText2   = Color(0xFF558866);

class AssessmentDetailScreen extends StatelessWidget {
  final String recordId;
  const AssessmentDetailScreen({super.key, required this.recordId});

  @override
  Widget build(BuildContext context) {
    final record = context.read<AssessmentProvider>().getById(recordId);
    if (record == null) {
      return Scaffold(
        backgroundColor: _kBg,
        appBar: AppBar(backgroundColor: _kSurface,
            title: const Text('Not found')),
        body: const Center(child: Text('Record not found',
            style: TextStyle(color: _kText2))),
      );
    }

    final color = record.isGo ? _kGo : record.isCaution ? _kCaution : _kNoGo;

    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: _kSurface,
        title: Text(
          record.pilotName.isNotEmpty ? record.pilotName : 'Assessment',
          style: GoogleFonts.shareTechMono(
              fontSize: 14, color: _kText1),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined,
                color: _kCaution, size: 20),
            tooltip: 'Export PDF',
            onPressed: () =>
                PdfExportService.instance.exportAndShare(context, record),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: color.withOpacity(0.4)),
              ),
              child: Text(record.decisionLabel,
                  style: GoogleFonts.shareTechMono(
                      fontSize: 11, color: color,
                      fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 80),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

          // ── Header card ──────────────────────────────────
          _InfoCard(record: record, color: color),
          const SizedBox(height: 14),

          // ── IMSAFE radar ─────────────────────────────────
          _Label('IMSAFE BREAKDOWN', _kCaution),
          const SizedBox(height: 8),
          _RadarChart(
            labels: ImsafeScores.fullLabels,
            values: record.imsafe.asList,
          ),
          const SizedBox(height: 14),

          // ── PAVE bars ─────────────────────────────────────
          _Label('PAVE BREAKDOWN', _kCyan),
          const SizedBox(height: 8),
          _DetailBarChart(
            labels: PaveScores.fullLabels,
            values: record.pave.asList,
          ),
          const SizedBox(height: 14),

          // ── DECIDE notes ──────────────────────────────────
          if (record.decideNotes.isNotEmpty) ...[
            _Label('DECIDE NOTES', _kText2),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _kSurface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _kBorder),
              ),
              child: Text(record.decideNotes,
                  style: const TextStyle(
                      fontSize: 13, color: _kText1, height: 1.5)),
            ),
            const SizedBox(height: 14),
          ],

          // ── Arousal indicator ─────────────────────────────
          _Label('AROUSAL LEVEL', _kText2),
          const SizedBox(height: 8),
          _ArousalIndicator(level: record.arousalLevel),
          const SizedBox(height: 20),

          // ── Export PDF button ─────────────────────────────
          SizedBox(
            height: 50,
            child: OutlinedButton.icon(
              onPressed: () =>
                  PdfExportService.instance.exportAndShare(context, record),
              icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
              label: Text('EXPORT PDF REPORT',
                  style: GoogleFonts.shareTechMono(
                      fontSize: 12, letterSpacing: 1.5)),
              style: OutlinedButton.styleFrom(
                foregroundColor: _kCaution,
                side: const BorderSide(color: _kCaution),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

// ── Info card ─────────────────────────────────────────────────
class _InfoCard extends StatelessWidget {
  final AssessmentRecord record; final Color color;
  const _InfoCard({required this.record, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: _kSurface,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: _kBorder),
    ),
    child: Row(children: [
      Container(
        width: 64, height: 64,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withOpacity(0.1),
          border: Border.all(color: color.withOpacity(0.5), width: 2),
        ),
        child: Center(child: Text(
          '${record.totalRiskScore.toStringAsFixed(0)}',
          style: GoogleFonts.shareTechMono(
              fontSize: 20, color: color, fontWeight: FontWeight.w700),
        )),
      ),
      const SizedBox(width: 16),
      Expanded(child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (record.flightId.isNotEmpty)
          Text(record.flightId, style: GoogleFonts.shareTechMono(
              fontSize: 12, color: _kCyan)),
        Text(DateFormat('EEEE dd MMM yyyy').format(record.timestamp),
            style: const TextStyle(fontSize: 13, color: _kText1)),
        Text(DateFormat('HH:mm').format(record.timestamp),
            style: GoogleFonts.shareTechMono(fontSize: 11, color: _kText2)),
        const SizedBox(height: 6),
        Row(children: [
          _Chip('IMSAFE ${record.imsafe.total.toStringAsFixed(0)}%', _kCaution),
          const SizedBox(width: 6),
          _Chip('PAVE ${record.pave.total.toStringAsFixed(0)}%', _kCyan),
        ]),
      ])),
    ]),
  );
}

class _Chip extends StatelessWidget {
  final String text; final Color color;
  const _Chip(this.text, this.color);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(4),
      border: Border.all(color: color.withOpacity(0.3)),
    ),
    child: Text(text, style: GoogleFonts.shareTechMono(
        fontSize: 9, color: color)),
  );
}

// ── Radar chart (using RadarChart from fl_chart) ──────────────
class _RadarChart extends StatelessWidget {
  final List<String> labels;
  final List<double> values;
  const _RadarChart({required this.labels, required this.values});

  @override
  Widget build(BuildContext context) => Container(
    height: 220,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: _kSurface,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: _kBorder),
    ),
    child: RadarChart(
      RadarChartData(
        dataSets: [
          RadarDataSet(
            dataEntries: values.map((v) => RadarEntry(value: v)).toList(),
            fillColor: _kCaution.withOpacity(0.15),
            borderColor: _kCaution,
            borderWidth: 2,
            entryRadius: 3,
          ),
        ],
        radarBackgroundColor: Colors.transparent,
        borderData: FlBorderData(show: false),
        radarBorderData: const BorderSide(color: _kBorder, width: 1),
        gridBorderData: const BorderSide(color: _kBorder, width: 0.5),
        tickCount: 4,
        ticksTextStyle: GoogleFonts.shareTechMono(
            fontSize: 0, color: Colors.transparent),
        radarShape: RadarShape.polygon,
        getTitle: (i, _) => RadarChartTitle(
          text: labels[i],
          angle: 0,
          positionPercentageOffset: 0.1,
        ),
        titleTextStyle: GoogleFonts.shareTechMono(
            fontSize: 10, color: _kCaution),
        titlePositionPercentageOffset: 0.15,
      ),
    ),
  );
}

// ── Horizontal bar chart ──────────────────────────────────────
class _DetailBarChart extends StatelessWidget {
  final List<String> labels;
  final List<double> values;
  const _DetailBarChart({required this.labels, required this.values});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: _kSurface,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: _kBorder),
    ),
    child: Column(
      children: values.asMap().entries.map((e) {
        final color = e.value >= 75 ? _kNoGo
                    : e.value >= 40 ? _kCaution
                    : _kGo;
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(children: [
            SizedBox(width: 80,
                child: Text(labels[e.key],
                    style: GoogleFonts.shareTechMono(
                        fontSize: 10, color: _kText2))),
            Expanded(child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: e.value / 100,
                minHeight: 10,
                backgroundColor: _kBorder,
                valueColor: AlwaysStoppedAnimation(color),
              ),
            )),
            const SizedBox(width: 8),
            SizedBox(width: 36, child: Text(
              '${e.value.toStringAsFixed(0)}%',
              style: GoogleFonts.shareTechMono(
                  fontSize: 10, color: color,
                  fontWeight: FontWeight.w700),
            )),
          ]),
        );
      }).toList(),
    ),
  );
}

// ── Arousal indicator ─────────────────────────────────────────
class _ArousalIndicator extends StatelessWidget {
  final double level; // 0–10
  const _ArousalIndicator({required this.level});

  @override
  Widget build(BuildContext context) {
    final pct = level / 10;
    final color = pct < 0.3 ? _kText2
                : pct < 0.5 ? _kGo
                : pct < 0.7 ? _kCaution
                : _kNoGo;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _kBorder),
      ),
      child: Column(children: [
        Row(children: [
          Text('LOW', style: GoogleFonts.shareTechMono(
              fontSize: 9, color: _kText2)),
          const Spacer(),
          Text('OPTIMAL', style: GoogleFonts.shareTechMono(
              fontSize: 9, color: _kGo)),
          const Spacer(),
          Text('HIGH', style: GoogleFonts.shareTechMono(
              fontSize: 9, color: _kNoGo)),
        ]),
        const SizedBox(height: 6),
        Stack(children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 14,
              backgroundColor: _kBorder,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ]),
        const SizedBox(height: 6),
        Text('Arousal: ${level.toStringAsFixed(1)} / 10',
            style: GoogleFonts.shareTechMono(
                fontSize: 11, color: color)),
      ]),
    );
  }
}

class _Label extends StatelessWidget {
  final String text; final Color color;
  const _Label(this.text, this.color);
  @override
  Widget build(BuildContext context) => Text(text,
      style: GoogleFonts.shareTechMono(
          fontSize: 10, color: color, letterSpacing: 1.5));
}
