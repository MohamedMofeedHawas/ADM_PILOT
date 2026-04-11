// lib/features/medical/medical_assessment_screen.dart
// ══════════════════════════════════════════════════════════════
// Medical Fitness Assessment — Heart Rate, BP, Blood Sugar, Temp
// ✅ Full Light/Dark theme support
// ✅ isInitialFlow param (hides app bar when embedded in wrapper)
// ══════════════════════════════════════════════════════════════

import 'package:check_list_stress/screens/medical_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../theme/theme.dart';
import 'medical_provider.dart';

class MedicalAssessmentScreen extends StatefulWidget {
  final bool showArabic;
  final VoidCallback? onFinished;

  /// true = embedded in _InitialMedicalWrapper (skip standalone AppBar)
  final bool isInitialFlow;
  final bool wrapInScaffold;

  const MedicalAssessmentScreen({
    this.wrapInScaffold = true,
    super.key,
    required this.showArabic,
    this.onFinished,
    this.isInitialFlow = false,
  });

  @override
  State<MedicalAssessmentScreen> createState() =>
      _MedicalAssessmentScreenState();
}

class _MedicalAssessmentScreenState extends State<MedicalAssessmentScreen>
    with TickerProviderStateMixin {
  final _vitals = buildMedVitals();
  bool _refExpanded = true;
  bool _showDecision = false;
  late AnimationController _pulseCtrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  bool get _isAr => widget.showArabic;

  // ── Theme helpers ─────────────────────────────────────────
  Color _bg(BuildContext ctx) => Theme.of(ctx).brightness == Brightness.dark
      ? const Color(0xFF07090F)
      : const Color(0xFFF0F4F8);

  Color _surface(BuildContext ctx) =>
      Theme.of(ctx).brightness == Brightness.dark
          ? const Color(0xFF0E1219)
          : Colors.white;

  Color _border(BuildContext ctx) => Theme.of(ctx).brightness == Brightness.dark
      ? const Color(0xFF1E2D45)
      : const Color(0xFFD0DCE8);

  Color _text1(BuildContext ctx) => Theme.of(ctx).brightness == Brightness.dark
      ? const Color(0xFFE2EAF4)
      : const Color(0xFF0D1520);

  Color _text2(BuildContext ctx) => Theme.of(ctx).brightness == Brightness.dark
      ? const Color(0xFF6B8CAE)
      : const Color(0xFF3A5070);

  @override
  Widget build(BuildContext context) {
    final mp = context.watch<MedicalProvider>();
    final content = Stack(
      children: [
      Positioned.fill(
          child: CustomPaint(
              painter: _MedGridPainter(borderColor: _border(context)))),
      Positioned.fill(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
          child:
              Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          // ── Title (only shown in initial flow, no app bar) ──
          if (widget.isInitialFlow) ...[
            _InlineTitle(
                isAr: _isAr, text1: _text1(context), text2: _text2(context)),
            const SizedBox(height: 16),
          ],

          _SectionHeader(
                  isAr: _isAr, text1: _text1(context), text2: _text2(context))
              .animate()
              .fadeIn(duration: 500.ms)
              .slideY(begin: -0.1),
          const SizedBox(height: 16),

          _ReferencePanel(
            vitals: _vitals,
            isAr: _isAr,
            expanded: _refExpanded,
            onToggle: () => setState(() => _refExpanded = !_refExpanded),
            surface: _surface(context),
            border: _border(context),
            text1: _text1(context),
          ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
          const SizedBox(height: 20),

          ..._vitals.asMap().entries.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _VitalInputCard(
                  vital: e.value,
                  isAr: _isAr,
                  surface: _surface(context),
                  border: _border(context),
                  text1: _text1(context),
                  text2: _text2(context),
                  onChanged: (v, v2) {
                    if (v2 != null) {
                      context
                          .read<MedicalProvider>()
                          .setValue2(e.value.id, v2);
                    }
                    context.read<MedicalProvider>().setValue(e.value.id, v);
                    if (mp.allFilled) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) {
                          setState(() => _showDecision = true);
                        }
                      });
                    }
                  },
                )
                    .animate()
                    .fadeIn(
                      delay: Duration(milliseconds: 150 + e.key * 80),
                      duration: 400.ms,
                    )
                    .slideX(begin: 0.05),
              )),

          if (mp.allFilled || _showDecision) ...[
            const SizedBox(height: 8),
            _DecisionBanner(
              mp: mp,
              isAr: _isAr,
              pulseCtrl: _pulseCtrl,
              surface: _surface(context),
              border: _border(context),
            )
                .animate()
                .fadeIn(duration: 500.ms)
                .scale(begin: const Offset(0.96, 0.96)),
            const SizedBox(height: 20),
          ],

          if (mp.currentResults.isNotEmpty) ...[
            _ScoreBreakdown(
              mp: mp,
              isAr: _isAr,
              vitals: _vitals,
              surface: _surface(context),
              border: _border(context),
              text1: _text1(context),
              text2: _text2(context),
            ).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 20),
          ],
        ]),
        ),
      )
    ]);

    return Directionality(
      textDirection: _isAr ? TextDirection.rtl : TextDirection.ltr,

      child: Scaffold(
          backgroundColor: _bg(context),
          appBar: widget.isInitialFlow ? null : _buildAppBar(context, mp),
          bottomNavigationBar: _FinishBar(
            isAr: _isAr,
            mp: mp,
            saving: _saving,
            onFinish: _onFinish,
            surface: _surface(context),
            border: _border(context),
            text2: _text2(context),
          ),
          body: content),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, MedicalProvider mp) =>
      AppBar(
        backgroundColor: _surface(context),
        elevation: 0,
        title: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(
            _isAr ? 'الكشف الطبي' : 'MEDICAL ASSESSMENT',
            style: GoogleFonts.shareTechMono(
              fontSize: 14,
              color: AppColors.cyan,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            ),
          ),
          if (mp.allFilled)
            Text(
              _isAr ? 'اكتمل الكشف' : 'Assessment complete',
              style: GoogleFonts.rajdhani(fontSize: 11, color: _text2(context)),
            ),
        ]),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: AppColors.cyan, size: 18),
          onPressed: () => Navigator.maybePop(context),
        ),
        actions: [
          IconButton(
            icon:
                Icon(Icons.refresh_outlined, color: _text2(context), size: 20),
            tooltip: _isAr ? 'إعادة ضبط' : 'Reset',
            onPressed: () => _confirmReset(context),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: _ProgressStrip(mp: mp, vitals: _vitals),
        ),
      );

  Future<void> _onFinish() async {
    if (!context.read<MedicalProvider>().allFilled) {
      _showError();
      return;
    }
    setState(() => _saving = true);
    await context.read<MedicalProvider>().saveAssessment();
    setState(() => _saving = false);
    if (mounted) {
      HapticFeedback.mediumImpact();
      widget.onFinished?.call();
    }
  }

  void _showError() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: AppColors.red,
      content: Text(
        _isAr
            ? 'يرجى إدخال جميع القياسات أولاً'
            : 'Please enter all vital measurements first',
        style: GoogleFonts.rajdhani(
            fontSize: 14, color: Colors.white, fontWeight: FontWeight.w600),
      ),
      duration: const Duration(seconds: 2),
    ));
  }

  void _confirmReset(BuildContext ctx) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        backgroundColor: _surface(context),
        title: Text(
          _isAr ? 'إعادة ضبط الكشف؟' : 'Reset Assessment?',
          style:
              GoogleFonts.shareTechMono(fontSize: 14, color: _text1(context)),
        ),
        content: Text(
          _isAr
              ? 'ستُمسح جميع القيم المدخلة.'
              : 'All entered values will be cleared.',
          style: GoogleFonts.rajdhani(fontSize: 13, color: _text2(context)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child:
                const Text('Cancel', style: TextStyle(color: AppColors.cyan)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.red),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<MedicalProvider>().resetAll();
              setState(() => _showDecision = false);
            },
            child: Text(
              _isAr ? 'إعادة ضبط' : 'Reset',
              style: GoogleFonts.rajdhani(
                  color: Colors.white, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// ── Inline title (used when isInitialFlow = true) ─────────────
// ══════════════════════════════════════════════════════════════
class _InlineTitle extends StatelessWidget {
  final bool isAr;
  final Color text1, text2;

  const _InlineTitle(
      {required this.isAr, required this.text1, required this.text2});

  @override
  Widget build(BuildContext context) => Row(children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.cyan.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.cyan.withOpacity(0.25)),
          ),
          child: const Icon(Icons.monitor_heart_outlined,
              color: AppColors.cyan, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            isAr ? 'الكشف الطبي الإلزامي' : 'MANDATORY MEDICAL CHECK',
            style: GoogleFonts.tajawal(
              fontSize: 15,
              color: AppColors.cyan,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),
          Text(
            isAr
                ? 'يجب إتمامه قبل بدء تقييم IMSAFE'
                : 'Must complete before IMSAFE assessment',
            style: GoogleFonts.tajawal(fontSize: 14, color: text2,
              fontWeight: FontWeight.w700
            ),
          ),
        ])),
        // Progress strip inline
        SizedBox(
          width: 60,
          child: _ProgressStrip(
              mp: context.read<MedicalProvider>(), vitals: buildMedVitals()),
        ),
      ]);
}

// ══════════════════════════════════════════════════════════════
// ── Section header ────────────────────────────────────────────
// ══════════════════════════════════════════════════════════════
class _SectionHeader extends StatelessWidget {
  final bool isAr;
  final Color text1, text2;

  const _SectionHeader(
      {required this.isAr, required this.text1, required this.text2});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.cyan.withOpacity(0.12),
              AppColors.cyan.withOpacity(0.04)
            ],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.cyan.withOpacity(0.25)),
        ),
        child: Row(children: [
          const Text('🏥', style: TextStyle(fontSize: 36)),
          const SizedBox(width: 16),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(
                  isAr ? 'الكشف الطبي للطيار' : 'PILOT MEDICAL FITNESS',
                  style: GoogleFonts.tajawal(
                    fontSize: 18,
                    color: AppColors.cyan,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  isAr
                      ? 'أدخل قيمك الحيوية وسيتم تقييم لياقتك الطبية تلقائياً. يجب ألا تطير إذا كانت قيمة واحدة أو أكثر في نطاق "خطر جداً".'
                      : 'Enter your vital readings. Fitness will be assessed automatically. Do not fly if any reading falls in the "Very Dangerous" range.',
                  style: GoogleFonts.tajawal(
                      fontSize: 15, color: text2, height: 1.5,
                  fontWeight: FontWeight.w700),
                ),
              ])),
        ]),
      );
}

// ══════════════════════════════════════════════════════════════
// ── Reference panel ───────────────────────────────────────────
// ══════════════════════════════════════════════════════════════
class _ReferencePanel extends StatelessWidget {
  final List<MedVital> vitals;
  final bool isAr, expanded;
  final VoidCallback onToggle;
  final Color surface, border, text1;

  const _ReferencePanel({
    required this.vitals,
    required this.isAr,
    required this.expanded,
    required this.onToggle,
    required this.surface,
    required this.border,
    required this.text1,
  });

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(11),
          child: Column(children: [
            Container(height: 2, color: AppColors.cyan),
            InkWell(
              onTap: onToggle,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(children: [
                  const Icon(Icons.medical_information_outlined,
                      color: AppColors.cyan, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                      child: Text(
                    isAr
                        ? 'المعدلات الطبيعية المرجعية'
                        : 'NORMAL REFERENCE RANGES',
                    style: GoogleFonts.tajawal(
                        fontSize: 13,
                        color: AppColors.cyan,
                        letterSpacing: 1.5,
                    fontWeight: FontWeight.w700),
                  )),
                  Icon(expanded ? Icons.expand_less : Icons.expand_more,
                      color: AppColors.textSecondary, size: 20),
                ]),
              ),
            ),
            if (expanded) ...[
              Divider(color: border, height: 1),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
                child: Column(
                  children: vitals
                      .map((v) => _VitalRefTable(
                            v: v,
                            isAr: isAr,
                            text1: text1,
                            border: border,
                          ))
                      .toList(),
                ),
              ),
            ],
          ]),
        ),
      );
}

class _VitalRefTable extends StatelessWidget {
  final MedVital v;
  final bool isAr;
  final Color text1, border;

  const _VitalRefTable(
      {required this.v,
      required this.isAr,
      required this.text1,
      required this.border});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text(v.iconEmoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Text(isAr ? v.arabicTitle : v.title,
                style: GoogleFonts.shareTechMono(
                    fontSize: 12, color: text1, fontWeight: FontWeight.w700)),
            const SizedBox(width: 6),
            Text('(${v.unit})',
                style: GoogleFonts.shareTechMono(
                    fontSize: 9, color: AppColors.textSecondary)),
          ]),
          const SizedBox(height: 8),
          ...v.ranges.map((r) => _RangeRow(r: r, isAr: isAr, text1: text1)),
        ]),
      );
}

class _RangeRow extends StatelessWidget {
  final MedRangeRow r;
  final bool isAr;
  final Color text1;

  const _RangeRow({required this.r, required this.isAr, required this.text1});

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: r.level.dimColor.withOpacity(0.6),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: r.level.color.withOpacity(0.2)),
        ),
        child: Row(children: [
          Icon(r.level.icon, color: r.level.color, size: 14),
          const SizedBox(width: 8),
          Expanded(
              child: Text(isAr ? r.arabicRangeText : r.rangeText,
                  style:
                      GoogleFonts.shareTechMono(fontSize: 11, color: text1))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: r.level.color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: r.level.color.withOpacity(0.4)),
            ),
            child: Text(isAr ? r.level.arabicLabel : r.level.label,
                style: GoogleFonts.shareTechMono(
                    fontSize: 9,
                    color: r.level.color,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1)),
          ),
        ]),
      );
}

// ══════════════════════════════════════════════════════════════
// ── Vital Input Card ──────────────────────────────────────────
// ══════════════════════════════════════════════════════════════
class _VitalInputCard extends StatefulWidget {
  final MedVital vital;
  final bool isAr;
  final Color surface, border, text1, text2;
  final void Function(double value, double? value2) onChanged;

  const _VitalInputCard({
    required this.vital,
    required this.isAr,
    required this.surface,
    required this.border,
    required this.text1,
    required this.text2,
    required this.onChanged,
  });

  @override
  State<_VitalInputCard> createState() => _VitalInputCardState();
}

class _VitalInputCardState extends State<_VitalInputCard> {
  final _ctrl1 = TextEditingController();
  final _ctrl2 = TextEditingController();
  MedLevel? _level;
  bool _showInfo = false;

  @override
  void dispose() {
    _ctrl1.dispose();
    _ctrl2.dispose();
    super.dispose();
  }

  void _compute() {
    final v1 = double.tryParse(_ctrl1.text.trim());
    if (v1 == null) {
      setState(() => _level = null);
      return;
    }
    MedLevel lvl;
    double? v2;
    if (widget.vital.isDual) {
      v2 = double.tryParse(_ctrl2.text.trim());
      if (v2 == null) {
        setState(() => _level = null);
        return;
      }
      lvl = widget.vital.classifyDual!(v1, v2);
    } else {
      lvl = widget.vital.classify(v1);
    }
    setState(() => _level = lvl);
    widget.onChanged(v1, v2);
    HapticFeedback.selectionClick();
  }

  @override
  Widget build(BuildContext context) {
    final lvl = _level;
    final borderColor =
        lvl != null ? lvl.color.withOpacity(0.5) : widget.border;
    final accent = lvl?.color ?? AppColors.cyan;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: widget.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: lvl != null ? 1.5 : 1),
        boxShadow: lvl != null
            ? [
                BoxShadow(
                    color: lvl.color.withOpacity(0.08),
                    blurRadius: 16,
                    spreadRadius: 0),
              ]
            : [],
      ),
      child: Column(children: [
        // accent bar top
        Container(
            height: 3,
            decoration: BoxDecoration(
              color: accent,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(13)),
            )),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Title row
            Row(children: [
              Text(widget.vital.iconEmoji,
                  style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(
                      widget.isAr
                          ? widget.vital.arabicTitle
                          : widget.vital.title,
                      style: GoogleFonts.shareTechMono(
                        fontSize: 15,
                        color: widget.text1,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                    Text(
                      '(${widget.vital.unit})',
                      style: GoogleFonts.rajdhani(
                          fontSize: 11, color: widget.text2),
                    ),
                  ])),
              GestureDetector(
                onTap: () => setState(() => _showInfo = !_showInfo),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: accent.withOpacity(0.3)),
                  ),
                  child: Icon(
                    _showInfo ? Icons.info : Icons.info_outline,
                    color: accent,
                    size: 16,
                  ),
                ),
              ),
            ]),
            const SizedBox(height: 14),

            // Input field(s)
            if (widget.vital.isDual) ...[
              Row(children: [
                Expanded(
                    child: _InputField(
                  ctrl: _ctrl1,
                  hint: widget.isAr
                      ? (widget.vital.arabicHint)
                      : widget.vital.hint,
                  unit: widget.vital.unit,
                  accent: accent,
                  text1: widget.text1,
                  text2: widget.text2,
                  border: widget.border,
                  onChanged: (_) => _compute(),
                  label: widget.isAr ? 'الانقباضي' : 'Systolic',
                )),
                const SizedBox(width: 12),
                Text('/', style: TextStyle(fontSize: 20, color: widget.text2)),
                const SizedBox(width: 12),
                Expanded(
                    child: _InputField(
                  ctrl: _ctrl2,
                  hint: widget.isAr
                      ? (widget.vital.arabicHint2 ?? '')
                      : (widget.vital.hint2 ?? ''),
                  unit: widget.vital.unit2 ?? widget.vital.unit,
                  accent: accent,
                  text1: widget.text1,
                  text2: widget.text2,
                  border: widget.border,
                  onChanged: (_) => _compute(),
                  label: widget.isAr ? 'الانبساطي' : 'Diastolic',
                )),
              ]),
            ] else ...[
              _InputField(
                ctrl: _ctrl1,
                hint: widget.isAr ? widget.vital.arabicHint : widget.vital.hint,
                unit: widget.vital.unit,
                accent: accent,
                text1: widget.text1,
                text2: widget.text2,
                border: widget.border,
                onChanged: (_) => _compute(),
              ),
            ],
            const SizedBox(height: 12),

            // Level badge
            if (lvl != null)
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: lvl.dimColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: lvl.color.withOpacity(0.4)),
                ),
                child: Row(children: [
                  Icon(lvl.icon, color: lvl.color, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text(
                          widget.isAr ? lvl.arabicLabel : lvl.label,
                          style: GoogleFonts.shareTechMono(
                            fontSize: 16,
                            color: lvl.color,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                          ),
                        ),
                        Text(
                          _getLevelDesc(lvl, widget.isAr),
                          style: GoogleFonts.rajdhani(
                              fontSize: 12, color: lvl.color.withOpacity(0.8)),
                        ),
                      ])),
                  if (lvl == MedLevel.veryDangerous || lvl == MedLevel.high)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.red.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(4),
                        border:
                            Border.all(color: AppColors.red.withOpacity(0.4)),
                      ),
                      child: Text(
                        widget.isAr ? '🛑 لا تطر' : '🛑 NO-FLY',
                        style: GoogleFonts.shareTechMono(
                            fontSize: 9,
                            color: AppColors.red,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                ]),
              )
                  .animate(key: ValueKey(lvl))
                  .fadeIn(duration: 300.ms)
                  .scale(begin: const Offset(0.97, 0.97)),

            // Inline reference toggle
            if (_showInfo) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: widget.border.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: widget.vital.ranges
                        .map((r) => _MiniRangeRow(
                            r: r, isAr: widget.isAr, text1: widget.text1))
                        .toList()),
              ),
            ],
          ]),
        ),
      ]),
    );
  }

  String _getLevelDesc(MedLevel lvl, bool isAr) {
    if (isAr)
      return const {
        MedLevel.low: 'القيمة أقل من المعدل الطبيعي',
        MedLevel.normal: 'القيمة ضمن النطاق الطبيعي — ممتاز',
        MedLevel.medium: 'تحتاج مراقبة — استشر طبيباً',
        MedLevel.high: 'مرتفع — يُنصح بعدم الطيران',
        MedLevel.veryDangerous: 'خطر جداً — لا تطر تحت أي ظرف',
      }[lvl]!;
    return const {
      MedLevel.low: 'Below normal range — monitor closely',
      MedLevel.normal: 'Within normal range — excellent',
      MedLevel.medium: 'Borderline — consult physician if persistent',
      MedLevel.high: 'Elevated — flight not recommended',
      MedLevel.veryDangerous: 'Critical — do not fly under any circumstances',
    }[lvl]!;
  }
}

class _MiniRangeRow extends StatelessWidget {
  final MedRangeRow r;
  final bool isAr;
  final Color text1;

  const _MiniRangeRow(
      {required this.r, required this.isAr, required this.text1});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(children: [
          Icon(r.level.icon, color: r.level.color, size: 12),
          const SizedBox(width: 6),
          Expanded(
              child: Text(isAr ? r.arabicRangeText : r.rangeText,
                  style:
                      GoogleFonts.tajawal(fontSize: 14, color: text1))),
          Text(isAr ? r.level.arabicLabel : r.level.label,
              style: GoogleFonts.tajawal(
                  fontSize: 12,
                  color: r.level.color,
                  fontWeight: FontWeight.w700)),
        ]),
      );
}

class _InputField extends StatelessWidget {
  final TextEditingController ctrl;
  final String hint, unit;
  final Color accent, text1, text2, border;
  final ValueChanged<String> onChanged;
  final String? label;

  const _InputField({
    required this.ctrl,
    required this.hint,
    required this.unit,
    required this.accent,
    required this.text1,
    required this.text2,
    required this.border,
    required this.onChanged,
    this.label,
  });

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label != null) ...[
            Text(label!,
                style: GoogleFonts.tajawal(fontSize: 14, color: text2,
                fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
          ],
          TextField(
            controller: ctrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: GoogleFonts.shareTechMono(
                fontSize: 22, color: text1, fontWeight: FontWeight.w700),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.shareTechMono(
                  fontSize: 16, color: text2.withOpacity(0.5)),
              suffixText: unit,
              suffixStyle: GoogleFonts.rajdhani(
                  fontSize: 13,
                  color: accent.withOpacity(0.7),
                  fontWeight: FontWeight.w600),
              filled: true,
              fillColor: accent.withOpacity(0.06),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: accent.withOpacity(0.25)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: accent, width: 1.5),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            ),
            onChanged: onChanged,
          ),
        ],
      );
}

// ══════════════════════════════════════════════════════════════
// ── Decision Banner ───────────────────────────────────────────
// ══════════════════════════════════════════════════════════════
class _DecisionBanner extends StatelessWidget {
  final MedicalProvider mp;
  final bool isAr;
  final AnimationController pulseCtrl;
  final Color surface, border;

  const _DecisionBanner({
    required this.mp,
    required this.isAr,
    required this.pulseCtrl,
    required this.surface,
    required this.border,
  });

  @override
  Widget build(BuildContext context) {
    final decision = mp.currentDecision;
    final isGo = decision == 'go';
    final isCaution = decision == 'caution';
    final color = isGo
        ? const Color(0xFF00E676)
        : isCaution
            ? const Color(0xFFFFB020)
            : const Color(0xFFFF3D57);
    final label = isGo
        ? (isAr ? '✅ مسموح بالطيران' : '✅ CLEARED TO FLY')
        : isCaution
            ? (isAr
                ? '⚠️ تحذير — راجع طبيباً'
                : '⚠️ CAUTION — CONSULT PHYSICIAN')
            : (isAr ? '🛑 ممنوع الطيران' : '🛑 NOT CLEARED TO FLY');

    return AnimatedBuilder(
      animation: pulseCtrl,
      builder: (_, __) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.15 + pulseCtrl.value * 0.05),
              color.withOpacity(0.06),
            ],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: color.withOpacity(0.5 + pulseCtrl.value * 0.2),
              width: 1.5),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1 + pulseCtrl.value * 0.08),
              blurRadius: 20,
              spreadRadius: 0,
            )
          ],
        ),
        child: Row(children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.15),
              border: Border.all(color: color.withOpacity(0.5), width: 2),
            ),
            child: Center(
                child: Text(
              '${mp.overallRisk.toStringAsFixed(0)}',
              style: GoogleFonts.shareTechMono(
                  fontSize: 18, color: color, fontWeight: FontWeight.w700),
            )),
          ),
          const SizedBox(width: 16),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(
                  isAr ? 'نتيجة الكشف الطبي' : 'MEDICAL ASSESSMENT RESULT',
                  style: GoogleFonts.shareTechMono(
                      fontSize: 9,
                      color: AppColors.textSecondary,
                      letterSpacing: 1.5),
                ),
                const SizedBox(height: 4),
                Text(label,
                    style: GoogleFonts.shareTechMono(
                      fontSize: 15,
                      color: color,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    )),
              ])),
        ]),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// ── Score Breakdown ───────────────────────────────────────────
// ══════════════════════════════════════════════════════════════
class _ScoreBreakdown extends StatelessWidget {
  final MedicalProvider mp;
  final bool isAr;
  final List<MedVital> vitals;
  final Color surface, border, text1, text2;

  const _ScoreBreakdown({
    required this.mp,
    required this.isAr,
    required this.vitals,
    required this.surface,
    required this.border,
    required this.text1,
    required this.text2,
  });

  @override
  Widget build(BuildContext context) {
    final results = mp.currentResults;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          isAr ? 'ملخص القياسات' : 'READINGS SUMMARY',
          style: GoogleFonts.shareTechMono(
              fontSize: 10, color: text2, letterSpacing: 1.5),
        ),
        const SizedBox(height: 14),
        ...results.map((r) {
          final vital = vitals.firstWhere((v) => v.id == r.id,
              orElse: () => vitals.first);
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(children: [
              Text(vital.iconEmoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 10),
              SizedBox(
                width: 110,
                child: Text(isAr ? vital.arabicTitle : vital.title,
                    style: GoogleFonts.rajdhani(fontSize: 13, color: text1)),
              ),
              Expanded(
                  child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: r.level.riskPoints / 10.0,
                  minHeight: 8,
                  backgroundColor: border,
                  valueColor: AlwaysStoppedAnimation(r.level.color),
                ),
              )),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: r.level.dimColor,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: r.level.color.withOpacity(0.4)),
                ),
                child: Text(
                  isAr ? r.level.arabicLabel : r.level.label,
                  style: GoogleFonts.shareTechMono(
                      fontSize: 8,
                      color: r.level.color,
                      fontWeight: FontWeight.w700),
                ),
              ),
            ]),
          );
        }),
      ]),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// ── Progress Strip ────────────────────────────────────────────
// ══════════════════════════════════════════════════════════════
class _ProgressStrip extends StatelessWidget {
  final MedicalProvider mp;
  final List<MedVital> vitals;

  const _ProgressStrip({required this.mp, required this.vitals});

  @override
  Widget build(BuildContext context) {
    final filled = vitals.where((v) {
      final val = mp.getValue(v.id);
      if (val == null) return false;
      if (v.isDual && mp.getValue2(v.id) == null) return false;
      return true;
    }).length;
    final pct = filled / vitals.length;

    return SizedBox(
      height: 3,
      child: LinearProgressIndicator(
        value: pct,
        backgroundColor: const Color(0xFF1E2D45),
        valueColor: AlwaysStoppedAnimation(
          pct >= 1.0 ? const Color(0xFF00E676) : AppColors.cyan,
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// ── Finish Bar ────────────────────────────────────────────────
// ══════════════════════════════════════════════════════════════
class _FinishBar extends StatelessWidget {
  final bool isAr, saving;
  final MedicalProvider mp;
  final VoidCallback onFinish;
  final Color surface, border, text2;

  const _FinishBar({
    required this.isAr,
    required this.mp,
    required this.saving,
    required this.onFinish,
    required this.surface,
    required this.border,
    required this.text2,
  });

  @override
  Widget build(BuildContext context) {
    final ready = mp.allFilled;
    final color = ready ? const Color(0xFF00E676) : text2;

    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
      decoration: BoxDecoration(
        color: surface,
        border: Border(top: BorderSide(color: border)),
      ),
      child: SizedBox(
        height: 54,
        child: ElevatedButton.icon(
          onPressed: saving ? null : onFinish,
          style: ElevatedButton.styleFrom(
            backgroundColor:
                ready ? color.withOpacity(0.15) : border.withOpacity(0.3),
            foregroundColor: color,
            side: BorderSide(color: ready ? color : border),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
          icon: saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white))
              : Icon(ready ? Icons.check_circle_outline : Icons.lock_outline,
                  size: 20),
          label: Text(
            saving
                ? (isAr ? 'جاري الحفظ...' : 'Saving...')
                : ready
                    ? (isAr
                        ? 'إنهاء الكشف الطبي ← IMSAFE'
                        : 'FINISH MEDICAL CHECK → IMSAFE')
                    : (isAr
                        ? 'أدخل جميع القياسات أولاً'
                        : 'Enter all measurements first'),
            style: GoogleFonts.shareTechMono(
                fontSize: 12, letterSpacing: 1.5, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// ── Grid background ───────────────────────────────────────────
// ══════════════════════════════════════════════════════════════
class _MedGridPainter extends CustomPainter {
  final Color borderColor;

  const _MedGridPainter({required this.borderColor});

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = borderColor.withOpacity(0.3)
      ..strokeWidth = 0.5;
    for (double x = 0; x < size.width; x += 44) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    }
    for (double y = 0; y < size.height; y += 44) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
  }

  @override
  bool shouldRepaint(_MedGridPainter old) => old.borderColor != borderColor;
}

extension _MedProviderExt on MedicalProvider {
  double get overallRisk {
    final results = currentResults;
    if (results.isEmpty) return 0;
    final total = results.fold(0, (s, r) => s + r.level.riskPoints);
    final max = results.length * MedLevel.veryDangerous.riskPoints;
    return (total / max * 100).clamp(0, 100);
  }
}
