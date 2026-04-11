// lib/features/history/history_screen.dart
// ══════════════════════════════════════════════════════════════
// History — ADM assessments + Medical records | full light/dark
// ══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../theme/theme.dart';
import '../../core/storage/assessment_provider.dart';
import '../../screens/medical_model.dart';
import '../../screens/medical_provider.dart';

class HistoryScreen extends StatefulWidget {
  final bool showArabic;
  const HistoryScreen({super.key, this.showArabic = false});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.surface : Colors.white;
    final border  = isDark ? AppColors.border  : const Color(0xFFD0DCE8);
    final text2   = isDark ? const Color(0xFF6B8CAE) : const Color(0xFF3A5070);
    final bg      = isDark ? AppColors.bg      : const Color(0xFFF0F4F8);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: surface,
        elevation: 0,
        title: Text(
          widget.showArabic ? 'السجل' : 'HISTORY',
          style: GoogleFonts.shareTechMono(
              fontSize: 16, color: AppColors.cyan,
              fontWeight: FontWeight.w700, letterSpacing: 3),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: Container(
            color: surface,
            child: TabBar(
              controller: _tabCtrl,
              indicatorColor: AppColors.cyan,
              indicatorWeight: 3,
              labelColor: AppColors.cyan,
              unselectedLabelColor: text2,
              labelStyle: GoogleFonts.shareTechMono(
                  fontSize: 10, letterSpacing: 1.5),
              tabs: [
                Tab(text: widget.showArabic ? 'تقييمات ADM' : 'ADM ASSESSMENTS'),
                Tab(
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.monitor_heart_outlined, size: 14),
                    const SizedBox(width: 4),
                    Text(widget.showArabic ? 'الكشوف الطبية' : 'MEDICAL',
                        style: GoogleFonts.shareTechMono(
                            fontSize: 10, letterSpacing: 1.5)),
                  ]),
                ),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          // Tab 0 — ADM assessments
          _AdmHistoryTab(
            showArabic: widget.showArabic,
            bg: bg, surface: surface, border: border, text2: text2,
          ),
          // Tab 1 — Medical records
          _MedicalHistoryTab(
            showArabic: widget.showArabic,
            bg: bg, surface: surface, border: border, text2: text2,
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Tab 0 — ADM Assessments
// ══════════════════════════════════════════════════════════════
class _AdmHistoryTab extends StatelessWidget {
  final bool showArabic;
  final Color bg, surface, border, text2;

  const _AdmHistoryTab({
    required this.showArabic,
    required this.bg, required this.surface,
    required this.border, required this.text2,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final text1  = isDark ? Colors.white : const Color(0xFF0D1520);
    final ap     = context.watch<AssessmentProvider>();
    final records = ap.records;

    if (records.isEmpty) {
      return Center(child: Column(
          mainAxisSize: MainAxisSize.min, children: [
        const Text('📋', style: TextStyle(fontSize: 48)),
        const SizedBox(height: 12),
        Text(
          showArabic ? 'لا يوجد سجل تقييم بعد' : 'No assessments yet',
          style: GoogleFonts.rajdhani(fontSize: 16, color: text2),
        ),
        const SizedBox(height: 6),
        Text(
          showArabic
              ? 'أكمل تقييمك الأول للرؤية هنا'
              : 'Complete your first assessment to see it here',
          style: GoogleFonts.rajdhani(fontSize: 13, color: text2),
        ),
      ]));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(14),
      itemCount: records.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (ctx, i) {
        final rec = records[i];
        return Dismissible(
          key: Key(rec.timestamp.toString()),
          direction: DismissDirection.endToStart,
          onDismissed: (_) => ap.delete(
            i.toString(),
          ),
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: AppColors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.red.withOpacity(0.3)),
            ),
            child: const Icon(Icons.delete_outline, color: AppColors.red),
          ),
          child: _AdmHistoryTile(
            record: rec,
            showArabic: showArabic,
            surface: surface, border: border,
            text1: text1, text2: text2,
          ),
        );
      },
    );
  }
}

class _AdmHistoryTile extends StatelessWidget {
  final dynamic record;
  final bool showArabic;
  final Color surface, border, text1, text2;

  const _AdmHistoryTile({
    required this.record, required this.showArabic,
    required this.surface, required this.border,
    required this.text1, required this.text2,
  });

  @override
  Widget build(BuildContext context) {
    // final risk     = (record.totalRisk as double);
    final risk    = record.totalRiskScore;
    final decision = record.decision as String;
    final isGo     = decision == 'go';
    final isCaution = decision == 'caution';
    final color    = isGo ? AppColors.green
        : isCaution ? AppColors.amber : AppColors.red;
    final label    = isGo ? (showArabic ? 'مسموح' : 'GO')
        : isCaution ? (showArabic ? 'تحذير' : 'CAUTION')
        : (showArabic ? 'ممنوع' : 'NO-GO');

    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(11),
        child: IntrinsicHeight(
          child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Container(width: 4, color: color),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Expanded(child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start, children: [
                      if (record.pilotName?.isNotEmpty == true)
                        Text(record.pilotName,
                            style: GoogleFonts.shareTechMono(
                                fontSize: 12, color: text1,
                                fontWeight: FontWeight.w700)),
                      Text(
                        DateFormat('EEE dd MMM yyyy · HH:mm')
                            .format(record.timestamp as DateTime),
                        style: GoogleFonts.shareTechMono(
                            fontSize: 9, color: text2),
                      ),
                    ])),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: color.withOpacity(0.4)),
                      ),
                      child: Text(label,
                          style: GoogleFonts.shareTechMono(
                              fontSize: 12, color: color,
                              fontWeight: FontWeight.w700, letterSpacing: 1)),
                    ),
                  ]),
                  const SizedBox(height: 10),
                  // Score mini bars
                  Row(children: [
                    _MiniScore('I', record.imsafe.total, AppColors.cyan),
                    const SizedBox(width: 8),
                    _MiniScore('P', record.pave.total,   AppColors.green),                    const SizedBox(width: 8),
                    const SizedBox(width: 8),
                    Expanded(child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end, children: [
                      Text(
                        '${risk.toStringAsFixed(0)}% ${showArabic ? "مخاطرة" : "total risk"}',
                        style: GoogleFonts.shareTechMono(
                            fontSize: 11, color: color,
                            fontWeight: FontWeight.w700),
                      ),
                    ])),
                  ]),
                  if (record.decideNotes.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(record.decideNotes,
                        maxLines: 2, overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.rajdhani(
                            fontSize: 11, color: text2, height: 1.4)),
                  ],
                ]),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class _MiniScore extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  const _MiniScore(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 18, height: 18,
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(0.15),
            border: Border.all(color: color.withOpacity(0.4))),
        child: Center(child: Text(label,
            style: GoogleFonts.shareTechMono(
                fontSize: 8, color: color, fontWeight: FontWeight.w700))),
      ),
      const SizedBox(width: 4),
      Text('${value.toStringAsFixed(0)}%',
          style: GoogleFonts.shareTechMono(
              fontSize: 10, color: color, fontWeight: FontWeight.w700)),
    ],
  );
}

// ══════════════════════════════════════════════════════════════
// Tab 1 — Medical Records
// ══════════════════════════════════════════════════════════════
class _MedicalHistoryTab extends StatelessWidget {
  final bool showArabic;
  final Color bg, surface, border, text2;

  const _MedicalHistoryTab({
    required this.showArabic,
    required this.bg, required this.surface,
    required this.border, required this.text2,
  });

  @override
  Widget build(BuildContext context) {
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    final text1   = isDark ? Colors.white : const Color(0xFF0D1520);
    final mp      = context.watch<MedicalProvider>();
    final history = mp.history;

    if (history.isEmpty) {
      return Center(child: Column(
          mainAxisSize: MainAxisSize.min, children: [
        const Text('🏥', style: TextStyle(fontSize: 48)),
        const SizedBox(height: 12),
        Text(
          showArabic ? 'لا يوجد كشف طبي بعد' : 'No medical records yet',
          style: GoogleFonts.rajdhani(fontSize: 16, color: text2),
        ),
        const SizedBox(height: 6),
        Text(
          showArabic
              ? 'أكمل كشفك الطبي الأول من خلال MEDICAL'
              : 'Complete your first medical check via the MEDICAL tab',
          style: GoogleFonts.rajdhani(fontSize: 13, color: text2),
          textAlign: TextAlign.center,
        ),
      ]));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(14),
      itemCount: history.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (ctx, i) {
        final rec = history[i];
        return Dismissible(
          key: Key(rec.timestamp.toIso8601String()),
          direction: DismissDirection.endToStart,
          onDismissed: (_) => mp.deleteRecord(i),
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: AppColors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.red.withOpacity(0.3)),
            ),
            child: const Icon(Icons.delete_outline, color: AppColors.red),
          ),
          child: _MedicalRecordTile(
            record: rec, showArabic: showArabic,
            surface: surface, border: border,
            text1: text1, text2: text2,
          ),
        );
      },
    );
  }
}

class _MedicalRecordTile extends StatelessWidget {
  final MedicalAssessment record;
  final bool showArabic;
  final Color surface, border, text1, text2;

  const _MedicalRecordTile({
    required this.record, required this.showArabic,
    required this.surface, required this.border,
    required this.text1, required this.text2,
  });

  @override
  Widget build(BuildContext context) {
    final score = record.overallScore;

    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: record.decisionColor.withOpacity(0.25)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(11),
        child: Column(children: [
          // color bar top
          Container(height: 3, color: record.decisionColor),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(children: [
              // Header row
              Row(children: [
                // Score circle
                Container(
                  width: 52, height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: record.decisionColor.withOpacity(0.1),
                    border: Border.all(
                        color: record.decisionColor.withOpacity(0.4), width: 1.5),
                  ),
                  child: Center(child: Text(
                    score.toStringAsFixed(0),
                    style: GoogleFonts.shareTechMono(
                        fontSize: 14, color: record.decisionColor,
                        fontWeight: FontWeight.w700),
                  )),
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(
                    DateFormat('EEE dd MMM yyyy · HH:mm')
                        .format(record.timestamp),
                    style: GoogleFonts.shareTechMono(
                        fontSize: 9, color: text2),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${score.toStringAsFixed(0)}% ${showArabic ? "مخاطرة طبية" : "medical risk"}',
                    style: GoogleFonts.shareTechMono(
                        fontSize: 13, color: record.decisionColor,
                        fontWeight: FontWeight.w700),
                  ),
                ])),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: record.decisionColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: record.decisionColor.withOpacity(0.4)),
                  ),
                  child: Text(
                    showArabic
                        ? (record.isGo ? 'مسموح'
                        : record.isCaution ? 'تحذير' : 'ممنوع')
                        : record.decisionLabel,
                    style: GoogleFonts.shareTechMono(
                        fontSize: 12, color: record.decisionColor,
                        fontWeight: FontWeight.w700, letterSpacing: 1),
                  ),
                ),
              ]),
              const SizedBox(height: 12),
              // Vitals mini bars
              ...record.results.map((r) {
                final vital = buildMedVitals().firstWhere(
                        (v) => v.id == r.id,
                    orElse: () => buildMedVitals().first);
                final valStr = r.value2 != null
                    ? '${r.value.toStringAsFixed(0)}/${r.value2!.toStringAsFixed(0)}'
                    : r.id == 'temp'
                    ? r.value.toStringAsFixed(1)
                    : r.value.toStringAsFixed(0);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(children: [
                    Text(vital.iconEmoji,
                        style: const TextStyle(fontSize: 14)),
                    const SizedBox(width: 6),
                    SizedBox(
                      width: 90,
                      child: Text(
                        showArabic ? vital.arabicTitle : vital.title,
                        style: GoogleFonts.rajdhani(
                            fontSize: 11, color: text1),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Expanded(child: ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: r.level.riskPoints / 10.0,
                        minHeight: 6,
                        backgroundColor: border,
                        valueColor: AlwaysStoppedAnimation(r.level.color),
                      ),
                    )),
                    const SizedBox(width: 8),
                    Text(valStr,
                        style: GoogleFonts.shareTechMono(
                            fontSize: 10, color: r.level.color,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: r.level.dimColor,
                        borderRadius: BorderRadius.circular(3),
                        border: Border.all(
                            color: r.level.color.withOpacity(0.4)),
                      ),
                      child: Text(
                        showArabic ? r.level.arabicLabel : r.level.label,
                        style: GoogleFonts.shareTechMono(
                            fontSize: 7, color: r.level.color,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  ]),
                );
              }),
            ]),
          ),
        ]),
      ),
    );
  }
}