// lib/screens/report_screen.dart — Light + Dark mode support
// ══════════════════════════════════════════════════════════════

import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:check_list_stress/screens/pilot_eval_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../features/export/pdf_export_service.dart';
import '../models/models.dart';
import '../models/scoring.dart';
import '../models/ai_recommendations.dart';
import '../theme/app_theme_colors.dart';
import '../widgets/widgets.dart';
import 'camera_screen.dart';
import 'decide_screen.dart';
import 'pilot_info_screen.dart';

// ══════════════════════════════════════════════════════════════
// REPORT SCREEN
// ══════════════════════════════════════════════════════════════

class ReportScreen extends StatefulWidget {
  final List<ImsafeItem> imsafe;
  final List<PaveItem> pave;
  final List<DecideStep> decide;
  final List<HazardEntry> hazards;
  final bool showArabic;
  final VoidCallback onRestart;
  final PilotInfo? pilotInfo;
  final PilotEvalController? pilotEvalController;

  const ReportScreen({
    super.key,
    required this.imsafe,
    required this.pave,
    required this.decide,
    this.hazards = const [],
    required this.showArabic,
    required this.onRestart,
    this.pilotInfo,
    this.pilotEvalController,
  });

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen>
    with SingleTickerProviderStateMixin {
  late PilotScore _score;
  late AnimationController _animCtrl;
  late Animation<double> _scoreAnim;
  bool _showDetails = false;
  Map<String, dynamic>? _faceAnalysis;
  bool _exportingPdf = false;

  @override
  void initState() {
    super.initState();
    _score = PilotScore.fromAssessment(
      imsafe: widget.imsafe,
      pave: widget.pave,
      decide: widget.decide,
    );
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1800));
    _scoreAnim = Tween<double>(begin: 0, end: _score.performanceScore).animate(
        CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _animCtrl.forward();
    });
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _exportPdf() async {
    setState(() => _exportingPdf = true);
    try {
      await PdfExportService.generateAndPrint(
        imsafe: widget.imsafe,
        pave: widget.pave,
        decide: widget.decide,
        hazards: widget.hazards,
        score: _score,
        faceAnalysis: _faceAnalysis,
        showArabic: widget.showArabic,
        pilotInfo: widget.pilotInfo,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('PDF export error: $e'),
          backgroundColor: AppThemeColors.red,
        ));
      }
    } finally {
      if (mounted) setState(() => _exportingPdf = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final decision = _score.finalDecision;
    final now = DateFormat('dd MMM yyyy — HH:mm').format(DateTime.now());

    return Directionality(
      textDirection: widget.showArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: c.bg,
        appBar: AppBar(
          backgroundColor: c.surface,
          elevation: 0,
          title: Text(
            widget.showArabic
                ? 'تقرير القرار النهائي'
                : 'FINAL DECISION REPORT',
            style: GoogleFonts.shareTechMono(
                color: AppThemeColors.cyan, letterSpacing: 1),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: c.border),
          ),
          actions: [
            _exportingPdf
                ? const Padding(
                    padding: EdgeInsets.only(right: 12),
                    child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: AppThemeColors.cyan)))
                : IconButton(
                    icon: const Icon(Icons.picture_as_pdf_outlined, size: 20),
                    tooltip: widget.showArabic ? 'تصدير PDF' : 'Export PDF',
                    onPressed: _exportPdf,
                  ),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Center(
                child: Text(now,
                    style: GoogleFonts.shareTechMono(
                        fontSize: 8, color: c.textTertiary, letterSpacing: 1)),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 0)
          ,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── 1. DECISION BANNER ────────────────────────
              _DecisionBanner(
                decision: decision,
                score: _score,
                showArabic: widget.showArabic,
                scoreAnim: _scoreAnim,
              ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2),
              const SizedBox(height: 16),

              // ── 2. REASONS ────────────────────────────────
              if (_score.decisionReasons.isNotEmpty) ...[
                _ReasonsPanel(
                  reasons: _score.decisionReasons,
                  decision: decision,
                  showArabic: widget.showArabic,
                ).animate().fadeIn(delay: 300.ms),
                const SizedBox(height: 16),
              ],

              // ── 3. PERFORMANCE GAUGE ──────────────────────
              _PerformanceGauge(
                score: _score,
                anim: _scoreAnim,
                showArabic: widget.showArabic,
              ).animate().fadeIn(delay: 400.ms),
              const SizedBox(height: 16),

              // ── 4. BAR CHART ──────────────────────────────
              _ComponentBarChart(score: _score, showArabic: widget.showArabic)
                  .animate()
                  .fadeIn(delay: 500.ms),
              const SizedBox(height: 16),

              // ── 5. RADAR CHART ────────────────────────────
              _RadarChart(score: _score, showArabic: widget.showArabic)
                  .animate()
                  .fadeIn(delay: 600.ms),
              const SizedBox(height: 16),

              // ── 6. KPI CARDS ──────────────────────────────
              _KpiRow(score: _score, showArabic: widget.showArabic)
                  .animate()
                  .fadeIn(delay: 700.ms),
              const SizedBox(height: 16),

              if (widget.pilotEvalController != null &&
                  widget.pilotEvalController!.totalRated > 0) ...[
                _PilotEvalSummaryPanel(
                  controller: widget.pilotEvalController!,
                  showArabic: widget.showArabic,
                ).animate().fadeIn(delay: 720.ms),
                const SizedBox(height: 16),
              ],

              // ── 7. HAZARD SUMMARY ─────────────────────────
              if (widget.hazards.isNotEmpty) ...[
                _HazardSummaryPanel(
                  hazards: widget.hazards,
                  showArabic: widget.showArabic,
                ).animate().fadeIn(delay: 750.ms),
                const SizedBox(height: 16),
              ],

              // ── 8. DETAILS TOGGLE ─────────────────────────
              GestureDetector(
                onTap: () => setState(() => _showDetails = !_showDetails),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: c.surfaceAlt,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: c.border),
                  ),
                  child: Row(children: [
                    Expanded(
                      child: Text(
                        widget.showArabic
                            ? (_showDetails
                                ? 'إخفاء التفاصيل'
                                : 'عرض التفاصيل الكاملة')
                            : (_showDetails
                                ? 'HIDE DETAILS'
                                : 'SHOW FULL BREAKDOWN'),
                        style: GoogleFonts.shareTechMono(
                            fontSize: 11,
                            color: AppThemeColors.cyan,
                            letterSpacing: 1.5),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(_showDetails ? Icons.expand_less : Icons.expand_more,
                        size: 18, color: AppThemeColors.cyan),
                  ]),
                ),
              ).animate().fadeIn(delay: 800.ms),

              if (_showDetails) ...[
                const SizedBox(height: 14),
                _ImsafeDetail(
                        imsafe: widget.imsafe, showArabic: widget.showArabic)
                    .animate()
                    .fadeIn(),
                const SizedBox(height: 14),
                _PaveDetail(pave: widget.pave, showArabic: widget.showArabic)
                    .animate()
                    .fadeIn(),
                const SizedBox(height: 14),
                _DecideDetail(
                        decide: widget.decide, showArabic: widget.showArabic)
                    .animate()
                    .fadeIn(),
              ],
              const SizedBox(height: 24),

              // ── 9. AI RECOMMENDATIONS ─────────────────────
              _AiRecsPanel(score: _score, showArabic: widget.showArabic)
                  .animate()
                  .fadeIn(delay: 850.ms),
              const SizedBox(height: 16),

              // ── 10. FACE ANALYSIS RESULT ──────────────────
              if (_faceAnalysis != null) ...[
                _FaceAnalysisResultPanel(
                        result: _faceAnalysis!, showArabic: widget.showArabic)
                    .animate()
                    .fadeIn(),
                const SizedBox(height: 16),
              ],

              // ── 11. CAMERA BUTTON ─────────────────────────
              if (_faceAnalysis == null)
                OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => CameraAnalysisScreen(
                        showArabic: widget.showArabic,
                        onAnalysisComplete: (result) {
                          setState(() => _faceAnalysis = result);
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.camera_alt_outlined, size: 16),
                  label: Text(
                    widget.showArabic
                        ? '🤖 إضافة تحليل الوجه'
                        : '🤖 ADD FACE ANALYSIS',
                    style: GoogleFonts.shareTechMono(
                        fontSize: 11, letterSpacing: 1.5),
                    overflow: TextOverflow.ellipsis,
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppThemeColors.cyan,
                    side: BorderSide(color: c.border),
                    minimumSize: const Size(double.infinity, 46),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ).animate().fadeIn(delay: 880.ms),
              const SizedBox(height: 16),

              // ── 12. RESTART ───────────────────────────────
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: widget.onRestart,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppThemeColors.cyan.withOpacity(0.15),
                    foregroundColor: AppThemeColors.cyan,
                    side: const BorderSide(color: AppThemeColors.cyan),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                  child: Text(
                    widget.showArabic
                        ? '🔄 بدء تقييم جديد'
                        : '🔄 START NEW ASSESSMENT',
                    style: GoogleFonts.shareTechMono(
                        fontSize: 13, letterSpacing: 2),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ).animate().fadeIn(delay: 900.ms),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// HAZARD SUMMARY PANEL
// ══════════════════════════════════════════════════════════════

class _HazardSummaryPanel extends StatelessWidget {
  final List<HazardEntry> hazards;
  final bool showArabic;
  const _HazardSummaryPanel({required this.hazards, required this.showArabic});

  bool get _ar => showArabic;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final evaluated = hazards.where((h) => h.isEvaluated).length;
    final mitigated = hazards.where((h) => h.hasResidual).length;
    final critical = hazards
        .where((h) => h.isEvaluated && h.riskLevel == RiskLevel.critical)
        .length;
    final high = hazards
        .where((h) => h.isEvaluated && h.riskLevel == RiskLevel.high)
        .length;

    return APanel(
      title: _ar ? 'سجل المخاطر' : 'HAZARD REGISTER',
      accent: AppThemeColors.red,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          _StatBox(
              '${hazards.length}', _ar ? 'إجمالي' : 'Total', c.textSecondary),
          _StatBox('$evaluated', _ar ? 'مُقيَّم' : 'Evaluated',
              AppThemeColors.amber),
          _StatBox('$mitigated', _ar ? 'مُعالَج' : 'Mitigated',
              AppThemeColors.green),
          if (critical > 0)
            _StatBox(
                '$critical', _ar ? 'حرج' : 'Critical', AppThemeColors.purple),
          if (high > 0)
            _StatBox('$high', _ar ? 'مرتفع' : 'High', AppThemeColors.red),
        ]),
        const SizedBox(height: 14),
        ...hazards.asMap().entries.map((e) {
          final h = e.value;
          final riskC = h.isEvaluated ? h.riskLevel.color : c.textTertiary;
          final resC = h.hasResidual ? h.residualLevel.color : c.textTertiary;

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: c.elevated,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: h.isEvaluated
                    ? h.riskLevel.color.withOpacity(0.35)
                    : c.border,
              ),
            ),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppThemeColors.red.withOpacity(0.12),
                    border:
                        Border.all(color: AppThemeColors.red.withOpacity(0.4)),
                  ),
                  child: Center(
                    child: Text('${e.key + 1}',
                        style: GoogleFonts.shareTechMono(
                            fontSize: 9,
                            color: AppThemeColors.red,
                            fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(h.hazard,
                      style: TextStyle(
                          fontSize: 13,
                          color: c.textPrimary,
                          fontWeight: FontWeight.w600)),
                ),
              ]),
              if (h.isEvaluated) ...[
                const SizedBox(height: 8),
                Row(children: [
                  _MiniMetric('S', '${h.severity}', riskC),
                  const SizedBox(width: 10),
                  _MiniMetric('L', '${h.likelihood}', riskC),
                  const SizedBox(width: 10),
                  _MiniMetric('S×L', '${h.riskScore}', riskC),
                  const SizedBox(width: 8),
                  _RiskBadgeInline(h.riskLevel.label(_ar), h.riskLevel.color),
                  if (h.hasResidual) ...[
                    const SizedBox(width: 8),
                    Text('→', style: TextStyle(color: c.textTertiary)),
                    const SizedBox(width: 8),
                    _MiniMetric('Res.', '${h.residualScore}', resC),
                    const SizedBox(width: 4),
                    _RiskBadgeInline(h.residualLevel.label(_ar), resC),
                  ],
                ]),
              ],
              if (h.mitigation.isNotEmpty) ...[
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: c.surface,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: c.border),
                  ),
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.shield_outlined,
                            size: 12, color: AppThemeColors.green),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(h.mitigation,
                              style: TextStyle(
                                  fontSize: 11,
                                  color: c.textSecondary,
                                  height: 1.4)),
                        ),
                      ]),
                ),
              ],
            ]),
          )
              .animate()
              .fadeIn(
                  duration: 280.ms, delay: Duration(milliseconds: e.key * 60))
              .slideY(
                  begin: 0.08,
                  duration: 280.ms,
                  delay: Duration(milliseconds: e.key * 60));
        }),
      ]),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String value, label;
  final Color color;
  const _StatBox(this.value, this.label, this.color);

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          margin: const EdgeInsets.only(right: 6),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.06),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Column(children: [
            Text(value,
                style: GoogleFonts.shareTechMono(
                    fontSize: 18, color: color, fontWeight: FontWeight.w700)),
            Text(label,
                style: TextStyle(
                    fontSize: 9,
                    color: context.appColors.textTertiary,
                    letterSpacing: 0.5)),
          ]),
        ),
      );
}

class _MiniMetric extends StatelessWidget {
  final String label, value;
  final Color color;
  const _MiniMetric(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) =>
      Column(mainAxisSize: MainAxisSize.min, children: [
        Text(value,
            style: GoogleFonts.shareTechMono(
                fontSize: 14, color: color, fontWeight: FontWeight.w700)),
        Text(label,
            style:
                TextStyle(fontSize: 8, color: context.appColors.textTertiary)),
      ]);
}

class _RiskBadgeInline extends StatelessWidget {
  final String text;
  final Color color;
  const _RiskBadgeInline(this.text, this.color);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Text(text,
            style: GoogleFonts.shareTechMono(
                fontSize: 8, color: color, fontWeight: FontWeight.w700)),
      );
}

// ══════════════════════════════════════════════════════════════
// DECISION BANNER
// ══════════════════════════════════════════════════════════════

class _DecisionBanner extends StatelessWidget {
  final FlightDecision decision;
  final PilotScore score;
  final bool showArabic;
  final Animation<double> scoreAnim;

  const _DecisionBanner({
    required this.decision,
    required this.score,
    required this.showArabic,
    required this.scoreAnim,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final dc = decision.color;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: dc.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: dc.withOpacity(0.4), width: 1.5),
      ),
      child: Column(children: [
        Text(decision.emoji, style: const TextStyle(fontSize: 52)),
        const SizedBox(height: 10),
        Text(
          showArabic ? decision.arabicLabel : decision.label,
          style: GoogleFonts.shareTechMono(
              fontSize: 28,
              color: dc,
              fontWeight: FontWeight.w700,
              letterSpacing: 4),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: score.performanceColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: score.performanceColor.withOpacity(0.3)),
          ),
          child: AnimatedBuilder(
            animation: scoreAnim,
            builder: (_, __) => Text(
              '${showArabic ? "الأداء" : "PERFORMANCE"}: ${score.performanceLabel}  ${scoreAnim.value.toInt()}%',
              style: GoogleFonts.shareTechMono(
                  fontSize: 11,
                  color: score.performanceColor,
                  letterSpacing: 1.5),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          _MiniStat(
              'IMSAFE',
              '${score.imsafeScore}/6',
              score.imsafeScore < 4
                  ? AppThemeColors.green
                  : score.imsafeScore < 8
                      ? AppThemeColors.amber
                      : AppThemeColors.red),
          Container(width: 1, height: 30, color: c.border),
          _MiniStat(
              'PAVE',
              '${score.paveScore}/20',
              score.paveMissedChecks < 4
                  ? AppThemeColors.green
                  : score.paveMissedChecks < 8
                      ? AppThemeColors.amber
                      : AppThemeColors.red),
          Container(width: 1, height: 30, color: c.border),
          _MiniStat(
              'DECIDE',
              '${score.decideScore}/6',
              score.decideScore >= 5
                  ? AppThemeColors.green
                  : score.decideScore >= 3
                      ? AppThemeColors.amber
                      : AppThemeColors.red),
        ]),
      ]),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label, value;
  final Color color;
  const _MiniStat(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) => Column(children: [
        Text(value,
            style: GoogleFonts.shareTechMono(
                fontSize: 20, color: color, fontWeight: FontWeight.w700)),
        Text(label,
            style: TextStyle(
                fontSize: 9,
                color: context.appColors.textTertiary,
                letterSpacing: 1)),
      ]);
}

// ══════════════════════════════════════════════════════════════
// REASONS PANEL
// ══════════════════════════════════════════════════════════════

class _ReasonsPanel extends StatelessWidget {
  final List<String> reasons;
  final FlightDecision decision;
  final bool showArabic;

  const _ReasonsPanel({
    required this.reasons,
    required this.decision,
    required this.showArabic,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final dc = decision.color;
    return Container(
      decoration: BoxDecoration(
        color: dc.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: dc.withOpacity(0.3)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
          child: Text(
            showArabic ? '⚠ أسباب القرار' : '⚠ DECISION FACTORS',
            style: GoogleFonts.shareTechMono(
                fontSize: 11, color: dc, letterSpacing: 2),
          ),
        ),
        Divider(height: 1, color: c.border),
        ...reasons.map((r) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child:
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  margin: const EdgeInsets.only(top: 5),
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: dc),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(r,
                      style: TextStyle(
                          fontSize: 12, color: c.textSecondary, height: 1.4)),
                ),
              ]),
            )),
        const SizedBox(height: 4),
      ]),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// PERFORMANCE GAUGE
// ══════════════════════════════════════════════════════════════

class _PerformanceGauge extends StatelessWidget {
  final PilotScore score;
  final Animation<double> anim;
  final bool showArabic;

  const _PerformanceGauge({
    required this.score,
    required this.anim,
    required this.showArabic,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return APanel(
      title: showArabic ? 'مؤشر الأداء الكلي' : 'OVERALL PERFORMANCE INDEX',
      accent: score.performanceColor,
      child: Column(children: [
        SizedBox(
          height: 160,
          child: AnimatedBuilder(
            animation: anim,
            builder: (_, __) => CustomPaint(
              size: const Size(double.infinity, 160),
              painter: _GaugePainter(
                value: anim.value / 100.0,
                color: score.performanceColor,
                score: anim.value.toInt(),
                label: score.performanceLabel,
                trackColor: c.elevated,
                labelColor: c.textSecondary,
                bgColor: c.bg,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('0', style: TextStyle(fontSize: 9, color: AppThemeColors.red)),
          Text('35',
              style: TextStyle(fontSize: 9, color: AppThemeColors.amber)),
          Text('55',
              style: TextStyle(fontSize: 9, color: const Color(0xFFFFB020))),
          Text('70', style: TextStyle(fontSize: 9, color: AppThemeColors.cyan)),
          Text('100',
              style: TextStyle(fontSize: 9, color: AppThemeColors.green)),
        ]),
        const SizedBox(height: 2),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('CRITICAL',
              style: TextStyle(
                  fontSize: 7, color: AppThemeColors.red, letterSpacing: 0.5)),
          Text('POOR',
              style: TextStyle(
                  fontSize: 7,
                  color: AppThemeColors.amber,
                  letterSpacing: 0.5)),
          Text('MARGINAL',
              style: TextStyle(
                  fontSize: 7,
                  color: const Color(0xFFFFB020),
                  letterSpacing: 0.5)),
          Text('GOOD',
              style: TextStyle(
                  fontSize: 7, color: AppThemeColors.cyan, letterSpacing: 0.5)),
          Text('EXCELLENT',
              style: TextStyle(
                  fontSize: 7,
                  color: AppThemeColors.green,
                  letterSpacing: 0.5)),
        ]),
      ]),
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double value;
  final Color color, trackColor, labelColor, bgColor;
  final int score;
  final String label;

  const _GaugePainter({
    required this.value,
    required this.color,
    required this.score,
    required this.label,
    required this.trackColor,
    required this.labelColor,
    required this.bgColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height * 0.82;
    final r = math.min(size.width * 0.40, size.height * 0.75);

    canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: r),
        math.pi,
        math.pi,
        false,
        Paint()
          ..color = trackColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 18
          ..strokeCap = StrokeCap.round);

    final segs = [
      (const Color(0xFFFF3D57), 0.0, 0.35),
      (const Color(0xFFFF6B35), 0.35, 0.55),
      (const Color(0xFFFFB020), 0.55, 0.70),
      (const Color(0xFF00C8F0), 0.70, 0.85),
      (const Color(0xFF00E676), 0.85, 1.0),
    ];
    for (final s in segs) {
      canvas.drawArc(
          Rect.fromCircle(center: Offset(cx, cy), radius: r),
          math.pi + math.pi * (s.$2 as double),
          math.pi * ((s.$3 as double) - (s.$2 as double)),
          false,
          Paint()
            ..color = (s.$1 as Color).withOpacity(0.22)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 14
            ..strokeCap = StrokeCap.butt);
    }

    if (value > 0) {
      canvas.drawArc(
          Rect.fromCircle(center: Offset(cx, cy), radius: r),
          math.pi,
          math.pi * value.clamp(0.0, 1.0),
          false,
          Paint()
            ..color = color
            ..style = PaintingStyle.stroke
            ..strokeWidth = 16
            ..strokeCap = StrokeCap.round);
    }

    final angle = math.pi + math.pi * value.clamp(0.0, 1.0);
    canvas.drawLine(
        Offset(cx, cy),
        Offset(
            cx + math.cos(angle) * r * 0.76, cy + math.sin(angle) * r * 0.76),
        Paint()
          ..color = color
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round);
    canvas.drawCircle(Offset(cx, cy), 6, Paint()..color = color);
    canvas.drawCircle(Offset(cx, cy), 4, Paint()..color = bgColor);

    final tp = TextPainter(
      text: TextSpan(
          text: '$score%',
          style: TextStyle(
              fontFamily: 'ShareTechMono',
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: color)),
      textDirection: ui.TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(cx - tp.width / 2, cy - tp.height - 12));

    final lp = TextPainter(
      text: TextSpan(
          text: label,
          style:
              TextStyle(fontSize: 10, color: labelColor, letterSpacing: 1.5)),
      textDirection: ui.TextDirection.ltr,
    )..layout();
    lp.paint(canvas, Offset(cx - lp.width / 2, cy + 6));
  }

  @override
  bool shouldRepaint(_GaugePainter old) => old.value != value;
}

// ══════════════════════════════════════════════════════════════
// COMPONENT BAR CHART
// ══════════════════════════════════════════════════════════════

class _ComponentBarChart extends StatelessWidget {
  final PilotScore score;
  final bool showArabic;
  const _ComponentBarChart({required this.score, required this.showArabic});

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return APanel(
      title: showArabic ? 'تحليل المكونات' : 'COMPONENT ANALYSIS',
      accent: AppThemeColors.cyan,
      child: Column(
        children: score.barChartData
            .map((bar) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Expanded(
                            child: Text(bar.label.replaceAll('\n', ' '),
                                style: TextStyle(
                                    fontSize: 11, color: c.textSecondary)),
                          ),
                          Text('${bar.value.toInt()}%',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: bar.color,
                                  fontFamily: 'ShareTechMono',
                                  fontWeight: FontWeight.w700)),
                        ]),
                        const SizedBox(height: 5),
                        Stack(children: [
                          Container(
                              height: 10,
                              decoration: BoxDecoration(
                                  color: c.elevated,
                                  borderRadius: BorderRadius.circular(5))),
                          FractionallySizedBox(
                            widthFactor: (bar.value / 100).clamp(0.0, 1.0),
                            child: Container(
                                height: 10,
                                decoration: BoxDecoration(
                                    color: bar.color,
                                    borderRadius: BorderRadius.circular(5))),
                          ),
                          FractionallySizedBox(
                            widthFactor: 0.70,
                            child: Align(
                              alignment: Alignment.topRight,
                              child: Container(
                                  width: 1.5,
                                  height: 10,
                                  color: AppThemeColors.amber.withOpacity(0.5)),
                            ),
                          ),
                        ]),
                      ]),
                ))
            .toList(),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// RADAR CHART
// ══════════════════════════════════════════════════════════════

class _RadarChart extends StatelessWidget {
  final PilotScore score;
  final bool showArabic;
  const _RadarChart({required this.score, required this.showArabic});

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return APanel(
      title: showArabic
          ? 'مخطط الأداء متعدد المحاور'
          : 'MULTI-AXIS PERFORMANCE RADAR',
      accent: AppThemeColors.purple,
      child: Column(children: [
        SizedBox(
          height: 220,
          child: CustomPaint(
            size: const Size(double.infinity, 220),
            painter: _RadarPainter(
                data: score.radarData,
                gridColor: c.border,
                labelColor: c.textSecondary,
                bgColor: c.bg),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 14,
          runSpacing: 6,
          children: score.radarData.entries.map((e) {
            final val = (e.value * 100).toInt();
            final col = val >= 70
                ? AppThemeColors.green
                : val >= 40
                    ? AppThemeColors.amber
                    : AppThemeColors.red;
            return Row(mainAxisSize: MainAxisSize.min, children: [
              Container(
                  width: 8,
                  height: 8,
                  decoration:
                      BoxDecoration(shape: BoxShape.circle, color: col)),
              const SizedBox(width: 5),
              Text('${e.key}: $val%',
                  style: TextStyle(
                      fontSize: 10, color: col, fontFamily: 'ShareTechMono')),
            ]);
          }).toList(),
        ),
      ]),
    );
  }
}

class _RadarPainter extends CustomPainter {
  final Map<String, double> data;
  final Color gridColor, labelColor, bgColor;
  const _RadarPainter({
    required this.data,
    required this.gridColor,
    required this.labelColor,
    required this.bgColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = math.min(cx, cy) * 0.75;
    final keys = data.keys.toList();
    final vals = data.values.toList();
    final n = keys.length;

    for (int ring = 1; ring <= 4; ring++) {
      canvas.drawCircle(
          Offset(cx, cy),
          r * ring / 4,
          Paint()
            ..color = gridColor.withOpacity(0.35)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.7);
    }
    for (int i = 0; i < n; i++) {
      final angle = -math.pi / 2 + 2 * math.pi * i / n;
      canvas.drawLine(
          Offset(cx, cy),
          Offset(cx + math.cos(angle) * r, cy + math.sin(angle) * r),
          Paint()
            ..color = gridColor.withOpacity(0.35)
            ..strokeWidth = 0.7);
      final lx = cx + math.cos(angle) * (r + 20);
      final ly = cy + math.sin(angle) * (r + 20);
      final tp = TextPainter(
        text: TextSpan(
            text: keys[i],
            style:
                TextStyle(fontSize: 9, color: labelColor, letterSpacing: 0.5)),
        textDirection: ui.TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(lx - tp.width / 2, ly - tp.height / 2));
    }
    final path = Path();
    for (int i = 0; i < n; i++) {
      final angle = -math.pi / 2 + 2 * math.pi * i / n;
      final rv = r * vals[i].clamp(0.0, 1.0);
      final x = cx + math.cos(angle) * rv;
      final y = cy + math.sin(angle) * rv;
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    path.close();
    canvas.drawPath(
        path,
        Paint()
          ..color = const Color(0xFFB060FF).withOpacity(0.12)
          ..style = PaintingStyle.fill);
    canvas.drawPath(
        path,
        Paint()
          ..color = const Color(0xFFB060FF)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..strokeJoin = StrokeJoin.round);
    for (int i = 0; i < n; i++) {
      final angle = -math.pi / 2 + 2 * math.pi * i / n;
      final rv = r * vals[i].clamp(0.0, 1.0);
      final x = cx + math.cos(angle) * rv;
      final y = cy + math.sin(angle) * rv;
      final v = (vals[i] * 100).toInt();
      final pc = v >= 70
          ? AppThemeColors.green
          : v >= 40
              ? AppThemeColors.amber
              : AppThemeColors.red;
      canvas.drawCircle(Offset(x, y), 5, Paint()..color = pc);
      canvas.drawCircle(Offset(x, y), 3, Paint()..color = bgColor);
    }
  }

  @override
  bool shouldRepaint(_RadarPainter old) => old.data != data;
}

// ══════════════════════════════════════════════════════════════
// KPI ROW
// ══════════════════════════════════════════════════════════════

class _KpiRow extends StatelessWidget {
  final PilotScore score;
  final bool showArabic;
  const _KpiRow({required this.score, required this.showArabic});

  @override
  Widget build(BuildContext context) {
    final cards = [
      _KpiCard(
          icon: '🧠',
          label: showArabic ? 'الصحة الذهنية' : 'Mental Fitness',
          value: score.hasStress || score.hasEmotions ? 'AT RISK' : 'OK',
          color: score.hasStress || score.hasEmotions
              ? AppThemeColors.red
              : AppThemeColors.green),
      _KpiCard(
          icon: '💪',
          label: showArabic ? 'اللياقة البدنية' : 'Physical Fitness',
          value:
              score.hasAlcohol || score.hasCriticalIllness || score.hasFatigue
                  ? 'AT RISK'
                  : 'OK',
          color:
              score.hasAlcohol || score.hasCriticalIllness || score.hasFatigue
                  ? AppThemeColors.red
                  : AppThemeColors.green),
      _KpiCard(
          icon: '✈️',
          label: showArabic ? 'جاهزية الطائرة' : 'Aircraft Ready',
          value: score.paveMissedChecks == 0
              ? 'READY'
              : 'GAPS: ${score.paveMissedChecks}',
          color: score.paveMissedChecks == 0
              ? AppThemeColors.green
              : score.paveMissedChecks < 4
                  ? AppThemeColors.amber
                  : AppThemeColors.red),
      _KpiCard(
          icon: '🎯',
          label: showArabic ? 'عملية القرار' : 'Decision Quality',
          value: score.decideScore >= 5
              ? 'SOLID'
              : score.decideScore >= 3
                  ? 'PARTIAL'
                  : 'WEAK',
          color: score.decideScore >= 5
              ? AppThemeColors.green
              : score.decideScore >= 3
                  ? AppThemeColors.amber
                  : AppThemeColors.red),
    ];
    return LayoutBuilder(builder: (context, constraints) {
      final w = (constraints.maxWidth - 8) / 2;
      return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: cards.map((c) => SizedBox(width: w, child: c)).toList());
    });
  }
}

class _KpiCard extends StatelessWidget {
  final String icon, label, value;
  final Color color;
  const _KpiCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(children: [
        Text(icon, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 8),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label,
                style: TextStyle(
                    fontSize: 9, color: c.textTertiary, letterSpacing: 1),
                overflow: TextOverflow.ellipsis),
            Text(value,
                style: GoogleFonts.shareTechMono(
                    fontSize: 13, color: color, fontWeight: FontWeight.w700),
                overflow: TextOverflow.ellipsis),
          ]),
        ),
      ]),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// DETAIL PANELS
// ══════════════════════════════════════════════════════════════

class _ImsafeDetail extends StatelessWidget {
  final List<ImsafeItem> imsafe;
  final bool showArabic;
  const _ImsafeDetail({required this.imsafe, required this.showArabic});

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return APanel(
      title: 'IMSAFE BREAKDOWN',
      accent: AppThemeColors.cyan,
      child: Column(
        children: imsafe
            .map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(children: [
                    Text(item.iconEmoji, style: const TextStyle(fontSize: 18)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(showArabic ? item.arabicTitle : item.title,
                                style: TextStyle(
                                    fontSize: 13, color: c.textPrimary)),
                            if (item.notes.isNotEmpty)
                              Text(item.notes,
                                  style: TextStyle(
                                      fontSize: 11, color: c.textSecondary)),
                          ]),
                    ),
                    RiskBadge(item.rating),
                  ]),
                ))
            .toList(),
      ),
    );
  }
}

class _PaveDetail extends StatelessWidget {
  final List<PaveItem> pave;
  final bool showArabic;
  const _PaveDetail({required this.pave, required this.showArabic});

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final colors = [
      AppThemeColors.cyan,
      AppThemeColors.green,
      AppThemeColors.amber,
      AppThemeColors.red,
    ];
    return APanel(
      title: 'PAVE COMPLETION',
      accent: AppThemeColors.green,
      child: Column(
        children: pave.asMap().entries.map((e) {
          final item = e.value;
          final checked = item.checkpoints.where((cp) => cp.checked).length;
          final pct = checked / item.checkpoints.length;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text(item.iconEmoji, style: const TextStyle(fontSize: 13)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(showArabic ? item.arabicTitle : item.title,
                      style: TextStyle(fontSize: 12, color: c.textPrimary)),
                ),
                Text('$checked/${item.checkpoints.length}',
                    style: TextStyle(
                        fontSize: 11,
                        color: colors[e.key],
                        fontFamily: 'ShareTechMono')),
              ]),
              const SizedBox(height: 4),
              AProgressBar(value: pct, color: colors[e.key], label: ''),
            ]),
          );
        }).toList(),
      ),
    );
  }
}

class _DecideDetail extends StatelessWidget {
  final List<DecideStep> decide;
  final bool showArabic;
  const _DecideDetail({required this.decide, required this.showArabic});

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return APanel(
      title: 'DECIDE LOG',
      accent: AppThemeColors.purple,
      child: Column(
        children: decide
            .map((step) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        StepCircle(
                            label: step.key.length > 1 ? step.key[0] : step.key,
                            color: step.color,
                            completed: step.completed),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(showArabic ? step.arabicTitle : step.title,
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: step.color,
                                        fontWeight: FontWeight.w600)),
                                if (step.userInput.isNotEmpty)
                                  Text(step.userInput,
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: c.textSecondary,
                                          height: 1.4))
                                else
                                  Text(
                                    showArabic
                                        ? (step.skipped
                                            ? '(تم تخطي الخطوة)'
                                            : '(لم تُدخل ملاحظات)')
                                        : (step.skipped
                                            ? '(step skipped)'
                                            : '(no notes entered)'),
                                    style: TextStyle(
                                        fontSize: 11, color: c.textTertiary),
                                  ),
                              ]),
                        ),
                      ]),
                ))
            .toList(),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// AI RECOMMENDATIONS PANEL
// ══════════════════════════════════════════════════════════════

class _AiRecsPanel extends StatelessWidget {
  final PilotScore score;
  final bool showArabic;
  const _AiRecsPanel({required this.score, required this.showArabic});

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final recs = AiRecommendationEngine.generate(score);
    if (recs.isEmpty) return const SizedBox.shrink();

    return APanel(
      title: showArabic
          ? 'توصيات الذكاء الاصطناعي الطبية'
          : 'AI MEDICAL RECOMMENDATIONS',
      accent: AppThemeColors.cyan,
      child: Column(
        children: recs.map((rec) {
          final color = rec.priority.color;
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color.withOpacity(0.2)),
            ),
            child: IntrinsicHeight(
              child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      width: rec.priority == RecPriority.critical ? 4 : 2,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(8),
                            bottomLeft: Radius.circular(8)),
                      ),
                    ),
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
                              child: Row(children: [
                                Text(rec.icon,
                                    style: const TextStyle(fontSize: 18)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                                color: color.withOpacity(0.15),
                                                borderRadius:
                                                    BorderRadius.circular(3)),
                                            child: Text(rec.priority.label,
                                                style: TextStyle(
                                                    fontSize: 8,
                                                    color: color,
                                                    fontWeight: FontWeight.w700,
                                                    letterSpacing: 1)),
                                          ),
                                          const SizedBox(width: 8),
                                          if (rec.daysUntilRecheck == 0)
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                      vertical: 2),
                                              decoration: BoxDecoration(
                                                  color: AppThemeColors.red
                                                      .withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(3)),
                                              child: const Text('IMMEDIATE',
                                                  style: TextStyle(
                                                      fontSize: 8,
                                                      color: AppThemeColors.red,
                                                      letterSpacing: 0.5)),
                                            )
                                          else if (rec.daysUntilRecheck > 0)
                                            Text(
                                                'Recheck in ${rec.daysUntilRecheck}d',
                                                style: TextStyle(
                                                    fontSize: 8,
                                                    color: c.textTertiary)),
                                        ]),
                                        const SizedBox(height: 4),
                                        Text(
                                            showArabic
                                                ? rec.titleArabic
                                                : rec.title,
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: color,
                                                fontWeight: FontWeight.w700)),
                                      ]),
                                ),
                              ]),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                              child: Text(
                                  showArabic ? rec.detailArabic : rec.detail,
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: c.textSecondary,
                                      height: 1.5)),
                            ),
                            Container(
                              margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: c.elevated,
                                borderRadius: BorderRadius.circular(6),
                                border:
                                    Border.all(color: color.withOpacity(0.2)),
                              ),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(children: [
                                      Icon(Icons.assignment_outlined,
                                          size: 12, color: color),
                                      const SizedBox(width: 6),
                                      Text(
                                        showArabic
                                            ? 'الإجراءات المطلوبة:'
                                            : 'REQUIRED ACTIONS:',
                                        style: TextStyle(
                                            fontSize: 9,
                                            color: color,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0.5),
                                      ),
                                    ]),
                                    const SizedBox(height: 5),
                                    Text(
                                      showArabic
                                          ? rec.actionArabic
                                          : rec.actionRequired,
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: c.textSecondary,
                                          height: 1.5),
                                    ),
                                  ]),
                            ),
                          ]),
                    ),
                  ]),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// FACE ANALYSIS RESULT PANEL
// ══════════════════════════════════════════════════════════════

class _FaceAnalysisResultPanel extends StatelessWidget {
  final Map<String, dynamic> result;
  final bool showArabic;
  const _FaceAnalysisResultPanel(
      {required this.result, required this.showArabic});

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final stressLevel = result['stressLevel'] as String;
    final fatigueLevel = result['fatigueLevel'] as String;
    final stressIdx = result['stressIndex'] as int;
    final fatigueIdx = result['fatigueIndex'] as int;
    final eyeScore = result['eyeOpennessScore'] as int;
    final confidence = result['confidence'] as int;
    final stressColor = AppThemeColors.red;
    final fatigueColor = AppThemeColors.amber;

    return APanel(
      title: showArabic
          ? 'نتائج تحليل الوجه — ذكاء اصطناعي'
          : 'AI FACE ANALYSIS RESULTS',
      accent: AppThemeColors.purple,
      child: Column(children: [
        Row(children: [
          _MetricChip(
              icon: '🧠',
              label: showArabic ? 'إجهاد' : 'STRESS',
              value: stressLevel,
              score: stressIdx,
              color: stressColor),
          const SizedBox(width: 8),
          _MetricChip(
              icon: '😴',
              label: showArabic ? 'إرهاق' : 'FATIGUE',
              value: fatigueLevel,
              score: fatigueIdx,
              color: fatigueColor),
          const SizedBox(width: 8),
          _MetricChip(
              icon: '👁️',
              label: showArabic ? 'انتباه' : 'ALERT',
              value: eyeScore > 70
                  ? 'HIGH'
                  : eyeScore > 40
                      ? 'MED'
                      : 'LOW',
              score: eyeScore,
              color: eyeScore > 70
                  ? AppThemeColors.green
                  : eyeScore > 40
                      ? AppThemeColors.amber
                      : AppThemeColors.red),
        ]),
        const SizedBox(height: 10),
        AProgressBar(
            value: stressIdx / 100,
            color: stressColor,
            label: '${showArabic ? "إجهاد" : "Stress"}: $stressIdx%'),
        const SizedBox(height: 5),
        AProgressBar(
            value: fatigueIdx / 100,
            color: fatigueColor,
            label: '${showArabic ? "إرهاق" : "Fatigue"}: $fatigueIdx%'),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: c.elevated,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: c.border),
          ),
          child: Row(children: [
            const Text('🤖', style: TextStyle(fontSize: 13)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                showArabic
                    ? 'تحليل AI • ثقة: $confidence% • بيانات مساعدة فقط'
                    : 'AI Analysis • Confidence: $confidence% • Supplementary data only',
                style: TextStyle(fontSize: 10, color: c.textTertiary),
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}

class _MetricChip extends StatelessWidget {
  final String icon, label, value;
  final int score;
  final Color color;
  const _MetricChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.score,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.06),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Column(children: [
            Text(icon, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 3),
            Text(value,
                style: TextStyle(
                    fontSize: 11,
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'ShareTechMono')),
            Text('$score%',
                style: TextStyle(fontSize: 9, color: color.withOpacity(0.7))),
            Text(label,
                style: TextStyle(
                    fontSize: 8,
                    color: context.appColors.textTertiary,
                    letterSpacing: 0.5)),
          ]),
        ),
      );
}

// ══════════════════════════════════════════════════════════════
// PILOT EVAL SUMMARY PANEL
// ══════════════════════════════════════════════════════════════

class _PilotEvalSummaryPanel extends StatelessWidget {
  final PilotEvalController controller;
  final bool showArabic;
  const _PilotEvalSummaryPanel(
      {required this.controller, required this.showArabic});

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final pct = controller.overallPct;
    final pctInt = (pct * 100).toInt();
    final color = pctInt >= 80
        ? AppThemeColors.green
        : pctInt >= 60
            ? AppThemeColors.amber
            : AppThemeColors.red;

    return APanel(
      title: showArabic ? 'تقييم مستوى الطيار' : 'PILOT LEVEL ASSESSMENT',
      accent: AppThemeColors.cyan,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(showArabic ? 'المتوسط الكلي' : 'Overall Average',
                  style: TextStyle(fontSize: 11, color: c.textSecondary)),
              Text('$pctInt%',
                  style: GoogleFonts.shareTechMono(
                      fontSize: 28, color: color, fontWeight: FontWeight.bold)),
            ]),
          ),
          Text('${controller.totalRated} / ${controller.totalCriteria}',
              style: GoogleFonts.shareTechMono(
                  fontSize: 13, color: c.textSecondary)),
        ]),
        const SizedBox(height: 10),
        AProgressBar(value: pct, color: color, label: ''),
        const SizedBox(height: 12),
        for (final sec in controller.sections)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                        color: sec.color, shape: BoxShape.circle)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(showArabic ? sec.titleAr : sec.titleEn,
                      style: TextStyle(fontSize: 11, color: c.textSecondary),
                      overflow: TextOverflow.ellipsis),
                ),
                Text(
                  sec.ratedCount == 0
                      ? '--'
                      : '${(sec.averagePct * 100).toInt()}%',
                  style:
                      GoogleFonts.shareTechMono(fontSize: 11, color: sec.color),
                ),
              ]),
              const SizedBox(height: 3),
              AProgressBar(value: sec.averagePct, color: sec.color, label: ''),
            ]),
          ),
      ]),
    );
  }
}
