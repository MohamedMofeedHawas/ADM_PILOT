
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/models.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';

// Assuming TimelineSlider and TimelineMarker are available in your project
// If not, you would need to create or import them.
class TimelineSlider extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final List<TimelineMarker> markers;
  final ValueChanged<double>? onChanged;

  const TimelineSlider({
    super.key,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.markers,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textPrimary)),
            Text('${value.toInt()}h',
                style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.cyan,
                    fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        Stack(
          alignment: Alignment.center,
          children: [
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: AppColors.cyan,
                inactiveTrackColor: AppColors.border,
                thumbColor: AppColors.cyan,
                overlayColor: AppColors.cyan.withOpacity(0.2),
                trackHeight: 4.0,
                thumbShape:
                    const RoundSliderThumbShape(enabledThumbRadius: 8.0),
              ),
              child: Slider(
                value: value,
                min: min,
                max: max,
                divisions: (max - min).toInt(),
                onChanged: onChanged,
              ),
            ),
            // Position markers
            ...markers.map((marker) {
              final left = ((marker.value - min) / (max - min)) *
                  (MediaQuery.of(context).size.width - 48); // Approximate width
              return Positioned(
                left: left,
                bottom: 0,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: marker.color.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    marker.label,
                    style: const TextStyle(
                        fontSize: 9,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ],
    );
  }
}

class TimelineMarker {
  final double value;
  final String label;
  final Color color;

  TimelineMarker(
      {required this.value, required this.label, required this.color});
}

class AlcoholCard extends StatefulWidget {
  final ImsafeItem item;
  final bool isExpanded;
  final bool showArabic;
  final VoidCallback onTap;
  final ValueChanged<String> onRatingChanged;
  final ValueChanged<String> onNotesChanged;
  final Function(int index, String rating, String notes) onItemChanged;
  final int index;

  const AlcoholCard({
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
  State<AlcoholCard> createState() => AlcoholCardState();
}

class AlcoholCardState extends State<AlcoholCard> {
  late bool _hadAlcohol;
  late double _hoursSinceLastDrink;
  late bool _feelsFullyRecovered;

  @override
  void initState() {
    super.initState();
    _hadAlcohol = widget.item.subItems['hadAlcohol'] ?? false;
    _hoursSinceLastDrink =
        (widget.item.subItems['hoursSinceLastDrink'] ?? 0.0).toDouble();
    _feelsFullyRecovered = widget.item.subItems['feelsFullyRecovered'] ?? false;
  }

  void _updateState(bool ar) {
    widget.item.subItems['hadAlcohol'] = _hadAlcohol;
    widget.item.subItems['hoursSinceLastDrink'] = _hoursSinceLastDrink;
    widget.item.subItems['feelsFullyRecovered'] = _feelsFullyRecovered;

    int score = 0;
    String rating;
    String recommendation;
    String reason = '';

    if (!_hadAlcohol) {
      rating = 'LOW';
      recommendation = ar ? '✅ مسموح' : '✅ GO';
      reason = ar ? 'لم يتم تناول الكحول' : 'No alcohol consumed';
    } else if (_hoursSinceLastDrink < 8) {
      rating = 'HIGH';
      recommendation = ar ? '❌ لا تطير' : '❌ NO-GO';
      reason = ar
          ? 'أقل من 8 ساعات (قاعدة الزجاجة للمقود)'
          : 'Under 8 hours (Bottle-to-throttle rule)';
      score = 100; // Max score for automatic NO-GO
    } else {
      // 8 hours or more
      if (!_feelsFullyRecovered) {
        rating = 'MEDIUM';
        recommendation = ar ? '⚠️ بحذر' : '⚠️ CAUTION';
        reason = ar
            ? 'لا يزال الطيار لا يشعر بالتعافي الكامل'
            : 'Pilot does not feel fully recovered';
        score = 60;
      } else {
        // Feels recovered
        if (_hoursSinceLastDrink >= 12) {
          rating = 'LOW';
          recommendation = ar ? '✅ مسموح' : '✅ GO';
          reason = ar
              ? 'تجاوز فترة كافية مع شعور بالتعافي'
              : 'Sufficient time passed with full recovery';
          score = 10;
        } else {
          // Between 8 and 12 hours, but feels recovered
          rating = 'LOW';
          recommendation = ar ? '⚠️ راقب الحالة' : '⚠️ Monitor condition';
          reason = ar
              ? '8-12 ساعة مع الشعور بالتعافي (تأثيرات متبقية محتملة)'
              : '8-12 hours with recovery (Residual effects possible)';
          score = 30;
        }
      }
    }

    widget.item.subItems['riskScore'] = score;
    widget.item.subItems['recommendation'] = recommendation;
    widget.item.subItems['reason'] = reason;

    widget.onRatingChanged(rating);
    widget.onItemChanged(widget.index, widget.item.rating, widget.item.notes);
  }

  @override
  Widget build(BuildContext context) {
    final color = AppColors.riskColor(widget.item.rating);
    final reason = widget.item.subItems['reason'] ?? '';
    final recommendation = widget.item.subItems['recommendation'] ?? '';
    final ar = widget.showArabic;

    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(9),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          IntrinsicHeight(
              child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                Container(width: 3, color: color),
                Expanded(
                  child: Material(
                    color: AppColors.surface,
                    child: InkWell(
                      onTap: widget.onTap,
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
                              child: Text(
                                '${widget.item.subItems['riskScore'] ?? 0}',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: color),
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
                                    ar
                                        ? widget.item.arabicTitle
                                        : widget.item.title,
                                    style: const TextStyle(
                                        fontSize: 13,
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.w600)),
                                Text(
                                    ar
                                        ? widget.item.arabicSubtitle
                                        : widget.item.subtitle,
                                    style: const TextStyle(
                                        fontSize: 10,
                                        color: AppColors.textSecondary)),
                              ])),
                          RiskBadge(widget.item.rating),
                          const SizedBox(width: 6),
                          Icon(
                              widget.isExpanded
                                  ? Icons.expand_less
                                  : Icons.expand_more,
                              size: 16,
                              color: AppColors.textTertiary),
                        ]),
                      ),
                    ),
                  ),
                )
              ])),
          if (widget.isExpanded) ...[
            const Divider(height: 1, color: AppColors.border),
            Container(
              color: AppColors.surface,
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                            child: Text(
                                ar
                                    ? 'هل تناولت الكحول خلال 24 ساعة الأخيرة؟'
                                    : 'Did you consume alcohol in the last 24 hours?',
                                style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textPrimary))),
                        Switch(
                            value: _hadAlcohol,
                            onChanged: (v) {
                              setState(() {
                                _hadAlcohol = v;
                                if (!_hadAlcohol) {
                                  _hoursSinceLastDrink = 0;
                                  _feelsFullyRecovered = false;
                                  widget.item.subItems['additionalNotes'] = '';
                                }
                                _updateState(ar);
                              });
                            },
                            activeColor: AppColors.red),
                      ]),
                  if (_hadAlcohol) ...[
                    const SizedBox(height: 16),
                    TimelineSlider(
                      label:
                          ar ? 'ساعات منذ آخر مشروب' : 'Hours since last drink',
                      value: _hoursSinceLastDrink,
                      min: 0,
                      max: 24,
                      markers: [
                        TimelineMarker(
                            value: 8, label: '8h', color: AppColors.amber),
                        TimelineMarker(
                            value: 12, label: '12h', color: AppColors.green),
                      ],
                      onChanged: (v) {
                        setState(() {
                          _hoursSinceLastDrink = v;
                          // Reset recovery feeler if hours drop below 8
                          if (_hoursSinceLastDrink < 8) {
                            _feelsFullyRecovered = false;
                          }
                          _updateState(ar);
                        });
                      },
                    ),
                    const SizedBox(height: 14),
                    if (_hoursSinceLastDrink >= 8)
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                                child: Text(
                                    ar
                                        ? 'هل تشعر بالتعافي الكامل؟'
                                        : 'Do you feel fully recovered?',
                                    style: const TextStyle(
                                        fontSize: 13,
                                        color: AppColors.textPrimary))),
                            Switch(
                                value: _feelsFullyRecovered,
                                onChanged: (v) {
                                  setState(() {
                                    _feelsFullyRecovered = v;
                                    _updateState(ar);
                                  });
                                },
                                activeColor: AppColors.green),
                          ]),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: (_hoursSinceLastDrink < 8)
                            ? AppColors.red.withOpacity(0.1)
                            : AppColors.amber.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: (_hoursSinceLastDrink < 8)
                                ? AppColors.red.withOpacity(0.3)
                                : AppColors.amber.withOpacity(0.3)),
                      ),
                      child: Row(children: [
                        Icon(
                          _hoursSinceLastDrink < 8
                              ? Icons.block
                              : Icons.warning_amber,
                          size: 18,
                          color: _hoursSinceLastDrink < 8
                              ? AppColors.red
                              : AppColors.amber,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            recommendation,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _hoursSinceLastDrink < 8
                                  ? AppColors.red
                                  : AppColors.amber,
                            ),
                          ),
                        ),
                      ]),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceAlt,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        ar
                            ? '📋 قاعدة FAA: 8 ساعات من "بطانة" إلى رحلة. الحد القانوني للكحول في الدم: 0.04%. إذا كنت في شك، عامل المخاطرة على أنها عالية حتى تعود إلى أدائك الأساسي.'
                            : '📋 FAA Rule: 8 hours "bottle to throttle". Legal BAC limit: 0.04%. If in doubt, treat the risk as high until you are back to baseline performance.',
                        style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textTertiary,
                            height: 1.4),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(ar ? 'ملاحظات إضافية:' : 'Additional Notes:',
                        style: GoogleFonts.shareTechMono(
                            fontSize: 10,
                            color: AppColors.textTertiary,
                            letterSpacing: 1.5)),
                    const SizedBox(height: 6),
                    TextFormField(
                      initialValue:
                          widget.item.subItems['additionalNotes'] ?? '',
                      onChanged: (val) {
                        setState(() {
                          widget.item.subItems['additionalNotes'] = val;
                        });
                      },
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        hintText: ar
                            ? 'أضف أي تفاصيل ذات صلة...'
                            : 'Add any relevant details...',
                        hintStyle: TextStyle(
                            fontSize: 11,
                            color: AppColors.textTertiary.withOpacity(0.7)),
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
