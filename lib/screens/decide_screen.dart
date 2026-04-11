import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/models.dart';
import '../theme/theme.dart';
import '../widgets/widgets.dart';

// ═══════════════════════════════════════════════════════════════
// HAZARD MODEL
// ═══════════════════════════════════════════════════════════════

class HazardEntry {
  final String id;
  final String hazard;
  // Evaluate tab fills these:
  final int?   severity;
  final int?   likelihood;
  // Consider tab fills these:
  final String mitigation;
  final int?   residualS;
  final int?   residualL;

  const HazardEntry({
    required this.id,
    required this.hazard,
    this.severity,
    this.likelihood,
    this.mitigation = '',
    this.residualS,
    this.residualL,
  });

  bool get isEvaluated  => severity != null && likelihood != null;
  bool get hasResidual  => residualS != null && residualL != null;

  int get riskScore     => isEvaluated ? severity! * likelihood! : 0;
  int get residualScore => hasResidual  ? residualS! * residualL! : 0;

  RiskLevel get riskLevel     => HazardEntry.levelFor(riskScore);
  RiskLevel get residualLevel => HazardEntry.levelFor(residualScore);

  static RiskLevel levelFor(int score) {
    if (score >= 15) return RiskLevel.critical;
    if (score >= 8)  return RiskLevel.high;
    if (score >= 4)  return RiskLevel.medium;
    return RiskLevel.low;
  }

  HazardEntry copyWith({
    String? hazard,
    int? severity,
    int? likelihood,
    String? mitigation,
    int? residualS,
    int? residualL,
  }) =>
      HazardEntry(
        id:          id,
        hazard:      hazard      ?? this.hazard,
        severity:    severity    ?? this.severity,
        likelihood:  likelihood  ?? this.likelihood,
        mitigation:  mitigation  ?? this.mitigation,
        residualS:   residualS   ?? this.residualS,
        residualL:   residualL   ?? this.residualL,
      );
}

enum RiskLevel { low, medium, high, critical }

extension RiskLevelX on RiskLevel {
  String label(bool ar) => ar
      ? const ['منخفض', 'متوسط', 'مرتفع', 'حرج'][index]
      : const ['Low', 'Medium', 'High', 'Critical'][index];

  Color get color => const [
    Color(0xFF00E676),
    Color(0xFFFFB020),
    Color(0xFFFF3D57),
    Color(0xFFB060FF),
  ][index];

  Color get bgColor => color.withOpacity(0.15);
}

// ═══════════════════════════════════════════════════════════════
// SHARED HAZARD STATE
// ═══════════════════════════════════════════════════════════════

class HazardState {
  final List<HazardEntry> hazards;
  const HazardState({this.hazards = const []});

  HazardState copyWith({List<HazardEntry>? hazards}) =>
      HazardState(hazards: hazards ?? this.hazards);
}

// ═══════════════════════════════════════════════════════════════
// DECIDE SCREEN
// ═══════════════════════════════════════════════════════════════

class DecideScreen extends StatefulWidget {
  final List<DecideStep> steps;
  final bool showArabic;
  final Function(int index, String userInput) onStepCompleted;
  final VoidCallback? onComplete;
  // Optional: pass in existing hazard state (for resuming sessions)
  final HazardState? initialHazardState;
  final void Function(HazardState)? onHazardStateChanged;

  const DecideScreen({
    super.key,
    required this.steps,
    required this.showArabic,
    required this.onStepCompleted,
    this.onComplete,
    this.initialHazardState,
    this.onHazardStateChanged,
  });

  @override
  State<DecideScreen> createState() => _DecideScreenState();
}

class _DecideScreenState extends State<DecideScreen> {
  int _currentStep = 0;
  final Map<int, TextEditingController> _controllers = {};
  late HazardState _hazardState;

  List<DecideStep> get steps => widget.steps;

  @override
  void initState() {
    super.initState();
    _hazardState = widget.initialHazardState ?? const HazardState();
    for (int i = 0; i < steps.length; i++) {
      _controllers[i] = TextEditingController(text: steps[i].userInput);
    }
  }

  @override
  void dispose() {
    for (final c in _controllers.values) c.dispose();
    super.dispose();
  }

  bool get canFinish => steps.every((s) => s.completed || s.skipped);

  void _markCompleted(int idx) {
    final input = _controllers[idx]?.text.trim() ?? '';
    if (input.isEmpty) return;
    widget.onStepCompleted(idx, input);
    setState(() {
      steps[idx].userInput = input;
      steps[idx].completed = true;
      steps[idx].skipped   = false;
      if (idx < steps.length - 1) _currentStep = idx + 1;
    });
  }

  void _skipStep(int idx) {
    setState(() {
      steps[idx].skipped   = true;
      steps[idx].completed = false;
      if (idx < steps.length - 1) {
        _currentStep = idx + 1;
      } else {
        widget.onComplete?.call();
      }
    });
  }

  void _onHazardStateChanged(HazardState s) {
    setState(() => _hazardState = s);
    widget.onHazardStateChanged?.call(s);
  }

  bool _canNavigateTo(int index) {
    // Read-only if skipped
    return !steps[index].skipped;
  }

  void _tryNavigate(int index) {
    if (!_canNavigateTo(index)) return; // skipped → blocked
    setState(() => _currentStep = index);
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _currentStep == steps.length - 1;

    return Directionality(
      textDirection: widget.showArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColors.bg,
        appBar: AppBar(title: const Text('DECIDE MODEL')),
        body: LayoutBuilder(builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 700;
          return isWide
              ? Row(children: [
            SizedBox(
              width: 200,
              child: _Sidebar(
                steps: steps,
                currentStep: _currentStep,
                showArabic: widget.showArabic,
                onStepTap: _tryNavigate, // uses guard
              ),
            ),
            Container(width: 1, color: AppColors.border),
            Expanded(child: _buildDetail(isLast)),
          ])
              : Column(children: [
            _StepperBar(
              steps: steps,
              currentStep: _currentStep,
              onTap: _tryNavigate,
            ),
            Expanded(child: _buildDetail(isLast)),
          ]);
        }),
      ),
    );
  }

  Widget _buildDetail(bool isLast) => _StepDetail(
    step: steps[_currentStep],
    stepIndex: _currentStep,
    totalSteps: steps.length,
    controller: _controllers[_currentStep]!,
    showArabic: widget.showArabic,
    hazardState: _hazardState,
    onHazardStateChanged: _onHazardStateChanged,
    onComplete: () => _markCompleted(_currentStep),
    onSkip: () => _skipStep(_currentStep),
    isLastStep: isLast,
    canFinish: canFinish,
    onFinish: widget.onComplete,
  );
}

// ═══════════════════════════════════════════════════════════════
// SIDEBAR — skipped steps are read-only (no tap)
// ═══════════════════════════════════════════════════════════════

class _Sidebar extends StatelessWidget {
  final List<DecideStep> steps;
  final int currentStep;
  final bool showArabic;
  final ValueChanged<int> onStepTap;

  const _Sidebar({
    required this.steps,
    required this.currentStep,
    required this.showArabic,
    required this.onStepTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.all(14),
          child: Text(
            showArabic ? 'خطوات DECIDE' : 'DECIDE STEPS',
            style: GoogleFonts.shareTechMono(
                fontSize: 9, color: AppColors.textTertiary, letterSpacing: 2),
          ),
        ),
        const Divider(height: 1, color: AppColors.border),
        Expanded(
          child: ListView.builder(
            itemCount: steps.length,
            itemBuilder: (context, i) {
              final step      = steps[i];
              final isActive  = i == currentStep;
              final isSkipped = step.skipped;

              return GestureDetector(
                // skipped → null callback (no interaction)
                onTap: isSkipped ? null : () => onStepTap(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSkipped
                        ? AppColors.elevated.withOpacity(0.3)
                        : isActive
                        ? step.color.withOpacity(0.08)
                        : Colors.transparent,
                    border: Border(
                      left: BorderSide(
                        color: isSkipped
                            ? Colors.transparent
                            : isActive
                            ? step.color
                            : Colors.transparent,
                        width: 3,
                      ),
                      bottom: const BorderSide(
                          color: AppColors.border, width: 0.5),
                    ),
                  ),
                  child: Row(children: [
                    // icon — dim if skipped
                    Opacity(
                      opacity: isSkipped ? 0.35 : 1.0,
                      child: Text(step.iconEmoji,
                          style: const TextStyle(fontSize: 16)),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        showArabic ? step.arabicTitle : step.title,
                        style: TextStyle(
                          fontSize: 11,
                          color: isSkipped
                              ? AppColors.textTertiary
                              : isActive
                              ? step.color
                              : AppColors.textSecondary,
                          fontWeight: isActive && !isSkipped
                              ? FontWeight.w700
                              : FontWeight.w400,
                        ),
                      ),
                    ),
                    // status icon
                    if (step.completed && !isSkipped)
                      Icon(Icons.check_circle, size: 12, color: step.color)
                    else if (isSkipped)
                      Row(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.block, size: 10,
                            color: AppColors.textTertiary),
                        const SizedBox(width: 2),
                        Text(
                          showArabic ? 'تخطى' : 'skip',
                          style: const TextStyle(
                              fontSize: 8,
                              color: AppColors.textTertiary,
                              letterSpacing: 0.5),
                        ),
                      ]),
                  ]),
                ),
              );
            },
          ),
        ),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// STEPPER BAR — skipped tabs greyed, non-tappable
// ═══════════════════════════════════════════════════════════════

class _StepperBar extends StatelessWidget {
  final List<DecideStep> steps;
  final int currentStep;
  final ValueChanged<int> onTap;

  const _StepperBar({
    required this.steps,
    required this.currentStep,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      color: AppColors.surface,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: steps.length,
        itemBuilder: (context, i) {
          final step      = steps[i];
          final isActive  = i == currentStep;
          final isSkipped = step.skipped;

          return GestureDetector(
            onTap: isSkipped ? null : () => onTap(i),
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Opacity(
                opacity: isSkipped ? 0.35 : 1.0,
                child: StepCircle(
                  label: step.key.length > 1 ? step.key[0] : step.key,
                  color: isSkipped ? AppColors.textTertiary : step.color,
                  active: isActive,
                  completed: step.completed && !isSkipped,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// STEP DETAIL
// ═══════════════════════════════════════════════════════════════

class _StepDetail extends StatelessWidget {
  final DecideStep step;
  final int stepIndex, totalSteps;
  final TextEditingController controller;
  final bool showArabic;
  final HazardState hazardState;
  final ValueChanged<HazardState> onHazardStateChanged;
  final VoidCallback onComplete;
  final VoidCallback onSkip;
  final bool isLastStep;
  final bool canFinish;
  final VoidCallback? onFinish;

  const _StepDetail({
    required this.step,
    required this.stepIndex,
    required this.totalSteps,
    required this.controller,
    required this.showArabic,
    required this.hazardState,
    required this.onHazardStateChanged,
    required this.onComplete,
    required this.onSkip,
    required this.isLastStep,
    required this.canFinish,
    this.onFinish,
  });

  // Step index mapping (adjust if your DECIDE order differs)
  bool get _isDetect    => stepIndex == 0; // D — Detect
  bool get _isEvaluate  => stepIndex == 1; // E — Evaluate
  bool get _isConsider  => stepIndex == 2; // C — Consider

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: R.pad(context),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [

        // ── Step header ──────────────────────────────────────
        _StepHeader(
          step: step,
          stepIndex: stepIndex,
          totalSteps: totalSteps,
          showArabic: showArabic,
        ).animate().fadeIn(duration: 350.ms),
        const SizedBox(height: 14),

        // ── Cockpit panel ────────────────────────────────────
        APanel(
          title: showArabic
              ? 'التطبيق في قمرة القيادة'
              : 'COCKPIT APPLICATION',
          accent: step.color,
          child: Text(
            showArabic ? step.arabicCockpitApp : step.cockpitApp,
            style: const TextStyle(
                fontSize: 12, color: AppColors.textSecondary, height: 1.6),
          ),
        ).animate().fadeIn(delay: 100.ms),
        const SizedBox(height: 12),

        // ── D — Detect: hazard name input ────────────────────
        if (_isDetect) ...[
          _DetectHazardSection(
            hazardState: hazardState,
            onChanged: onHazardStateChanged,
            showArabic: showArabic,
            stepColor: step.color,
          ),
          const SizedBox(height: 12),
        ],

        // ── E — Evaluate: S + L only ─────────────────────────
        if (_isEvaluate) ...[
          _EvaluateSection(
            hazardState: hazardState,
            onChanged: onHazardStateChanged,
            showArabic: showArabic,
            stepColor: step.color,
          ),
          const SizedBox(height: 12),
        ],

        // ── C — Consider: mitigation + residual ─────────────
        if (_isConsider) ...[
          _ConsiderSection(
            hazardState: hazardState,
            onChanged: onHazardStateChanged,
            showArabic: showArabic,
            stepColor: step.color,
          ),
          const SizedBox(height: 12),
        ],

        // ── Notes ────────────────────────────────────────────
        APanel(
          title: showArabic ? 'ملاحظاتك لهذه الخطوة' : 'YOUR NOTES',
          accent: step.color.withOpacity(0.5),
          child: TextFormField(
            controller: controller,
            style: const TextStyle(
                fontSize: 12, color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: showArabic
                  ? 'صِف ما اكتشفته / قررته...'
                  : 'Describe what you detected / decided...',
              hintStyle: const TextStyle(
                  fontSize: 11, color: AppColors.textTertiary),
              filled: true,
              fillColor: AppColors.surfaceAlt,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(color: AppColors.border)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(color: AppColors.border)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: BorderSide(color: step.color, width: 1.5)),
              contentPadding: const EdgeInsets.all(10),
            ),
            maxLines: 4,
          ),
        ).animate().fadeIn(delay: 200.ms),
        const SizedBox(height: 18),

        // ── Buttons ──────────────────────────────────────────
        if (isLastStep)
        // Last step: finish button enabled when text exists OR already done
          _LastStepFinishRow(
            controller: controller,
            step: step,
            showArabic: showArabic,
            onFinish: () {
              // auto-mark last step as completed before finishing
              onComplete();
              (onFinish ?? () {})();
            },
            onSkip: onSkip,
          )
        else if (canFinish)
          _FinishRow(showArabic: showArabic, onFinish: onFinish ?? () {})
        else
          _ConfirmSkipRow(
            controller: controller,
            step: step,
            showArabic: showArabic,
            onComplete: onComplete,
            onSkip: onSkip,
          ),

        const SizedBox(height: 40),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// STEP HEADER
// ═══════════════════════════════════════════════════════════════

class _StepHeader extends StatelessWidget {
  final DecideStep step;
  final int stepIndex, totalSteps;
  final bool showArabic;

  const _StepHeader({
    required this.step,
    required this.stepIndex,
    required this.totalSteps,
    required this.showArabic,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: step.color.withOpacity(0.08),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: step.color.withOpacity(0.25)),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Text(step.iconEmoji, style: const TextStyle(fontSize: 30)),
        const SizedBox(width: 12),
        Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            _Pill('${stepIndex + 1} / $totalSteps', step.color),
            if (step.completed) ...[
              const SizedBox(width: 6),
              _Pill(showArabic ? '✓ مكتمل' : '✓ DONE', step.color),
            ],
            if (step.skipped) ...[
              const SizedBox(width: 6),
              _Pill(showArabic ? '— تم تخطيه' : '— SKIPPED',
                  AppColors.textTertiary),
            ],
          ]),
          const SizedBox(height: 5),
          Text(
            showArabic ? step.arabicTitle : step.title,
            style: GoogleFonts.shareTechMono(
                fontSize: 20,
                color: step.color,
                fontWeight: FontWeight.w700,
                letterSpacing: 2),
          ),
        ])),
      ]),
      const SizedBox(height: 10),
      Text(
        showArabic ? step.arabicDescription : step.description,
        style: const TextStyle(
            fontSize: 12, color: AppColors.textPrimary, height: 1.5),
      ),
    ]),
  );
}

// ═══════════════════════════════════════════════════════════════
// D — DETECT: hazard name only
// ═══════════════════════════════════════════════════════════════

class _DetectHazardSection extends StatefulWidget {
  final HazardState hazardState;
  final ValueChanged<HazardState> onChanged;
  final bool showArabic;
  final Color stepColor;

  const _DetectHazardSection({
    required this.hazardState,
    required this.onChanged,
    required this.showArabic,
    required this.stepColor,
  });

  @override
  State<_DetectHazardSection> createState() => _DetectHazardSectionState();
}

class _DetectHazardSectionState extends State<_DetectHazardSection> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _add() {
    final name = _ctrl.text.trim();
    if (name.isEmpty) return;
    final entry = HazardEntry(
      id:     DateTime.now().millisecondsSinceEpoch.toString(),
      hazard: name,
    );
    widget.onChanged(widget.hazardState
        .copyWith(hazards: [...widget.hazardState.hazards, entry]));
    _ctrl.clear();
  }

  void _remove(String id) {
    widget.onChanged(widget.hazardState.copyWith(
      hazards: widget.hazardState.hazards.where((h) => h.id != id).toList(),
    ));
  }

  bool get _ar => widget.showArabic;

  @override
  Widget build(BuildContext context) {
    final hazards = widget.hazardState.hazards;
    final color   = widget.stepColor;

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      // header
      Row(children: [
        Expanded(child: Text(
          _ar ? 'المخاطر المكتشفة' : 'DETECTED HAZARDS',
          style: GoogleFonts.shareTechMono(
              fontSize: 11, color: color, letterSpacing: 2),
        )),
        if (hazards.isNotEmpty) _CountBadge('${hazards.length}', color),
      ]),
      const SizedBox(height: 10),

      // input
      Row(children: [
        Expanded(
          child: TextField(
            controller: _ctrl,
            style: const TextStyle(
                fontSize: 13, color: AppColors.textPrimary),
            onSubmitted: (_) => _add(),
            decoration: InputDecoration(
              hintText:
              _ar ? 'اكتب اسم الخطر...' : 'Enter hazard name...',
              hintStyle: const TextStyle(
                  fontSize: 12, color: AppColors.textTertiary),
              filled: true,
              fillColor: AppColors.elevated,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.border)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.border)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: color, width: 1.5)),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 10),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          height: 48,
          child: ElevatedButton.icon(
            onPressed: _add,
            icon: const Icon(Icons.add, size: 16),
            label: Text(_ar ? 'إضافة' : 'Add',
                style: GoogleFonts.shareTechMono(fontSize: 11)),
            style: ElevatedButton.styleFrom(
              backgroundColor: color.withOpacity(0.12),
              foregroundColor: color,
              side: BorderSide(color: color.withOpacity(0.5)),
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
      ]),
      const SizedBox(height: 10),

      if (hazards.isEmpty)
        _EmptyHint(_ar ? 'لا توجد مخاطر بعد' : 'No hazards yet')
      else
        ...hazards.asMap().entries.map((e) => _HazardNameTile(
          key:      ValueKey(e.value.id),
          index:    e.key,
          entry:    e.value,
          ar:       _ar,
          color:    color,
          onDelete: () => _remove(e.value.id),
        )
            .animate()
            .fadeIn(
            duration: 280.ms,
            delay: Duration(milliseconds: e.key * 50))
            .slideX(
            begin: 0.08,
            duration: 280.ms,
            delay: Duration(milliseconds: e.key * 50))),
    ]);
  }
}

class _HazardNameTile extends StatelessWidget {
  final int index;
  final HazardEntry entry;
  final bool ar;
  final Color color;
  final VoidCallback onDelete;

  const _HazardNameTile({
    super.key,
    required this.index,
    required this.entry,
    required this.ar,
    required this.color,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 6),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(
      color: AppColors.elevated,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: AppColors.border),
    ),
    child: Row(children: [
      _IndexCircle(index + 1, color),
      const SizedBox(width: 10),
      Expanded(child: Text(entry.hazard,
          style: const TextStyle(
              fontSize: 13, color: AppColors.textPrimary))),
      if (entry.isEvaluated) ...[
        _SmallBadge(entry.riskLevel.label(ar), entry.riskLevel.color),
        const SizedBox(width: 4),
      ],
      if (entry.hasResidual) ...[
        _SmallBadge('→${entry.residualLevel.label(ar)}',
            entry.residualLevel.color),
        const SizedBox(width: 4),
      ],
      IconButton(
        icon: const Icon(Icons.close, size: 16,
            color: AppColors.textTertiary),
        onPressed: onDelete,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
      ),
    ]),
  );
}

// ═══════════════════════════════════════════════════════════════
// E — EVALUATE: S and L only (no mitigation here)
// ═══════════════════════════════════════════════════════════════

class _EvaluateSection extends StatelessWidget {
  final HazardState hazardState;
  final ValueChanged<HazardState> onChanged;
  final bool showArabic;
  final Color stepColor;

  const _EvaluateSection({
    required this.hazardState,
    required this.onChanged,
    required this.showArabic,
    required this.stepColor,
  });

  bool get _ar => showArabic;

  void _evaluate(BuildContext context, HazardEntry entry) async {
    final updated = await showDialog<HazardEntry>(
      context: context,
      builder: (_) => _EvaluateOnlyDialog(entry: entry, showArabic: _ar),
    );
    if (updated != null) {
      final newList = hazardState.hazards
          .map((h) => h.id == updated.id ? updated : h)
          .toList();
      onChanged(hazardState.copyWith(hazards: newList));
    }
  }

  @override
  Widget build(BuildContext context) {
    final hazards = hazardState.hazards;
    final color   = stepColor;

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Row(children: [
        Expanded(child: Text(
          _ar ? 'تقييم مستوى الخطر والاحتمالية' : 'EVALUATE: RISK LEVEL & LIKELIHOOD',
          style: GoogleFonts.shareTechMono(
              fontSize: 10, color: color, letterSpacing: 1.5),
        )),
        if (hazards.isNotEmpty)
          _CountBadge(
            '${hazards.where((h) => h.isEvaluated).length}/${hazards.length}',
            color,
          ),
      ]),
      const SizedBox(height: 4),
      // hint: mitigation goes in Consider
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.elevated,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.border),
        ),
        child: Text(
          _ar
              ? 'ℹ️ هنا بس شدة الخطر والاحتمالية — الإجراء التصحيحي والمتبقي في مرحلة "تأمل"'
              : 'ℹ️ Rate severity & likelihood only — mitigation & residual risk go in "Consider"',
          style: const TextStyle(
              fontSize: 10, color: AppColors.textTertiary, height: 1.4),
        ),
      ),
      const SizedBox(height: 10),

      if (hazards.isEmpty)
        _EmptyHint(_ar
            ? 'أضف مخاطر في "اكتشف" أولاً'
            : 'Add hazards in "Detect" first')
      else
        ...hazards.asMap().entries.map((e) => _EvaluateCard(
          key:        ValueKey(e.value.id),
          index:      e.key,
          entry:      e.value,
          ar:         _ar,
          color:      color,
          onEvaluate: () => _evaluate(context, e.value),
        )
            .animate()
            .fadeIn(
            duration: 280.ms,
            delay: Duration(milliseconds: e.key * 60))
            .slideY(
            begin: 0.1,
            duration: 280.ms,
            delay: Duration(milliseconds: e.key * 60))),
    ]);
  }
}

class _EvaluateCard extends StatelessWidget {
  final int index;
  final HazardEntry entry;
  final bool ar;
  final Color color;
  final VoidCallback onEvaluate;

  const _EvaluateCard({
    super.key,
    required this.index,
    required this.entry,
    required this.ar,
    required this.color,
    required this.onEvaluate,
  });

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: AppColors.elevated,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(
        color: entry.isEvaluated
            ? entry.riskLevel.color.withOpacity(0.4)
            : AppColors.border,
      ),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        _IndexCircle(index + 1, color),
        const SizedBox(width: 10),
        Expanded(child: Text(entry.hazard,
            style: const TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600))),
        if (entry.isEvaluated)
          _SmallBadge(
            'S×L = ${entry.riskScore}  ${entry.riskLevel.label(ar)}',
            entry.riskLevel.color,
          ),
      ]),
      const SizedBox(height: 10),

      // Evaluate button
      SizedBox(
        width: double.infinity,
        height: 40,
        child: OutlinedButton.icon(
          onPressed: onEvaluate,
          icon: Icon(
            entry.isEvaluated ? Icons.edit : Icons.assessment_outlined,
            size: 16,
          ),
          label: Text(
            entry.isEvaluated
                ? (ar ? 'تعديل التقييم' : 'Edit S & L')
                : (ar
                ? 'تقييم مستوى الخطر والاحتمالية'
                : 'Evaluate Risk Level & Likelihood'),
            style: GoogleFonts.shareTechMono(fontSize: 11),
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor:
            entry.isEvaluated ? entry.riskLevel.color : color,
            side: BorderSide(
              color: entry.isEvaluated
                  ? entry.riskLevel.color.withOpacity(0.5)
                  : color.withOpacity(0.5),
            ),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ),

      if (entry.isEvaluated) ...[
        const SizedBox(height: 8),
        Row(children: [
          _MiniStat('S', '${entry.severity}', AppColors.amber),
          const SizedBox(width: 12),
          _MiniStat('L', '${entry.likelihood}', AppColors.amber),
          const SizedBox(width: 12),
          _MiniStat('S×L', '${entry.riskScore}', entry.riskLevel.color),
        ]),
      ],
    ]),
  );
}

// ── Evaluate dialog: S and L only ────────────────────────────

class _EvaluateOnlyDialog extends StatefulWidget {
  final HazardEntry entry;
  final bool showArabic;
  const _EvaluateOnlyDialog({required this.entry, required this.showArabic});

  @override
  State<_EvaluateOnlyDialog> createState() => _EvaluateOnlyDialogState();
}

class _EvaluateOnlyDialogState extends State<_EvaluateOnlyDialog> {
  late int _severity;
  late int _likelihood;
  bool get _ar => widget.showArabic;

  @override
  void initState() {
    super.initState();
    _severity   = widget.entry.severity   ?? 1;
    _likelihood = widget.entry.likelihood ?? 1;
  }

  int get _score => _severity * _likelihood;
  RiskLevel get _level => HazardEntry.levelFor(_score);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape:
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(children: [
                Expanded(child: Text(widget.entry.hazard,
                    style: GoogleFonts.shareTechMono(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700))),
                IconButton(
                  icon: const Icon(Icons.close, size: 18,
                      color: AppColors.textTertiary),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                ),
              ]),
              const SizedBox(height: 16),

              _RatingSlider(
                label: _ar ? 'الشدة (S)  1 = منخفض  5 = حرج'
                    : 'Severity (S)   1 = low   5 = critical',
                value: _severity,
                onChanged: (v) => setState(() => _severity = v),
              ),
              _RatingSlider(
                label: _ar ? 'الاحتمالية (L)  1 = نادر  5 = مؤكد'
                    : 'Likelihood (L)   1 = rare   5 = certain',
                value: _likelihood,
                onChanged: (v) => setState(() => _likelihood = v),
              ),

              // live result
              _RiskResultCard(
                score: _score,
                level: _level,
                label: _ar ? 'الخطر الأولي' : 'Initial Risk',
                ar:    _ar,
              ),

              const SizedBox(height: 4),
              Text(
                _ar
                    ? 'ℹ️ الإجراء التصحيحي والخطر المتبقي ستُدخله في مرحلة "تأمل"'
                    : 'ℹ️ You\'ll add mitigation & residual risk in the "Consider" step',
                style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textTertiary,
                    height: 1.4),
              ),

              const SizedBox(height: 20),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(
                    context,
                    widget.entry.copyWith(
                      severity:   _severity,
                      likelihood: _likelihood,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.green.withOpacity(0.15),
                    foregroundColor: AppColors.green,
                    side: const BorderSide(color: AppColors.green),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  child: Text(
                    _ar ? 'حفظ التقييم ✓' : 'Save Evaluation ✓',
                    style: GoogleFonts.shareTechMono(fontSize: 12),
                  ),
                ),
              ),
            ]),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// C — CONSIDER: mitigation + residual S & L
// ═══════════════════════════════════════════════════════════════

class _ConsiderSection extends StatelessWidget {
  final HazardState hazardState;
  final ValueChanged<HazardState> onChanged;
  final bool showArabic;
  final Color stepColor;

  const _ConsiderSection({
    required this.hazardState,
    required this.onChanged,
    required this.showArabic,
    required this.stepColor,
  });

  bool get _ar => showArabic;

  void _openConsiderDialog(BuildContext context, HazardEntry entry) async {
    final updated = await showDialog<HazardEntry>(
      context: context,
      builder: (_) => _ConsiderDialog(entry: entry, showArabic: _ar),
    );
    if (updated != null) {
      final newList = hazardState.hazards
          .map((h) => h.id == updated.id ? updated : h)
          .toList();
      onChanged(hazardState.copyWith(hazards: newList));
    }
  }

  @override
  Widget build(BuildContext context) {
    final hazards = hazardState.hazards;
    final color   = stepColor;

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Row(children: [
        Expanded(child: Text(
          _ar ? 'الإجراء التصحيحي والخطر المتبقي' : 'MITIGATION & RESIDUAL RISK',
          style: GoogleFonts.shareTechMono(
              fontSize: 10, color: color, letterSpacing: 1.5),
        )),
        if (hazards.isNotEmpty)
          _CountBadge(
            '${hazards.where((h) => h.hasResidual).length}/${hazards.length}',
            color,
          ),
      ]),
      const SizedBox(height: 10),

      if (hazards.isEmpty)
        _EmptyHint(_ar
            ? 'لا توجد مخاطر — أضف في مرحلة "اكتشف"'
            : 'No hazards — add them in "Detect" first')
      else
        ...hazards.asMap().entries.map((e) => _ConsiderCard(
          key:       ValueKey(e.value.id),
          index:     e.key,
          entry:     e.value,
          ar:        _ar,
          color:     color,
          onConsider: () => _openConsiderDialog(context, e.value),
        )
            .animate()
            .fadeIn(
            duration: 280.ms,
            delay: Duration(milliseconds: e.key * 60))
            .slideY(
            begin: 0.1,
            duration: 280.ms,
            delay: Duration(milliseconds: e.key * 60))),
    ]);
  }
}

class _ConsiderCard extends StatelessWidget {
  final int index;
  final HazardEntry entry;
  final bool ar;
  final Color color;
  final VoidCallback onConsider;

  const _ConsiderCard({
    super.key,
    required this.index,
    required this.entry,
    required this.ar,
    required this.color,
    required this.onConsider,
  });

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: AppColors.elevated,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(
        color: entry.hasResidual
            ? entry.residualLevel.color.withOpacity(0.4)
            : AppColors.border,
      ),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Hazard name + initial risk badge
      Row(children: [
        _IndexCircle(index + 1, color),
        const SizedBox(width: 10),
        Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(entry.hazard,
              style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600)),
          if (entry.isEvaluated)
            Text(
              ar
                  ? 'الخطر الأولي: S=${entry.severity} × L=${entry.likelihood} = ${entry.riskScore} (${entry.riskLevel.label(ar)})'
                  : 'Initial: S=${entry.severity} × L=${entry.likelihood} = ${entry.riskScore} (${entry.riskLevel.label(ar)})',
              style: TextStyle(
                  fontSize: 10,
                  color: entry.riskLevel.color,
                  fontWeight: FontWeight.w500),
            ),
        ])),
      ]),

      // mitigation preview
      if (entry.mitigation.isNotEmpty) ...[
        const SizedBox(height: 6),
        Container(
          padding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.06),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Text(entry.mitigation,
              style: const TextStyle(
                  fontSize: 11, color: AppColors.textSecondary)),
        ),
      ],

      const SizedBox(height: 10),

      // Consider button
      SizedBox(
        width: double.infinity,
        height: 40,
        child: OutlinedButton.icon(
          onPressed: onConsider,
          icon: Icon(
              entry.hasResidual
                  ? Icons.edit
                  : Icons.shield_outlined,
              size: 16),
          label: Text(
            entry.hasResidual
                ? (ar ? 'تعديل الإجراء والمتبقي' : 'Edit Mitigation & Residual')
                : (ar
                ? 'إضافة الإجراء التصحيحي والخطر المتبقي'
                : 'Add Mitigation & Residual Risk'),
            style: GoogleFonts.shareTechMono(fontSize: 11),
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor:
            entry.hasResidual ? entry.residualLevel.color : color,
            side: BorderSide(
              color: entry.hasResidual
                  ? entry.residualLevel.color.withOpacity(0.5)
                  : color.withOpacity(0.5),
            ),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ),

      if (entry.hasResidual) ...[
        const SizedBox(height: 8),
        Row(children: [
          _MiniStat('Res.S', '${entry.residualS}', AppColors.cyan),
          const SizedBox(width: 12),
          _MiniStat('Res.L', '${entry.residualL}', AppColors.cyan),
          const SizedBox(width: 12),
          _MiniStat('Res.', '${entry.residualScore}',
              entry.residualLevel.color),
          const SizedBox(width: 8),
          _SmallBadge(entry.residualLevel.label(ar),
              entry.residualLevel.color),
        ]),
      ],
    ]),
  );
}

// ── Consider dialog: mitigation + residual S & L ─────────────

class _ConsiderDialog extends StatefulWidget {
  final HazardEntry entry;
  final bool showArabic;
  const _ConsiderDialog({required this.entry, required this.showArabic});

  @override
  State<_ConsiderDialog> createState() => _ConsiderDialogState();
}

class _ConsiderDialogState extends State<_ConsiderDialog> {
  late int _resS, _resL;
  late TextEditingController _mitigationCtrl;
  bool get _ar => widget.showArabic;

  @override
  void initState() {
    super.initState();
    _resS           = widget.entry.residualS  ?? 1;
    _resL           = widget.entry.residualL  ?? 1;
    _mitigationCtrl =
        TextEditingController(text: widget.entry.mitigation);
  }

  @override
  void dispose() {
    _mitigationCtrl.dispose();
    super.dispose();
  }

  int get _residualScore => _resS * _resL;
  RiskLevel get _residualLevel => HazardEntry.levelFor(_residualScore);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape:
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // header
              Row(children: [
                Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(widget.entry.hazard,
                      style: GoogleFonts.shareTechMono(
                          fontSize: 13,
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700)),
                  if (widget.entry.isEvaluated)
                    Text(
                      _ar
                          ? 'الخطر الأولي: ${widget.entry.riskScore} — ${widget.entry.riskLevel.label(_ar)}'
                          : 'Initial risk: ${widget.entry.riskScore} — ${widget.entry.riskLevel.label(_ar)}',
                      style: TextStyle(
                          fontSize: 10,
                          color: widget.entry.riskLevel.color),
                    ),
                ])),
                IconButton(
                  icon: const Icon(Icons.close, size: 18,
                      color: AppColors.textTertiary),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                ),
              ]),
              const SizedBox(height: 16),

              // mitigation field
              Text(_ar ? 'الإجراء التصحيحي' : 'Mitigation',
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textSecondary)),
              const SizedBox(height: 6),
              TextField(
                controller: _mitigationCtrl,
                maxLines: 3,
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: _ar
                      ? 'كيف ستعالج الخطر؟'
                      : 'How will you address this hazard?',
                  hintStyle: const TextStyle(
                      fontSize: 11, color: AppColors.textTertiary),
                  filled: true,
                  fillColor: AppColors.elevated,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(color: AppColors.border)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(color: AppColors.border)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(
                          color: AppColors.cyan, width: 1.5)),
                  contentPadding: const EdgeInsets.all(10),
                ),
              ),

              const SizedBox(height: 16),
              Text(_ar ? 'الخطر المتبقي' : 'Residual Risk',
                  style: GoogleFonts.shareTechMono(
                      fontSize: 9,
                      color: AppColors.textTertiary,
                      letterSpacing: 1.5)),
              const SizedBox(height: 10),

              _RatingSlider(
                label: _ar ? 'الشدة المتبقية (S)' : 'Residual Severity (S)',
                value: _resS,
                onChanged: (v) => setState(() => _resS = v),
              ),
              _RatingSlider(
                label: _ar
                    ? 'الاحتمالية المتبقية (L)'
                    : 'Residual Likelihood (L)',
                value: _resL,
                onChanged: (v) => setState(() => _resL = v),
              ),

              _RiskResultCard(
                score: _residualScore,
                level: _residualLevel,
                label: _ar ? 'الخطر المتبقي' : 'Residual Risk',
                ar:    _ar,
              ),

              const SizedBox(height: 20),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(
                    context,
                    widget.entry.copyWith(
                      mitigation: _mitigationCtrl.text.trim(),
                      residualS:  _resS,
                      residualL:  _resL,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.green.withOpacity(0.15),
                    foregroundColor: AppColors.green,
                    side: const BorderSide(color: AppColors.green),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  child: Text(_ar ? 'حفظ ✓' : 'Save ✓',
                      style: GoogleFonts.shareTechMono(fontSize: 12)),
                ),
              ),
            ]),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// CONFIRM + SKIP ROW
// ═══════════════════════════════════════════════════════════════

class _ConfirmSkipRow extends StatefulWidget {
  final TextEditingController controller;
  final DecideStep step;
  final bool showArabic;
  final VoidCallback onComplete;
  final VoidCallback onSkip;

  const _ConfirmSkipRow({
    required this.controller,
    required this.step,
    required this.showArabic,
    required this.onComplete,
    required this.onSkip,
  });

  @override
  State<_ConfirmSkipRow> createState() => _ConfirmSkipRowState();
}

class _ConfirmSkipRowState extends State<_ConfirmSkipRow> {
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _hasText = widget.controller.text.trim().isNotEmpty;
    widget.controller.addListener(_onText);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onText);
    super.dispose();
  }

  void _onText() {
    final v = widget.controller.text.trim().isNotEmpty;
    if (v != _hasText) setState(() => _hasText = v);
  }

  @override
  Widget build(BuildContext context) {
    final color      = widget.step.color;
    final ar         = widget.showArabic;
    final canConfirm = _hasText || widget.step.completed;

    return Row(children: [
      Expanded(
        flex: 3,
        child: SizedBox(
          height: 48,
          child: ElevatedButton(
            onPressed: canConfirm ? widget.onComplete : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: color.withOpacity(0.15),
              foregroundColor: color,
              disabledBackgroundColor: AppColors.elevated,
              disabledForegroundColor: AppColors.textTertiary,
              side: BorderSide(
                  color: canConfirm ? color : AppColors.border),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
            child: Text(
              widget.step.completed
                  ? (ar ? '✓ مكتمل — التالي ▶' : '✓ DONE — NEXT ▶')
                  : (ar ? 'تأكيد وأكمل ▶' : 'CONFIRM & CONTINUE ▶'),
              style: GoogleFonts.shareTechMono(
                  fontSize: 12, letterSpacing: 1.5),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
      const SizedBox(width: 8),
      SizedBox(
        height: 48,
        child: OutlinedButton(
          onPressed: widget.step.completed ? null : widget.onSkip,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.textTertiary,
            side: const BorderSide(color: AppColors.border),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8)),
          ),
          child: Text(ar ? 'تخطَّ' : 'Skip',
              style: GoogleFonts.shareTechMono(fontSize: 12)),
        ),
      ),
    ]);
  }
}

// ═══════════════════════════════════════════════════════════════
// FINISH ROW
// ═══════════════════════════════════════════════════════════════

class _FinishRow extends StatelessWidget {
  final bool showArabic;
  final VoidCallback onFinish;

  const _FinishRow({required this.showArabic, required this.onFinish});

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 52,
    child: ElevatedButton.icon(
      onPressed: onFinish,
      icon: const Icon(Icons.flag_rounded, size: 20),
      label: Text(
        showArabic ? '🎯 عرض التقرير النهائي' : '🎯 VIEW FINAL REPORT',
        style: GoogleFonts.shareTechMono(
            fontSize: 13, letterSpacing: 1.5),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.green.withOpacity(0.15),
        foregroundColor: AppColors.green,
        side: const BorderSide(color: AppColors.green),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)),
        elevation: 0,
      ),
    ),
  );
}

// ═══════════════════════════════════════════════════════════════
// LAST STEP FINISH ROW — enabled when text written, marks step done
// ═══════════════════════════════════════════════════════════════

class _LastStepFinishRow extends StatefulWidget {
  final TextEditingController controller;
  final DecideStep step;
  final bool showArabic;
  final VoidCallback onFinish;
  final VoidCallback onSkip;

  const _LastStepFinishRow({
    required this.controller,
    required this.step,
    required this.showArabic,
    required this.onFinish,
    required this.onSkip,
  });

  @override
  State<_LastStepFinishRow> createState() => _LastStepFinishRowState();
}

class _LastStepFinishRowState extends State<_LastStepFinishRow> {
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _hasText = widget.controller.text.trim().isNotEmpty;
    widget.controller.addListener(_onText);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onText);
    super.dispose();
  }

  void _onText() {
    final v = widget.controller.text.trim().isNotEmpty;
    if (v != _hasText) setState(() => _hasText = v);
  }

  bool get _canFinish => _hasText || widget.step.completed;

  @override
  Widget build(BuildContext context) {
    final ar = widget.showArabic;

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      // hint when no text yet
      if (!_canFinish)
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.amber.withOpacity(0.06),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.amber.withOpacity(0.3)),
            ),
            child: Row(children: [
              const Icon(Icons.info_outline,
                  size: 14, color: AppColors.amber),
              const SizedBox(width: 8),
              Expanded(child: Text(
                ar
                    ? 'اكتب ملاحظاتك أولاً لتفعيل زرار التقرير النهائي'
                    : 'Write your notes above to enable the final report button',
                style: const TextStyle(
                    fontSize: 11, color: AppColors.amber, height: 1.4),
              )),
            ]),
          ),
        ),

      Row(children: [
        // FINISH button
        Expanded(
          flex: 3,
          child: SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _canFinish ? widget.onFinish : null,
              icon: Icon(
                _canFinish ? Icons.flag_rounded : Icons.lock_outline,
                size: 18,
              ),
              label: Text(
                ar ? '🎯 عرض التقرير النهائي' : '🎯 VIEW FINAL REPORT',
                style: GoogleFonts.shareTechMono(
                    fontSize: 12, letterSpacing: 1.5),
                overflow: TextOverflow.ellipsis,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _canFinish
                    ? AppColors.green.withOpacity(0.15)
                    : AppColors.elevated,
                foregroundColor:
                _canFinish ? AppColors.green : AppColors.textTertiary,
                disabledBackgroundColor: AppColors.elevated,
                disabledForegroundColor: AppColors.textTertiary,
                side: BorderSide(
                    color: _canFinish
                        ? AppColors.green
                        : AppColors.border),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        // SKIP still available
        SizedBox(
          height: 52,
          child: OutlinedButton(
            onPressed: widget.step.completed ? null : widget.onSkip,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textTertiary,
              side: const BorderSide(color: AppColors.border),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(ar ? 'تخطَّ' : 'Skip',
                style: GoogleFonts.shareTechMono(fontSize: 12)),
          ),
        ),
      ]),
    ]);
  }
}

// ═══════════════════════════════════════════════════════════════
// SHARED SMALL WIDGETS
// ═══════════════════════════════════════════════════════════════

class _CountBadge extends StatelessWidget {
  final String text;
  final Color color;
  const _CountBadge(this.text, this.color);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: color.withOpacity(0.15),
      borderRadius: BorderRadius.circular(4),
      border: Border.all(color: color.withOpacity(0.4)),
    ),
    child: Text(text,
        style: GoogleFonts.shareTechMono(
            fontSize: 9, color: color, letterSpacing: 1)),
  );
}

class _EmptyHint extends StatelessWidget {
  final String text;
  const _EmptyHint(this.text);

  @override
  Widget build(BuildContext context) => Container(
    height: 72,
    decoration: BoxDecoration(
      color: AppColors.elevated,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: AppColors.border),
    ),
    child: Center(child: Text(text,
        style: const TextStyle(
            fontSize: 12, color: AppColors.textTertiary))),
  );
}

class _Pill extends StatelessWidget {
  final String text;
  final Color color;
  const _Pill(this.text, this.color);

  @override
  Widget build(BuildContext context) => Container(
    padding:
    const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
    decoration: BoxDecoration(
      color: color.withOpacity(0.15),
      borderRadius: BorderRadius.circular(3),
    ),
    child: Text(text,
        style: GoogleFonts.shareTechMono(
            fontSize: 9, color: color, letterSpacing: 1)),
  );
}

class _SmallBadge extends StatelessWidget {
  final String text;
  final Color color;
  const _SmallBadge(this.text, this.color);

  @override
  Widget build(BuildContext context) => Container(
    padding:
    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
      color: color.withOpacity(0.15),
      borderRadius: BorderRadius.circular(4),
      border: Border.all(color: color.withOpacity(0.4)),
    ),
    child: Text(text,
        style: GoogleFonts.shareTechMono(
            fontSize: 8,
            color: color,
            fontWeight: FontWeight.w700)),
  );
}

class _IndexCircle extends StatelessWidget {
  final int number;
  final Color color;
  const _IndexCircle(this.number, this.color);

  @override
  Widget build(BuildContext context) => Container(
    width: 24,
    height: 24,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: color.withOpacity(0.12),
      border: Border.all(color: color.withOpacity(0.4)),
    ),
    child: Center(child: Text('$number',
        style: GoogleFonts.shareTechMono(
            fontSize: 10,
            color: color,
            fontWeight: FontWeight.w700))),
  );
}

class _MiniStat extends StatelessWidget {
  final String label, value;
  final Color color;
  const _MiniStat(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(value,
          style: GoogleFonts.shareTechMono(
              fontSize: 16,
              color: color,
              fontWeight: FontWeight.w700)),
      Text(label,
          style: const TextStyle(
              fontSize: 9, color: AppColors.textTertiary)),
    ],
  );
}

class _RatingSlider extends StatelessWidget {
  final String label;
  final int value;
  final ValueChanged<int> onChanged;
  const _RatingSlider(
      {required this.label, required this.value, required this.onChanged});

  Color get _color {
    if (value >= 4) return AppColors.red;
    if (value >= 3) return AppColors.amber;
    return AppColors.green;
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(children: [
        Expanded(child: Text(label,
            style: const TextStyle(
                fontSize: 11, color: AppColors.textSecondary))),
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: _color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: _color.withOpacity(0.4)),
          ),
          child: Text('$value',
              style: GoogleFonts.shareTechMono(
                  fontSize: 13,
                  color: _color,
                  fontWeight: FontWeight.w700)),
        ),
      ]),
      SliderTheme(
        data: SliderTheme.of(context).copyWith(
          activeTrackColor: _color,
          inactiveTrackColor: AppColors.border,
          thumbColor: _color,
          overlayColor: _color.withOpacity(0.15),
          trackHeight: 4,
        ),
        child: Slider(
          value: value.toDouble(),
          min: 1,
          max: 5,
          divisions: 4,
          onChanged: (v) => onChanged(v.round()),
        ),
      ),
      const SizedBox(height: 6),
    ],
  );
}

class _RiskResultCard extends StatelessWidget {
  final int score;
  final RiskLevel level;
  final String label;
  final bool ar;
  const _RiskResultCard(
      {required this.score,
        required this.level,
        required this.label,
        required this.ar});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: BoxDecoration(
      color: level.bgColor,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: level.color.withOpacity(0.4)),
    ),
    child: Row(children: [
      Text(label,
          style: const TextStyle(
              fontSize: 11, color: AppColors.textSecondary)),
      const Spacer(),
      Text('$score',
          style: GoogleFonts.shareTechMono(
              fontSize: 22,
              color: level.color,
              fontWeight: FontWeight.w700)),
      const SizedBox(width: 8),
      Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: level.color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(4),
          border:
          Border.all(color: level.color.withOpacity(0.5)),
        ),
        child: Text(level.label(ar),
            style: GoogleFonts.shareTechMono(
                fontSize: 10,
                color: level.color,
                fontWeight: FontWeight.w700)),
      ),
    ]),
  );
}