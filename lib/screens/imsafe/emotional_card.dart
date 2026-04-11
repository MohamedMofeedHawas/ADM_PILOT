
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/models.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';

class EmotionalCard extends StatefulWidget {
  final ImsafeItem item;
  final bool isExpanded;
  final bool showArabic;
  final VoidCallback onTap;
  final ValueChanged<String> onRatingChanged;
  final ValueChanged<String> onNotesChanged;
  final Function(int index, String rating, String notes) onItemChanged;
  final int index;

  const EmotionalCard({super.key,
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
  State<EmotionalCard> createState() => EmotionalCardState();
}

class EmotionalCardState extends State<EmotionalCard> {
  late bool _hasEmotionalEvent;
  late Map<String, bool> _emotionalEvents;
  late String _intensityLevel; // 'low', 'medium', 'high'

  @override
  void initState() {
    super.initState();
    _hasEmotionalEvent = widget.item.subItems['hasEmotionalEvent'] ?? false;
    _emotionalEvents = Map<String, bool>.from(
        widget.item.subItems['emotionalEvents'] ?? {
          'conflict_disagreement': false,
          'argument_family': false,
          'celebration_good_news': false,
          'personal_worry': false,
          'grief_loss': false,
          'excitement_anticipation': false,
          'frustration_annoyance': false,
          'anxiety_flight': false,
          'mental_saturation': false, // Professional addition
        });
    _intensityLevel = widget.item.subItems['intensityLevel'] ?? 'low';
  }

  void _updateState(bool ar) {
    widget.item.subItems['hasEmotionalEvent'] = _hasEmotionalEvent;
    widget.item.subItems['emotionalEvents'] = _emotionalEvents;
    widget.item.subItems['intensityLevel'] = _intensityLevel;


    int score = 0;

    // Score for each event
    final eventScores = {
      'conflict_disagreement': 15,
      'argument_family': 20,
      'celebration_good_news': 10,
      'personal_worry': 15,
      'grief_loss': 25,
      'excitement_anticipation': 10,
      'frustration_annoyance': 15,
      'anxiety_flight': 20,
      'mental_saturation': 30, // High score for professional addition
    };

    _emotionalEvents.forEach((key, value) {
      if (value == true && eventScores.containsKey(key)) {
        score += eventScores[key]!;
      }
    });

    // Score for intensity level
    final intensityScores = {'low': 5, 'medium': 25, 'high': 50};
    score += intensityScores[_intensityLevel] ?? 0;

    String rating;
    String recommendation;
    String reason = '';

    // High intensity is an immediate NO-GO
    if (_intensityLevel == 'high') {
      rating = 'HIGH';
      recommendation = ar ? '❌ لا تطير' : '❌ NO-GO';
      reason = ar ? 'حالة عاطفية متقلبة (عالية)' : 'Volatile emotional state (High)';
    }
    // Grief/Loss is also a critical factor
    else if (_emotionalEvents['grief_loss'] == true) {
      rating = 'HIGH';
      recommendation = ar ? '❌ لا تطير' : '❌ NO-GO';
      reason = ar ? 'تأثير الحزن أو الفقدان' : 'Impact of grief or loss';
    }
    // Mental saturation is a critical factor
    else if (_emotionalEvents['mental_saturation'] == true) {
      rating = 'HIGH';
      recommendation = ar ? '❌ لا تطير' : '❌ NO-GO';
      reason = ar ? 'إرهاق معرفي/تحميل ذهني مرتفع' : 'High cognitive load/mental saturation';
    }
    // Scoring thresholds
    else if (score >= 50) {
      rating = 'HIGH';
      recommendation = ar ? '❌ لا تطير' : '❌ NO-GO';
      reason = ar ? 'مستوى تأثير عاطفي مرتفع جدًا' : 'Very high emotional impact';
    } else if (score >= 25) {
      rating = 'MEDIUM';
      recommendation = ar ? '⚠️ بحذر' : '⚠️ CAUTION';
      reason = ar ? 'مستوى تأثير عاطفي متوسط' : 'Moderate emotional impact';
    } else if (score > 5) {
      rating = 'LOW';
      recommendation = ar ? '⚠️ راقب الحالة' : '⚠️ Monitor condition';
      reason = ar ? 'تأثير عاطفي بسيط' : 'Minor emotional impact';
    } else {
      rating = 'LOW';
      recommendation = ar ? '✅ مسموح' : '✅ GO';
      reason = ar ? 'حالة عاطفية محايدة' : 'Neutral emotional state';
    }

    // Add procedural advice to the recommendation
    if (rating != 'LOW') {
      String proceduralAdvice = ar
          ? ' - أعلن حالتك وأعد دخول حلقة DECIDE'
          : ' - Verbalize state and re-enter DECIDE loop';
      recommendation += proceduralAdvice;
    }

    widget.item.subItems['riskScore'] = score;
    widget.item.subItems['recommendation'] = recommendation;
    widget.item.subItems['reason'] = reason;

    widget.onRatingChanged(rating);
    widget.onItemChanged(widget.index, widget.item.rating, widget.item.notes);
  }

  Widget _eventCheckbox(String title, String key) {
    bool isSelected = _emotionalEvents[key] ?? false;
    bool isEnabled = _hasEmotionalEvent;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: InkWell(
        onTap: isEnabled ? () {
          setState(() {
            _emotionalEvents[key] = !isSelected;
            _updateState(widget.showArabic);
          });
        } : null,
        child: Row(children: [
          Checkbox(
            value: isSelected,
            onChanged: isEnabled ? (_) {
              setState(() {
                _emotionalEvents[key] = !isSelected;
                _updateState(widget.showArabic);
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
        ]),
      ),
    );
  }

  Widget _eventCheckboxLocalized(String key) {
    final ar = widget.showArabic;
    final titles = {
      'conflict_disagreement': ar ? 'خلاف أو عدم اتفاق (مع زميل، إلخ)' : 'Conflict/Disagreement (e.g., with a colleague)',
      'argument_family': ar ? 'جدال مع فرد من العائلة' : 'Argument with a family member',
      'celebration_good_news': ar ? 'احتفال أو أخبار سارة (ترقية، إنجاز)' : 'Celebration/Good news (e.g., promotion, achievement)',
      'personal_worry': ar ? 'قلق بشأن مسألة شخصية' : 'Worry about a personal issue',
      'grief_loss': ar ? 'حزن أو فقدان' : 'Grief or loss',
      'excitement_anticipation': ar ? 'حماس أو ترقب لحدث قادم' : 'Excitement/Anticipation for an upcoming event',
      'frustration_annoyance': ar ? 'إحباط أو انزعاج (تأخيرات، مشاكل تقنية)' : 'Frustration/Annoyance (e.g., delays, tech issues)',
      'anxiety_flight': ar ? 'قلق من الرحلة أو اختبار طيران' : 'Anxiety about the flight or a checkride',
      'mental_saturation': ar ? 'الشعور بالإرهاق الذهني أو التشبع العقلي' : 'Feeling mentally overloaded or saturated',
    };
    return _eventCheckbox(titles[key] ?? key, key);
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
                  Text(widget.showArabic ? 'هل مررت بحدث عاطفي مؤخرًا؟' : 'Experienced a significant emotional event?', style: const TextStyle(fontSize: 13, color: AppColors.textPrimary)),
                  Switch(value: _hasEmotionalEvent, onChanged: (v) {
                    setState(() {
                      _hasEmotionalEvent = v;
                      if (!_hasEmotionalEvent) {
                        _emotionalEvents.updateAll((key, value) => false);
                        _intensityLevel = 'low';
                        widget.item.subItems['additionalNotes'] = '';
                      }
                      _updateState(widget.showArabic);
                    });
                  }, activeColor: AppColors.red),
                ]),
                const SizedBox(height: 12),
                Text(widget.showArabic ? 'الأحداث العاطفية المحتملة:' : 'Potential Emotional Events:', style: GoogleFonts.inter(fontSize: 10, color: AppColors.textTertiary, letterSpacing: 1.5)),
                const SizedBox(height: 8),
                _eventCheckboxLocalized('conflict_disagreement'),
                _eventCheckboxLocalized('argument_family'),
                _eventCheckboxLocalized('celebration_good_news'),
                _eventCheckboxLocalized('personal_worry'),
                _eventCheckboxLocalized('grief_loss'),
                _eventCheckboxLocalized('excitement_anticipation'),
                _eventCheckboxLocalized('frustration_annoyance'),
                _eventCheckboxLocalized('anxiety_flight'),
                _eventCheckboxLocalized('mental_saturation'),
                const SizedBox(height: 12),
                Text(widget.showArabic ? 'مستوى الشدة العاطفية:' : 'Emotional Intensity Level:', style: GoogleFonts.inter(fontSize: 10, color: AppColors.textTertiary, letterSpacing: 1.5)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _intensityLevel,
                  isExpanded: true,
                  style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.surfaceAlt,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: AppColors.border)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: AppColors.border)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: AppColors.cyan, width: 1.5)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  ),
                  onChanged: _hasEmotionalEvent ? (String? newValue) {
                    setState(() {
                      _intensityLevel = newValue!;
                      _updateState(widget.showArabic);
                    });
                  } : null,
                  items: [
                    DropdownMenuItem(value: 'low', child: Text(widget.showArabic ? 'منخفض (محايد)' : 'Low (Neutral)')),
                    DropdownMenuItem(value: 'medium', child: Text(widget.showArabic ? 'متوسط (مشوش)' : 'Medium (Distracted)')),
                    DropdownMenuItem(value: 'high', child: Text(widget.showArabic ? 'مرتفع (متقلب)' : 'High (Volatile)')),
                  ],
                ),
                const SizedBox(height: 12),
                Text(widget.showArabic ? 'التوصية:' : 'Recommendation:', style: const TextStyle(fontSize: 12, color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                Text('$recommendation\n($reason)', style: const TextStyle(fontSize: 11, color: AppColors.textTertiary, fontStyle: FontStyle.italic)),
                if (_hasEmotionalEvent) ...[
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
                    style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: widget.showArabic ? 'صف الحدث ومشاعرك...' : 'Describe the event and your feelings...',
                      hintStyle: TextStyle(fontSize: 11, color: AppColors.textTertiary.withOpacity(0.7)),
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