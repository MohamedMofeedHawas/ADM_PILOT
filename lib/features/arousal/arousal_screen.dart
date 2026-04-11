import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/storage/assessment_provider.dart';

// ── Palette ───────────────────────────────────────────────────
const _kGo      = Color(0xFF00C853);   // optimal
const _kCaution = Color(0xFFFFAA00);   // boundary / caution
const _kNoGo    = Color(0xFFFF1744);   // high arousal
const _kCyan    = Color(0xFF00BCD4);   // low arousal
const _kBg      = Color(0xFF0A0E14);
const _kSurface = Color(0xFF0D1520);
const _kBorder  = Color(0xFF1A3A2A);
const _kText1   = Color(0xFFE0E0E0);
const _kText2   = Color(0xFF558866);
const _kPurple  = Color(0xFF9C27B0);
const _kAmber   = Color(0xFFFFB300);

// ── Zone thresholds (0–10 scale) ──────────────────────────────
// Based on Yerkes & Dodson (1908) and Hancock & Warm (1989):
//   Low    : 0.0 – 3.0   (0 – 30 %)
//   Optimal : 3.0 – 7.0  (30 – 70 %)
//   High   : 7.0 – 10.0  (70 – 100 %)
const _kLowMax  = 3.0;
const _kOptMax  = 7.0;

class ArousalScreen extends StatefulWidget {
  final bool showArabic;
  const ArousalScreen({super.key, this.showArabic = false});
  @override
  State<ArousalScreen> createState() => _ArousalScreenState();
}

class _ArousalScreenState extends State<ArousalScreen> {
  double _arousal = 5.0;

  @override
  Widget build(BuildContext context) {
    final ar = widget.showArabic;
    final p  = context.watch<AssessmentProvider>();

    if (p.records.isNotEmpty && _arousal == 5.0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() => _arousal = p.records.first.arousalLevel);
      });
    }

    final zone      = _zone(_arousal);
    final zoneColor = zone == 'optimal' ? _kGo
        : zone == 'low'                 ? _kCyan
        :                                 _kNoGo;
    final zoneLabel = _zoneLabel(zone, ar);

    final langBtn = TextButton(
      onPressed: () => Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => ArousalScreen(showArabic: !ar)),
      ),
      child: Text(
        ar ? 'EN' : 'AR',
        style: GoogleFonts.shareTechMono(fontSize: 13, color: _kCyan),
      ),
    );

    return Directionality(
      textDirection: ar ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: _kBg,
        appBar: AppBar(
          backgroundColor: _kSurface,
          title: Text(
            ar ? 'منحنى الاستثارة' : 'AROUSAL CURVE',
            style: GoogleFonts.shareTechMono(
                fontSize: 18, color: _kPurple, letterSpacing: 2),
          ),
          actions: [
            // Zone badge
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 4),
                  decoration: BoxDecoration(
                    color: zoneColor.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: zoneColor.withValues(alpha: .4)),
                  ),
                  child: Text(
                    zoneLabel.toUpperCase(),
                    style: GoogleFonts.shareTechMono(
                        fontSize: 13, color: zoneColor, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
            langBtn,
            const SizedBox(width: 6),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              // ── Theory card ──────────────────────────────────
              _TheoryCard(ar: ar),
              const SizedBox(height: 16),

              // ── Yerkes-Dodson curve ──────────────────────────
              _SectionLabel(
                ar ? 'منحنى يركس-دودسون للأداء' : 'YERKES-DODSON PERFORMANCE CURVE',
                _kPurple,
              ),
              const SizedBox(height: 4),
              _ZoneLegend(ar: ar),
              const SizedBox(height: 8),
              _YerkesDodsonChart(arousal: _arousal),
              const SizedBox(height: 16),

              // ── Slider ───────────────────────────────────────
              _SectionLabel(
                ar ? 'ضبط مستوى الاستثارة الحالي' : 'SET CURRENT AROUSAL LEVEL',
                _kText2,
              ),
              const SizedBox(height: 8),
              _ArousalSlider(
                value: _arousal,
                ar: ar,
                onChanged: (v) => setState(() => _arousal = v),
              ),
              const SizedBox(height: 16),

              // ── Zone detail ──────────────────────────────────
              _ZoneInfoCard(zone: zone, arousal: _arousal, ar: ar),
              const SizedBox(height: 16),

              // ── Performance / Attention / Narrow Attention ───
              _SectionLabel(
                ar ? 'الأداء · الانتباه · الانتباه الضيق' : 'PERFORMANCE · ATTENTION · TUNNEL VISION',
                _kAmber,
              ),
              const SizedBox(height: 8),
              _AttentionCard(arousal: _arousal, ar: ar),
              const SizedBox(height: 16),

              // ── Historical trend ─────────────────────────────
              if (p.records.length >= 2) ...[
                _SectionLabel(
                  ar ? 'تاريخ مستوى الاستثارة' : 'AROUSAL HISTORY',
                  _kCyan,
                ),
                const SizedBox(height: 8),
                _ArousalTrendChart(records: p.getLast(10).reversed.toList()),
                const SizedBox(height: 16),
              ],

              // ── Symptoms guide ───────────────────────────────
              _SectionLabel(
                ar ? 'دليل أعراض الاستثارة' : 'AROUSAL SYMPTOMS GUIDE',
                _kText2,
              ),
              const SizedBox(height: 8),
              _SymptomsCard(ar: ar),
              const SizedBox(height: 16),

              // ── References ───────────────────────────────────
              _SectionLabel(
                ar ? 'المراجع العلمية' : 'SCIENTIFIC REFERENCES',
                _kText2,
              ),
              const SizedBox(height: 8),
              _ReferencesCard(ar: ar),
            ],
          ),
        ),
      ),
    );
  }

  String _zone(double a) {
    if (a < _kLowMax) return 'low';
    if (a <= _kOptMax) return 'optimal';
    return 'high';
  }

  String _zoneLabel(String zone, bool ar) {
    if (!ar) return zone;
    return zone == 'low' ? 'منخفض' : zone == 'optimal' ? 'مثالي' : 'مرتفع';
  }
}

// ══════════════════════════════════════════════════════════════
// Zone Legend
// ══════════════════════════════════════════════════════════════
class _ZoneLegend extends StatelessWidget {
  final bool ar;
  const _ZoneLegend({this.ar = false});

  @override
  Widget build(BuildContext context) {
    final items = ar
        ? [
      (label: 'منخفض  0 – 3  (0 – 30 %)', color: _kCyan),
      (label: 'مثالي  3 – 7  (30 – 70 %)', color: _kGo),
      (label: 'مرتفع  7 – 10  (70 – 100 %)', color: _kNoGo),
    ]
        : [
      (label: 'Low  0 – 3  (0 – 30 %)', color: _kCyan),
      (label: 'Optimal  3 – 7  (30 – 70 %)', color: _kGo),
      (label: 'High  7 – 10  (70 – 100 %)', color: _kNoGo),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: items.map((item) => Padding(
        padding: const EdgeInsets.only(right: 16),
        child: Row(children: [
          Container(
            width: 10, height: 10,
            decoration: BoxDecoration(
              color: item.color.withOpacity(0.25),
              shape: BoxShape.circle,
              border: Border.all(color: item.color, width: 1.5),
            ),
          ),
          const SizedBox(width: 5),
          Text(
            item.label,
            style: GoogleFonts.shareTechMono(
                fontSize: 13, color: item.color,
            fontWeight: FontWeight.w600),
          ),
        ]),
      )).toList(),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Yerkes-Dodson Curve Chart
// ══════════════════════════════════════════════════════════════
class _YerkesDodsonChart extends StatelessWidget {
  final double arousal;
  const _YerkesDodsonChart({required this.arousal});

  /// Inverted-U: performance = −(x − 5)² + 25, normalised 0–100.
  double _perf(double x) => (-(pow(x - 5, 2)) + 25) / 25 * 100;

  @override
  Widget build(BuildContext context) {
    final curveSpots = List.generate(101, (i) {
      final x = i / 10.0;
      return FlSpot(x, _perf(x).clamp(0, 100));
    });

    final pilotY = _perf(arousal).clamp(0.0, 100.0);

    return Container(
      height: 265,
      padding: const EdgeInsets.fromLTRB(8, 12, 16, 8),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _kBorder),
      ),
      child: LineChart(
        LineChartData(
          minX: 0, maxX: 10,
          minY: 0, maxY: 100,
          clipData: const FlClipData.all(),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 25,
            getDrawingHorizontalLine: (_) =>
                const FlLine(color: _kBorder, strokeWidth: 0.5),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(
              showTitles: true, reservedSize: 40, interval: 25,
              getTitlesWidget: (v, _) => Text(
                '${v.toInt()}%',
                style: GoogleFonts.shareTechMono(fontSize: 11, color: _kText2),
              ),
            )),
            bottomTitles: AxisTitles(sideTitles: SideTitles(
              showTitles: true, reservedSize: 22, interval: 1,
              getTitlesWidget: (v, _) {
                if (v != v.roundToDouble()) return const SizedBox();
                return Text(
                  '${v.toInt()}',
                  style: GoogleFonts.shareTechMono(fontSize: 11, color: _kText2),
                );
              },
            )),
            topTitles:   const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          extraLinesData: ExtraLinesData(
            verticalLines: [
              // Low / Optimal boundary
              VerticalLine(
                x: _kLowMax,
                color: _kCaution.withOpacity(0.45),
                strokeWidth: 1.2,
                dashArray: [5, 4],
                label: VerticalLineLabel(
                  show: true,
                  alignment: Alignment.topRight,
                  labelResolver: (_) => '30%',
                  style: GoogleFonts.shareTechMono(
                      fontSize: 9, color: _kCaution),
                ),
              ),
              // Optimal / High boundary
              VerticalLine(
                x: _kOptMax,
                color: _kCaution.withOpacity(0.45),
                strokeWidth: 1.2,
                dashArray: [5, 4],
                label: VerticalLineLabel(
                  show: true,
                  alignment: Alignment.topRight,
                  labelResolver: (_) => '70%',
                  style: GoogleFonts.shareTechMono(
                      fontSize: 9, color: _kCaution),
                ),
              ),
              // Pilot marker
              VerticalLine(
                x: arousal,
                color: _kPurple.withOpacity(0.85),
                strokeWidth: 2,
              ),
            ],
          ),
          lineBarsData: [
            // Curve line
            LineChartBarData(
              spots: curveSpots,
              isCurved: true,
              color: _kCyan,
              barWidth: 2.5,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [_kCyan.withOpacity(0.10), Colors.transparent],
                ),
              ),
            ),
            // Pilot dot
            LineChartBarData(
              spots: [FlSpot(arousal, pilotY)],
              isCurved: false,
              color: Colors.transparent,
              dotData: FlDotData(
                show: true,
                getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                  radius: 6,
                  color: _kPurple,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Arousal Slider
// ══════════════════════════════════════════════════════════════
class _ArousalSlider extends StatelessWidget {
  final double value;
  final bool ar;
  final ValueChanged<double> onChanged;
  const _ArousalSlider(
      {required this.value, required this.onChanged, this.ar = false});

  @override
  Widget build(BuildContext context) {
    final color = value < _kLowMax
        ? _kCyan
        : value <= _kOptMax
        ? _kGo
        : _kNoGo;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _kBorder),
      ),
      child: Column(children: [
        Row(children: [
          Text(ar ? 'منخفض\n0–30%' : 'LOW\n0–30%',
              textAlign: TextAlign.center,
              style: GoogleFonts.shareTechMono(
                  fontSize: 12, color: _kCyan, fontWeight: FontWeight.w700)),
          const Spacer(),
          Text(ar ? 'مثالي\n30–70%' : 'OPTIMAL\n30–70%',
              textAlign: TextAlign.center,
              style: GoogleFonts.shareTechMono(
                  fontSize: 12, color: _kGo, fontWeight: FontWeight.w700)),
          const Spacer(),
          Text(ar ? 'مرتفع\n70–100%' : 'HIGH\n70–100%',
              textAlign: TextAlign.center,
              style: GoogleFonts.shareTechMono(
                  fontSize: 12, color: _kNoGo, fontWeight: FontWeight.w700)),
        ]),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: color,
            inactiveTrackColor: _kBorder,
            thumbColor: color,
            overlayColor: color.withOpacity(0.2),
            trackHeight: 4,
          ),
          child: Slider(
            value: value, min: 0, max: 10,
            divisions: 20,
            onChanged: onChanged,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${value.toStringAsFixed(1)} / 10',
              style: GoogleFonts.shareTechMono(
                  fontSize: 18, color: color, fontWeight: FontWeight.w700),
            ),
            Text(
              '${(value * 10).toStringAsFixed(0)} %',
              style: GoogleFonts.shareTechMono(
                  fontSize: 13, color: color.withOpacity(0.7)),
            ),
          ],
        ),
      ]),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Zone Info Card  (with performance & attention narrative)
// ══════════════════════════════════════════════════════════════
class _ZoneInfoCard extends StatelessWidget {
  final String zone;
  final double arousal;
  final bool ar;
  const _ZoneInfoCard(
      {required this.zone, required this.arousal, this.ar = false});

  @override
  Widget build(BuildContext context) {
    final data = switch (zone) {
      'low' => (
      color: _kCyan,
      title: ar ? 'استثارة منخفضة  (0 – 3 / 0 – 30 %)' : 'LOW AROUSAL  (0 – 3 · 0 – 30 %)',
      body: ar
          ? 'الأداء دون المستوى الأمثل. الانتباه منتشر وغير مركّز، مما يُعرّض الطيار '
          'لإغفال إشارات دقيقة. تتسع دائرة الانتباه لتشمل مثيرات غير ذات صلة '
          '(Easterbrook، 1959)، فيما تتراجع اليقظة وتُفضي إلى الرضا الزائد.'
          : 'Performance is suboptimal. Attention is broad and unfocused — the pilot '
          'is susceptible to distraction by irrelevant stimuli. Per Easterbrook\'s '
          'Cue-Utilization Theory (1959), cue range is too wide, allowing '
          'task-irrelevant peripheral cues to enter awareness. Drowsiness, slow '
          'reactions, and attention lapses are typical.',
      action: ar
          ? 'زيادة اليقظة: النشاط البدني الخفيف، الراحة الوقائية، الكافيين إذا كان مناسباً.'
          : 'Increase alertness: light physical activity, preventive rest, or caffeine if operationally appropriate.',
      ),
      'optimal' => (
      color: _kGo,
      title: ar ? 'استثارة مثالية  (3 – 7 / 30 – 70 %)' : 'OPTIMAL AROUSAL  (3 – 7 · 30 – 70 %)',
      body: ar
          ? 'ذروة الأداء المعرفي والحسي-حركي. وفقاً لنظرية استخدام الإشارات '
          '(Easterbrook، 1959) يتضيّق نطاق الانتباه بشكل كافٍ لاستبعاد '
          'المثيرات غير ذات الصلة، مع الحفاظ على استيعاب جميع الإشارات المهمة. '
          'اتخاذ القرار حاد، والوعي الظرفي مرتفع.'
          : 'Peak cognitive and psychomotor performance. Per Easterbrook\'s '
          'Cue-Utilization Theory (1959), attentional range is narrowed '
          'sufficiently to exclude irrelevant cues while still encompassing '
          'all task-critical cues. Decision-making is sharp, situational '
          'awareness is high, and CRM is effective.',
      action: ar
          ? 'حافظ على الحالة الراهنة. راقب التغييرات خلال الرحلات الطويلة.'
          : 'Maintain current state. Monitor for degradation during long-haul flights.',
      ),
      _ => (
      color: _kNoGo,
      title: ar ? 'استثارة مرتفعة — إجهاد  (7 – 10 / 70 – 100 %)' : 'HIGH AROUSAL — STRESS  (7 – 10 · 70 – 100 %)',
      body: ar
          ? 'فرط الاستثارة يُدهور الأداء. يضيق نطاق الانتباه تجاوزاً للحد المثالي '
          '(Easterbrook، 1959)، فيتركّز على تهديد وحيد ويُغفل إشارات حيوية أخرى: '
          '"الرؤية النفقية". تتراجع الذاكرة العاملة، وتتعطل وظيفة الفصّ الأمامي، '
          'مما يُفضي إلى قرارات خاطئة وتجمّد ذهني (Staal، 2004).'
          : 'Over-arousal severely degrades performance. Attentional range narrows '
          'beyond the optimal point (Easterbrook, 1959) — the pilot fixates on '
          'one threat and misses other critical cues: "tunnel vision". Working '
          'memory capacity decreases, prefrontal function is impaired, and the '
          'error rate rises markedly (Staal, 2004). Physiological signs include '
          'tremor, dry mouth, and tachycardia.',
      action: ar
          ? 'طبّق إدارة الإجهاد: تنفس بطيء ومنتظم، فوّض المهام، أعطِ الأولوية للطيران.'
          : 'Apply CRM: controlled breathing (4–4–4), delegate tasks, verbalise priorities.',
      ),
    };

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: data.color.withOpacity(0.4)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(data.title,
            style: GoogleFonts.shareTechMono(
                fontSize: 13, color: data.color,
                letterSpacing: 1, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Text(data.body,
            style: const TextStyle(fontSize: 12.5, color: _kText1, height: 1.55)),
        const SizedBox(height: 8),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(Icons.arrow_right, color: data.color, size: 16),
          const SizedBox(width: 4),
          Expanded(
            child: Text(data.action,
                style: TextStyle(fontSize: 13, color: data.color, height: 1.4)),
          ),
        ]),
      ]),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Performance · Attention · Narrow Attention Card
// ══════════════════════════════════════════════════════════════
class _AttentionCard extends StatelessWidget {
  final double arousal;
  final bool ar;
  const _AttentionCard({required this.arousal, this.ar = false});

  @override
  Widget build(BuildContext context) {
    // Three dimensions always shown; current zone is highlighted
    final zone = arousal < _kLowMax
        ? 'low'
        : arousal <= _kOptMax
        ? 'optimal'
        : 'high';

    final rows = ar ? _rowsAr : _rowsEn;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _kAmber.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Table(
            columnWidths: const {
              0: FlexColumnWidth(1.4),
              1: FlexColumnWidth(2.0),
              2: FlexColumnWidth(2.0),
              3: FlexColumnWidth(2.0),
            },
            children: [
              TableRow(
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: _kBorder, width: 1),
                  ),
                ),
                children: [
                  _th(ar ? 'البُعد' : 'Dimension'),
                  _th(ar ? 'منخفض  (0–30 %)' : 'Low  (0–30 %)', color: _kCyan),
                  _th(ar ? 'مثالي  (30–70 %)' : 'Optimal  (30–70 %)', color: _kGo),
                  _th(ar ? 'مرتفع  (70–100 %)' : 'High  (70–100 %)', color: _kNoGo),
                ],
              ),
              ...rows.map((row) {
                final isActive = (zone == 'low'     && rows.contains(row)) ||
                    (zone == 'optimal' && rows.contains(row)) ||
                    (zone == 'high'    && rows.contains(row));
                return TableRow(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                          color: _kBorder.withValues(alpha: .5), width: 0.5),
                    ),
                  ),
                  children: [
                    _td(row[0], bold: true),
                    _tdZone(row[1], zone == 'low',     _kCyan),
                    _tdZone(row[2], zone == 'optimal', _kGo),
                    _tdZone(row[3], zone == 'high',    _kNoGo),
                  ],
                );
              }),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            ar
                ? '* نظرية استخدام الإشارات — Easterbrook (1959): مع زيادة الاستثارة '
                'يضيق نطاق الانتباه تدريجياً. المنطقة المثالية تستبعد المشتّتات '
                'مع الإبقاء على الإشارات الحيوية.'
                : '* Cue-Utilization Theory — Easterbrook (1959): as arousal rises, '
                'the range of cues utilised progressively narrows. The optimal '
                'zone excludes irrelevant distractors while retaining all '
                'task-critical cues.',
            style: const TextStyle(
                fontSize: 13, color: _kText2, height: 1.5,
                fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  Widget _th(String text, {Color color = _kText2}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
    child: Text(text,
        style: GoogleFonts.shareTechMono(
            fontSize: 10, color: color, fontWeight: FontWeight.w700)),
  );

  Widget _td(String text, {bool bold = false}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
    child: Text(text,
        style: TextStyle(
            fontSize: 11, color: _kText1,
            fontWeight: bold ? FontWeight.w700 : FontWeight.normal,
            height: 1.4)),
  );

  Widget _tdZone(String text, bool active, Color zoneColor) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
    child: Container(
      decoration: active
          ? BoxDecoration(
        color: zoneColor.withOpacity(0.10),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: zoneColor.withOpacity(0.35), width: 0.8),
      )
          : null,
      padding: active ? const EdgeInsets.all(3) : EdgeInsets.zero,
      child: Text(text,
          style: TextStyle(
              fontSize: 11,
              color: active ? zoneColor : _kText1.withOpacity(0.5),
              height: 1.4,
              fontWeight: active ? FontWeight.w600 : FontWeight.normal)),
    ),
  );

  // [dimension, low, optimal, high]
  static const _rowsEn = [
    [
      'Performance',
      'Suboptimal => ↓ accuracy ↓ reaction',
      'PEAK => ↑ accuracy ↑ speed',
      'Degraded => ↑ errors cognitive freeze',
    ],
    [
      'Attention width',
      'Too broad relevant cues missed in noise',
      'Selective focused on critical cues',
      'Too narrow tunnel vision cues excluded',
    ],
    [
      'Tunnel vision',
      'Absent (diffuse awareness)',
      'Moderate (healthy filter)',
      'SEVERE fixation on single threat',
    ],
    [
      'Working memory',
      'Under-loaded complacency lapses',
      'Optimal capacity',
      'Overloaded ↓ capacity decision errors',
    ],
    [
      'Situational awareness',
      'SA level 1–2 missed cues',
      'SA level 3 full picture',
      'SA breakdown tunnel SA',
    ],
  ];

  static const _rowsAr = [
    [
      'الأداء',
      'دون المثالي => ↓ دقة ↓ ردود فعل',
      'ذروة الأداء => ↑ دقة ↑ سرعة',
      'متدهور => ↑ أخطاء تجمّد ذهني',
    ],
    [
      'اتساع الانتباه',
      'واسع جداً إشارات مهمة تُفقد في الضجيج',
      'انتقائي مُركّز على الإشارات الحيوية',
      'ضيّق جداً رؤية نفقية إشارات تُهمَل',
    ],
    [
      'الرؤية النفقية',
      'غائبة (وعي منتشر)',
      'معتدلة (تصفية صحية)',
      'شديدة تركيز على تهديد واحد',
    ],
    [
      'الذاكرة العاملة',
      'محمّلة أقل غفلة',
      'سعة مثالية',
      'محمّلة زائداً قرارات خاطئة',
    ],
    [
      'الوعي الظرفي',
      'المستوى 1–2 إشارات مفقودة',
      'المستوى 3 صورة كاملة',
      'انهيار الوعي الظرفي النفقي',
    ],
  ];}

// ══════════════════════════════════════════════════════════════
// Arousal History Trend
// ══════════════════════════════════════════════════════════════
class _ArousalTrendChart extends StatelessWidget {
  final List records;
  const _ArousalTrendChart({required this.records});

  @override
  Widget build(BuildContext context) {
    final spots = records
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.arousalLevel as double))
        .toList();

    return Container(
      height: 150,
      padding: const EdgeInsets.fromLTRB(8, 12, 16, 8),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _kBorder),
      ),
      child: LineChart(LineChartData(
        minY: 0, maxY: 10,
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(
            showTitles: true, reservedSize: 28, interval: 5,
            getTitlesWidget: (v, _) => Text(
              '${v.toInt()}',
              style: GoogleFonts.shareTechMono(fontSize: 11, color: _kText2),
            ),
          )),
          bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:   const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        extraLinesData: ExtraLinesData(horizontalLines: [
          HorizontalLine(y: _kLowMax, color: _kCaution.withOpacity(0.35),
              strokeWidth: 1, dashArray: [4, 4]),
          HorizontalLine(y: _kOptMax, color: _kCaution.withOpacity(0.35),
              strokeWidth: 1, dashArray: [4, 4]),
        ]),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: _kPurple,
            barWidth: 2,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, _, __, ___) => FlDotCirclePainter(
                radius: 3,
                color: spot.y < _kLowMax
                    ? _kCyan
                    : spot.y <= _kOptMax
                    ? _kGo
                    : _kNoGo,
                strokeWidth: 0,
              ),
            ),
          ),
        ],
      )),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Symptoms Card
// ══════════════════════════════════════════════════════════════
class _SymptomsCard extends StatelessWidget {
  final bool ar;
  const _SymptomsCard({this.ar = false});

  @override
  Widget build(BuildContext context) {
    final symptoms = ar ? _symptomsAr : _symptomsEn;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        children: symptoms.map((s) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 58,
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
                decoration: BoxDecoration(
                  color: s.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: s.color.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Text(
                      s.zone,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.shareTechMono(
                        fontSize: 11,
                        color: s.color,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  s.text,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: _kText1,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        )).toList(),
      ),
    );
  }

  static const _symptomsEn = [
    (
    zone: 'LOW',
    color: _kCyan,
    text:
    'Drowsiness, slow reactions, missed radio calls, complacency, '
        'under-scanning instruments. Attention cue range is too broad — '
        'task-irrelevant stimuli compete for awareness.',
    ),
    (
    zone: 'OPTIMAL',
    color: _kGo,
    text:
    'Alert, decisive, good situational awareness. Calm under pressure, '
        'effective CRM. Attention is selectively focused on critical cues — '
        'the ideal attentional filter per Easterbrook (1959).',
    ),
    (
    zone: 'HIGH',
    color: _kCaution,
    text:
    'Tunnel vision — fixation on one problem. Trembling, dry mouth, '
        'rapid heart rate. Cognitive freeze, inability to prioritise. '
        'Peripheral cues are blocked: a critical EGPWS alert may be missed '
        'while fixating on an engine parameter.',
    ),
  ];

  static const _symptomsAr = [
    (
    zone: 'منخفض',
    color: _kCyan,
    text:
    'نعاس، بطء ردود الفعل، تفويت نداءات الراديو، رضا زائد، '
        'ضعف متابعة الأجهزة. دائرة الانتباه واسعة جداً — مثيرات غير '
        'مهمة تتنافس على الوعي.',
    ),
    (
    zone: 'مثالي',
    color: _kGo,
    text:
    'يقظ، حاسم، وعي ظرفي جيد. هادئ تحت الضغط، تعاون فعّال. '
        'الانتباه مُركّز انتقائياً على الإشارات الحيوية — '
        'مرشّح الانتباه المثالي (Easterbrook، 1959).',
    ),
    (
    zone: 'مرتفع',
    color: _kCaution,
    text:
    'رؤية نفقية — تركيز على مشكلة واحدة. ارتعاش، جفاف الفم، '
        'تسارع القلب. تجمّد ذهني وعدم القدرة على ترتيب الأولويات. '
        'تُحجب الإشارات الطرفية: قد يُغفَل تحذير EGPWS الحيوي '
        'أثناء التركيز على معامل المحرك.',
    ),
  ];
}
// ══════════════════════════════════════════════════════════════
// Theory Card
// ══════════════════════════════════════════════════════════════
class _TheoryCard extends StatelessWidget {
  final bool ar;
  const _TheoryCard({this.ar = false});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: _kPurple.withOpacity(0.06),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: _kPurple.withOpacity(0.3)),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
        ar ? 'قانون يركس-دودسون (1908)' : 'YERKES-DODSON LAW (1908)',
        style: GoogleFonts.shareTechMono(
            fontSize: 13, color: _kPurple,
            letterSpacing: 1, fontWeight: FontWeight.w700),
      ),
      const SizedBox(height: 6),
      Text(
        ar
            ? 'يرتفع الأداء مع زيادة الاستثارة حتى نقطة مثالية (30–70 %)، '
            'ثم يتراجع عند الإفراط (>70 %). في الطيران: الطيار خامل الاستثارة '
            'والطيار المجهد كلاهما يرتكب أخطاء أكثر ممن يكون في المنطقة '
            'المثالية. تُكمّل نظرية استخدام الإشارات (Easterbrook، 1959) '
            'هذا النموذج بتفسير آلية الانتباه.'
            : 'Performance increases with arousal up to an optimal point '
            '(30–70 %), then declines as arousal becomes excessive (>70 %). '
            'Applied to aviation: both the under-stimulated and the over-stressed '
            'pilot commit more errors than the pilot in the optimal zone. '
            'Easterbrook\'s Cue-Utilization Theory (1959) complements this '
            'model by explaining the attentional mechanism behind the curve.',
        style: const TextStyle(fontSize: 12.5, color: _kText1, height: 1.55),
      ),
    ]),
  );
}

// ══════════════════════════════════════════════════════════════
// Scientific References Card
// ══════════════════════════════════════════════════════════════
class _ReferencesCard extends StatelessWidget {
  final bool ar;
  const _ReferencesCard({this.ar = false});

  @override
  Widget build(BuildContext context) {
    const refs = [
      (
      num: '1',
      citation: 'Yerkes, R.M. & Dodson, J.D. (1908). The relation of strength '
          'of stimulus to rapidity of habit-formation. Journal of Comparative '
          'Neurology and Psychology, 18, 459–482.',
      note: 'Original source of the Yerkes-Dodson Law.',
      ),
      (
      num: '2',
      citation: 'Easterbrook, J.A. (1959). The effect of emotion on cue '
          'utilization and the organization of behavior. Psychological '
          'Review, 66(3), 183–201.',
      note: 'Foundation for tunnel vision / cue-utilization mechanism.',
      ),
      (
      num: '3',
      citation: 'Hancock, P.A. & Warm, J.S. (1989). A dynamic model of stress '
          'and sustained attention. Human Factors, 31(5), 519–537.',
      note: 'Defines zone thresholds in sustained operational performance.',
      ),
      (
      num: '4',
      citation: 'Staal, M.A. (2004). Stress, Cognition, and Human Performance: '
          'A Literature Review and Conceptual Framework. NASA Technical '
          'Memorandum 212824.',
      note: 'Comprehensive review of high-arousal cognitive degradation.',
      ),
      (
      num: '5',
      citation: 'FAA-H-8083-2 (2016). Aeronautical Decision Making. '
          'U.S. Federal Aviation Administration.',
      note: 'Aviation application of arousal and situational awareness.',
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        children: refs.map((r) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: 22, height: 22,
              decoration: BoxDecoration(
                color: _kPurple.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(r.num,
                  style: GoogleFonts.shareTechMono(
                      fontSize: 10, color: _kPurple, fontWeight: FontWeight.w700)),
            ),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(r.citation,
                  style: const TextStyle(
                      fontSize: 11.5, color: _kText1, height: 1.5)),
              const SizedBox(height: 2),
              Text(r.note,
                  style: const TextStyle(
                      fontSize: 10.5,
                      color: _kText2,
                      fontStyle: FontStyle.italic,
                      height: 1.4)),
            ])),
          ]),
        )).toList(),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Helpers
// ══════════════════════════════════════════════════════════════
class _SectionLabel extends StatelessWidget {
  final String text;
  final Color color;
  const _SectionLabel(this.text, this.color);

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: GoogleFonts.shareTechMono(
        fontSize: 12, color: color, letterSpacing: 1, fontWeight: FontWeight.w700),
  );
}