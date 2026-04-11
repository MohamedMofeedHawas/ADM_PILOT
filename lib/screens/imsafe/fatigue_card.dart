//
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
//
// import '../../models/models.dart';
// import '../../theme/theme.dart';
// import '../../widgets/widgets.dart';
//
// // Assuming TimelineSlider and TimelineMarker are available
// // (Same as used in AlcoholCard)
// class TimelineSlider extends StatelessWidget {
//   final String label;
//   final double value;
//   final double min;
//   final double max;
//   final List<TimelineMarker> markers;
//   final ValueChanged<double>? onChanged;
//
//   const TimelineSlider({
//     super.key,
//     required this.label,
//     required this.value,
//     required this.min,
//     required this.max,
//     required this.markers,
//     this.onChanged,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textPrimary)),
//             Text('${value.toInt()}h', style: const TextStyle(fontSize: 12, color: AppColors.cyan, fontWeight: FontWeight.bold)),
//           ],
//         ),
//         const SizedBox(height: 8),
//         SliderTheme(
//           data: SliderTheme.of(context).copyWith(
//             activeTrackColor: AppColors.cyan,
//             inactiveTrackColor: AppColors.border,
//             thumbColor: AppColors.cyan,
//             overlayColor: AppColors.cyan.withOpacity(0.2),
//             trackHeight: 4.0,
//             thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8.0),
//           ),
//           child: Slider(
//             value: value,
//             min: min,
//             max: max,
//             divisions: (max - min).toInt(),
//             onChanged: onChanged,
//           ),
//         ),
//       ],
//     );
//   }
// }
//
// class TimelineMarker {
//   final double value;
//   final String label;
//   final Color color;
//   TimelineMarker({required this.value, required this.label, required this.color});
// }
//
// // Enum for Sleep Quality
// enum SleepQuality {
//   good('good', 'Good', 'جيد', 1.0),
//   fair('fair', 'Fair', 'مقبول', 1.5),
//   poor('poor', 'Poor', 'سيئ', 2.0);
//
//   const SleepQuality(this.id, this.labelEn, this.labelAr, this.multiplier);
//   final String id;
//   final String labelEn;
//   final String labelAr;
//   final double multiplier;
//
//   String label(bool ar) => ar ? labelAr : labelEn;
// }
//
// // Compact Radio Tile for Sleep Quality
// class _RadioTile extends StatelessWidget {
//   final String label;
//   final String? subtitle;
//   final bool selected;
//   final Color color;
//   final VoidCallback onTap;
//   final bool compact;
//
//   const _RadioTile({
//     required this.label,
//     this.subtitle,
//     required this.selected,
//     required this.color,
//     required this.onTap,
//     this.compact = false,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: EdgeInsets.all(compact ? 8 : 12),
//         decoration: BoxDecoration(
//           color: selected ? color.withOpacity(0.15) : AppColors.surfaceAlt,
//           borderRadius: BorderRadius.circular(8),
//           border: Border.all(
//             color: selected ? color.withOpacity(0.5) : AppColors.border,
//             width: 1.5,
//           ),
//         ),
//         child: Column(
//           children: [
//             Text(label,
//                 style: TextStyle(
//                     fontSize: compact ? 10 : 11,
//                     fontWeight: FontWeight.w600,
//                     color: selected ? color : AppColors.textPrimary)),
//             if (subtitle != null) ...[
//               const SizedBox(height: 2),
//               Text(subtitle!,
//                   style: TextStyle(
//                       fontSize: 9,
//                       color: selected ? color : AppColors.textTertiary)),
//             ]
//           ],
//         ),
//       ),
//     );
//   }
// }
//
//
// class FatigueCard extends StatefulWidget {
//   final ImsafeItem item;
//   final bool isExpanded;
//   final bool showArabic;
//   final VoidCallback onTap;
//   final ValueChanged<String> onRatingChanged;
//   final ValueChanged<String> onNotesChanged;
//   final Function(int index, String rating, String notes) onItemChanged;
//   final int index;
//
//   const FatigueCard({super.key,
//     required this.item,
//     required this.isExpanded,
//     required this.showArabic,
//     required this.onTap,
//     required this.onRatingChanged,
//     required this.onNotesChanged,
//     required this.onItemChanged,
//     required this.index,
//   });
//
//   @override
//   State<FatigueCard> createState() => FatigueCardState();
// }
//
// class FatigueCardState extends State<FatigueCard> {
//   late double _hoursOfSleep;
//   late SleepQuality _sleepQuality;
//   // late double _hoursAwake;
//   late String _dutyCycle;
//   late bool _highCaffeine;
//   late bool _enableMidFlightCheck;
//
//   final List<String> _dutyCycleOptions = ['short', 'long', 'back_to_back', 'multi_day'];
//
//   @override
//   void initState() {
//     super.initState();
//     _hoursOfSleep = (widget.item.subItems['hoursOfSleep'] ?? 8.0).toDouble();
//     _sleepQuality = SleepQuality.values.firstWhere((q) => q.id == (widget.item.subItems['sleepQuality'] ?? 'good'), orElse: () => SleepQuality.good);
//     // _hoursAwake = (widget.item.subItems['hoursAwake'] ?? 4.0).toDouble();
//     _dutyCycle = widget.item.subItems['dutyCycle'] ?? 'short';
//     _highCaffeine = widget.item.subItems['highCaffeine'] ?? false;
//     _enableMidFlightCheck = widget.item.subItems['enableMidFlightCheck'] ?? false;
//   }
//
//   void _updateState(bool ar) {
//     widget.item.subItems['hoursOfSleep'] = _hoursOfSleep;
//     widget.item.subItems['sleepQuality'] = _sleepQuality.id;
//     // widget.item.subItems['hoursAwake'] = _hoursAwake;
//     widget.item.subItems['dutyCycle'] = _dutyCycle;
//     widget.item.subItems['highCaffeine'] = _highCaffeine;
//     widget.item.subItems['enableMidFlightCheck'] = _enableMidFlightCheck;
//
//     double score = 0;
//     String rating;
//     String recommendation;
//     String reason = '';
//
//     // Scoring logic
//     if (_hoursOfSleep < 5
//         // || _hoursAwake > 16
//     ) {
//       rating = 'HIGH';
//       recommendation = ar ? '❌ لا تطير' : '❌ NO-GO';
//       reason = _hoursOfSleep < 5
//           ? (ar ? 'أقل من 5 ساعات نوم' : 'Less than 5 hours of sleep')
//           : (ar ? 'أكثر من 16 ساعة صحو' : 'More than 16 hours awake');
//       score = 100; // Max score for automatic NO-GO
//     } else {
//       // Sleep score
//       if (_hoursOfSleep < 7) score += 40;
//       if (_hoursOfSleep < 6) score += 20;
//       // Awake score
//       // if (_hoursAwake > 12) score += 30;
//       // if (_hoursAwake > 14) score += 20;
//       // Quality score
//       score += (_sleepQuality.multiplier - 1) * 40 ;
//       // Duty Cycle score
//       if (_dutyCycle == 'back_to_back') score += 20;
//       if (_dutyCycle == 'multi_day') score += 40;
//       if (_dutyCycle == 'long') score += 10;
//       // Caffeine score
//       if (_highCaffeine) score += 15;
//
//       if (score > 70) {
//         rating = 'HIGH';
//         recommendation = ar ? '❌ لا تطير' : '❌ NO-GO';
//         reason = ar ? 'مؤشرات إرهاق عالية متعددة' : 'Multiple high fatigue indicators';
//       } else if (score > 30) {
//         rating = 'MEDIUM';
//         recommendation = ar ? '⚠️ بحذر' : '⚠️ CAUTION';
//         reason = ar ? 'مؤشرات إرهاق متوسطة' : 'Moderate fatigue indicators';
//       } else {
//         rating = 'LOW';
//         recommendation = ar ? '✅ مسموح' : '✅ GO';
//         reason = ar ? 'مستوى إرهاق منخفض' : 'Low fatigue level';
//       }
//     }
//
//     widget.item.subItems['riskScore'] = score;
//     widget.item.subItems['recommendation'] = recommendation;
//     widget.item.subItems['reason'] = reason;
//
//     widget.onRatingChanged(rating);
//     widget.onItemChanged(widget.index, widget.item.rating, widget.item.notes);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final color = AppColors.riskColor(widget.item.rating);
//     final reason = widget.item.subItems['reason'] ?? '';
//     final recommendation = widget.item.subItems['recommendation'] ?? '';
//     final ar = widget.showArabic;
//
//     return Container(
//       decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
//       child: ClipRRect(borderRadius: BorderRadius.circular(9),
//         child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//           IntrinsicHeight(child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
//             Container(width: 3, color: color),
//             Expanded(child: Material(color: AppColors.surface,
//               child: InkWell(onTap: widget.onTap,
//                 child: Padding(padding: const EdgeInsets.all(14),
//                   child: Row(children: [
//                     Container(width: 34, height: 34, decoration: BoxDecoration(shape: BoxShape.circle, color: color.withOpacity(0.1), border: Border.all(color: color.withOpacity(0.3))),
//                       child: Center(child:
//                       Text(
//                         '${widget.item.subItems['riskScore'] ?? 0}',
//                         style: TextStyle(
//                             fontSize: 12,
//                             fontWeight: FontWeight.bold,
//                             color: color),
//                       ),                          ),
//                     ),
//                     const SizedBox(width: 10),
//                     Text(widget.item.iconEmoji, style: const TextStyle(fontSize: 20)),
//                     const SizedBox(width: 8),
//                     Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                       Text(ar ? widget.item.arabicTitle : widget.item.title, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
//                       Text(ar ? widget.item.arabicSubtitle : widget.item.subtitle, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
//                     ])),
//                     RiskBadge(widget.item.rating),
//                     const SizedBox(width: 6),
//                     Icon(widget.isExpanded ? Icons.expand_less : Icons.expand_more, size: 16, color: AppColors.textTertiary),
//                   ]),
//                 ),
//               ),
//             ),
//             )])),
//           if (widget.isExpanded) ...[
//             const Divider(height: 1, color: AppColors.border),
//             Container(color: AppColors.surface, padding: const EdgeInsets.all(14),
//               child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                 TimelineSlider(
//                   label: ar ? 'ساعات النوم (آخر 24 ساعة)' : 'Hours of Sleep (last 24h)',
//                   value: _hoursOfSleep,
//                   min: 0,
//                   max: 12,
//                   markers: [
//                     TimelineMarker(value: 5, label: '5h', color: AppColors.red),
//                     TimelineMarker(value: 7, label: '7h', color: AppColors.amber),
//                     TimelineMarker(value: 8, label: '8h', color: AppColors.green),
//                   ],
//                   onChanged: (v) { setState(() { _hoursOfSleep = v; _updateState(ar); }); },
//                 ),
//                 const SizedBox(height: 16),
//                 Text(ar ? 'جودة النوم:' : 'SLEEP QUALITY:', style: GoogleFonts.inter(fontSize: 10, color: AppColors.cyan, letterSpacing: 1.5)),
//                 const SizedBox(height: 8),
//                 Row(children: SleepQuality.values.map((q) => Expanded(
//                   child: Padding(padding: const EdgeInsets.symmetric(horizontal: 3),
//                     child: _RadioTile(
//                       label: q.label(ar),
//                       subtitle: '×${q.multiplier.toStringAsFixed(1)}',
//                       selected: _sleepQuality == q,
//                       color: switch (q) {
//                         SleepQuality.good => AppColors.green,
//                         SleepQuality.fair => AppColors.amber,
//                         SleepQuality.poor => AppColors.red,
//                       },
//                       onTap: () { setState(() { _sleepQuality = q; _updateState(ar); }); },
//                       compact: true,
//                     ),
//                   ),
//                 )).toList()),
//                 const SizedBox(height: 16),
//                 // TimelineSlider(
//                 //   label: ar ? 'ساعات الصحو' : 'Hours Awake',
//                 //   value: _hoursAwake,
//                 //   min: 0,
//                 //   max: 24,
//                 //   markers: [
//                 //     TimelineMarker(value: 12, label: '12h', color: AppColors.amber),
//                 //     TimelineMarker(value: 16, label: '16h', color: AppColors.red),
//                 //   ],
//                 //   onChanged: (v) { setState(() { _hoursAwake = v; _updateState(ar); }); },
//                 // ),
//                 // const SizedBox(height: 16),
//                 Text(ar ? 'دورية العمل الأخيرة:' : 'Recent Duty Cycle:', style: GoogleFonts.inter(fontSize: 10, color: AppColors.cyan, letterSpacing: 1.5)),
//                 const SizedBox(height: 8),
//                 DropdownButtonFormField<String>(
//                   value: _dutyCycle,
//                   isExpanded: true,
//                   style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
//                   decoration: InputDecoration(
//                     filled: true, fillColor: AppColors.surfaceAlt,
//                     border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: AppColors.border)),
//                     enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: AppColors.border)),
//                     focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: AppColors.cyan, width: 1.5)),
//                     contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
//                   ),
//                   onChanged: (v) { setState(() { _dutyCycle = v!; _updateState(ar); }); },
//                   items: [
//                     DropdownMenuItem(value: 'short', child: Text(ar ? 'رحلة قصيرة' : 'Short Haul')),
//                     DropdownMenuItem(value: 'long', child: Text(ar ? 'رحلة طويلة' : 'Long Haul')),
//                     DropdownMenuItem(value: 'back_to_back', child: Text(ar ? 'رحلات متتالية' : 'Back-to-Back')),
//                     DropdownMenuItem(value: 'multi_day', child: Text(ar ? 'على مدار عدة أيام' : 'Multi-Day')),
//                   ],
//                 ),
//                 const SizedBox(height: 16),
//                 Row(children: [
//                   Expanded(child: SwitchListTile(
//                     contentPadding: EdgeInsets.zero,
//                     title: Text(ar ? 'تناول كافيين عالٍ (>4 أكواب)' : 'High Caffeine (>4 cups)', style: const TextStyle(fontSize: 12, color: AppColors.textPrimary)),
//                     value: _highCaffeine,
//                     onChanged: (v) { setState(() { _highCaffeine = v!; _updateState(ar); }); },
//                     activeColor: AppColors.cyan,
//                   )),
//                 ]),
//                 const SizedBox(height: 12),
//                 Container(
//                   padding: const EdgeInsets.all(12),
//                   decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: color.withOpacity(0.3))),
//                   child: Row(children: [
//                     Icon(widget.item.rating == 'HIGH' ? Icons.block : Icons.warning_amber, size: 18, color: color),
//                     const SizedBox(width: 10),
//                     Expanded(child: Text(recommendation, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color))),
//                   ]),
//                 ),
//                 const SizedBox(height: 12),
//                 Container(
//                   padding: const EdgeInsets.all(12),
//                   decoration: BoxDecoration(color: AppColors.surfaceAlt, borderRadius: BorderRadius.circular(8)),
//                   child: Row(children: [
//                     const Icon(Icons.notifications_outlined, color: AppColors.cyan, size: 20),
//                     const SizedBox(width: 12),
//                     Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                       Text(ar ? 'فحص الإرهاق أثناء الرحلة' : 'Mid-Flight Fatigue Check', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
//                       Text(ar ? 'تذكير في Cruise وTop of Descent' : 'Reminder at Cruise & Top of Descent', style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
//                     ])),
//                     Switch(value: _enableMidFlightCheck, onChanged: (v) { setState(() { _enableMidFlightCheck = v!; _updateState(ar); }); }, activeColor: AppColors.cyan),
//                   ]),
//                 ),
//               ]),
//             ),
//           ],
//         ]),
//       ),
//     );
//   }
// }
// lib/screens/imsafe/fatigue_card_v2.dart
// ══════════════════════════════════════════════════════════════
// Enhanced Fatigue Card — Physical / Mental / Sleep sub-scores
// ══════════════════════════════════════════════════════════════

import 'package:check_list_stress/screens/imsafe/imsafe_severity.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/models.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';

class FatigueCardV2 extends StatefulWidget {
  final ImsafeItem item;
  final int index;
  final bool isExpanded;
  final bool showArabic;
  final VoidCallback onTap;
  final ValueChanged<String> onRatingChanged;
  final ValueChanged<String> onNotesChanged;
  final Function(int index, String rating, String notes) onItemChanged;

  const FatigueCardV2({
    super.key,
    required this.item,
    required this.index,
    required this.isExpanded,
    required this.showArabic,
    required this.onTap,
    required this.onRatingChanged,
    required this.onNotesChanged,
    required this.onItemChanged,
  });

  @override
  State<FatigueCardV2> createState() => _FatigueCardV2State();
}

class _FatigueCardV2State extends State<FatigueCardV2> {
  late bool _hasFatigue;
  late double _hoursOfSleep; //
  // Sub-category severities (0-100)
  late double _physicalFatigue;
  late double _mentalFatigue;
  late double _sleepDeprivation;
  late double _workloadFatigue;
  late double _jetLagFatigue;

  // Which sub-categories are active
  late Map<String, bool> _active;

  @override
  void initState() {
    super.initState();
    _hasFatigue       = widget.item.subItems['hasFatigue']         ?? false;
    _physicalFatigue  = (widget.item.subItems['physicalSev']       ?? 0.0).toDouble();
    _mentalFatigue    = (widget.item.subItems['mentalSev']         ?? 0.0).toDouble();
    _sleepDeprivation = (widget.item.subItems['sleepSev']          ?? 0.0).toDouble();
    _workloadFatigue  = (widget.item.subItems['workloadSev']       ?? 0.0).toDouble();
    _jetLagFatigue    = (widget.item.subItems['jetlagSev']         ?? 0.0).toDouble();
    _hoursOfSleep     = (widget.item.subItems['hoursOfSleep']      ?? 7.0).toDouble(); // ✅ ده المفقود

    _active = Map<String, bool>.from(
        widget.item.subItems['fatigueActive'] ?? {
          'physical': false,
          'mental': false,
          'sleep': false,
          'workload': false,
          'jetlag': false,
        });
  }

  // Overall fatigue score = weighted average of active categories
  double get _overallScore {
    if (!_hasFatigue) return 0;
    final weights = {
      'physical': 0.25,
      'mental':   0.25,
      'sleep':    0.30,  // sleep deprivation has highest weight
      'workload': 0.10,
      'jetlag':   0.10,
    };
    final vals = {
      'physical': _physicalFatigue,
      'mental':   _mentalFatigue,
      'sleep':    _sleepDeprivation,
      'workload': _workloadFatigue,
      'jetlag':   _jetLagFatigue,
    };
    double total = 0;
    double weightSum = 0;
    _active.forEach((k, v) {
      if (v) {
        total += vals[k]! * weights[k]!;
        weightSum += weights[k]!;
      }
    });
    return weightSum == 0 ? 0 : total / weightSum;
  }
  String _sleepHoursContext(double h, bool ar) {
    if (!ar) {
      if (h >= 8)  return '✅ Optimal rest — full cognitive performance expected';
      if (h >= 7)  return '✅ Adequate sleep — normal vigilance';
      if (h >= 6)  return '⚠️ Mild sleep deficit — occasional attention lapses';
      if (h >= 5)  return '⚠️ Moderate deprivation — microsleep risk possible';
      return '❌ Severe deprivation — DO NOT FLY';
    } else {
      if (h >= 8)  return '✅ راحة مثالية — أداء معرفي كامل';
      if (h >= 7)  return '✅ نوم كافٍ — يقظة طبيعية';
      if (h >= 6)  return '⚠️ نقص بسيط — تراجع متقطع في الانتباه';
      if (h >= 5)  return '⚠️ حرمان متوسط — خطر النوم الميكروي محتمل';
      return '❌ حرمان شديد — لا تطير';
    }
  }

  void _persist() {
    widget.item.subItems['hasFatigue']    = _hasFatigue;
    widget.item.subItems['physicalSev']   = _physicalFatigue;
    widget.item.subItems['mentalSev']     = _mentalFatigue;
    widget.item.subItems['sleepSev']      = _sleepDeprivation;
    widget.item.subItems['workloadSev']   = _workloadFatigue;
    widget.item.subItems['jetlagSev']     = _jetLagFatigue;
    widget.item.subItems['fatigueActive'] = _active;
    widget.item.subItems['riskScore']     = _overallScore.toInt();
    widget.item.subItems['hoursOfSleep'] = _hoursOfSleep;

    final score = _overallScore;
    String rating;
    String recommendation;
    if (!(_active['sleep'] ?? false)) {
      // ساعات نوم أقل من 7 = ترفع الـ sleep risk
      if (_hoursOfSleep < 5) _sleepDeprivation = 90;
      else if (_hoursOfSleep < 6) _sleepDeprivation = 65;
      else if (_hoursOfSleep < 7) _sleepDeprivation = 35;
      else _sleepDeprivation = 0;
    }

    if (score >= 80) {
      rating = 'HIGH';
      recommendation = widget.showArabic
          ? '❌ خطر حرج — عدم الطيران'
          : '❌ Critical fatigue — DO NOT FLY';
    } else if (score >= 60) {
      rating = 'HIGH';
      recommendation = widget.showArabic
          ? '❌ إرهاق شديد — توقف وارتاح'
          : '❌ Severe fatigue — Rest required';
    } else if (score >= 40) {
      rating = 'MEDIUM';
      recommendation = widget.showArabic
          ? '⚠️ إرهاق متوسط — طر بحذر'
          : '⚠️ Moderate fatigue — Fly with caution';
    } else if (score >= 20) {
      rating = 'LOW';
      recommendation = widget.showArabic
          ? '⚠️ إرهاق بسيط — راقب نفسك'
          : '⚠️ Mild fatigue — Self-monitor';
    } else {
      rating = 'LOW';
      recommendation = widget.showArabic
          ? '✅ لا إرهاق — مسموح'
          : '✅ No fatigue — GO';
    }

    widget.item.subItems['recommendation'] = recommendation;
    widget.onRatingChanged(rating);
    widget.onItemChanged(widget.index, widget.item.rating, widget.item.notes);
  }

  String _physContext() {
    final s = _physicalFatigue;
    if (!widget.showArabic) {
      if (s <= 20) return 'Minimal physical fatigue — normal performance expected';
      if (s <= 40) return 'Mild physical fatigue — slight reduction in manual control precision';
      if (s <= 60) return 'Moderate — reduced physical coordination and reaction time';
      if (s <= 80) return 'High physical fatigue — significant impairment of motor skills';
      return 'Extreme physical exhaustion — severe motor control impairment ❌';
    } else {
      if (s <= 20) return 'إرهاق جسدي ضئيل — أداء طبيعي';
      if (s <= 40) return 'إرهاق جسدي خفيف — تقليل طفيف في دقة التحكم';
      if (s <= 60) return 'متوسط — انخفاض في التنسيق والزمن الرجعي';
      if (s <= 80) return 'إرهاق عالٍ — ضعف ملحوظ في المهارات الحركية';
      return 'إرهاق جسدي حرج — ضعف شديد في التحكم ❌';
    }
  }

  String _mentContext() {
    final s = _mentalFatigue;
    if (!widget.showArabic) {
      if (s <= 20) return 'Clear mental alertness — full cognitive capacity';
      if (s <= 40) return 'Mild mental fatigue — slightly reduced focus';
      if (s <= 60) return 'Moderate cognitive impairment — affects decision-making quality';
      if (s <= 80) return 'High mental fatigue — situational awareness degraded';
      return 'Cognitive overload — critical decision-making impairment ❌';
    } else {
      if (s <= 20) return 'يقظة ذهنية كاملة — قدرات معرفية سليمة';
      if (s <= 40) return 'إرهاق ذهني خفيف — انخفاض طفيف في التركيز';
      if (s <= 60) return 'ضعف معرفي متوسط — يؤثر على جودة القرار';
      if (s <= 80) return 'إرهاق ذهني عالٍ — تدهور الوعي الظرفي';
      return 'إرهاق معرفي حرج — ضعف خطير في صنع القرار ❌';
    }
  }

  String _sleepContext() {
    final s = _sleepDeprivation;
    if (!widget.showArabic) {
      if (s <= 20) return 'Adequate rest — normal vigilance';
      if (s <= 40) return 'Mild sleep deficit — occasional lapses in attention';
      if (s <= 60) return 'Moderate sleep deprivation — microsleep risk possible';
      if (s <= 80) return 'Severe sleep deprivation — high microsleep and error risk';
      return 'Critical sleep deprivation — extreme safety risk ❌';
    } else {
      if (s <= 20) return 'راحة كافية — يقظة طبيعية';
      if (s <= 40) return 'نقص نوم خفيف — تراجع متقطع في الانتباه';
      if (s <= 60) return 'حرمان متوسط من النوم — خطر النوم الميكروي محتمل';
      if (s <= 80) return 'حرمان شديد من النوم — خطر مرتفع جداً';
      return 'حرمان حرج من النوم — خطر أمان حرج ❌';
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = AppColors.riskColor(widget.item.rating);
    final overall = _overallScore;
    final level = SeverityLevel.fromValue(overall);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(9),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // ── Header ──────────────────────────────────────
          IntrinsicHeight(
            child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Container(width: 3, color: color),
              Expanded(
                child: Material(
                  color: AppColors.surface,
                  child: InkWell(
                    onTap: widget.onTap,
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(children: [
                        // Score circle
                        Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: color.withOpacity(0.1),
                            border: Border.all(color: color.withOpacity(0.3)),
                          ),
                          child: Center(
                            child: Text(
                              '${overall.toInt()}',
                              style: TextStyle(
                                fontSize: 11, fontWeight: FontWeight.bold, color: color,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(widget.item.iconEmoji,
                            style: const TextStyle(fontSize: 20)),
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
                                    fontSize: 13, color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w600),
                              ),
                              Text(
                                widget.showArabic
                                    ? widget.item.arabicSubtitle
                                    : widget.item.subtitle,
                                style: const TextStyle(
                                    fontSize: 10, color: AppColors.textSecondary),
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
                          size: 16, color: AppColors.textTertiary,
                        ),
                      ]),
                    ),
                  ),
                ),
              ),
            ]),
          ),

          if (widget.isExpanded) ...[
            const Divider(height: 1, color: AppColors.border),
            Container(
              color: AppColors.surface,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Toggle
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.showArabic
                            ? 'هل تشعر بالإرهاق؟'
                            : 'Are you experiencing fatigue?',
                        style: const TextStyle(
                            fontSize: 13, color: AppColors.textPrimary),
                      ),
                      Switch(
                        value: _hasFatigue,
                        onChanged: (v) {
                          setState(() {
                            _hasFatigue = v;
                            if (!v) {
                              _active.updateAll((k, _) => false);
                              _physicalFatigue = _mentalFatigue =
                                  _sleepDeprivation = _workloadFatigue =
                                  _jetLagFatigue = 0;
                            }
                            _persist();
                          });
                        },
                        activeColor: AppColors.amber,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // ── Overall Fatigue Index ──────────────
                  if (_hasFatigue) ...[
                    _OverallFatigueGauge(
                      score: overall,
                      level: level,
                      showArabic: widget.showArabic,
                    ),
                    const SizedBox(height: 16),
                    Container(height: 1, color: AppColors.border),
                    const SizedBox(height: 16),
                  ],
                  // ✅ Sleep Hours Slider
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.elevated,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              widget.showArabic
                                  ? '😴 ساعات النوم (آخر 24 ساعة)'
                                  : '😴 Hours of Sleep (last 24h)',
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary),
                            ),
                            // Badge لون حسب الساعات
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: _hoursOfSleep >= 7
                                    ? AppColors.green.withOpacity(0.15)
                                    : _hoursOfSleep >= 5
                                    ? AppColors.amber.withOpacity(0.15)
                                    : AppColors.red.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: _hoursOfSleep >= 7
                                      ? AppColors.green.withOpacity(0.4)
                                      : _hoursOfSleep >= 5
                                      ? AppColors.amber.withOpacity(0.4)
                                      : AppColors.red.withOpacity(0.4),
                                ),
                              ),
                              child: Text(
                                '${_hoursOfSleep.toInt()}h',
                                style: GoogleFonts.shareTechMono(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: _hoursOfSleep >= 7
                                      ? AppColors.green
                                      : _hoursOfSleep >= 5
                                      ? AppColors.amber
                                      : AppColors.red,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: _hoursOfSleep >= 7
                                ? AppColors.green
                                : _hoursOfSleep >= 5
                                ? AppColors.amber
                                : AppColors.red,
                            inactiveTrackColor: AppColors.border,
                            thumbColor: _hoursOfSleep >= 7
                                ? AppColors.green
                                : _hoursOfSleep >= 5
                                ? AppColors.amber
                                : AppColors.red,
                            trackHeight: 4,
                            thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 8),
                          ),
                          child: Slider(
                            value: _hoursOfSleep,
                            min: 0,
                            max: 12,
                            divisions: 24,
                            onChanged: (v) {
                              setState(() {
                                _hoursOfSleep = v;
                                // ✅ لو sleep sub-card مش active، السليدر هو اللي يحدد
                                if (!(_active['sleep'] ?? false)) {
                                  _active['sleep'] = _hoursOfSleep < 7;
                                }
                                _persist();
                              });
                            },
                          ),
                        ),
                        // Markers
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('0h',
                                  style: GoogleFonts.shareTechMono(
                                      fontSize: 8, color: AppColors.red)),
                              Text(
                                widget.showArabic
                                    ? '< 5h خطر'
                                    : '< 5h DANGER',
                                style: GoogleFonts.shareTechMono(
                                    fontSize: 8, color: AppColors.red),
                              ),
                              Text(
                                widget.showArabic ? '7h مثالي' : '7h IDEAL',
                                style: GoogleFonts.shareTechMono(
                                    fontSize: 8, color: AppColors.green),
                              ),
                              Text('12h',
                                  style: GoogleFonts.shareTechMono(
                                      fontSize: 8, color: AppColors.green)),
                            ],
                          ),
                        ),
                        // Context text
                        const SizedBox(height: 6),
                        Text(
                          _sleepHoursContext(_hoursOfSleep, widget.showArabic),
                          style: GoogleFonts.rajdhani(
                            fontSize: 11,
                            color: _hoursOfSleep >= 7
                                ? AppColors.green
                                : _hoursOfSleep >= 5
                                ? AppColors.amber
                                : AppColors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ── Sub-categories ────────────────────
                  Text(
                    widget.showArabic
                        ? 'مكونات الإرهاق:'
                        : 'FATIGUE COMPONENTS:',
                    style: GoogleFonts.shareTechMono(
                        fontSize: 9, color: AppColors.textTertiary,
                        letterSpacing: 1.5),
                  ),
                  const SizedBox(height: 12),

                  _FatigueSubCard(
                    icon: '💪',
                    title: 'Physical Fatigue',
                    arabicTitle: 'الإرهاق الجسدي',
                    subtitle: 'Muscle fatigue, body aches',
                    arabicSubtitle: 'تعب العضلات، آلام الجسد',
                    key_: 'physical',
                    severity: _physicalFatigue,
                    isActive: _active['physical'] ?? false,
                    isEnabled: _hasFatigue,
                    contextText: _physContext(),
                    showArabic: widget.showArabic,
                    onToggle: () => setState(() {
                      _active['physical'] = !(_active['physical'] ?? false);
                      if (!(_active['physical'] ?? false)) _physicalFatigue = 0;
                      _persist();
                    }),
                    onSeverityChanged: (v) => setState(() {
                      _physicalFatigue = v;
                      _persist();
                    }),
                  ),
                  const SizedBox(height: 10),

                  _FatigueSubCard(
                    icon: '🧠',
                    title: 'Mental Fatigue',
                    arabicTitle: 'الإرهاق الذهني',
                    subtitle: 'Cognitive overload, poor focus',
                    arabicSubtitle: 'حمل معرفي، ضعف التركيز',
                    key_: 'mental',
                    severity: _mentalFatigue,
                    isActive: _active['mental'] ?? false,
                    isEnabled: _hasFatigue,
                    contextText: _mentContext(),
                    showArabic: widget.showArabic,
                    onToggle: () => setState(() {
                      _active['mental'] = !(_active['mental'] ?? false);
                      if (!(_active['mental'] ?? false)) _mentalFatigue = 0;
                      _persist();
                    }),
                    onSeverityChanged: (v) => setState(() {
                      _mentalFatigue = v;
                      _persist();
                    }),
                  ),
                  const SizedBox(height: 10),

                  _FatigueSubCard(
                    icon: '😴',
                    title: 'Sleep Deprivation',
                    arabicTitle: 'الحرمان من النوم',
                    subtitle: 'Insufficient rest, microsleep risk',
                    arabicSubtitle: 'راحة غير كافية، خطر النوم الميكروي',
                    key_: 'sleep',
                    severity: _sleepDeprivation,
                    isActive: _active['sleep'] ?? false,
                    isEnabled: _hasFatigue,
                    contextText: _sleepContext(),
                    showArabic: widget.showArabic,
                    onToggle: () => setState(() {
                      _active['sleep'] = !(_active['sleep'] ?? false);
                      if (!(_active['sleep'] ?? false)) _sleepDeprivation = 0;
                      _persist();
                    }),
                    onSeverityChanged: (v) => setState(() {
                      _sleepDeprivation = v;
                      _persist();
                    }),
                  ),
                  const SizedBox(height: 10),

                  _FatigueSubCard(
                    icon: '📋',
                    title: 'Workload Fatigue',
                    arabicTitle: 'إرهاق الضغط الوظيفي',
                    subtitle: 'Long duty hours, high workload',
                    arabicSubtitle: 'ساعات عمل طويلة، عبء مرتفع',
                    key_: 'workload',
                    severity: _workloadFatigue,
                    isActive: _active['workload'] ?? false,
                    isEnabled: _hasFatigue,
                    showArabic: widget.showArabic,
                    onToggle: () => setState(() {
                      _active['workload'] = !(_active['workload'] ?? false);
                      if (!(_active['workload'] ?? false)) _workloadFatigue = 0;
                      _persist();
                    }),
                    onSeverityChanged: (v) => setState(() {
                      _workloadFatigue = v;
                      _persist();
                    }),
                  ),
                  const SizedBox(height: 10),

                  _FatigueSubCard(
                    icon: '✈️',
                    title: 'Jet Lag / Circadian Disruption',
                    arabicTitle: 'اضطراب الرحلات الجوية',
                    subtitle: 'Time zone changes, circadian disruption',
                    arabicSubtitle: 'تغيير المناطق الزمنية',
                    key_: 'jetlag',
                    severity: _jetLagFatigue,
                    isActive: _active['jetlag'] ?? false,
                    isEnabled: _hasFatigue,
                    showArabic: widget.showArabic,
                    onToggle: () => setState(() {
                      _active['jetlag'] = !(_active['jetlag'] ?? false);
                      if (!(_active['jetlag'] ?? false)) _jetLagFatigue = 0;
                      _persist();
                    }),
                    onSeverityChanged: (v) => setState(() {
                      _jetLagFatigue = v;
                      _persist();
                    }),
                  ),

                  const SizedBox(height: 12),

                  // Recommendation
                  if (widget.item.subItems['recommendation'] != null) ...[
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: color.withOpacity(0.2)),
                      ),
                      child: Row(children: [
                        Icon(Icons.info_outline, size: 14, color: color),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.item.subItems['recommendation'] as String,
                            style: GoogleFonts.rajdhani(
                                fontSize: 12, color: color),
                          ),
                        ),
                      ]),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ]),
      ),
    );
  }
}

// ── Overall Fatigue Gauge ─────────────────────────────────────
class _OverallFatigueGauge extends StatelessWidget {
  final double score;
  final SeverityLevel level;
  final bool showArabic;
  const _OverallFatigueGauge({
    required this.score,
    required this.level,
    required this.showArabic,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: level.color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: level.color.withOpacity(0.3)),
      ),
      child: Column(children: [
        Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                showArabic ? 'مؤشر الإرهاق الكلي' : 'OVERALL FATIGUE INDEX',
                style: GoogleFonts.shareTechMono(
                    fontSize: 9, color: AppColors.textTertiary, letterSpacing: 1.5),
              ),
              const SizedBox(height: 4),
              Row(crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '${score.toInt()}',
                      style: GoogleFonts.shareTechMono(
                          fontSize: 32, color: level.color,
                          fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '%',
                      style: GoogleFonts.shareTechMono(
                          fontSize: 14, color: level.color),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${level.emoji} ${showArabic ? level.arabicLabel : level.label}',
                      style: GoogleFonts.shareTechMono(
                          fontSize: 12, color: level.color,
                          fontWeight: FontWeight.w700),
                    ),
                  ]),
            ]),
          ),
          // Risk ring
          SizedBox(
            width: 56, height: 56,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: score / 100),
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOutCubic,
              builder: (_, v, __) => CircularProgressIndicator(
                value: v,
                strokeWidth: 6,
                backgroundColor: AppColors.border,
                valueColor: AlwaysStoppedAnimation(level.color),
              ),
            ),
          ),
        ]),
        const SizedBox(height: 10),
        // Gradient progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: score / 100),
            duration: const Duration(milliseconds: 700),
            builder: (_, v, __) => LinearProgressIndicator(
              value: v,
              minHeight: 10,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation(level.color),
            ),
          ),
        ),
        const SizedBox(height: 6),
        // Performance risk text
        Text(
          _performanceRisk(score, showArabic),
          style: GoogleFonts.rajdhani(
              fontSize: 11, color: level.color.withOpacity(0.8), height: 1.4),
          textAlign: TextAlign.center,
        ),
      ]),
    );
  }

  String _performanceRisk(double s, bool ar) {
    if (!ar) {
      if (s <= 20) return 'Normal performance • No safety impact';
      if (s <= 40) return 'Mild performance reduction • Minor safety consideration';
      if (s <= 60) return 'Moderate impairment • Increased error probability';
      if (s <= 80) return 'Significant impairment • High risk of error chains';
      return 'Critical performance degradation • Extreme accident risk';
    } else {
      if (s <= 20) return 'أداء طبيعي • لا تأثير على الأمان';
      if (s <= 40) return 'انخفاض طفيف في الأداء • اعتبار أمان بسيط';
      if (s <= 60) return 'ضعف متوسط • احتمالية خطأ متزايدة';
      if (s <= 80) return 'ضعف ملحوظ • خطر مرتفع من سلاسل الأخطاء';
      return 'تدهور أداء حرج • خطر حادث مرتفع جداً';
    }
  }
}

// ── Fatigue Sub Card ──────────────────────────────────────────
class _FatigueSubCard extends StatelessWidget {
  final String icon;
  final String title;
  final String arabicTitle;
  final String subtitle;
  final String arabicSubtitle;
  final String key_;
  final double severity;
  final bool isActive;
  final bool isEnabled;
  final String? contextText;
  final bool showArabic;
  final VoidCallback onToggle;
  final ValueChanged<double> onSeverityChanged;

  const _FatigueSubCard({
    required this.icon,
    required this.title,
    required this.arabicTitle,
    required this.subtitle,
    required this.arabicSubtitle,
    required this.key_,
    required this.severity,
    required this.isActive,
    required this.isEnabled,
    this.contextText,
    required this.showArabic,
    required this.onToggle,
    required this.onSeverityChanged,
  });

  @override
  Widget build(BuildContext context) {
    final level = SeverityLevel.fromValue(severity);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: isActive
            ? level.color.withOpacity(0.04)
            : AppColors.elevated,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isActive ? level.color.withOpacity(0.3) : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: isEnabled ? onToggle : null,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(children: [
                Text(icon, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        showArabic ? arabicTitle : title,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isEnabled
                              ? AppColors.textPrimary
                              : AppColors.textTertiary,
                        ),
                      ),
                      Text(
                        showArabic ? arabicSubtitle : subtitle,
                        style: const TextStyle(
                            fontSize: 10, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                // Active toggle
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 44, height: 24,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: isActive
                        ? level.color.withOpacity(0.3)
                        : AppColors.border.withOpacity(0.5),
                    border: Border.all(
                        color: isActive ? level.color : AppColors.border),
                  ),
                  child: Row(
                    mainAxisAlignment: isActive
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(2),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 18, height: 18,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isActive ? level.color : AppColors.textTertiary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isActive) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: level.color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${severity.toInt()}%',
                      style: GoogleFonts.shareTechMono(
                          fontSize: 10, color: level.color,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ]),
            ),
          ),
          if (isActive) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: SeveritySlider(
                value: severity,
                onChanged: onSeverityChanged,
                showArabic: showArabic,
                contextText: contextText,
                enabled: isEnabled && isActive,
              ),
            ),
          ],
        ],
      ),
    );
  }
}