// lib/features/dashboard/dashboard_screen.dart
// ══════════════════════════════════════════════════════════════
// Dashboard — integrates Medical summary card + light/dark mode
// ══════════════════════════════════════════════════════════════

import 'package:check_list_stress/features/arousal/arousal_screen.dart';
import 'package:check_list_stress/screens/medical_history.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../models/pilot_eval_model.dart';
import '../../screens/pilot_eval_controller.dart';
import '../../theme/theme.dart';
import '../../core/storage/assessment_provider.dart';
import '../../screens/medical_model.dart';
import '../../screens/medical_provider.dart';

class DashboardScreen extends StatelessWidget {
  final bool showArabic;
  final PilotEvalController? pilotEvalController;
  const DashboardScreen({super.key, this.showArabic = false, this.pilotEvalController});

  @override
  Widget build(BuildContext context) {
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    final bg      = isDark ? AppColors.bg      : const Color(0xFFF0F4F8);
    final surface = isDark ? AppColors.surface : Colors.white;
    final border  = isDark ? AppColors.border  : const Color(0xFFD0DCE8);
    final text1   = isDark ? Colors.white      : const Color(0xFF0D1520);
    final text2   = isDark ? const Color(0xFF6B8CAE) : const Color(0xFF3A5070);

    final ap = context.watch<AssessmentProvider>();
    final mp = context.watch<MedicalProvider>();
    final records = ap.records;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: surface,
        actions: [
          IconButton(
            icon: const Icon(Icons.psychology, size: 25, color: Colors.purple),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => ArousalScreen(showArabic: showArabic))),
            tooltip: showArabic ? 'تقييم الإثارة' : 'Arousal Assessment',
          ),

        ],
        elevation: 0,
        title: Text(
          showArabic ? 'لوحة التحكم' : 'DASHBOARD',
          style: GoogleFonts.shareTechMono(
              fontSize: 16, color: AppColors.cyan,
              fontWeight: FontWeight.w700, letterSpacing: 3),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: Container(height: 2,
              color: AppColors.cyan.withOpacity(0.4)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              // ── 1. MEDICAL SUMMARY CARD ──────────────────────
              _SectionLabel(
                showArabic ? 'آخر كشف طبي' : 'LATEST MEDICAL CHECK',
                AppColors.red, text2,
              ),
              const SizedBox(height: 8),
              MedicalDashboardCard(showArabic: showArabic),
              const SizedBox(height: 20),

              // ── 2. LAST ASSESSMENT ───────────────────────────
              _SectionLabel(
                showArabic ? 'آخر تقييم' : 'LATEST ASSESSMENT',
                AppColors.cyan, text2,
              ),
              const SizedBox(height: 8),
              records.isEmpty
                  ? _EmptyCard(
                showArabic
                    ? 'لا يوجد سجل تقييم بعد'
                    : 'No assessments yet',
                surface: surface, border: border, text2: text2,
              )
                  : _LatestAssessmentCard(
                record: records.first,
                showArabic: showArabic,
                surface: surface, border: border,
                text1: text1, text2: text2,
              ),
              const SizedBox(height: 20),

              // ── 3. STATS GRID ────────────────────────────────
              if (records.isNotEmpty) ...[
                _SectionLabel(
                  showArabic ? 'إحصاءات سريعة' : 'QUICK STATS',
                  AppColors.amber, text2,
                ),
                const SizedBox(height: 8),
                _StatsGrid(
                  records: records,
                  showArabic: showArabic,
                  surface: surface, border: border,
                  text1: text1, text2: text2,
                ),
                const SizedBox(height: 20),
              ],

              // ── 4. MEDICAL HISTORY MINI LIST ─────────────────
              if (mp.history.isNotEmpty) ...[
                _SectionLabel(
                  showArabic ? 'سجل الكشوف الطبية' : 'MEDICAL HISTORY',
                  AppColors.purple, text2,
                ),
                const SizedBox(height: 8),
                _MedicalMiniHistory(
                  history: mp.history.take(3).toList(),
                  showArabic: showArabic,
                  surface: surface, border: border,
                  text1: text1, text2: text2,
                ),
                const SizedBox(height: 20),
              ],

              // ── 5. RISK TREND ─────────────────────────────────
              if (records.length >= 1) ...[
                _SectionLabel(
                  showArabic ? 'اتجاه المخاطر' : 'RISK TREND',
                  AppColors.green, text2,
                ),
                const SizedBox(height: 8),
                _RiskTrendCard(
                  records: records.toList().reversed.toList(),
                  showArabic: showArabic,
                  surface: surface, border: border,
                  text1: text1, text2: text2,
                ),
              ],
              if (pilotEvalController != null) ...[
                const SizedBox(height: 20),
                _SectionLabel(
                  showArabic ? 'تقييم مستوى الطيار' : 'PILOT LEVEL ASSESSMENT',
                  AppColors.cyan, text2,
                ),
                const SizedBox(height: 8),
                _PilotEvalDashCard(
                  controller: pilotEvalController!,
                  showArabic: showArabic,
                  surface: surface, border: border,
                  text1: text1, text2: text2,
                ),
              ],

              const SizedBox(height: 40),
            ]),
      ),
    );
  }
}
class _PilotEvalDashCard extends StatelessWidget {
  final PilotEvalController controller;
  final bool showArabic;
  final Color surface, border, text1, text2;

  const _PilotEvalDashCard({
    required this.controller,
    required this.showArabic,
    required this.surface, required this.border,
    required this.text1, required this.text2,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (ctx, _) {
        final pct    = controller.overallPct;
        final pctInt = (pct * 100).toInt();
        final rated  = controller.totalRated;
        final total  = controller.totalCriteria;
        final color  = pctInt >= 80
            ? AppColors.green
            : pctInt >= 60 ? AppColors.amber : AppColors.red;

        return Container(
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: rated == 0
                    ? border
                    : color.withOpacity(0.35)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(11),
            child: Column(children: [
              // colour top stripe
              Container(height: 3, color: rated == 0 ? border : color),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(children: [
                  // Score row
                  Row(children: [
                    // Circle score
                    Container(
                      width: 54, height: 54,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: (rated == 0 ? border : color)
                            .withOpacity(0.1),
                        border: Border.all(
                            color: (rated == 0 ? border : color)
                                .withOpacity(0.4),
                            width: 1.5),
                      ),
                      child: Center(
                        child: Text(
                          rated == 0 ? '--' : '$pctInt',
                          style: GoogleFonts.shareTechMono(
                              fontSize: 16,
                              color: rated == 0 ? text2 : color,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(
                        showArabic ? 'تقييم مستوى الطيار' : 'Pilot Level Assessment',
                        style: GoogleFonts.rajdhani(
                            fontSize: 15, color: text1,
                            fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        rated == 0
                            ? (showArabic
                            ? 'لم يبدأ التقييم بعد'
                            : 'No assessment started')
                            : (showArabic
                            ? '$rated / $total معيار مُقيَّم'
                            : '$rated / $total criteria rated'),
                        style: GoogleFonts.rajdhani(
                            fontSize: 12, color: text2),
                      ),
                    ])),
                  ]),

                  if (rated > 0) ...[
                    const SizedBox(height: 14),
                    // Per-section mini bars
                    for (final sec in controller.sections) ...[
                      _MiniSectionBar(
                        sec: sec,
                        showArabic: showArabic,
                        text2: text2,
                      ),
                      const SizedBox(height: 6),
                    ],
                  ],
                ]),
              ),
            ]),
          ),
        );
      },
    );
  }
}
class _MiniSectionBar extends StatelessWidget {
  final PilotEvalSection sec;
  final bool showArabic;
  final Color text2;
  const _MiniSectionBar(
      {required this.sec, required this.showArabic, required this.text2});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      SizedBox(
        width: 70,
        child: Text(
          showArabic ? sec.titleAr.split(' ').last : sec.id,
          style: GoogleFonts.shareTechMono(
              fontSize: 8, color: text2, letterSpacing: 1),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      Expanded(child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(
          value: sec.averagePct,
          minHeight: 7,
          backgroundColor: AppColors.elevated,
          valueColor: AlwaysStoppedAnimation(sec.color),
        ),
      )),
      const SizedBox(width: 8),
      Text(
        sec.ratedCount == 0
            ? '--'
            : '${(sec.averagePct * 100).toInt()}%',
        style: GoogleFonts.shareTechMono(
            fontSize: 10,
            color: sec.ratedCount == 0 ? text2 : sec.color,
            fontWeight: FontWeight.w700),
      ),
    ]);
  }
}


// ── Section label ─────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String text;
  final Color accent, text2;
  const _SectionLabel(this.text, this.accent, this.text2);

  @override
  Widget build(BuildContext context) => Row(children: [
    Container(width: 3, height: 14,
        decoration: BoxDecoration(
          color: accent,
          borderRadius: BorderRadius.circular(2),
        )),
    const SizedBox(width: 8),
    Text(text, style: GoogleFonts.shareTechMono(
        fontSize: 10, color: text2, letterSpacing: 1.5)),
  ]);
}

// ── Empty placeholder ─────────────────────────────────────────
class _EmptyCard extends StatelessWidget {
  final String message;
  final Color surface, border, text2;
  const _EmptyCard(this.message,
      {required this.surface, required this.border, required this.text2});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: surface,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: border),
    ),
    child: Center(
      child: Text(message,
          style: GoogleFonts.rajdhani(fontSize: 14, color: text2)),
    ),
  );
}

// ── Latest assessment card ────────────────────────────────────
class _LatestAssessmentCard extends StatelessWidget {
  final dynamic record; // AssessmentRecord
  final bool showArabic;
  final Color surface, border, text1, text2;

  const _LatestAssessmentCard({
    required this.record, required this.showArabic,
    required this.surface, required this.border,
    required this.text1, required this.text2,
  });

  @override
  Widget build(BuildContext context) {
    // final risk    = (record.totalRisk as double);
    final risk    = (record.totalRiskScore);
    final decision = record.decision as String;
    final isGo    = decision == 'go';
    final isCaution = decision == 'caution';
    final color   = isGo
        ? AppColors.green
        : isCaution ? AppColors.amber : AppColors.red;
    final label   = isGo ? (showArabic ? 'مسموح' : 'GO')
        : isCaution ? (showArabic ? 'تحذير' : 'CAUTION')
        : (showArabic ? 'ممنوع' : 'NO-GO');

    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(11),
        child: Column(children: [
          Container(height: 3, color: color),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              Row(children: [
                // Decision badge
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: color.withOpacity(0.4)),
                  ),
                  child: Text(label,
                      style: GoogleFonts.shareTechMono(
                          fontSize: 18, color: color,
                          fontWeight: FontWeight.w700, letterSpacing: 2)),
                ),
                const SizedBox(width: 14),
                Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(
                    '${risk.toStringAsFixed(1)}% ${showArabic ? "مخاطرة" : "risk"}',
                    style: GoogleFonts.shareTechMono(
                        fontSize: 20, color: color,
                        fontWeight: FontWeight.w700),
                  ),
                  if (record.pilotName?.isNotEmpty == true)
                    Text(record.pilotName,
                        style: GoogleFonts.rajdhani(
                            fontSize: 12, color: text2)),
                  Text(
                    DateFormat('dd MMM yyyy · HH:mm')
                        .format(record.timestamp as DateTime),
                    style: GoogleFonts.shareTechMono(
                        fontSize: 9, color: text2),
                  ),
                ])),
              ]),
              const SizedBox(height: 14),
              // Mini component bars
              _MiniBar('IMSAFE', record.imsafe.total, AppColors.cyan, text2),

              const SizedBox(height: 6),
              _MiniBar('PAVE',   record.pave.total,   AppColors.green, text2),

            ]),
          ),
        ]),
      ),
    );
  }
}

class _MiniBar extends StatelessWidget {
  final String label;
  final double value;
  final Color color, text2;
  const _MiniBar(this.label, this.value, this.color, this.text2);

  @override
  Widget build(BuildContext context) => Row(children: [
    SizedBox(
      width: 60,
      child: Text(label, style: GoogleFonts.shareTechMono(
          fontSize: 9, color: text2, letterSpacing: 1)),
    ),
    Expanded(child: ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: LinearProgressIndicator(
        value: (value / 100).clamp(0.0, 1.0),
        minHeight: 8,
        backgroundColor: AppColors.elevated,
        valueColor: AlwaysStoppedAnimation(color),
      ),
    )),
    const SizedBox(width: 8),
    Text('${value.toStringAsFixed(0)}%',
        style: GoogleFonts.shareTechMono(
            fontSize: 10, color: color, fontWeight: FontWeight.w700)),
  ]);
}

// ── Stats grid ────────────────────────────────────────────────
class _StatsGrid extends StatelessWidget {
  final List<dynamic> records;
  final bool showArabic;
  final Color surface, border, text1, text2;

  const _StatsGrid({
    required this.records, required this.showArabic,
    required this.surface, required this.border,
    required this.text1, required this.text2,
  });

  @override
  Widget build(BuildContext context) {
    final total   = records.length;
    final goCount = records.where((r) => r.decision == 'go').length;
    final noGoCount = records.where((r) => r.decision == 'no_go').length;
    final avgRisk = records.isEmpty
        ? 0.0
        : records.fold(0.0, (s, r) => s + r.totalRiskScore) / records.length;


    return Row(children: [
      Expanded(child: _StatTile(
        value: '$total',
        label: showArabic ? 'إجمالي' : 'Total',
        color: AppColors.cyan,
        surface: surface, border: border, text1: text1, text2: text2,
      )),
      const SizedBox(width: 8),
      Expanded(child: _StatTile(
        value: '$goCount',
        label: showArabic ? 'مسموح' : 'GO',
        color: AppColors.green,
        surface: surface, border: border, text1: text1, text2: text2,
      )),
      const SizedBox(width: 8),
      Expanded(child: _StatTile(
        value: '$noGoCount',
        label: showArabic ? 'ممنوع' : 'NO-GO',
        color: AppColors.red,
        surface: surface, border: border, text1: text1, text2: text2,
      )),
      const SizedBox(width: 8),
      Expanded(child: _StatTile(
        value: '${avgRisk.toStringAsFixed(0)}%',
        label: showArabic ? 'متوسط' : 'Avg Risk',
        color: AppColors.amber,
        surface: surface, border: border, text1: text1, text2: text2,
      )),
    ]);
  }
}

class _StatTile extends StatelessWidget {
  final String value, label;
  final Color color, surface, border, text1, text2;

  const _StatTile({
    required this.value, required this.label, required this.color,
    required this.surface, required this.border,
    required this.text1, required this.text2,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
    decoration: BoxDecoration(
      color: surface,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: color.withOpacity(0.25)),
    ),
    child: Column(children: [
      Text(value, style: GoogleFonts.shareTechMono(
          fontSize: 20, color: color, fontWeight: FontWeight.w700)),
      const SizedBox(height: 3),
      Text(label, style: GoogleFonts.rajdhani(
          fontSize: 10, color: text2, letterSpacing: 0.5),
          textAlign: TextAlign.center),
    ]),
  );
}

// ── Medical mini history ──────────────────────────────────────
class _MedicalMiniHistory extends StatelessWidget {
  final List<MedicalAssessment> history;
  final bool showArabic;
  final Color surface, border, text1, text2;

  const _MedicalMiniHistory({
    required this.history, required this.showArabic,
    required this.surface, required this.border,
    required this.text1, required this.text2,
  });

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: surface,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: border),
    ),
    child: Column(
      children: history.asMap().entries.map((e) {
        final rec = e.value;
        final score = rec.overallScore;
        return Column(children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: rec.decisionColor.withOpacity(0.1),
                  border: Border.all(
                      color: rec.decisionColor.withOpacity(0.4), width: 1.5),
                ),
                child: Center(child: Text(
                  '${score.toStringAsFixed(0)}',
                  style: GoogleFonts.shareTechMono(
                      fontSize: 11, color: rec.decisionColor,
                      fontWeight: FontWeight.w700),
                )),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                  DateFormat('EEE dd MMM · HH:mm').format(rec.timestamp),
                  style: GoogleFonts.shareTechMono(
                      fontSize: 9, color: text2),
                ),
                const SizedBox(height: 2),
                Row(children: rec.results.map((r) {
                  final vital = buildMedVitals().firstWhere(
                          (v) => v.id == r.id,
                      orElse: () => buildMedVitals().first);
                  return Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Text(vital.iconEmoji,
                        style: const TextStyle(fontSize: 14)),
                  );
                }).toList()),
              ])),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: rec.decisionColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                      color: rec.decisionColor.withOpacity(0.4)),
                ),
                child: Text(
                  showArabic
                      ? (rec.isGo ? 'مسموح'
                      : rec.isCaution ? 'تحذير' : 'ممنوع')
                      : rec.decisionLabel,
                  style: GoogleFonts.shareTechMono(
                      fontSize: 10, color: rec.decisionColor,
                      fontWeight: FontWeight.w700),
                ),
              ),
            ]),
          ),
          if (e.key < history.length - 1)
            Divider(color: border, height: 1),
        ]);
      }).toList(),
    ),
  );
}

// ── Risk trend chart ──────────────────────────────────────────
class _RiskTrendCard extends StatelessWidget {
  final List<dynamic> records;
  final bool showArabic;
  final Color surface, border, text1, text2;

  const _RiskTrendCard({
    required this.records, required this.showArabic,
    required this.surface, required this.border,
    required this.text1, required this.text2,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: surface,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: border),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Text(
      //   showArabic ? 'اتجاه المخاطر ' : 'RISK TREND ',
      //   style: GoogleFonts.shareTechMono(
      //       fontSize: 15, color: text2, letterSpacing: 1.5),
      // ),
      // const SizedBox(height: 16),
      SizedBox(
        height: 80,
        child: CustomPaint(
          size: const Size(double.infinity, 80),
          painter: _TrendPainter(
            values: records
                .map((r) => (r.totalRiskScore as double ) / 100.0)
                .toList(),
            borderColor: border,
          ),
        ),
      ),
      const SizedBox(height: 8),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: records.asMap().entries.map((e) {
            final risk  = (e.value.totalRiskScore as double);
            final c     = risk >= 75 ? AppColors.red
                : risk >= 40 ? AppColors.amber
                : AppColors.green;
            return Expanded(child: Column(children: [
              Container(width: 8, height: 8,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: c)),
              const SizedBox(height: 2),
              Text('${risk.toStringAsFixed(0)}',
                  style: GoogleFonts.shareTechMono(
                      fontSize: 7, color: c, fontWeight: FontWeight.w700),
                  textAlign: TextAlign.center),
            ]));
          }).toList()),
    ]),
  );
}

class _TrendPainter extends CustomPainter {
  final List<double> values;
  final Color borderColor;
  const _TrendPainter({required this.values, required this.borderColor});

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    // Grid lines
    final gridP = Paint()
      ..color = borderColor.withOpacity(0.4)
      ..strokeWidth = 0.5;
    for (int i = 0; i <= 4; i++) {
      final y = size.height * (1 - i / 4);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridP);
    }

    final n = values.length;
    if (n < 2) return;
    final step = size.width / (n - 1);

    // Area fill
    final path = Path();
    for (int i = 0; i < n; i++) {
      final x = i * step;
      final y = size.height * (1 - values[i]);
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    path.lineTo((n - 1) * step, size.height);
    path.lineTo(0, size.height);
    path.close();
    canvas.drawPath(path, Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
        colors: [AppColors.cyan.withOpacity(0.3), AppColors.cyan.withOpacity(0.02)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill);

    // Line
    final linePath = Path();
    for (int i = 0; i < n; i++) {
      final x = i * step;
      final y = size.height * (1 - values[i]);
      i == 0 ? linePath.moveTo(x, y) : linePath.lineTo(x, y);
    }
    canvas.drawPath(linePath, Paint()
      ..color = AppColors.cyan
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round);

    // Dots
    for (int i = 0; i < n; i++) {
      final x = i * step;
      final y = size.height * (1 - values[i]);
      final c = values[i] >= 0.75 ? AppColors.red
          : values[i] >= 0.40 ? AppColors.amber
          : AppColors.green;
      canvas.drawCircle(Offset(x, y), 4, Paint()..color = c);
      canvas.drawCircle(Offset(x, y), 2.5, Paint()..color = AppColors.bg);
    }
  }

  @override
  bool shouldRepaint(_TrendPainter old) => old.values != values;
}