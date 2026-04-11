// lib/features/medical/medical_history_widget.dart
// ══════════════════════════════════════════════════════════════
// Medical widgets — Dashboard card + History list
// ✅ Full Light/Dark theme support (uses Theme.of(context))
// ══════════════════════════════════════════════════════════════

import 'package:check_list_stress/screens/medical_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'medical_provider.dart';

// ══════════════════════════════════════════════════════════════
// ── Dashboard card ────────────────────────────────────────────
// ══════════════════════════════════════════════════════════════
class MedicalDashboardCard extends StatelessWidget {
  final bool showArabic;
  const MedicalDashboardCard({super.key, this.showArabic = false});

  @override
  Widget build(BuildContext context) {
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    final mp      = context.watch<MedicalProvider>();
    final latest  = mp.latest;

    final bg      = isDark ? const Color(0xFF0E1219) : Colors.white;
    final border  = isDark ? const Color(0xFF1E2D45) : const Color(0xFFD0DCE8);
    final text1   = isDark ? Colors.white             : const Color(0xFF0D1520);
    final text2   = isDark ? const Color(0xFF6B8CAE)  : const Color(0xFF3A5070);

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(11),
        child: Column(children: [
          // Accent bar
          Container(height: 3, color: const Color(0xFFFF3D57)),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Header
              Row(children: [
                const Text('🏥', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Expanded(child: Text(
                  showArabic ? 'آخر كشف طبي' : 'LATEST MEDICAL CHECK',
                  style: GoogleFonts.shareTechMono(
                      fontSize: 10, color: text2, letterSpacing: 1.5),
                )),
                if (latest != null)
                  Text(
                    DateFormat('dd/MM/yy').format(latest.timestamp),
                    style: GoogleFonts.shareTechMono(fontSize: 9, color: text2),
                  ),
              ]),
              const SizedBox(height: 12),

              if (latest == null) ...[
                Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00C8F0).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                          color: const Color(0xFF00C8F0).withOpacity(0.3)),
                    ),
                    child: const Icon(Icons.monitor_heart_outlined,
                        color: Color(0xFF00C8F0), size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text(
                    showArabic
                        ? 'لم يُجرَ كشف طبي بعد\nابدأ من خلال خطوة MEDICAL'
                        : 'No medical assessment yet\nStart from the MEDICAL step',
                    style: GoogleFonts.rajdhani(fontSize: 13, color: text2, height: 1.4),
                  )),
                ]),
              ] else ...[
                // Decision badge + score
                Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: latest.decisionColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                          color: latest.decisionColor.withOpacity(0.4)),
                    ),
                    child: Text(
                      latest.decisionLabel,
                      style: GoogleFonts.shareTechMono(
                          fontSize: 14, color: latest.decisionColor,
                          fontWeight: FontWeight.w700, letterSpacing: 2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(
                      '${latest.overallScore.toStringAsFixed(0)}% ${showArabic ? "خطر" : "risk"}',
                      style: GoogleFonts.shareTechMono(
                          fontSize: 16, color: latest.decisionColor,
                          fontWeight: FontWeight.w700),
                    ),
                    Text(
                      '${latest.results.length} ${showArabic ? "قياسات" : "vitals assessed"}',
                      style: GoogleFonts.rajdhani(fontSize: 12, color: text2),
                    ),
                  ])),
                ]),
                const SizedBox(height: 12),

                // Vital mini bars
                ...latest.results.map((r) {
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
                        width: 80,
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
                              fontSize: 9, color: r.level.color,
                              fontWeight: FontWeight.w700)),
                      const SizedBox(width: 6),
                      Container(
                        width: 58,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(
                          color: r.level.dimColor,
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Text(
                          showArabic ? r.level.arabicLabel : r.level.label,
                          style: GoogleFonts.shareTechMono(
                              fontSize: 7, color: r.level.color,
                              fontWeight: FontWeight.w700),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ]),
                  );
                }),
              ],
            ]),
          ),
        ]),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// ── Medical history list ──────────────────────────────────────
// ══════════════════════════════════════════════════════════════
class MedicalHistoryList extends StatelessWidget {
  final bool showArabic;
  const MedicalHistoryList({super.key, this.showArabic = false});

  @override
  Widget build(BuildContext context) {
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    final mp      = context.watch<MedicalProvider>();
    final history = mp.history;

    final bg     = isDark ? const Color(0xFF0E1219) : Colors.white;
    final border = isDark ? const Color(0xFF1E2D45) : const Color(0xFFD0DCE8);
    final text1  = isDark ? Colors.white             : const Color(0xFF0D1520);
    final text2  = isDark ? const Color(0xFF6B8CAE)  : const Color(0xFF3A5070);

    if (history.isEmpty) {
      return Center(child: Text(
        showArabic ? 'لا يوجد سجل طبي' : 'No medical records yet',
        style: GoogleFonts.rajdhani(fontSize: 14, color: text2),
      ));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(14),
      itemCount: history.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (ctx, i) {
        final rec = history[i];
        return _MedHistoryTile(
          record: rec, isAr: showArabic,
          bg: bg, border: border, text1: text1, text2: text2,
          onDelete: () => mp.deleteRecord(i),
        );
      },
    );
  }
}

class _MedHistoryTile extends StatelessWidget {
  final MedicalAssessment record;
  final bool isAr;
  final Color bg, border, text1, text2;
  final VoidCallback onDelete;

  const _MedHistoryTile({
    required this.record, required this.isAr,
    required this.bg, required this.border,
    required this.text1, required this.text2,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) => Dismissible(
    key: Key(record.timestamp.toIso8601String()),
    direction: DismissDirection.endToStart,
    onDismissed: (_) => onDelete(),
    background: Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFF3D57).withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFF3D57).withOpacity(0.3)),
      ),
      child: const Icon(Icons.delete_outline, color: Color(0xFFFF3D57)),
    ),
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: border),
      ),
      child: Row(children: [
        // Score circle
        Container(
          width: 50, height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: record.decisionColor.withOpacity(0.1),
            border: Border.all(
                color: record.decisionColor.withOpacity(0.4), width: 1.5),
          ),
          child: Center(child: Text(
            '${record.overallScore.toStringAsFixed(0)}',
            style: GoogleFonts.shareTechMono(
                fontSize: 13, color: record.decisionColor,
                fontWeight: FontWeight.w700),
          )),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            DateFormat('EEE dd MMM yyyy · HH:mm').format(record.timestamp),
            style: GoogleFonts.shareTechMono(fontSize: 9, color: text2),
          ),
          const SizedBox(height: 4),
          Row(children: record.results.map((r) {
            final vital = buildMedVitals().firstWhere(
                    (v) => v.id == r.id,
                orElse: () => buildMedVitals().first);
            return Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Tooltip(
                message: '${vital.title}: ${r.level.label}',
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: r.level.dimColor,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text(vital.iconEmoji,
                      style: const TextStyle(fontSize: 12)),
                ),
              ),
            );
          }).toList()),
        ])),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: record.decisionColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: record.decisionColor.withOpacity(0.4)),
          ),
          child: Text(
            isAr
                ? (record.isGo ? 'مسموح'
                : record.isCaution ? 'تحذير' : 'ممنوع')
                : record.decisionLabel,
            style: GoogleFonts.shareTechMono(
                fontSize: 10, color: record.decisionColor,
                fontWeight: FontWeight.w700),
          ),
        ),
      ]),
    ),
  );
}

extension _MedAssessmentExt on MedicalAssessment {
  double get overallScore {
    if (results.isEmpty) return 0;
    final total = results.fold(0, (s, r) => s + r.level.riskPoints);
    final max   = results.length * MedLevel.veryDangerous.riskPoints;
    return (total / max * 100).clamp(0, 100);
  }
}