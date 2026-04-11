
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/models.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';

class StressCard extends StatefulWidget {
  final ImsafeItem item;
  final bool isExpanded;
  final bool showArabic;
  final VoidCallback onTap;
  final ValueChanged<String> onRatingChanged;
  final ValueChanged<String> onNotesChanged;
  final Function(int index, String rating, String notes) onItemChanged;
  final int index;

  const StressCard({super.key,
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
  State<StressCard> createState() => StressCardState();
}

class StressCardState extends State<StressCard> {
  late bool _hasStress;
  late Map<String, bool> _stressors;

  @override
  void initState() {
    super.initState();
    _hasStress = widget.item.subItems['hasStress'] ?? false;
    _stressors = Map<String, bool>.from(
        widget.item.subItems['stressors'] ?? {
          'death_of_spouse': false,
          'divorce': false,
          'marital_separation': false,
          'imprisonment': false,
          'death_of_family_member': false,
          'personal_injury_illness': false,
          'marriage': false,
          'dismissal_from_work': false,
          'retirement': false,
          'new_home_purchase': false,
          'family_health_change': false,
          'pregnancy': false,
          'vacation': false,
          'minor_law_violations': false,
        }    );
  }

  void _updateState(bool ar) {
    widget.item.subItems['hasStress'] = _hasStress;
    widget.item.subItems['stressors'] = _stressors;

    int score = 0;

    final scores = {
      'death_of_spouse': 100,
      'divorce': 73,
      'marital_separation': 65,
      'imprisonment': 63,
      'death_of_family_member': 63,
      'personal_injury_illness': 53,
      'marriage': 50,
      'dismissal_from_work': 47,
      'retirement': 45,
      'new_home_purchase': 45,
      'family_health_change': 44,
      'pregnancy': 40,
      'vacation': 13,
      'minor_law_violations': 11,
    };

    /// عوامل التوتر الحرجة ❌
    final criticalStressors = [
      'death_of_spouse',
      'divorce',
      'imprisonment',
      'personal_injury_illness',
    ];

    _stressors.forEach((key, value) {
      if (value == true && scores.containsKey(key)) {
        score += scores[key]!;
      }
    });

    if (_hasStress) score += 5;

    String rating;
    String recommendation;
    String reason = '';

    /// 🚨 تحقق من عوامل التوتر الحرجة
    final activeCritical = criticalStressors.firstWhere(
          (k) => _stressors[k] == true,
      orElse: () => '',
    );

    if (activeCritical.isNotEmpty) {
      rating = 'HIGH';
      recommendation = widget.showArabic ? '❌ لا تطير' : '❌ NO-GO';

      final reasonsMap = {
        'death_of_spouse': ar ? 'وفاة الزوج/ة أو الشريك أو الطفل' : 'Death of a spouse, partner, or child',
        'divorce': ar ? 'طلاق' : 'Divorce',
        'imprisonment': ar ? 'سجن' : 'Imprisonment',
        'personal_injury_illness': ar ? 'إصابة شخصية أو مرض' : 'Personal injury or illness',
      };

      reason = reasonsMap[activeCritical]!;
    }

    /// 📊 باقي الحالات
    else if (score >= 60) {
      rating = 'HIGH';
      recommendation = widget.showArabic ? '❌ لا تطير' : '❌ NO-GO';
      reason = widget.showArabic
          ? 'مستوى توتر مرتفع جدًا'
          : 'Very high stress level';
    } else if (score >= 30) {
      rating = 'MEDIUM';
      recommendation = widget.showArabic ? '⚠️ بحذر' : '⚠️ CAUTION';
      reason = widget.showArabic
          ? 'مستوى توتر متوسط'
          : 'Moderate stress level';
    } else if (score > 0) {
      rating = 'LOW';
      recommendation =
      widget.showArabic ? '⚠️ راقب الحالة' : '⚠️ Monitor condition';
      reason =
      widget.showArabic ? 'توتر بسيط' : 'Minor stress';
    } else {
      rating = 'LOW';
      recommendation = widget.showArabic ? '✅ مسموح' : '✅ GO';
      reason =
      widget.showArabic ? 'لا يوجد توتر' : 'No stress';
    }

    widget.item.subItems['riskScore'] = score;
    widget.item.subItems['recommendation'] = recommendation;
    widget.item.subItems['reason'] = reason;

    widget.onRatingChanged(rating);
    widget.onItemChanged(widget.index, widget.item.rating, widget.item.notes);
  }

  Widget _stressorCheckbox(String title, String icon, int score, String key) {
    bool isSelected = _stressors[key] ?? false;
    bool isEnabled = _hasStress;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: InkWell(
        onTap: isEnabled ? () {
          setState(() {
            _stressors[key] = !isSelected;
            _updateState(widget.showArabic);
          });
        } : null,
        child: Row(children: [
          Checkbox(
            value: isSelected,
            onChanged: isEnabled ? (_) {
              setState(() {
                _stressors[key] = !isSelected;
                _updateState(widget.showArabic);
              });
            } : null,
            activeColor: AppColors.cyan,
          ),
          Text(icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 6),
          Expanded(child: Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: isEnabled
                  ? AppColors.textPrimary
                  : AppColors.textTertiary.withOpacity(0.7),
            ),
          )),
          // ✅ الرقم على اليمين
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.red.withOpacity(0.15)
                  : AppColors.elevated,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: isSelected
                    ? AppColors.red.withOpacity(0.4)
                    : AppColors.border,
              ),
            ),
            child: Text(
              '$score',
              style: GoogleFonts.shareTechMono(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isSelected
                    ? AppColors.red
                    : AppColors.textTertiary,
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _stressorCheckboxLocalized(String key) {
    final ar = widget.showArabic;

    final titles = {
      'death_of_spouse':         ar ? 'وفاة الزوج/ة أو الشريك أو الطفل' : 'Death of a spouse, partner, or child',
      'divorce':                 ar ? 'طلاق'                              : 'Divorce',
      'marital_separation':      ar ? 'انفصال زوجي'                      : 'Marital separation',
      'imprisonment':            ar ? 'سجن'                               : 'Imprisonment',
      'death_of_family_member':  ar ? 'وفاة فرد من العائلة المقربين'     : 'Death of a close family member',
      'personal_injury_illness': ar ? 'إصابة شخصية أو مرض'              : 'Personal injury or illness',
      'marriage':                ar ? 'زواج'                              : 'Marriage',
      'dismissal_from_work':     ar ? 'فصل من العمل'                     : 'Dismissal from work',
      'retirement':              ar ? 'تقاعد'                             : 'Retirement',
      'new_home_purchase':       ar ? 'شراء منزل جديد'                   : 'New home purchase',
      'family_health_change':    ar ? 'تغير في صحة فرد من العائلة'       : 'Health change of a family member',
      'pregnancy':               ar ? 'حمل'                               : 'Pregnancy',
      'vacation':                ar ? 'إجازة'                             : 'Vacation',
      'minor_law_violations':    ar ? 'انتهاكات طفيفة للقانون'           : 'Minor violations of the law',
    };

    const icons = {
      'death_of_spouse':         '💔',
      'divorce':                 '📝',
      'marital_separation':      '👫',
      'imprisonment':            '⛓️',
      'death_of_family_member':  '🕊️',
      'personal_injury_illness': '🤕',
      'marriage':                '💍',
      'dismissal_from_work':     '💼',
      'retirement':              '🏖️',
      'new_home_purchase':       '🏠',
      'family_health_change':    '🏥',
      'pregnancy':               '🤰',
      'vacation':                '✈️',
      'minor_law_violations':    '⚖️',
    };

    // ✅ نفس الـ scores map الموجودة في _updateState
    const scores = {
      'death_of_spouse':         100,
      'divorce':                  73,
      'marital_separation':       65,
      'imprisonment':             63,
      'death_of_family_member':   63,
      'personal_injury_illness':  53,
      'marriage':                 50,
      'dismissal_from_work':      47,
      'retirement':               45,
      'new_home_purchase':        45,
      'family_health_change':     44,
      'pregnancy':                40,
      'vacation':                 13,
      'minor_law_violations':     11,
    };

    return _stressorCheckbox(
      titles[key] ?? key,
      icons[key] ?? '•',
      scores[key] ?? 0,   // ✅ تمرير الرقم
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
                  Text(widget.showArabic ? 'هل تعاني من أي توتر؟' : 'Are you experiencing any stress?', style: const TextStyle(fontSize: 13, color: AppColors.textPrimary)),
                  Switch(value: _hasStress, onChanged: (v) {
                    setState(() {
                      _hasStress = v;
                      if (!_hasStress) {
                        _stressors.updateAll((key, value) => false);
                        widget.item.subItems['additionalNotes'] = '';
                      }
                      _updateState( widget.showArabic);
                    });
                  }, activeColor: AppColors.red),
                ]),
                const SizedBox(height: 12),
                Text(widget.showArabic ? 'أسباب الضغط:' : 'STRESSOR TYPES:', style: GoogleFonts.inter(fontSize: 10, color: AppColors.textTertiary, letterSpacing: 1.5)),
                const SizedBox(height: 8),
                _stressorCheckboxLocalized('death_of_spouse'),
                _stressorCheckboxLocalized('divorce'),
                _stressorCheckboxLocalized('marital_separation'),
                _stressorCheckboxLocalized('imprisonment'),
                _stressorCheckboxLocalized('death_of_family_member'),
                _stressorCheckboxLocalized('personal_injury_illness'),
                _stressorCheckboxLocalized('marriage'),
                _stressorCheckboxLocalized('dismissal_from_work'),
                _stressorCheckboxLocalized('retirement'),
                _stressorCheckboxLocalized('new_home_purchase'),
                _stressorCheckboxLocalized('family_health_change'),
                _stressorCheckboxLocalized('pregnancy'),
                _stressorCheckboxLocalized('vacation'),
                _stressorCheckboxLocalized('minor_law_violations'),
                const SizedBox(height: 12),
                Text(widget.showArabic ? 'التوصية:' : 'Recommendation:', style: const TextStyle(fontSize: 12, color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                Text('$recommendation ($reason)', style: const TextStyle(fontSize: 11, color: AppColors.textTertiary, fontStyle: FontStyle.italic)),
                if (_hasStress) ...[
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
                    enabled: _hasStress,
                    style: TextStyle(
                      fontSize: 12,
                      color: _hasStress ? AppColors.textPrimary : AppColors.textTertiary.withOpacity(0.6),
                    ),
                    decoration: InputDecoration(
                      hintText: widget.showArabic ? 'صف الحدث وتأثيره...' : 'Describe the event and its impact...',
                      hintStyle: TextStyle(
                        fontSize: 11,
                        color: AppColors.textTertiary.withOpacity(_hasStress ? 1.0 : 0.6),
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