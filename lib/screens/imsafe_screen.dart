/*import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/models.dart';
import '../screens/imsafe/illness_card.dart';
import '../screens/imsafe/medication_Card.dart';
import '../screens/imsafe/stress_Card.dart';
import '../screens/imsafe/emotional_card.dart';
import '../screens/imsafe/alcohol_Card.dart';
import '../screens/imsafe/fatigue_card.dart';
import '../theme/theme.dart';
import '../widgets/widgets.dart';

class ImsafeScreen extends StatefulWidget {
  final List<ImsafeItem> items;
  final bool showArabic;
  final Function(int index, String rating, String notes) onItemChanged;
  final VoidCallback? onComplete;

  const ImsafeScreen({
    super.key,
    required this.items,
    required this.showArabic,
    required this.onItemChanged,
    this.onComplete,
  });

  @override
  State<ImsafeScreen> createState() => _ImsafeScreenState();
}

class _ImsafeScreenState extends State<ImsafeScreen> {
  int _expanded = 0;

  List<ImsafeItem> get items => widget.items;

  int get totalRisk => items.fold(0, (s, i) => s + i.riskScore);

  String get flightDecision {
    final high = items.where((i) => i.rating == 'HIGH').length;
    if (high >= 2 || totalRisk >= 8) return 'NO-GO';
    if (high == 1 || totalRisk >= 4) return 'CAUTION';
    return 'GO';
  }

  Color get decisionColor {
    switch (flightDecision) {
      case 'GO':
        return AppColors.green;
      case 'CAUTION':
        return AppColors.amber;
      default:
        return AppColors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: widget.showArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColors.bg,
        appBar: AppBar(title: const Text('IMSAFE CHECKLIST')),
        body: SingleChildScrollView(
          padding: R.pad(context),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            SectionHeader(
              emoji: '🧑‍✈️',
              title: 'IMSAFE',
              subtitle: widget.showArabic
                  ? 'قيّم جاهزيتك الشخصية قبل كل رحلة. أجب بصدق على كل بند.'
                  : 'Self-assess your personal fitness before every flight.',
              color: AppColors.cyan,
            ).animate().fadeIn(duration: 600.ms),
            const SizedBox(height: 16),

            // Live summary
            _ScoreSummary(
              totalRisk: totalRisk,
              decision: flightDecision,
              decisionColor: decisionColor,
              showArabic: widget.showArabic,
              items: items,
            ).animate().fadeIn(delay: 150.ms),
            const SizedBox(height: 16),

            // Items
            // Items
            ...items.asMap().entries.map((e) {
              final idx = e.key;
              final item = e.value;

              // ✅ منطق اختيار البطارة المناسبة
              Widget cardWidget;
              if (item.key == 'I') {
                cardWidget = IllnessCard(
                  item: item,
                  index: idx,
                  isExpanded: _expanded == idx,
                  showArabic: widget.showArabic,
                  onTap: () =>
                      setState(() => _expanded = _expanded == idx ? -1 : idx),
                  onRatingChanged: (r) {
                    setState(() => item.rating = r);
                  },
                  onNotesChanged: (n) {
                    item.notes = n;
                  },
                  onItemChanged: widget.onItemChanged,
                );
              } else if (item.key == 'M') {
                // ✅ إضافة شرط بطاقة الأدوية
                cardWidget = MedicationCard(
                  item: item,
                  index: idx,
                  isExpanded: _expanded == idx,
                  showArabic: widget.showArabic,
                  onTap: () =>
                      setState(() => _expanded = _expanded == idx ? -1 : idx),
                  onRatingChanged: (r) {
                    setState(() => item.rating = r);
                  },
                  onNotesChanged: (n) {
                    item.notes = n;
                  },
                  onItemChanged: widget.onItemChanged,
                );
              } else if (item.key == 'A') {
                // ✅ إضافة شرط بطاقة الأدوية
                cardWidget = AlcoholCard(
                  item: item,
                  index: idx,
                  isExpanded: _expanded == idx,
                  showArabic: widget.showArabic,
                  onTap: () =>
                      setState(() => _expanded = _expanded == idx ? -1 : idx),
                  onRatingChanged: (r) {
                    setState(() => item.rating = r);
                  },
                  onNotesChanged: (n) {
                    item.notes = n;
                  },
                  onItemChanged: widget.onItemChanged,
                );
              }  else if (item.key == 'E') {
                cardWidget = EmotionalCard(
                  item: item,
                  index: idx,
                  isExpanded: _expanded == idx,
                  showArabic: widget.showArabic,
                  onTap: () =>
                      setState(() => _expanded = _expanded == idx ? -1 : idx),
                  onRatingChanged: (r) {
                    setState(() => item.rating = r);
                  },
                  onNotesChanged: (n) {
                    item.notes = n;
                  },
                  onItemChanged: widget.onItemChanged,
                );
              }else if (item.key == 'S') {
                cardWidget = StressCard(
                  item: item,
                  index: idx,
                  isExpanded: _expanded == idx,
                  showArabic: widget.showArabic,
                  onTap: () =>
                      setState(() => _expanded = _expanded == idx ? -1 : idx),
                  onRatingChanged: (r) {
                    setState(() => item.rating = r);
                  },
                  onNotesChanged: (n) {
                    item.notes = n;
                  },
                  onItemChanged: widget.onItemChanged,
                );
              } else {
                cardWidget = FatigueCard(
                  item: item,
                  index: idx, // ✅ تمرير الفهرس الصحيح
                  isExpanded: _expanded == idx,
                  showArabic: widget.showArabic,
                  onTap: () =>
                      setState(() => _expanded = _expanded == idx ? -1 : idx),
                  onRatingChanged: (r) {
                    // تحديث حالة الواجهة في الشاشة الأم
                    setState(() => item.rating = r);
                  },
                  onNotesChanged: (n) {
                    // تحديث حالة الواجهة في الشاشة الأم
                    setState(() => item.notes = n);
                  },
                  onItemChanged: widget.onItemChanged, // ✅ تمرير الدالة الصحيحة
                );
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: cardWidget.animate().fadeIn(delay: (200 + idx * 60).ms),
              );
            }),
            const SizedBox(height: 20),
            Row(children: [
              Expanded(
                  child: CBtn(
                label: widget.showArabic ? 'إعادة' : 'RESET',
                icon: Icons.refresh,
                outlined: true,
                onPressed: () => setState(() {
                  for (int i = 0; i < items.length; i++) {
                    items[i].rating = 'LOW';
                    items[i].notes = '';
                    widget.onItemChanged(i, 'LOW', '');
                  }
                }),
              )),
              const SizedBox(width: 12),
              Expanded(
                  flex: 2,
                  child: CBtn(
                    label:
                        widget.showArabic ? 'التالي: PAVE ▶' : 'NEXT: PAVE ▶',
                    icon: Icons.arrow_forward,
                    color: decisionColor,
                    onPressed: widget.onComplete,
                  )),
            ]),
            const SizedBox(height: 40),
          ]),
        ),
      ),
    );
  }
}

class _ScoreSummary extends StatelessWidget {
  final int totalRisk;
  final String decision;
  final Color decisionColor;
  final bool showArabic;
  final List<ImsafeItem> items;

  const _ScoreSummary(
      {required this.totalRisk,
      required this.decision,
      required this.decisionColor,
      required this.showArabic,
      required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: decisionColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: decisionColor.withOpacity(0.3)),
      ),
      child: Column(children: [
        Row(children: [
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(showArabic ? 'قرار الطيران' : 'FLIGHT DECISION',
                    style: GoogleFonts.shareTechMono(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                        letterSpacing: 2)),
                const SizedBox(height: 4),
                Text(decision,
                    style: GoogleFonts.shareTechMono(
                        fontSize: 26,
                        color: decisionColor,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 3)),
              ])),
          Text(
              decision == 'GO'
                  ? '✅'
                  : decision == 'CAUTION'
                      ? '⚠️'
                      : '🛑',
              style: const TextStyle(fontSize: 36)),
        ]),
        const SizedBox(height: 12),
        const Divider(color: AppColors.border, height: 1),
        const SizedBox(height: 10),
        ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Row(children: [
                Text(item.iconEmoji, style: const TextStyle(fontSize: 13)),
                const SizedBox(width: 8),
                Expanded(
                    child: Text(showArabic ? item.arabicTitle : item.title,
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.textSecondary))),
                RiskBadge(item.rating),
              ]),
            )),
      ]),
    );
  }
}

class _ImsafeCard extends StatelessWidget {
  final ImsafeItem item;
  final bool isExpanded;
  final bool showArabic;
  final VoidCallback onTap;
  final ValueChanged<String> onRatingChanged;
  final ValueChanged<String> onNotesChanged;

  const _ImsafeCard(
      {required this.item,
      required this.isExpanded,
      required this.showArabic,
      required this.onTap,
      required this.onRatingChanged,
      required this.onNotesChanged});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.riskColor(item.rating);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(9),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          IntrinsicHeight(
            child:
                Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Container(width: 3, color: color),
              Expanded(
                child: Material(
                  color: AppColors.surface,
                  child: InkWell(
                    onTap: onTap,
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: color.withOpacity(0.1),
                              border:
                                  Border.all(color: color.withOpacity(0.3))),
                          child: Center(
                              child: Text(item.key,
                                  style: GoogleFonts.shareTechMono(
                                      fontSize: 13,
                                      color: color,
                                      fontWeight: FontWeight.w700))),
                        ),
                        const SizedBox(width: 10),
                        Text(item.iconEmoji,
                            style: const TextStyle(fontSize: 20)),
                        const SizedBox(width: 8),
                        Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                              Text(showArabic ? item.arabicTitle : item.title,
                                  style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w600)),
                              Text(
                                  showArabic
                                      ? item.arabicSubtitle
                                      : item.subtitle,
                                  style: const TextStyle(
                                      fontSize: 10,
                                      color: AppColors.textSecondary)),
                            ])),
                        RiskBadge(item.rating),
                        const SizedBox(width: 6),
                        Icon(isExpanded ? Icons.expand_less : Icons.expand_more,
                            size: 16, color: AppColors.textTertiary),
                      ]),
                    ),
                  ),
                ),
              ),
            ]),
          ),
          if (isExpanded) ...[
            const Divider(height: 1, color: AppColors.border),
            Container(
              color: AppColors.surface,
              padding: const EdgeInsets.all(14),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: AppColors.elevated,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.border)),
                      child: Text(
                          showArabic
                              ? item.arabicDescription
                              : item.description,
                          style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              height: 1.5)),
                    ),
                    const SizedBox(height: 12),
                    Text(showArabic ? 'مستوى المخاطرة:' : 'RISK RATING:',
                        style: GoogleFonts.shareTechMono(
                            fontSize: 10,
                            color: AppColors.textTertiary,
                            letterSpacing: 1.5)),
                    const SizedBox(height: 8),
                    RiskSelector(
                        value: item.rating, onChanged: onRatingChanged),
                    const SizedBox(height: 12),
                    Text(showArabic ? 'ملاحظات:' : 'NOTES:',
                        style: GoogleFonts.shareTechMono(
                            fontSize: 10,
                            color: AppColors.textTertiary,
                            letterSpacing: 1.5)),
                    const SizedBox(height: 6),
                    TextFormField(
                      initialValue: item.notes,
                      onChanged: onNotesChanged,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        hintText: showArabic
                            ? 'أدخل ملاحظاتك هنا...'
                            : 'Enter notes...',
                        hintStyle: const TextStyle(
                            fontSize: 11, color: AppColors.textTertiary),
                        filled: true,
                        fillColor: AppColors.surfaceAlt,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide:
                                const BorderSide(color: AppColors.border)),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide:
                                const BorderSide(color: AppColors.border)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: const BorderSide(
                                color: AppColors.cyan, width: 1.5)),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                      ),
                      maxLines: 2,
                    ),
                  ]),
            ),
          ],
        ]),
      ),
    );
  }
}*/
// lib/screens/imsafe_screen_v2.dart
// ══════════════════════════════════════════════════════════════
// Enhanced IMSAFE Screen — Real-time Pilot Risk Assessment
// Professional aviation-grade medical/fitness-for-duty dashboard
// ══════════════════════════════════════════════════════════════

import 'package:check_list_stress/screens/imsafe/fatigue_card.dart';
import 'package:check_list_stress/screens/imsafe/imsafe_severity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/models.dart';
import '../theme/theme.dart';
import '../widgets/widgets.dart';
import 'imsafe/illness_card.dart';
import 'imsafe/medication_Card.dart';
import 'imsafe/stress_Card.dart';
import 'imsafe/emotional_card.dart';
import 'imsafe/alcohol_Card.dart';

class ImsafeScreenV2 extends StatefulWidget {
  final List<ImsafeItem> items;
  final bool showArabic;
  final Function(int index, String rating, String notes) onItemChanged;
  final VoidCallback? onComplete;

  const ImsafeScreenV2({
    super.key,
    required this.items,
    required this.showArabic,
    required this.onItemChanged,
    this.onComplete,
  });

  @override
  State<ImsafeScreenV2> createState() => _ImsafeScreenV2State();
}

class _ImsafeScreenV2State extends State<ImsafeScreenV2>
    with SingleTickerProviderStateMixin {
  int _expanded = 0;
  late TabController _tabCtrl;

  List<ImsafeItem> get items => widget.items;
  late double _hoursOfSleep;

  // ── Compute per-category risk scores (0-100) ──────────────
  double _itemRisk(ImsafeItem item) {
    // First try to get the numeric riskScore from subItems
    final raw = item.subItems['riskScore'];
    if (raw != null) {
      final v = (raw is double ? raw : (raw as int).toDouble());
      return v.clamp(0.0, 100.0);
    }
    // Fallback from rating
    switch (item.rating) {
      case 'HIGH':
        return 85.0;
      case 'MEDIUM':
        return 45.0;
      default:
        return 5.0;
    }
  }

  double get _illnessRisk => items.length > 0 ? _itemRisk(items[0]) : 0;
  double get _medicationRisk => items.length > 1 ? _itemRisk(items[1]) : 0;
  double get _stressRisk => items.length > 2 ? _itemRisk(items[2]) : 0;
  double get _alcoholRisk => items.length > 3 ? _itemRisk(items[3]) : 0;
  double get _fatigueRisk => items.length > 4 ? _itemRisk(items[4]) : 0;
  double get _emotionRisk => items.length > 5 ? _itemRisk(items[5]) : 0;

  // ── Weighted fitness-to-fly score ─────────────────────────
  // Weights reflect aviation medical literature importance
  double get _fitnessRiskScore {
    const weights = [0.20, 0.15, 0.20, 0.15, 0.20, 0.10];
    final scores = [
      _illnessRisk,
      _medicationRisk,
      _stressRisk,
      _alcoholRisk,
      _fatigueRisk,
      _emotionRisk,
    ];
    double total = 0;
    for (int i = 0; i < scores.length; i++) total += scores[i] * weights[i];
    return total.clamp(0.0, 100.0);
  }

  String get _fitnessDecision {
    final s = _fitnessRiskScore;
    // Any HIGH item = immediate caution/no-go
    final hasHigh = items.any((i) => i.rating == 'HIGH');
    final hasMedium = items.any((i) => i.rating == 'MEDIUM');
    if (hasHigh || s >= 60) return 'NOT_FIT';
    if (hasMedium || s >= 35) return 'CAUTION';
    return 'SAFE';
  }

  String get _legacyDecision {
    final high = items.where((i) => i.rating == 'HIGH').length;
    final total = items.fold(0, (s, i) => s + i.riskScore);
    if (high >= 2 || total >= 8) return 'NO-GO';
    if (high == 1 || total >= 4) return 'CAUTION';
    return 'GO';
  }

  Color get _decisionColor {
    switch (_fitnessDecision) {
      case 'SAFE':
        return AppColors.green;
      case 'CAUTION':
        return AppColors.amber;
      default:
        return AppColors.red;
    }
  }

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    // _hoursOfSleep = (widget.items[0].subItems['hoursOfSleep'] ?? 7.0).toDouble(); // ✅

  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.bg : const Color(0xFFF0F4F8);

    return Directionality(
      textDirection: widget.showArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: bg,
        appBar: AppBar(
          backgroundColor: isDark ? AppColors.surface : Colors.white,
          elevation: 0,
          title: Text(
            widget.showArabic ? 'تقييم IMSAFE' : 'IMSAFE ASSESSMENT',
            style: GoogleFonts.shareTechMono(
                fontSize: 15,
                color: AppColors.cyan,
                fontWeight: FontWeight.w700,
                letterSpacing: 2),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48),
            child: Container(
              color: isDark ? AppColors.surface : Colors.white,
              child: TabBar(
                controller: _tabCtrl,
                indicatorColor: AppColors.cyan,
                indicatorWeight: 2,
                labelColor: AppColors.cyan,
                unselectedLabelColor: AppColors.textTertiary,
                labelStyle:
                    GoogleFonts.shareTechMono(fontSize: 9, letterSpacing: 1.5),
                tabs: [
                  Tab(text: widget.showArabic ? 'التقييم' : 'ASSESSMENT'),
                  Tab(text: widget.showArabic ? 'الملخص' : 'SUMMARY'),
                ],
              ),
            ),
          ),
        ),
        body: TabBarView(
          controller: _tabCtrl,
          children: [
            // ── Tab 0: Assessment Cards ──────────────────
            _buildAssessmentTab(),
            // ── Tab 1: Reference Summary ─────────────────
            _buildSummaryTab(isDark, bg),
          ],
        ),
      ),
    );
  }

  // ── Assessment Tab ─────────────────────────────────────────
  Widget _buildAssessmentTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 100),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        // Fitness banner
        _FitnessBanner(
          riskScore: _fitnessRiskScore,
          decision: _fitnessDecision,
          showArabic: widget.showArabic,
        ).animate().fadeIn(duration: 500.ms),
        const SizedBox(height: 14),

        // Items
        ...items.asMap().entries.map((e) {
          final idx = e.key;
          final item = e.value;
          final card = _buildCard(item, idx);
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: card.animate().fadeIn(delay: (100 + idx * 50).ms),
          );
        }),

        const SizedBox(height: 16),

        // Action buttons
        Row(children: [
          Expanded(
            child: CBtn(
              label: widget.showArabic ? 'إعادة' : 'RESET',
              icon: Icons.refresh,
              outlined: true,
              onPressed: () => setState(() {
                for (int i = 0; i < items.length; i++) {
                  items[i].rating = 'LOW';
                  items[i].notes = '';
                  items[i].subItems.clear();
                  widget.onItemChanged(i, 'LOW', '');
                }
              }),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: CBtn(
              label: widget.showArabic ? 'التالي: PAVE ▶' : 'NEXT: PAVE ▶',
              icon: Icons.arrow_forward,
              color: _decisionColor,
              onPressed: widget.onComplete,
            ),
          ),
        ]),
      ]),
    );
  }

  Widget _buildCard(ImsafeItem item, int idx) {
    final isExp = _expanded == idx;
    void onTap() => setState(() => _expanded = isExp ? -1 : idx);

    switch (item.key) {
      case 'I':
        return IllnessCard(
          item: item,
          index: idx,
          isExpanded: isExp,
          showArabic: widget.showArabic,
          onTap: onTap,
          onRatingChanged: (r) => setState(() => item.rating = r),
          onNotesChanged: (n) {
            item.notes = n;
          },
          onItemChanged: (i, r, n) {
            widget.onItemChanged(i, r, n);
            setState(() {});
          },
        );
      case 'M':
        return MedicationCard(
          item: item,
          index: idx,
          isExpanded: isExp,
          showArabic: widget.showArabic,
          onTap: onTap,
          onRatingChanged: (r) => setState(() => item.rating = r),
          onNotesChanged: (n) {
            item.notes = n;
          },
          onItemChanged: (i, r, n) {
            widget.onItemChanged(i, r, n);
            setState(() {});
          },
        );
      case 'S':
        return StressCard(
          item: item,
          index: idx,
          isExpanded: isExp,
          showArabic: widget.showArabic,
          onTap: onTap,
          onRatingChanged: (r) => setState(() => item.rating = r),
          onNotesChanged: (n) {
            item.notes = n;
          },
          onItemChanged: (i, r, n) {
            widget.onItemChanged(i, r, n);
            setState(() {});
          },
        );
      case 'A':
        return AlcoholCard(
          item: item,
          index: idx,
          isExpanded: isExp,
          showArabic: widget.showArabic,
          onTap: onTap,
          onRatingChanged: (r) => setState(() => item.rating = r),
          onNotesChanged: (n) {
            item.notes = n;
          },
          onItemChanged: (i, r, n) {
            widget.onItemChanged(i, r, n);
            setState(() {});
          },
        );
      case 'F':
        // ✅ Use new enhanced fatigue card
        return FatigueCardV2(
          item: item,
          index: idx,
          isExpanded: isExp,
          showArabic: widget.showArabic,
          onTap: onTap,
          onRatingChanged: (r) => setState(() => item.rating = r),
          onNotesChanged: (n) {
            item.notes = n;
          },
          onItemChanged: (i, r, n) {
            widget.onItemChanged(i, r, n);
            setState(() {});
          },
        );
      case 'E':
        return EmotionalCard(
          item: item,
          index: idx,
          isExpanded: isExp,
          showArabic: widget.showArabic,
          onTap: onTap,
          onRatingChanged: (r) => setState(() => item.rating = r),
          onNotesChanged: (n) {
            item.notes = n;
          },
          onItemChanged: (i, r, n) {
            widget.onItemChanged(i, r, n);
            setState(() {});
          },
        );
      default:
        return const SizedBox.shrink();
    }
  }

  // ── Summary Tab ────────────────────────────────────────────
  Widget _buildSummaryTab(bool isDark, Color bg) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        // ── Fitness-to-Fly Score Card ────────────────────
        _FitnessToFlyCard(
          riskScore: _fitnessRiskScore,
          decision: _fitnessDecision,
          showArabic: widget.showArabic,
        ).animate().fadeIn(duration: 400.ms),
        const SizedBox(height: 16),

        // ── Category Reference Card ──────────────────────
        _CategoryReferenceCard(
          illnessRisk: _illnessRisk,
          medicationRisk: _medicationRisk,
          stressRisk: _stressRisk,
          alcoholRisk: _alcoholRisk,
          fatigueRisk: _fatigueRisk,
          emotionRisk: _emotionRisk,
          showArabic: widget.showArabic,
        ).animate().fadeIn(delay: 100.ms),
        const SizedBox(height: 16),

        // ── IMSAFE Rating Grid ───────────────────────────
        _ImsafeRatingGrid(
          items: items,
          showArabic: widget.showArabic,
        ).animate().fadeIn(delay: 200.ms),
        const SizedBox(height: 16),

        // ── Aviation Context Card ─────────────────────────
        _AviationContextCard(
          riskScore: _fitnessRiskScore,
          showArabic: widget.showArabic,
        ).animate().fadeIn(delay: 300.ms),

        const SizedBox(height: 40),
      ]),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// FITNESS BANNER (assessment tab top)
// ══════════════════════════════════════════════════════════════
class _FitnessBanner extends StatelessWidget {
  final double riskScore;
  final String decision;
  final bool showArabic;
  const _FitnessBanner({
    required this.riskScore,
    required this.decision,
    required this.showArabic,
  });

  Color get _color {
    switch (decision) {
      case 'SAFE':
        return AppColors.green;
      case 'CAUTION':
        return AppColors.amber;
      default:
        return AppColors.red;
    }
  }

  String get _label {
    final ar = showArabic;
    switch (decision) {
      case 'SAFE':
        return ar ? '✅ آمن للطيران' : '✅ FIT TO FLY';
      case 'CAUTION':
        return ar ? '⚠️ طر بحذر' : '⚠️ FLY WITH CAUTION';
      default:
        return ar ? '⛔ غير مؤهل للطيران' : '⛔ NOT FIT TO FLY';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _color.withOpacity(0.4), width: 1.5),
      ),
      child: Row(children: [
        // Score circle
        FitnessScoreBadge(score: riskScore, showArabic: showArabic),
        const SizedBox(width: 16),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              showArabic ? 'حالة اللياقة للطيران' : 'FITNESS-TO-FLY STATUS',
              style: GoogleFonts.shareTechMono(
                  fontSize: 9,
                  color: AppColors.textTertiary,
                  letterSpacing: 1.5),
            ),
            const SizedBox(height: 4),
            Text(
              _label,
              style: GoogleFonts.shareTechMono(
                  fontSize: 15,
                  color: _color,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1),
            ),
            const SizedBox(height: 6),
            // Mini progress bar
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: riskScore / 100),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
              builder: (_, v, __) => ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: v,
                  minHeight: 6,
                  backgroundColor: AppColors.border,
                  valueColor: AlwaysStoppedAnimation(_color),
                ),
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// FITNESS-TO-FLY CARD (summary tab)
// ══════════════════════════════════════════════════════════════
class _FitnessToFlyCard extends StatelessWidget {
  final double riskScore;
  final String decision;
  final bool showArabic;
  const _FitnessToFlyCard({
    required this.riskScore,
    required this.decision,
    required this.showArabic,
  });

  Color get _c {
    switch (decision) {
      case 'SAFE':
        return AppColors.green;
      case 'CAUTION':
        return AppColors.amber;
      default:
        return AppColors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final level = SeverityLevel.fromValue(riskScore);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surface : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _c.withOpacity(0.35), width: 1.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: Column(children: [
          // Top accent bar
          Container(height: 4, color: _c),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(children: [
              Text(
                showArabic ? 'مؤشر اللياقة للطيران' : 'FITNESS-TO-FLY INDEX',
                style: GoogleFonts.shareTechMono(
                    fontSize: 10,
                    color: AppColors.textTertiary,
                    letterSpacing: 2),
              ),
              const SizedBox(height: 16),

              // Big score display
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: riskScore),
                  duration: const Duration(milliseconds: 900),
                  curve: Curves.easeOutCubic,
                  builder: (_, v, __) => Text(
                    '${v.toInt()}',
                    style: GoogleFonts.shareTechMono(
                        fontSize: 60, color: _c, fontWeight: FontWeight.w700),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const SizedBox(height: 24),
                    Text('%',
                        style:
                            GoogleFonts.shareTechMono(fontSize: 20, color: _c)),
                    Text(
                      showArabic ? 'مخاطرة' : 'RISK',
                      style: GoogleFonts.shareTechMono(
                          fontSize: 9,
                          color: AppColors.textTertiary,
                          letterSpacing: 1),
                    ),
                  ],
                ),
              ]),

              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: _c.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _c.withOpacity(0.4)),
                ),
                child: Text(
                  '${level.emoji}  ${showArabic ? level.arabicLabel : level.label}',
                  style: GoogleFonts.shareTechMono(
                      fontSize: 16,
                      color: _c,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2),
                ),
              ),
              const SizedBox(height: 16),

              // Gradient scale
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  height: 18,
                  child: Stack(children: [
                    // Gradient
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(colors: [
                          Color(0xFF00E676),
                          Color(0xFFCDDC39),
                          Color(0xFFFFB020),
                          Color(0xFFFF6B35),
                          Color(0xFFFF3D57),
                        ]),
                      ),
                    ),
                    // Pointer
                    Positioned(
                      left: (riskScore / 100) *
                              (MediaQuery.of(context).size.width - 64) -
                          2,
                      top: 0,
                      bottom: 0,
                      child: Container(
                        width: 4,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(2),
                          boxShadow: [
                            BoxShadow(color: Colors.black26, blurRadius: 4)
                          ],
                        ),
                      ),
                    ),
                  ]),
                ),
              ),
              const SizedBox(height: 4),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('SAFE',
                    style: GoogleFonts.shareTechMono(
                        fontSize: 7, color: AppColors.green)),
                Text('CAUTION',
                    style: GoogleFonts.shareTechMono(
                        fontSize: 7, color: AppColors.amber)),
                Text('NOT FIT',
                    style: GoogleFonts.shareTechMono(
                        fontSize: 7, color: AppColors.red)),
              ]),
            ]),
          ),
        ]),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// CATEGORY REFERENCE CARD
// ══════════════════════════════════════════════════════════════
class _CategoryReferenceCard extends StatelessWidget {
  final double illnessRisk, medicationRisk, stressRisk;
  final double alcoholRisk, fatigueRisk, emotionRisk;
  final bool showArabic;
  const _CategoryReferenceCard({
    required this.illnessRisk,
    required this.medicationRisk,
    required this.stressRisk,
    required this.alcoholRisk,
    required this.fatigueRisk,
    required this.emotionRisk,
    required this.showArabic,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surface : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
              width: 3,
              height: 16,
              decoration:
                  BoxDecoration(              color: AppColors.cyan,

                      borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 8),
          Text(
            showArabic ? 'مرجع مخاطر IMSAFE' : 'IMSAFE RISK REFERENCE',
            style: GoogleFonts.shareTechMono(
                fontSize: 10,
                color: AppColors.textTertiary,
                letterSpacing: 1.5),
          ),
        ]),
        const SizedBox(height: 14),
        CategoryScoreRow(
          emoji: '🤒',
          label: 'Illness',
          arabicLabel: 'المرض',
          riskScore: illnessRisk,
          showArabic: showArabic,
        ),
        CategoryScoreRow(
          emoji: '💊',
          label: 'Medication',
          arabicLabel: 'الأدوية',
          riskScore: medicationRisk,
          showArabic: showArabic,
        ),
        CategoryScoreRow(
          emoji: '😰',
          label: 'Stress',
          arabicLabel: 'الإجهاد',
          riskScore: stressRisk,
          showArabic: showArabic,
        ),
        CategoryScoreRow(
          emoji: '🍺',
          label: 'Alcohol',
          arabicLabel: 'الكحول',
          riskScore: alcoholRisk,
          showArabic: showArabic,
        ),
        CategoryScoreRow(
          emoji: '😴',
          label: 'Fatigue',
          arabicLabel: 'الإرهاق',
          riskScore: fatigueRisk,
          showArabic: showArabic,
        ),
        CategoryScoreRow(
          emoji: '💭',
          label: 'Emotion',
          arabicLabel: 'العواطف',
          riskScore: emotionRisk,
          showArabic: showArabic,
        ),
      ]),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// IMSAFE RATING GRID
// ══════════════════════════════════════════════════════════════
class _ImsafeRatingGrid extends StatelessWidget {
  final List<ImsafeItem> items;
  final bool showArabic;
  const _ImsafeRatingGrid({required this.items, required this.showArabic});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surface : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
              width: 3,
              height: 16,
              decoration:
                  BoxDecoration(              color: AppColors.amber,

                      borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 8),
          Text(
            showArabic ? 'تقييمات بنود IMSAFE' : 'IMSAFE ITEM RATINGS',
            style: GoogleFonts.shareTechMono(
                fontSize: 10,
                color: AppColors.textTertiary,
                letterSpacing: 1.5),
          ),
        ]),
        const SizedBox(height: 14),

        // Grid: 2 columns
        LayoutBuilder(builder: (ctx, constraints) {
          final w = (constraints.maxWidth - 10) / 2;
          return Wrap(
            spacing: 10,
            runSpacing: 10,
            children: items
                .map((item) => SizedBox(
                      width: w,
                      child: _ImsafeRatingTile(
                        item: item,
                        showArabic: showArabic,
                      ),
                    ))
                .toList(),
          );
        }),
      ]),
    );
  }
}

class _ImsafeRatingTile extends StatelessWidget {
  final ImsafeItem item;
  final bool showArabic;
  const _ImsafeRatingTile({required this.item, required this.showArabic});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.riskColor(item.rating);
    final rawScore = item.subItems['riskScore'];
    final score = rawScore != null
        ? (rawScore is double ? rawScore : (rawScore as int).toDouble())
        : (item.rating == 'HIGH'
            ? 85.0
            : item.rating == 'MEDIUM'
                ? 45.0
                : 5.0);
    final level = SeverityLevel.fromValue(score);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(item.iconEmoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              showArabic ? item.arabicTitle : item.title,
              style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ]),
        const SizedBox(height: 8),
        // Score bar
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: score / 100),
            duration: const Duration(milliseconds: 700),
            builder: (_, v, __) => LinearProgressIndicator(
              value: v,
              minHeight: 8,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation(level.color),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(
            '${level.emoji} ${showArabic ? level.arabicLabel : level.label}',
            style: GoogleFonts.shareTechMono(
                fontSize: 8, color: level.color, fontWeight: FontWeight.w700),
          ),
          Text(
            '${score.toInt()}%',
            style: GoogleFonts.shareTechMono(
                fontSize: 10, color: level.color, fontWeight: FontWeight.w700),
          ),
        ]),
      ]),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// AVIATION CONTEXT CARD
// ══════════════════════════════════════════════════════════════
class _AviationContextCard extends StatelessWidget {
  final double riskScore;
  final bool showArabic;
  const _AviationContextCard({
    required this.riskScore,
    required this.showArabic,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bool ar = showArabic;
    final level = SeverityLevel.fromValue(riskScore);

    final items = riskScore <= 20
        ? [
            [
              '✅',
              ar ? 'قدرات معرفية كاملة' : 'Full cognitive capacity',
              ar ? 'جميع مهام الطيران مسموحة' : 'All flight tasks permitted'
            ],
            [
              '✅',
              ar ? 'الوعي الظرفي سليم' : 'Situational awareness intact',
              ar ? 'القرار الطبيعي متوقع' : 'Normal decision-making expected'
            ],
            [
              '✅',
              ar ? 'ردود أفعال طبيعية' : 'Normal reaction times',
              ar
                  ? 'الزمن الرجعي ضمن المعدل الطبيعي'
                  : 'Reaction times within normal range'
            ],
          ]
        : riskScore <= 40
            ? [
                [
                  '⚠️',
                  ar ? 'انخفاض بسيط في الأداء' : 'Mild performance reduction',
                  ar
                      ? 'راقب القرار طوال الرحلة'
                      : 'Monitor decision-making throughout flight'
                ],
                [
                  '⚠️',
                  ar ? 'التعب قد يتراكم' : 'Fatigue may accumulate',
                  ar
                      ? 'مراقبة ذاتية متكررة مطلوبة'
                      : 'Frequent self-monitoring required'
                ],
                [
                  '⚠️',
                  ar
                      ? 'بلّغ المتحكم بأرضية إذا ساءت'
                      : 'Inform ATC if condition worsens',
                  ar
                      ? 'استعد للأولوية إذا لزم'
                      : 'Be prepared to declare priority if needed'
                ],
              ]
            : riskScore <= 60
                ? [
                    [
                      '🟠',
                      ar
                          ? 'ضعف معرفي ملحوظ'
                          : 'Noticeable cognitive impairment',
                      ar
                          ? 'قد تكون متطلبات التصريح بالطيران مخترقة'
                          : 'Flight fitness requirements may be breached'
                    ],
                    [
                      '🟠',
                      ar
                          ? 'احتمالية الخطأ مرتفعة'
                          : 'Error probability elevated',
                      ar
                          ? 'تجنب الطيران الاستوائي أو المعقد'
                          : 'Avoid instrument or complex flying'
                    ],
                    [
                      '🟠',
                      ar
                          ? 'استشر طبيب الطيران'
                          : 'Consult aviation medical officer',
                      ar
                          ? 'قبل القرار النهائي'
                          : 'Before final go/no-go decision'
                    ],
                  ]
                : [
                    [
                      '❌',
                      ar ? 'لا تطير' : 'DO NOT FLY',
                      ar
                          ? 'مؤشرات اللياقة الطبية مخترقة'
                          : 'Medical fitness indicators breached'
                    ],
                    [
                      '❌',
                      ar
                          ? 'القدرات المعرفية منخفضة بشكل خطير'
                          : 'Cognitive capacity dangerously reduced',
                      ar
                          ? 'خطر حادث مرتفع جداً'
                          : 'Accident risk critically elevated'
                    ],
                    [
                      '❌',
                      ar ? 'أبلغ قائد الطاقم' : 'Notify crew commander',
                      ar
                          ? 'واطلب التوقف عن الخدمة'
                          : 'and request removal from duty'
                    ],
                  ];

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surface : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: level.color.withOpacity(0.3)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
              width: 3,
              height: 16,
              decoration:
                  BoxDecoration(              color: level.color,
                      borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 8),
          Text(
            ar ? 'السياق الجوي' : 'AVIATION CONTEXT',
            style: GoogleFonts.shareTechMono(
                fontSize: 10,
                color: AppColors.textTertiary,
                letterSpacing: 1.5),
          ),
        ]),
        const SizedBox(height: 12),
        ...items.map((it) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child:
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(it[0], style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(it[1],
                            style: TextStyle(
                                fontSize: 12,
                                color: level.color,
                                fontWeight: FontWeight.w600)),
                        Text(it[2],
                            style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                                height: 1.4)),
                      ]),
                ),
              ]),
            )),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.elevated,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(children: [
            const Text('📋', style: TextStyle(fontSize: 12)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                ar
                    ? 'مبني على منهجية FAASTeam ADM وبروتوكولات الطب الجوي الدولية'
                    : 'Based on FAASTeam ADM methodology & international aeromedical protocols',
                style: GoogleFonts.rajdhani(
                    fontSize: 10, color: AppColors.textTertiary, height: 1.4),
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}


