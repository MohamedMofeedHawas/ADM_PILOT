// lib/screens/imsafe/severity_widgets.dart
// ══════════════════════════════════════════════════════════════
// Shared Severity Slider + Label system for all IMSAFE cards
// ══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/theme.dart';

// ── Severity Level Model ─────────────────────────────────────
class SeverityLevel {
  final String label;
  final String arabicLabel;
  final String emoji;
  final Color color;
  final double min;
  final double max;

  const SeverityLevel({
    required this.label,
    required this.arabicLabel,
    required this.emoji,
    required this.color,
    required this.min,
    required this.max,
  });

  static SeverityLevel fromValue(double v) {
    if (v <= 20)  return veryLow;
    if (v <= 40)  return low;
    if (v <= 60)  return moderate;
    if (v <= 80)  return high;
    return veryHigh;
  }

  static const veryLow = SeverityLevel(
    label: 'Very Low',  arabicLabel: 'منخفض جداً',
    emoji: '🟢', color: Color(0xFF00E676),
    min: 0, max: 20,
  );
  static const low = SeverityLevel(
    label: 'Low',       arabicLabel: 'منخفض',
    emoji: '🟡', color: Color(0xFFCDDC39),
    min: 21, max: 40,
  );
  static const moderate = SeverityLevel(
    label: 'Moderate',  arabicLabel: 'متوسط',
    emoji: '🟠', color: Color(0xFFFFB020),
    min: 41, max: 60,
  );
  static const high = SeverityLevel(
    label: 'High',      arabicLabel: 'مرتفع',
    emoji: '🔴', color: Color(0xFFFF6B35),
    min: 61, max: 80,
  );
  static const veryHigh = SeverityLevel(
    label: 'Very High', arabicLabel: 'مرتفع جداً',
    emoji: '⛔', color: Color(0xFFFF3D57),
    min: 81, max: 100,
  );
}

// ── Severity Slider Widget ────────────────────────────────────
class SeveritySlider extends StatelessWidget {
  final double value;               // 0-100
  final ValueChanged<double> onChanged;
  final bool showArabic;
  final String? contextText;        // optional interpretation text
  final bool enabled;

  const SeveritySlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.showArabic = false,
    this.contextText,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final level = SeverityLevel.fromValue(value);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedOpacity(
      opacity: enabled ? 1.0 : 0.4,
      duration: const Duration(milliseconds: 200),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(children: [
            Text(
              showArabic ? 'شدة التأثير:' : 'Impact Severity:',
              style: GoogleFonts.shareTechMono(
                  fontSize: 9, color: AppColors.textTertiary, letterSpacing: 1),
            ),
            const Spacer(),
            // Severity badge
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: level.color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: level.color.withOpacity(0.5)),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text(level.emoji, style: const TextStyle(fontSize: 10)),
                const SizedBox(width: 4),
                Text(
                  showArabic ? level.arabicLabel : level.label,
                  style: GoogleFonts.shareTechMono(
                    fontSize: 9, color: level.color, fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '${value.toInt()}%',
                  style: GoogleFonts.shareTechMono(
                    fontSize: 10, color: level.color, fontWeight: FontWeight.w700,
                  ),
                ),
              ]),
            ),
          ]),
          const SizedBox(height: 6),

          // Custom gradient slider track
          SizedBox(
            height: 32,
            child: Stack(children: [
              // Gradient track background
              Positioned(
                left: 0, right: 0,
                top: 10, bottom: 10,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
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
                ),
              ),
              // Unfilled overlay
              Positioned(
                left: value / 100 * (MediaQuery.of(context).size.width - 80),
                right: 0, top: 10, bottom: 10,
                child: Container(
                  color: isDark
                      ? const Color(0xFF0E1219).withOpacity(0.85)
                      : Colors.white.withOpacity(0.85),
                ),
              ),
              // Slider
              Positioned.fill(
                child: SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 0,
                    thumbColor: level.color,
                    thumbShape: _GlowThumbShape(color: level.color),
                    overlayShape: SliderComponentShape.noOverlay,
                    activeTrackColor: Colors.transparent,
                    inactiveTrackColor: Colors.transparent,
                  ),
                  child: Slider(
                    value: value,
                    min: 0, max: 100,
                    onChanged: enabled ? onChanged : null,
                  ),
                ),
              ),
            ]),
          ),

          // Scale labels
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: ['0', '25', '50', '75', '100'].map((t) =>
                  Text(t, style: GoogleFonts.shareTechMono(
                      fontSize: 7, color: AppColors.textTertiary)),
              ).toList(),
            ),
          ),

          // Interpretation text
          if (contextText != null) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: level.color.withOpacity(0.06),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: level.color.withOpacity(0.2)),
              ),
              child: Row(children: [
                Container(
                  width: 3, height: 30,
                  decoration: BoxDecoration(
                    color: level.color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    contextText!,
                    style: GoogleFonts.rajdhani(
                      fontSize: 11, color: level.color, height: 1.4,
                    ),
                  ),
                ),
              ]),
            ),
          ],
        ],
      ),
    );
  }
}

// Custom glow thumb
class _GlowThumbShape extends SliderComponentShape {
  final Color color;
  const _GlowThumbShape({required this.color});

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) =>
      const Size(20, 20);

  @override
  void paint(PaintingContext context, Offset center,
      {Animation<double>? activationAnimation,
        Animation<double>? enableAnimation,
        bool? isDiscrete,
        TextPainter? labelPainter,
        RenderBox? parentBox,
        SliderThemeData? sliderTheme,
        TextDirection? textDirection,
        double? value,
        double? textScaleFactor,
        Size? sizeWithOverflow}) {
    final canvas = context.canvas;
    // Glow
    canvas.drawCircle(center, 12,
        Paint()..color = color.withOpacity(0.2)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));
    // Outer ring
    canvas.drawCircle(center, 8,
        Paint()..color = color.withOpacity(0.4)..style = PaintingStyle.stroke..strokeWidth = 1.5);
    // Inner fill
    canvas.drawCircle(center, 6, Paint()..color = color);
    // Center dot
    canvas.drawCircle(center, 2.5, Paint()..color = Colors.white);
  }
}

// ── Symptom Row with Severity Slider ─────────────────────────
class SymptomSeverityRow extends StatelessWidget {
  final String title;
  final String? arabicTitle;
  final String note;
  final bool isSelected;
  final bool isEnabled;
  final double severityValue;    // 0-100
  final String? contextHint;
  final bool showArabic;
  final VoidCallback onToggle;
  final ValueChanged<double> onSeverityChanged;

  const SymptomSeverityRow({
    super.key,
    required this.title,
    this.arabicTitle,
    this.note = '',
    required this.isSelected,
    required this.isEnabled,
    required this.severityValue,
    this.contextHint,
    required this.showArabic,
    required this.onToggle,
    required this.onSeverityChanged,
  });

  String _getContextText() {
    if (contextHint != null) return contextHint!;
    final level = SeverityLevel.fromValue(severityValue);
    if (showArabic) {
      switch (level.label) {
        case 'Very Low': return 'تأثير طفيف جداً على الأداء';
        case 'Low':      return 'تأثير بسيط على التركيز';
        case 'Moderate': return 'تأثير متوسط — مراقبة مستمرة مطلوبة';
        case 'High':     return 'تأثير مرتفع على الأداء وصنع القرار';
        default:         return 'خطر حرج — لا تطير ❌';
      }
    } else {
      switch (level.label) {
        case 'Very Low': return 'Minimal impact on performance';
        case 'Low':      return 'Slight impact on concentration';
        case 'Moderate': return 'Moderate impact — continuous monitoring required';
        case 'High':     return 'High impact on performance and decision-making';
        default:         return 'Critical hazard — DO NOT FLY ❌';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final level = SeverityLevel.fromValue(severityValue);

    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Checkbox row
          InkWell(
            onTap: isEnabled ? onToggle : null,
            borderRadius: BorderRadius.circular(6),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(children: [
                // Custom animated checkbox
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 20, height: 20,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: isSelected
                        ? level.color.withOpacity(0.2)
                        : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? level.color : AppColors.border,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: isSelected
                      ? Icon(Icons.check, size: 12, color: level.color)
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    showArabic && arabicTitle != null ? arabicTitle! : title,
                    style: TextStyle(
                      fontSize: 12,
                      color: isEnabled
                          ? AppColors.textPrimary
                          : AppColors.textTertiary.withOpacity(0.5),
                    ),
                  ),
                ),
                // Note
                if (note.isNotEmpty)
                  Text(note,
                      style: const TextStyle(
                          fontSize: 9, color: AppColors.textTertiary,
                          fontStyle: FontStyle.italic)),
                // Severity badge (when selected)
                if (isSelected) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: level.color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text(
                      '${severityValue.toInt()}%',
                      style: GoogleFonts.shareTechMono(
                          fontSize: 8, color: level.color,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ]),
            ),
          ),

          // Severity slider (only when selected)
          if (isSelected) ...[
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 30),
              child: SeveritySlider(
                value: severityValue,
                onChanged: onSeverityChanged,
                showArabic: showArabic,
                contextText: _getContextText(),
                enabled: isEnabled && isSelected,
              ),
            ),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

// ── Fitness Score Badge ───────────────────────────────────────
class FitnessScoreBadge extends StatelessWidget {
  final double score;    // 0-100 (risk score — higher = worse)
  final bool showArabic;

  const FitnessScoreBadge({
    super.key,
    required this.score,
    required this.showArabic,
  });

  String get _label {
    if (score <= 20) return showArabic ? 'آمن للطيران ✅' : 'FIT TO FLY ✅';
    if (score <= 40) return showArabic ? 'مراقبة ⚠️' : 'MONITOR ⚠️';
    if (score <= 60) return showArabic ? 'تحذير 🟠' : 'CAUTION 🟠';
    if (score <= 80) return showArabic ? 'خطر 🔴' : 'AT RISK 🔴';
    return showArabic ? 'لا تطير ⛔' : 'NOT FIT ⛔';
  }

  Color get _color {
    if (score <= 20) return const Color(0xFF00E676);
    if (score <= 40) return const Color(0xFFCDDC39);
    if (score <= 60) return const Color(0xFFFFB020);
    if (score <= 80) return const Color(0xFFFF6B35);
    return const Color(0xFFFF3D57);
  }

  @override
  Widget build(BuildContext context) => AnimatedContainer(
    duration: const Duration(milliseconds: 400),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    decoration: BoxDecoration(
      color: _color.withOpacity(0.12),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: _color.withOpacity(0.5), width: 1.5),
    ),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Text(
        '${score.toInt()}%',
        style: GoogleFonts.shareTechMono(
          fontSize: 22, color: _color, fontWeight: FontWeight.w700,
        ),
      ),
      Text(
        _label,
        style: GoogleFonts.shareTechMono(
          fontSize: 9, color: _color, letterSpacing: 1,
        ),
      ),
    ]),
  );
}

// ── Mini Category Score Row ───────────────────────────────────
class CategoryScoreRow extends StatelessWidget {
  final String emoji;
  final String label;
  final String arabicLabel;
  final double riskScore;    // 0-100
  final bool showArabic;

  const CategoryScoreRow({
    super.key,
    required this.emoji,
    required this.label,
    required this.arabicLabel,
    required this.riskScore,
    required this.showArabic,
  });

  @override
  Widget build(BuildContext context) {
    final level = SeverityLevel.fromValue(riskScore);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        Text(emoji, style: const TextStyle(fontSize: 14)),
        const SizedBox(width: 8),
        SizedBox(
          width: 80,
          child: Text(
            showArabic ? arabicLabel : label,
            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: riskScore / 100),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutCubic,
              builder: (_, v, __) => LinearProgressIndicator(
                value: v,
                minHeight: 7,
                backgroundColor: AppColors.border,
                valueColor: AlwaysStoppedAnimation(level.color),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 36,
          child: Text(
            '${riskScore.toInt()}%',
            style: GoogleFonts.shareTechMono(
              fontSize: 9, color: level.color, fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.right,
          ),
        ),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
          decoration: BoxDecoration(
            color: level.color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: level.color.withOpacity(0.35)),
          ),
          child: Text(
            '${level.emoji} ${showArabic ? level.arabicLabel : level.label}',
            style: GoogleFonts.shareTechMono(
              fontSize: 7, color: level.color, fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ]),
    );
  }
}