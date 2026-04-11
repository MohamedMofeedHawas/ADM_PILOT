
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/models.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';

class MedicationCard extends StatefulWidget {
  final ImsafeItem item;
  final bool isExpanded;
  final bool showArabic;
  final VoidCallback onTap;
  final ValueChanged<String> onRatingChanged;
  final ValueChanged<String> onNotesChanged;
  final Function(int index, String rating, String notes) onItemChanged;
  final int index;

  const MedicationCard({super.key,
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
  State<MedicationCard> createState() => MedicationCardState();
}

class MedicationCardState extends State<MedicationCard> {
  late bool _isTakingMedication;
  late Map<String, bool> _sideEffects;

  @override
  void initState() {
    super.initState();
    _isTakingMedication = widget.item.subItems['isTakingMedication'] ?? false;
    _sideEffects = Map<String, bool>.from(
        widget.item.subItems['sideEffects'] ?? {
          'drowsiness': false,
          'nausea': false,
          'blurred_vision': false,
          'headache': false,
          'dry_mouth': false,

          'dizziness': false,
          'fatigue': false,
          'insomnia': false,
          'vomiting': false,
          'diarrhea': false,
          'constipation': false,
          'loss_of_appetite': false,
          'increased_appetite': false,
          'sweating': false,
          'rash': false,
          'itching': false,
          'fever': false,
          'chills': false,
          'shortness_of_breath': false,
          'chest_pain': false,
          'palpitations': false,
          'anxiety': false,
          'confusion': false,
          'tremor': false,
        }    );
  }

  void _updateState(bool ar) {
    widget.item.subItems['isTakingMedication'] = _isTakingMedication;
    widget.item.subItems['sideEffects'] = _sideEffects;

    int score = 0;

    final scores = {
      'blurred_vision': 50,
      'drowsiness': 50,
      'nausea': 45,
      'headache': 20,
      'dry_mouth': 10,

      // إضافات 👇
      'dizziness': 40,
      'fatigue': 30,
      'insomnia': 25,
      'vomiting': 45,
      'diarrhea': 20,
      'constipation': 10,
      'loss_of_appetite': 15,
      'increased_appetite': 10,
      'sweating': 15,
      'rash': 20,
      'itching': 10,
      'fever': 35,
      'chills': 25,
      'shortness_of_breath': 50,
      'chest_pain': 60,
      'palpitations': 40,
      'anxiety': 25,
      'confusion': 50,
      'tremor': 30,
    };

    /// أعراض خطيرة مباشرة ❌
    final criticalSymptoms = [
      'blurred_vision',
      'drowsiness',
      'shortness_of_breath',
      'chest_pain',
      'confusion',
    ];

    _sideEffects.forEach((key, value) {
      if (value == true && scores.containsKey(key)) {
        score += scores[key]!;
      }
    });

    if (_isTakingMedication) score += 10;

    String rating;
    String recommendation;
    String reason = '';

    /// 🚨 تحقق من الأعراض الحرجة
    final activeCritical = criticalSymptoms.firstWhere(
          (k) => _sideEffects[k] == true,
      orElse: () => '',
    );

    if (activeCritical.isNotEmpty) {
      rating = 'HIGH';
      recommendation = widget.showArabic ? '❌ لا تطير' : '❌ NO-GO';

      final reasonsMap = {
        'blurred_vision': ar ? 'تشوش الرؤية' : 'Blurred vision',
        'drowsiness': ar ? 'نعاس شديد' : 'Severe drowsiness',
        'shortness_of_breath': ar ? 'ضيق تنفس' : 'Shortness of breath',
        'chest_pain': ar ? 'ألم في الصدر' : 'Chest pain',
        'confusion': ar ? 'ارتباك' : 'Confusion',
      };

      reason = reasonsMap[activeCritical]!;
    }

    /// 📊 باقي الحالات
    else if (score >= 60) {
      rating = 'HIGH';
      recommendation = widget.showArabic ? '❌ لا تطير' : '❌ NO-GO';
      reason = widget.showArabic
          ? 'آثار جانبية خطيرة'
          : 'Multiple severe side effects';
    } else if (score >= 25) {
      rating = 'MEDIUM';
      recommendation = widget.showArabic ? '⚠️ بحذر' : '⚠️ CAUTION';
      reason = widget.showArabic
          ? 'آثار جانبية مؤثرة'
          : 'Side effects may affect performance';
    } else if (score > 0) {
      rating = 'LOW';
      recommendation =
      widget.showArabic ? '⚠️ راقب الحالة' : '⚠️ Monitor condition';
      reason =
      widget.showArabic ? 'آثار جانبية بسيطة' : 'Minor side effects';
    } else {
      rating = 'LOW';
      recommendation = widget.showArabic ? '✅ مسموح' : '✅ GO';
      reason =
      widget.showArabic ? 'لا توجد آثار جانبية' : 'No side effects';
    }

    widget.item.subItems['riskScore'] = score;
    widget.item.subItems['recommendation'] = recommendation;
    widget.item.subItems['reason'] = reason;

    widget.onRatingChanged(rating);
    widget.onItemChanged(widget.index, widget.item.rating, widget.item.notes);
  }
  Widget _sideEffectCheckbox(String title, String note, String key) {
    bool isSelected = _sideEffects[key] ?? false;
    bool isEnabled = _isTakingMedication;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: InkWell(
        onTap: isEnabled ? () {
          setState(() {
            _sideEffects[key] = !isSelected;
            _updateState( widget.showArabic);
          });
        } : null,
        child: Row(children: [
          Checkbox(
            value: isSelected,
            onChanged: isEnabled ? (_) {
              setState(() {
                _sideEffects[key] = !isSelected;
                _updateState(
                  widget.showArabic
                );
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

  Widget _sideEffectCheckboxLocalized(String key) {
    final ar = widget.showArabic;

    final titles = {
      'drowsiness': ar ? 'نعاس' : 'Drowsiness',
      'nausea': ar ? 'غثيان' : 'Nausea',
      'blurred_vision': ar ? 'رؤية مشوشة' : 'Blurred Vision',
      'headache': ar ? 'صداع' : 'Headache',
      'dry_mouth': ar ? 'جفاف الفم' : 'Dry Mouth',

      // إضافات 👇
      'dizziness': ar ? 'دوخة' : 'Dizziness',
      'fatigue': ar ? 'إرهاق' : 'Fatigue',
      'insomnia': ar ? 'أرق' : 'Insomnia',
      'vomiting': ar ? 'قيء' : 'Vomiting',
      'diarrhea': ar ? 'إسهال' : 'Diarrhea',
      'constipation': ar ? 'إمساك' : 'Constipation',
      'loss_of_appetite': ar ? 'فقدان الشهية' : 'Loss of Appetite',
      'increased_appetite': ar ? 'زيادة الشهية' : 'Increased Appetite',
      'sweating': ar ? 'تعرق' : 'Sweating',
      'rash': ar ? 'طفح جلدي' : 'Rash',
      'itching': ar ? 'حكة' : 'Itching',
      'fever': ar ? 'حمى' : 'Fever',
      'chills': ar ? 'قشعريرة' : 'Chills',
      'shortness_of_breath': ar ? 'ضيق تنفس' : 'Shortness of Breath',
      'chest_pain': ar ? 'ألم في الصدر' : 'Chest Pain',
      'palpitations': ar ? 'خفقان' : 'Palpitations',
      'anxiety': ar ? 'قلق' : 'Anxiety',
      'confusion': ar ? 'ارتباك' : 'Confusion',
      'tremor': ar ? 'رعشة' : 'Tremor',
    };

    final notes = {
      'drowsiness': ar ? '(خطير - يؤثر على اليقظة)' : '(Critical - Affects alertness)',
      'nausea': ar ? '(قد يشتت الانتباه)' : '(Can be distracting)',
      'blurred_vision': ar ? '(خطير - يؤثر على الرؤية)' : '(Critical - Affects vision)',
      'headache': ar ? '(يؤثر على التركيز)' : '(Affects focus)',
      'dry_mouth': ar ? '(إزعاج بسيط)' : '(Minor annoyance)',

      // إضافات 👇
      'dizziness': ar ? '(قد يسبب فقدان التوازن)' : '(May affect balance)',
      'fatigue': ar ? '(يقلل الأداء)' : '(Reduces performance)',
      'insomnia': ar ? '(يؤثر على الراحة)' : '(Affects rest)',
      'vomiting': ar ? '(خطير)' : '(Severe)',
      'diarrhea': ar ? '(مزعج)' : '(Uncomfortable)',
      'constipation': ar ? '(إزعاج بسيط)' : '(Minor)',
      'loss_of_appetite': ar ? '(يؤثر على الطاقة)' : '(Affects energy)',
      'increased_appetite': ar ? '(تغير بسيط)' : '(Minor change)',
      'sweating': ar ? '(استجابة جسدية)' : '(Physical response)',
      'rash': ar ? '(حساسية محتملة)' : '(Possible allergy)',
      'itching': ar ? '(إزعاج)' : '(Irritation)',
      'fever': ar ? '(خطير)' : '(Serious)',
      'chills': ar ? '(قد تشير لمرض)' : '(May indicate illness)',
      'shortness_of_breath': ar ? '(خطير جدًا)' : '(Critical)',
      'chest_pain': ar ? '(طارئ)' : '(Emergency)',
      'palpitations': ar ? '(اضطراب القلب)' : '(Heart irregularity)',
      'anxiety': ar ? '(يؤثر على القرار)' : '(Affects judgment)',
      'confusion': ar ? '(خطير جدًا)' : '(Critical)',
      'tremor': ar ? '(يؤثر على التحكم)' : '(Affects control)',
    };

    return _sideEffectCheckbox(
      titles[key] ?? key,
      notes[key] ?? '',
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
                  Text(widget.showArabic ? 'هل تتناول أي أدوية؟' : 'Are you taking any medication?', style: const TextStyle(fontSize: 13, color: AppColors.textPrimary)),
                  Switch(value: _isTakingMedication, onChanged: (v) {
                    setState(() {
                      _isTakingMedication = v;
                      if (!_isTakingMedication) {
                        _sideEffects.updateAll((key, value) => false);
                        widget.item.subItems['additionalNotes'] = '';
                      }
                      _updateState( widget.showArabic);
                    });
                  }, activeColor: AppColors.red),
                ]),
                const SizedBox(height: 12),
                Text(widget.showArabic ? 'الآثار الجانبية:' : 'Side Effects:', style: GoogleFonts.inter(fontSize: 10, color: AppColors.textTertiary, letterSpacing: 1.5)),
                const SizedBox(height: 8),
                _sideEffectCheckboxLocalized('drowsiness'),
                _sideEffectCheckboxLocalized('blurred_vision'),
                _sideEffectCheckboxLocalized('nausea'),
                _sideEffectCheckboxLocalized('headache'),
                _sideEffectCheckboxLocalized('dry_mouth'),
                _sideEffectCheckboxLocalized('dizziness'),
                _sideEffectCheckboxLocalized('fatigue'),
                _sideEffectCheckboxLocalized('insomnia'),
                _sideEffectCheckboxLocalized('vomiting'),
                _sideEffectCheckboxLocalized('diarrhea'),
                _sideEffectCheckboxLocalized('constipation'),
                _sideEffectCheckboxLocalized('loss_of_appetite'),
                _sideEffectCheckboxLocalized('increased_appetite'),
                _sideEffectCheckboxLocalized('sweating'),
                _sideEffectCheckboxLocalized('rash'),
                _sideEffectCheckboxLocalized('itching'),
                _sideEffectCheckboxLocalized('fever'),
                _sideEffectCheckboxLocalized('chills'),
                _sideEffectCheckboxLocalized('shortness_of_breath'),
                _sideEffectCheckboxLocalized('chest_pain'), 
                const SizedBox(height: 12),
                Text(widget.showArabic ? 'التوصية:' : 'Recommendation:', style: const TextStyle(fontSize: 12, color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                Text('$recommendation ($reason)', style: const TextStyle(fontSize: 11, color: AppColors.textTertiary, fontStyle: FontStyle.italic)),
                if (_isTakingMedication) ...[
                  const SizedBox(height: 12),
                  Text(widget.showArabic ? 'ملاحظات إضافية:' : 'Additional Notes:',
                      style: GoogleFonts.shareTechMono(fontSize: 10, color: AppColors.textTertiary, letterSpacing: 1.5)),
                  const SizedBox(height: 6),
                  TextFormField(
                    initialValue: widget.item.subItems['additionalNotes'] ?? '',
                    onChanged: (val) {
                      setState(() {
                        widget.item.subItems['additionalNotes'] = val;
                      });
                    },
                    enabled: _isTakingMedication,
                    style: TextStyle(
                      fontSize: 12,
                      color: _isTakingMedication ? AppColors.textPrimary : AppColors.textTertiary.withOpacity(0.6),
                    ),
                    decoration: InputDecoration(
                      hintText: widget.showArabic ? 'اذكر الدواء وآثاره...' : 'Describe the medication and its effects...',
                      hintStyle: TextStyle(
                        fontSize: 11,
                        color: AppColors.textTertiary.withOpacity(_isTakingMedication ? 1.0 : 0.6),
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
}