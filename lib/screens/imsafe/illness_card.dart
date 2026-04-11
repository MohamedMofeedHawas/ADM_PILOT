
/*import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/models.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';

class IllnessCard extends StatefulWidget {
  final ImsafeItem item;
  final bool isExpanded;
  final bool showArabic;
  final VoidCallback onTap;
  final ValueChanged<String> onRatingChanged;
  final ValueChanged<String> onNotesChanged;
  final Function(int index, String rating, String notes) onItemChanged;
  final int index;

  const IllnessCard({super.key,
    required this.item,
    required this.isExpanded,
    required this.showArabic,
    required this.onTap,
    required this.onRatingChanged,
    required this.onNotesChanged,
    required this.onItemChanged,
    required this.index,
  });

  @override
  State<IllnessCard> createState() => IllnessCardState();
}

class IllnessCardState extends State<IllnessCard> {
  late bool _isIll;
  late Map<String, bool> _symptoms;

  @override
  void initState() {
    super.initState();
    _isIll = widget.item.subItems['isIll'] ?? false;
    _symptoms = Map<String, bool>.from(
      widget.item.subItems['symptoms'] ?? {
        'fever': false,
        'dizziness': false,
        'congestion': false,
        'headache': false,

        // ✅ إضافات
        'cold_flu': false,
        'nausea': false,
        'vomiting': false,
        'ear_pain': false,
        'breathing_problem': false,
        'migraine': false,
      },
    );  }

  void _updateState() {
    widget.item.subItems['isIll'] = _isIll;
    widget.item.subItems['symptoms'] = _symptoms;

    int score = 0;

    final scores = {
      'fever': 50,
      'dizziness': 45,
      'vomiting': 45,
      'breathing_problem': 50,
      'fatigue': 30,
      'migraine': 30,
      'nausea': 25,
      'headache': 20,
      'ear_pain': 20,
      'cold_flu': 15,
      'congestion': 10,
    };

    _symptoms.forEach((key, value) {
      if (value == true && scores.containsKey(key)) {
        score += scores[key]!;
      }
    });

    if (_isIll) score += 10;

    // 🎯 Rating
    String rating;
    String recommendation;
    String reason = '';

    if (_symptoms['fever'] == true) {
      rating = 'HIGH';
      recommendation = widget.showArabic ? '❌ لا تطير' : '❌ NO-GO';
      reason = widget.showArabic ? 'بسبب الحمى' : 'Due to fever';
    }
    else if (_symptoms['breathing_problem'] == true) {
      rating = 'HIGH';
      recommendation = widget.showArabic ? '❌ لا تطير' : '❌ NO-GO';
      reason = widget.showArabic ? 'مشكلة في التنفس' : 'Breathing issue';
    }
    else if (_symptoms['vomiting'] == true) {
      rating = 'HIGH';
      recommendation = widget.showArabic ? '❌ لا تطير' : '❌ NO-GO';
      reason = widget.showArabic ? 'قيء مستمر' : 'Vomiting';
    }
    else if (score >= 60) {
      rating = 'HIGH';
      recommendation = widget.showArabic ? '❌ لا تطير' : '❌ NO-GO';
      reason = widget.showArabic ? 'عدة أعراض خطيرة' : 'Multiple severe symptoms';
    }
    else if (score >= 25) {
      rating = 'MEDIUM';
      recommendation = widget.showArabic ? '⚠️ بحذر' : '⚠️ CAUTION';
      reason = widget.showArabic ? 'أعراض تؤثر على الأداء' : 'Symptoms may affect performance';
    }
    else if (score > 0) {
      rating = 'LOW';
      recommendation = widget.showArabic ? '⚠️ راقب الحالة' : '⚠️ Monitor condition';
      reason = widget.showArabic ? 'أعراض بسيطة' : 'Minor symptoms';
    }
    else {
      rating = 'LOW';
      recommendation = widget.showArabic ? '✅ مسموح' : '✅ GO';
      reason = widget.showArabic ? 'لا توجد أعراض' : 'No symptoms';
    }
    widget.item.subItems['riskScore'] = score;
    widget.item.subItems['recommendation'] = recommendation;
    widget.item.subItems['reason'] = reason;


    widget.onRatingChanged(rating);
    widget.onItemChanged(widget.index, widget.item.rating, widget.item.notes);
  }
  Widget _symptomCheckbox(String title, String note, String key) {
    bool isSelected = _symptoms[key] ?? false;
    bool isEnabled = _isIll;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: InkWell(
        onTap: isEnabled ? () {
          setState(() {
            _symptoms[key] = !isSelected;
            _updateState();
          });
        } : null,
        child: Row(children: [
          Checkbox(
            value: isSelected,
            onChanged: isEnabled ? (_) {
              setState(() {
                _symptoms[key] = !isSelected;
                _updateState();
              });
            } : null,
            activeColor: AppColors.cyan,
          ),
          Expanded(child: Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: isEnabled ? AppColors.textPrimary : AppColors.textTertiary.withOpacity(0.7),
            ),
          )),
          if (note.isNotEmpty)
            Text(note, style: const TextStyle(fontSize: 10, color: AppColors.textTertiary, fontStyle: FontStyle.italic)),
        ]),
      ),
    );
  }
  Widget _symptomCheckboxLocalized(String key) {
    final ar = widget.showArabic;

    final titles = {
      'fever': ar ? 'حمى' : 'Fever',
      'dizziness': ar ? 'دوخة' : 'Dizziness',
      'congestion': ar ? 'احتقان' : 'Congestion',
      'headache': ar ? 'صداع' : 'Headache',
      'cold_flu': ar ? 'برد / إنفلونزا' : 'Cold/Flu',
      'nausea': ar ? 'غثيان' : 'Nausea',
      'vomiting': ar ? 'قيء' : 'Vomiting',
      'ear_pain': ar ? 'ألم الأذن' : 'Ear Pain',
      'breathing_problem': ar ? 'مشكلة تنفس' : 'Breathing Problem',
      'migraine': ar ? 'صداع نصفي' : 'Migraine',
    };

    final notes = {
      'fever': ar ? 'عدوى نشطة — لا تطير' : 'Infection — NO GO',
      'dizziness': ar ? 'تؤثر على التوازن' : 'Affects balance',
      'congestion': ar ? 'مشكلة ضغط' : 'Pressure issue',
      'headache': ar ? 'يؤثر على التركيز' : 'Affects focus',
      'cold_flu': ar ? 'إرهاق عام' : 'General weakness',
      'nausea': ar ? 'قد تزداد بالطيران' : 'May worsen in flight',
      'vomiting': ar ? 'حالة شديدة — لا تطير' : 'Severe — NO GO',
      'ear_pain': ar ? 'مشكلة ضغط' : 'Pressure issue',
      'breathing_problem': ar ? 'خطر — لا تطير' : 'Critical — NO GO',
      'migraine': ar ? 'يؤثر على الرؤية' : 'Affects vision',
    };

    return _symptomCheckbox(
      titles[key]!,
      '(${notes[key]!})',
      key,
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = AppColors.riskColor(widget.item.rating);
    final reason = widget.item.subItems['reason'] ?? '';
    final recommendation = widget.item.subItems['recommendation'] ?? '';

    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
      child: ClipRRect(borderRadius: BorderRadius.circular(9),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          IntrinsicHeight(child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Container(width: 3, color: color),
            Expanded(child: Material(color: AppColors.surface,
              child: InkWell(onTap: widget.onTap,
                child: Padding(padding: const EdgeInsets.all(14),
                  child: Row(children: [
                    Container(width: 34, height: 34, decoration: BoxDecoration(shape: BoxShape.circle, color: color.withOpacity(0.1), border: Border.all(color: color.withOpacity(0.3))),
                      child: Center(child:
                      Text(
                        '${widget.item.subItems['riskScore'] ?? 0}',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: color),
                      ),                          ),
                    ),
                    const SizedBox(width: 10),


                    Text(widget.item.iconEmoji, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(widget.showArabic ? widget.item.arabicTitle : widget.item.title, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                      Text(widget.showArabic ? widget.item.arabicSubtitle : widget.item.subtitle, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                    ])),
                    RiskBadge(widget.item.rating),
                    const SizedBox(width: 6),
                    Icon(widget.isExpanded ? Icons.expand_less : Icons.expand_more, size: 16, color: AppColors.textTertiary),
                  ]),
                ),
              ),
            ),
            )])),
          if (widget.isExpanded) ...[
            const Divider(height: 1, color: AppColors.border),
            Container(color: AppColors.surface, padding: const EdgeInsets.all(14),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text(widget.showArabic ? 'هل أنا مريض حالياً؟' : 'Are you currently ill?', style: const TextStyle(fontSize: 13, color: AppColors.textPrimary)),
                  Switch(value: _isIll, onChanged: (v) {
                    setState(() { _isIll = v;    if (!_isIll) {
                      _symptoms.updateAll((key, value) => false);

                      widget.item.subItems['additionalNotes'] = '';
                    }
                    _updateState(); });
                  }, activeColor: AppColors.red),
                ]),
                const SizedBox(height: 12),
                Text(widget.showArabic ? 'الأعراض:' : 'Symptoms:', style: GoogleFonts.inter(fontSize: 10, color: AppColors.textTertiary, letterSpacing: 1.5)),
                const SizedBox(height: 8),
                _symptomCheckboxLocalized('fever'),
                _symptomCheckboxLocalized('dizziness'),
                _symptomCheckboxLocalized('congestion'),
                _symptomCheckboxLocalized('headache'),
                _symptomCheckboxLocalized('cold_flu'),
                _symptomCheckboxLocalized('nausea'),
                _symptomCheckboxLocalized('vomiting'),
                _symptomCheckboxLocalized('ear_pain'),
                _symptomCheckboxLocalized('breathing_problem'),
                _symptomCheckboxLocalized('migraine'),
                const SizedBox(height: 12),
                Text(widget.showArabic ? 'التوصية:' : 'Recommendation:', style: const TextStyle(fontSize: 12, color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                Text('$recommendation ($reason)', style: const TextStyle(fontSize: 11, color: AppColors.textTertiary, fontStyle: FontStyle.italic)),if (_isIll) ...[
                  const SizedBox(height: 12),
                  Text(widget.showArabic ? 'ملاحظات:' : 'Additional Notes:',
                      style: GoogleFonts.shareTechMono(fontSize: 10, color: AppColors.textTertiary, letterSpacing: 1.5)),
                  const SizedBox(height: 6),
                  TextFormField(
                    initialValue: widget.item.subItems['additionalNotes'] ?? '',
                    onChanged: (val) {
                      setState(() {
                        widget.item.subItems['additionalNotes'] = val;
                      });
                    },
                    enabled: _isIll,
                    style: TextStyle(
                      fontSize: 12,
                      color: _isIll ? AppColors.textPrimary : AppColors.textTertiary.withOpacity(0.6),
                    ),
                    decoration: InputDecoration(
                      hintText: widget.showArabic ? 'ادخل ملاحظاتك هنا...' : 'Write additional notes...',
                      hintStyle: TextStyle(
                        fontSize: 11,
                        color: AppColors.textTertiary.withOpacity(_isIll ? 1.0 : 0.6),
                      ),
                      filled: true,
                      fillColor: AppColors.surfaceAlt,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: AppColors.border)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: AppColors.border)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: AppColors.cyan, width: 1.5)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    ),
                    maxLines: 2,
                  ),
                ],

              ]),
            ),
          ],
        ]),
      ),
    );
  }
}*/
import 'package:check_list_stress/screens/imsafe/imsafe_severity.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/models.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';

// ─────────────────────────────────────────────
// Severity model for Illness
// ─────────────────────────────────────────────
class _IllnessSeverity {
  final String label;
  final String arabicLabel;
  final String emoji;
  final Color color;
  final String recommendation;
  final String arabicRecommendation;

  const _IllnessSeverity({
    required this.label,
    required this.arabicLabel,
    required this.emoji,
    required this.color,
    required this.recommendation,
    required this.arabicRecommendation,
  });

  static _IllnessSeverity fromScore(int score, bool hasCritical) {
    if (hasCritical || score >= 60) {
      return _IllnessSeverity(
        label: 'CRITICAL',
        arabicLabel: 'حرج',
        emoji: '🚨',
        color: const Color(0xFFFF3D57),
        recommendation: '❌ DO NOT FLY',
        arabicRecommendation: '❌ لا تطير',
      );
    } else if (score >= 30) {
      return _IllnessSeverity(
        label: 'HIGH RISK',
        arabicLabel: 'خطر مرتفع',
        emoji: '🔴',
        color: const Color(0xFFFF6B35),
        recommendation: '⚠️ CONSULT FLIGHT SURGEON',
        arabicRecommendation: '⚠️ استشر طبيب الطيران',
      );
    } else if (score >= 15) {
      return _IllnessSeverity(
        label: 'MODERATE',
        arabicLabel: 'متوسط',
        emoji: '🟡',
        color: const Color(0xFFFFB020),
        recommendation: '⚠️ FLY WITH CAUTION',
        arabicRecommendation: '⚠️ طر بحذر',
      );
    } else if (score > 0) {
      return _IllnessSeverity(
        label: 'LOW RISK',
        arabicLabel: 'خطر منخفض',
        emoji: '🟢',
        color: const Color(0xFF00C853),
        recommendation: '✅ MONITOR CONDITION',
        arabicRecommendation: '✅ راقب الحالة',
      );
    }
    return _IllnessSeverity(
      label: 'CLEAR',
      arabicLabel: 'سليم',
      emoji: '✅',
      color: const Color(0xFF00E676),
      recommendation: '✅ FIT TO FLY',
      arabicRecommendation: '✅ مؤهل للطيران',
    );
  }
}

// ─────────────────────────────────────────────
// Symptom definition
// ─────────────────────────────────────────────
class _SymptomDef {
  final String key;
  final String label;
  final String arabicLabel;
  final String note;
  final String arabicNote;
  final int riskPoints;
  final bool isCritical; // triggers NO-GO directly

  const _SymptomDef({
    required this.key,
    required this.label,
    required this.arabicLabel,
    required this.note,
    required this.arabicNote,
    required this.riskPoints,
    this.isCritical = false,
  });
}

const _kSymptoms = [
  _SymptomDef(
    key: 'fever',
    label: 'Fever',
    arabicLabel: 'حمى',
    note: 'Active infection — NO GO',
    arabicNote: 'عدوى نشطة — لا تطير',
    riskPoints: 50,
    isCritical: true,
  ),
  _SymptomDef(
    key: 'breathing_problem',
    label: 'Breathing Problem',
    arabicLabel: 'مشكلة تنفس',
    note: 'Critical — NO GO',
    arabicNote: 'خطر — لا تطير',
    riskPoints: 50,
    isCritical: true,
  ),
  _SymptomDef(
    key: 'vomiting',
    label: 'Vomiting',
    arabicLabel: 'قيء',
    note: 'Severe — NO GO',
    arabicNote: 'حالة شديدة — لا تطير',
    riskPoints: 45,
    isCritical: true,
  ),
  _SymptomDef(
    key: 'dizziness',
    label: 'Dizziness',
    arabicLabel: 'دوخة',
    note: 'Affects balance',
    arabicNote: 'تؤثر على التوازن',
    riskPoints: 45,
  ),
  _SymptomDef(
    key: 'migraine',
    label: 'Migraine',
    arabicLabel: 'صداع نصفي',
    note: 'Affects vision',
    arabicNote: 'يؤثر على الرؤية',
    riskPoints: 30,
  ),
  _SymptomDef(
    key: 'nausea',
    label: 'Nausea',
    arabicLabel: 'غثيان',
    note: 'May worsen in flight',
    arabicNote: 'قد تزداد بالطيران',
    riskPoints: 25,
  ),
  _SymptomDef(
    key: 'headache',
    label: 'Headache',
    arabicLabel: 'صداع',
    note: 'Affects focus',
    arabicNote: 'يؤثر على التركيز',
    riskPoints: 20,
  ),
  _SymptomDef(
    key: 'ear_pain',
    label: 'Ear Pain',
    arabicLabel: 'ألم الأذن',
    note: 'Pressure issue',
    arabicNote: 'مشكلة ضغط',
    riskPoints: 20,
  ),
  _SymptomDef(
    key: 'cold_flu',
    label: 'Cold / Flu',
    arabicLabel: 'برد / إنفلونزا',
    note: 'General weakness',
    arabicNote: 'إرهاق عام',
    riskPoints: 15,
  ),
  _SymptomDef(
    key: 'congestion',
    label: 'Congestion',
    arabicLabel: 'احتقان',
    note: 'Pressure issue',
    arabicNote: 'مشكلة ضغط',
    riskPoints: 10,
  ),
];

// ─────────────────────────────────────────────
// IllnessCard Widget
// ─────────────────────────────────────────────
class IllnessCard extends StatefulWidget {
  final ImsafeItem item;
  final bool isExpanded;
  final bool showArabic;
  final VoidCallback onTap;
  final ValueChanged<String> onRatingChanged;
  final ValueChanged<String> onNotesChanged;
  final Function(int index, String rating, String notes) onItemChanged;
  final int index;

  const IllnessCard({
    super.key,
    required this.item,
    required this.isExpanded,
    required this.showArabic,
    required this.onTap,
    required this.onRatingChanged,
    required this.onNotesChanged,
    required this.onItemChanged,
    required this.index,
  });

  @override
  State<IllnessCard> createState() => _IllnessCardState();
}

class _IllnessCardState extends State<IllnessCard> {
  late bool _isIll;
  late Map<String, bool> _symptoms;
  late Map<String, double> _symptomSeverity;


  @override
  void initState() {
    super.initState();
    _isIll = widget.item.subItems['isIll'] ?? false;
    _symptoms = Map<String, bool>.from(
      widget.item.subItems['symptoms'] ??
          {for (final s in _kSymptoms) s.key: false},
    );
    _symptomSeverity = Map<String, double>.from(
      widget.item.subItems['symptomSeverity'] ??
          {for (final s in _kSymptoms) s.key: 50.0},
    );
  }

  // ── Compute score & severity ─────────────────────────────
  int get _score {
    if (!_isIll) return 0;
    double total = 0;
    bool hasCritical = false;
    for (final s in _kSymptoms) {
      if (_symptoms[s.key] == true) {
        final sev = _symptomSeverity[s.key] ?? 50.0;
        total += s.riskPoints * (sev / 100.0);
        // total += s.riskPoints;
        if (s.isCritical) hasCritical = true;
      }
    }
    final result = total.toInt();
    return hasCritical ? result.clamp(60, 999) : result;
  }

  bool get _hasCritical =>
      _kSymptoms.any((s) => s.isCritical && (_symptoms[s.key] == true));

  _IllnessSeverity get _severity =>
      _IllnessSeverity.fromScore(_isIll ? _score : 0, _hasCritical);

  int get _selectedCount => _symptoms.values.where((v) => v).length;

  // ── Update parent ────────────────────────────────────────
  void _updateState() {
    widget.item.subItems['isIll'] = _isIll;
    widget.item.subItems['symptoms'] = _symptoms;
    widget.item.subItems['riskScore'] = _score;
    widget.item.subItems['recommendation'] = _severity.recommendation;
    widget.item.subItems['symptomSeverity'] = _symptomSeverity;

    String rating;
    if (!_isIll || _score == 0) {
      rating = 'LOW';
    } else if (_hasCritical || _score >= 60) {
      rating = 'HIGH';
    } else if (_score >= 30) {
      rating = 'HIGH';
    } else if (_score >= 15) {
      rating = 'MEDIUM';
    } else {
      rating = 'LOW';
    }

    widget.onRatingChanged(rating);
    widget.onItemChanged(widget.index, rating, widget.item.notes);
  }

  // ── Build ─────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final cardColor = AppColors.riskColor(widget.item.rating);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(9),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header row ──────────────────────────────────
            _buildHeader(cardColor),

            // ── Expanded body ───────────────────────────────
            if (widget.isExpanded) ...[
              const Divider(height: 1, color: AppColors.border),
              _buildBody(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Color cardColor) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Colored left bar
          Container(
            width: 3,
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(9),
              ),
            ),
          ),
          Expanded(
            child: Material(
              color: AppColors.surface,
              child: InkWell(
                onTap: widget.onTap,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      // Score circle
                      _ScoreCircle(
                        score: _isIll ? _score : 0,
                        color:
                            _isIll ? _severity.color : AppColors.textTertiary,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        widget.item.iconEmoji,
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.showArabic
                                  ? widget.item.arabicTitle
                                  : widget.item.title,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              widget.showArabic
                                  ? widget.item.arabicSubtitle
                                  : widget.item.subtitle,
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      RiskBadge(widget.item.rating),
                      const SizedBox(width: 6),
                      Icon(
                        widget.isExpanded
                            ? Icons.expand_less
                            : Icons.expand_more,
                        size: 16,
                        color: AppColors.textTertiary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    final ar = widget.showArabic;
    final sev = _severity;

    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Toggle: Am I ill? ───────────────────────────
          _IllToggle(
            isIll: _isIll,
            showArabic: ar,
            onChanged: (v) {
              setState(() {
                _isIll = v;
                if (!_isIll) {
                  _symptoms.updateAll((_, __) => false);
                  widget.item.subItems['additionalNotes'] = '';
                }
                _updateState();
              });
            },
          ),

          // ── Severity badge (live) ───────────────────────
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _isIll
                ? Padding(
                    key: ValueKey(_score),
                    padding: const EdgeInsets.only(top: 14, bottom: 4),
                    child: _SeverityBanner(severity: sev, showArabic: ar),
                  )
                : const SizedBox(key: ValueKey('empty'), height: 14),
          ),

          // ── Symptoms grid ───────────────────────────────
          if (_isIll) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  ar ? 'الأعراض:' : 'SELECT SYMPTOMS:',
                  style: GoogleFonts.shareTechMono(
                    fontSize: 10,
                    color: AppColors.textTertiary,
                    letterSpacing: 1.5,
                  ),
                ),
                if (_selectedCount > 0)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: sev.color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: sev.color.withOpacity(0.4)),
                    ),
                    child: Text(
                      '$_selectedCount ${ar ? 'أعراض' : 'selected'}',
                      style: GoogleFonts.shareTechMono(
                        fontSize: 9,
                        color: sev.color,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            ...(_kSymptoms.map((s) => _SymptomTile(
                  def: s,
                  isSelected: _symptoms[s.key] ?? false,
                  showArabic: ar,
              severity: _symptomSeverity[s.key] ?? 50.0,         // ✅
              onSeverityChanged: (v) {                             // ✅
                setState(() {
                  _symptomSeverity[s.key] = v;
                  _updateState();
                });
              },
                  onTap: () {
                    setState(() {
                      _symptoms[s.key] = !(_symptoms[s.key] ?? false);
                      _updateState();
                    });
                  },
                ))),
          ],

          // ── Notes ───────────────────────────────────────
          if (_isIll) ...[
            const SizedBox(height: 14),
            Text(
              ar ? 'ملاحظات إضافية:' : 'ADDITIONAL NOTES:',
              style: GoogleFonts.shareTechMono(
                fontSize: 10,
                color: AppColors.textTertiary,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 6),
            TextFormField(
              initialValue: widget.item.subItems['additionalNotes'] ?? '',
              onChanged: (val) {
                widget.item.subItems['additionalNotes'] = val;
                widget.item.notes = val;
                widget.onNotesChanged(val);
              },
              style:
                  const TextStyle(fontSize: 12, color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText:
                    ar ? 'أدخل ملاحظاتك هنا...' : 'Write additional notes...',
                hintStyle: const TextStyle(
                    fontSize: 11, color: AppColors.textTertiary),
                filled: true,
                fillColor: AppColors.surfaceAlt,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide:
                      const BorderSide(color: AppColors.cyan, width: 1.5),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              ),
              maxLines: 2,
            ),
          ],
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Sub-widgets
// ══════════════════════════════════════════════════════════════

class _ScoreCircle extends StatelessWidget {
  final int score;
  final Color color;
  const _ScoreCircle({required this.score, required this.color});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: score.toDouble()),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
      builder: (_, v, __) => Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withOpacity(0.1),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Center(
          child: Text(
            '${v.toInt()}',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}

class _IllToggle extends StatelessWidget {
  final bool isIll;
  final bool showArabic;
  final ValueChanged<bool> onChanged;
  const _IllToggle({
    required this.isIll,
    required this.showArabic,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isIll
            ? AppColors.red.withOpacity(0.06)
            : AppColors.green.withOpacity(0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isIll
              ? AppColors.red.withOpacity(0.25)
              : AppColors.green.withOpacity(0.25),
        ),
      ),
      child: Row(
        children: [
          Text(
            isIll ? '🤒' : '😊',
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              showArabic
                  ? (isIll ? 'أنا مريض حالياً' : 'أنا بصحة جيدة')
                  : (isIll ? 'I am currently ill' : 'I am feeling well'),
              style: TextStyle(
                fontSize: 13,
                color: isIll ? AppColors.red : AppColors.green,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Switch(
            value: isIll,
            onChanged: onChanged,
            activeColor: AppColors.red,
            inactiveThumbColor: AppColors.green,
          ),
        ],
      ),
    );
  }
}

class _SeverityBanner extends StatelessWidget {
  final _IllnessSeverity severity;
  final bool showArabic;
  const _SeverityBanner({
    required this.severity,
    required this.showArabic,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: severity.color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: severity.color.withOpacity(0.4), width: 1.5),
      ),
      child: Row(
        children: [
          Text(severity.emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  showArabic ? severity.arabicLabel : severity.label,
                  style: GoogleFonts.shareTechMono(
                    fontSize: 13,
                    color: severity.color,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  showArabic
                      ? severity.arabicRecommendation
                      : severity.recommendation,
                  style: TextStyle(
                    fontSize: 11,
                    color: severity.color.withOpacity(0.85),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SymptomTile extends StatelessWidget {
  final _SymptomDef def;
  final bool isSelected;
  final bool showArabic;
  final VoidCallback onTap;
  final double severity;              // ✅ جديد
  final ValueChanged<double> onSeverityChanged; // ✅ جديد

  const _SymptomTile({
    required this.def,
    required this.isSelected,
    required this.showArabic,
    required this.onTap,
    required this.severity,
    required this.onSeverityChanged,
  });

  @override
  Widget build(BuildContext context) {
    final color = def.isCritical ? AppColors.red : AppColors.amber;
    final level = SeverityLevel.fromValue(severity);

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.08) : AppColors.elevated,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color.withOpacity(0.5) : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header row (tap to select) ─────────────
            InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 8),
                child: Row(children: [
                  // Circle checkbox
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected
                          ? color.withOpacity(0.2)
                          : Colors.transparent,
                      border: Border.all(
                        color: isSelected
                            ? color
                            : AppColors.textTertiary,
                        width: 1.5,
                      ),
                    ),
                    child: isSelected
                        ? Icon(Icons.check, size: 12, color: color)
                        : null,
                  ),
                  const SizedBox(width: 10),

                  Expanded(
                    child: Text(
                      showArabic ? def.arabicLabel : def.label,
                      style: TextStyle(
                        fontSize: 12,
                        color: isSelected
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ),

                  // Note tag
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: def.isCritical
                          ? AppColors.red.withOpacity(0.08)
                          : AppColors.border.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      showArabic ? def.arabicNote : def.note,
                      style: TextStyle(
                        fontSize: 9,
                        color: def.isCritical
                            ? AppColors.red
                            : AppColors.textTertiary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                  if (def.isCritical) ...[
                    const SizedBox(width: 4),
                    const Text('🚨', style: TextStyle(fontSize: 10)),
                  ],
                  // ✅ severity badge لما يكون selected
                  if (isSelected) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: level.color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                            color: level.color.withOpacity(0.4)),
                      ),
                      child: Text(
                        '${severity.toInt()}%',
                        style: GoogleFonts.shareTechMono(
                          fontSize: 9,
                          color: level.color,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ]),
              ),
            ),

            // ✅ Severity slider — يظهر بس لما selected
            if (isSelected) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: SeveritySlider(
                  value: severity,
                  onChanged: onSeverityChanged,
                  showArabic: showArabic,
                  enabled: true,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}