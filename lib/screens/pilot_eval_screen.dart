// lib/screens/pilot_eval_screen.dart
// ══════════════════════════════════════════════════════════════
// PilotEvalScreen v2 — dark/light mode + controller state
// ══════════════════════════════════════════════════════════════

import 'package:check_list_stress/screens/pilot_eval_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/pilot_eval_model.dart';

import '../theme/theme.dart';

// ─────────────────────────────────────────────────────────────
// Theme helper — mirrors Dashboard / Settings pattern
// ─────────────────────────────────────────────────────────────
class _T {
  final Color bg, surface, border, elevated, text1, text2, text3;
  const _T({
    required this.bg,
    required this.surface,
    required this.border,
    required this.elevated,
    required this.text1,
    required this.text2,
    required this.text3,
  });

  factory _T.of(BuildContext ctx) {
    final dark = Theme.of(ctx).brightness == Brightness.dark;
    return dark
        ? const _T(
      bg:       Color(0xFF07090F),
      surface:  Color(0xFF0E1219),
      border:   Color(0xFF1E2D45),
      elevated: Color(0xFF151E2D),
      text1:    Colors.white,
      text2:    Color(0xFF6B8CAE),
      text3:    Color(0xFF3A5260),
    )
        : const _T(
      bg:       Color(0xFFF0F4F8),
      surface:  Colors.white,
      border:   Color(0xFFD0DCE8),
      elevated: Color(0xFFE8EDF4),
      text1:    Color(0xFF0D1520),
      text2:    Color(0xFF3A5070),
      text3:    Color(0xFF6B8CAE),
    );
  }
}

// ═════════════════════════════════════════════════════════════
// Entry widget  — accepts controller so state survives pop
// ═════════════════════════════════════════════════════════════
class PilotEvalScreen extends StatelessWidget {
  final PilotEvalController controller;
  final bool showArabic;
  final VoidCallback? onComplete;

  const PilotEvalScreen({
    super.key,
    required this.controller,
    required this.showArabic,
    this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    // ListenableBuilder re-builds when controller notifies
    return ListenableBuilder(
      listenable: controller,
      builder: (ctx, _) => _PilotEvalView(
        controller: controller,
        showArabic: showArabic,
        onComplete: onComplete,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Internal stateless view — rebuilt by ListenableBuilder
// ─────────────────────────────────────────────────────────────
class _PilotEvalView extends StatelessWidget {
  final PilotEvalController controller;
  final bool showArabic;
  final VoidCallback? onComplete;

  const _PilotEvalView({
    required this.controller,
    required this.showArabic,
    this.onComplete,
  });

  String _t(String en, String ar) => showArabic ? ar : en;

  @override
  Widget build(BuildContext context) {
    final t = _T.of(context);
    return Directionality(
      textDirection:
      showArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: t.bg,
        appBar: _buildAppBar(context, t),
        body: Column(children: [
          _OverallProgressBar(
            rated: controller.totalRated,
            total: controller.totalCriteria,
            pct: controller.overallPct,
            showArabic: showArabic,
            t: t,
          ),
          Divider(height: 1, color: t.border),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 8),
              children: [
                for (final sec in controller.sections) ...[
                  _SectionCard(
                    section: sec,
                    controller: controller,
                    showArabic: showArabic,
                    t: t,
                  ).animate().fadeIn(duration: 300.ms),
                  const SizedBox(height: 10),
                ],
                _RatingReferenceTable(showArabic: showArabic, t: t),
                const SizedBox(height: 100),
              ],
            ),
          ),
          _BottomActionBar(
            rated: controller.totalRated,
            total: controller.totalCriteria,
            allRated: controller.allRated,
            overallPct: controller.overallPct,
            showArabic: showArabic,
            t: t,
            onReset: controller.resetAll,
            onComplete: onComplete,
          ),
        ]),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context, _T t) {
    return AppBar(
      backgroundColor: t.surface,
      elevation: 0,
      centerTitle: false,
      title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          showArabic ? 'تقييم الطيار' : 'PILOT EVALUATION',
          style: GoogleFonts.rajdhani(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.cyan),
        ),
        Text(
          showArabic
              ? 'المقاييس المهنية لجاهزية الطيار'
              : 'Professional pilot readiness assessment',
          style: TextStyle(fontSize: 12, color: t.text3,
          fontWeight: FontWeight.w600),
        ),
      ]),
      iconTheme: IconThemeData(color: t.text2),
      actions: [
        IconButton(
          icon: Icon(Icons.info_outline, size: 18, color: t.text3),
          onPressed: () => _showInfoDialog(context, t),
        ),
      ],
    );
  }

  void _showInfoDialog(BuildContext ctx, _T t) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        backgroundColor: t.surface,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
        title: Text(
          showArabic ? 'دليل التقييم' : 'Evaluation Guide',
          style: GoogleFonts.rajdhani(
              color: AppColors.cyan, fontWeight: FontWeight.w700),
        ),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          for (final r in EvalRating.values)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(children: [
                Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                        color: r.color,
                        borderRadius: BorderRadius.circular(3))),
                const SizedBox(width: 10),
                Text('${r.value}  –  ',
                    style: GoogleFonts.shareTechMono(
                        fontSize: 11, color: t.text2)),
                Text(showArabic ? r.labelAr : r.labelEn,
                    style:
                    TextStyle(fontSize: 12, color: t.text1)),
                Text('  (${(r.pct * 100).toInt()}%)',
                    style: GoogleFonts.shareTechMono(
                        fontSize: 10, color: t.text3)),
              ]),
            ),
        ]),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(showArabic ? 'إغلاق' : 'CLOSE',
                style:
                const TextStyle(color: AppColors.cyan)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Overall progress bar
// ─────────────────────────────────────────────────────────────
class _OverallProgressBar extends StatelessWidget {
  final int rated, total;
  final double pct;
  final bool showArabic;
  final _T t;
  const _OverallProgressBar(
      {required this.rated,
        required this.total,
        required this.pct,
        required this.showArabic,
        required this.t});

  @override
  Widget build(BuildContext context) {
    final pctInt = (pct * 100).toInt();
    final barColor = pctInt >= 80
        ? AppColors.green
        : pctInt >= 60
        ? AppColors.amber
        : AppColors.red;
    return Container(
      color: t.surface,
      padding:
      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Text(
                showArabic
                    ? '$rated / $total معيار مُقيَّم'
                    : '$rated / $total criteria rated',
                style:
                TextStyle(fontSize: 13, color: t.text2),
              ),
              const Spacer(),
              Text('$pctInt%',
                  style: GoogleFonts.shareTechMono(
                      fontSize: 13, color: barColor)),
            ]),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: pct,
                minHeight: 4,
                backgroundColor: t.elevated,
                valueColor: AlwaysStoppedAnimation(barColor),
              ),
            ),
          ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Section card (collapsible) — uses StatefulWidget for expand
// ─────────────────────────────────────────────────────────────
class _SectionCard extends StatefulWidget {
  final PilotEvalSection section;
  final PilotEvalController controller;
  final bool showArabic;
  final _T t;

  const _SectionCard({
    required this.section,
    required this.controller,
    required this.showArabic,
    required this.t,
  });

  @override
  State<_SectionCard> createState() => _SectionCardState();
}

class _SectionCardState extends State<_SectionCard> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final sec = widget.section;
    final t = widget.t;
    final pctInt = (sec.averagePct * 100).toInt();

    return Container(
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: sec.color.withOpacity(0.25)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        // header
        InkWell(
          borderRadius: const BorderRadius.vertical(
              top: Radius.circular(12)),
          onTap: () => setState(() => _expanded = !_expanded),
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 12),
            child: Row(children: [
              Container(
                width: 34, height: 34,
                decoration: BoxDecoration(
                  color: sec.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: sec.color.withOpacity(0.4)),
                ),
                alignment: Alignment.center,
                child: Text(sec.id,
                    style: GoogleFonts.shareTechMono(
                        fontSize: 16,
                        color: sec.color,
                        fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.showArabic
                            ? sec.titleAr
                            : sec.titleEn,
                        style: GoogleFonts.rajdhani(
                            fontSize: 14,
                            color: sec.color,
                            fontWeight: FontWeight.w700),
                      ),
                      Text(
                        widget.showArabic
                            ? sec.subtitleAr
                            : sec.subtitleEn,
                        style: TextStyle(
                            fontSize: 10, color: t.text3),
                      ),
                    ]),
              ),
              const SizedBox(width: 8),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(
                  sec.ratedCount == 0 ? '--' : '$pctInt%',
                  style: GoogleFonts.shareTechMono(
                      fontSize: 13,
                      color: sec.ratedCount == 0
                          ? t.text3
                          : sec.color,
                      fontWeight: FontWeight.bold),
                ),
                Text('${sec.ratedCount}/${sec.criteria.length}',
                    style:
                    TextStyle(fontSize: 11, color: t.text3)),
              ]),
              const SizedBox(width: 6),
              Icon(
                _expanded
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
                color: t.text3,
                size: 18,
              ),
            ]),
          ),
        ),

        // section progress bar
        if (sec.ratedCount > 0)
          Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: 14),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: sec.averagePct,
                minHeight: 3,
                backgroundColor: t.elevated,
                valueColor:
                AlwaysStoppedAnimation(sec.color),
              ),
            ),
          ),

        if (_expanded) ...[
          Divider(height: 1, color: t.border),
          for (int i = 0; i < sec.criteria.length; i++)
            _CriterionTile(
              criterion: sec.criteria[i],
              sectionId: sec.id,
              sectionColor: sec.color,
              showArabic: widget.showArabic,
              isLast: i == sec.criteria.length - 1,
              t: t,
              onRatingSelected: (crit, rating) =>
                  widget.controller.setRating(
                      sec.id, crit.id, rating),
            ),
        ],
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Criterion tile with expandable description
// ─────────────────────────────────────────────────────────────
class _CriterionTile extends StatefulWidget {
  final PilotEvalCriterion criterion;
  final String sectionId;
  final Color sectionColor;
  final bool showArabic;
  final bool isLast;
  final _T t;
  final void Function(PilotEvalCriterion, EvalRating)
  onRatingSelected;

  const _CriterionTile({
    required this.criterion,
    required this.sectionId,
    required this.sectionColor,
    required this.showArabic,
    required this.isLast,
    required this.t,
    required this.onRatingSelected,
  });

  @override
  State<_CriterionTile> createState() =>
      _CriterionTileState();
}

class _CriterionTileState extends State<_CriterionTile> {
  bool _showDesc = false;

  @override
  Widget build(BuildContext context) {
    final c = widget.criterion;
    final t = widget.t;
    final selected = c.rating;
    final pctInt =
    selected == null ? null : (selected.pct * 100).toInt();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: selected != null
            ? selected.color.withOpacity(0.04)
            : Colors.transparent,
        border: widget.isLast
            ? null
            : Border(
            bottom: BorderSide(
                color: t.border, width: 0.5)),
      ),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 10),
              child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // id badge
                    Container(
                      width: 28, height: 28,
                      margin: const EdgeInsets.only(top: 1),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        color: selected != null
                            ? selected.color.withOpacity(0.15)
                            : t.elevated,
                        border: Border.all(
                            color: selected != null
                                ? selected.color
                                : t.border),
                      ),
                      alignment: Alignment.center,
                      child: Text(c.id,
                          style: GoogleFonts.shareTechMono(
                              fontSize: 8,
                              color: selected != null
                                  ? selected.color
                                  : t.text3)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            // title + percent badge
                            Row(children: [
                              Expanded(
                                child: Text(
                                  widget.showArabic
                                      ? c.titleAr
                                      : c.titleEn,
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: selected != null
                                          ? t.text1
                                          : t.text2),
                                ),
                              ),
                              if (pctInt != null) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: selected!.color
                                        .withOpacity(0.15),
                                    borderRadius:
                                    BorderRadius.circular(4),
                                  ),
                                  child: Text('$pctInt%',
                                      style: GoogleFonts.shareTechMono(
                                          fontSize: 10,
                                          color: selected.color)),
                                ),
                              ],
                            ]),

                            // description toggle
                            GestureDetector(
                              onTap: () => setState(
                                      () => _showDesc = !_showDesc),
                              child: Row(children: [
                                Expanded(
                                  child: Text(
                                    widget.showArabic
                                        ? c.descAr
                                        : c.descEn,
                                    style: TextStyle(
                                        fontSize: 10,
                                        color: t.text3,
                                        height: 1.3),
                                    maxLines:
                                    _showDesc ? null : 1,
                                    overflow: _showDesc
                                        ? null
                                        : TextOverflow.ellipsis,
                                  ),
                                ),
                                Icon(
                                  _showDesc
                                      ? Icons.expand_less
                                      : Icons.expand_more,
                                  size: 14,
                                  color: t.text3,
                                ),
                              ]),
                            ),

                            const SizedBox(height: 10),

                            // ── Rating chips ──────────────────────
                            Wrap(
                              spacing: 5,
                              runSpacing: 5,
                              children: EvalRating.values.map((r) {
                                final isSel = c.rating == r;
                                return GestureDetector(
                                  onTap: () => widget
                                      .onRatingSelected(c, r),
                                  child: AnimatedContainer(
                                    duration: const Duration(
                                        milliseconds: 150),
                                    padding:
                                    const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 5),
                                    decoration: BoxDecoration(
                                      color: isSel
                                          ? r.color
                                          .withOpacity(0.18)
                                          : t.elevated,
                                      borderRadius:
                                      BorderRadius.circular(6),
                                      border: Border.all(
                                        color: isSel
                                            ? r.color
                                            : t.border,
                                        width:
                                        isSel ? 1.5 : 0.8,
                                      ),
                                    ),
                                    child: Row(
                                        mainAxisSize:
                                        MainAxisSize.min,
                                        children: [
                                          Container(
                                              width: 7,
                                              height: 7,
                                              decoration: BoxDecoration(
                                                  color: r.color,
                                                  shape:
                                                  BoxShape.circle)),
                                          const SizedBox(width: 5),
                                          Text(
                                            widget.showArabic
                                                ? r.labelAr
                                                : r.labelEn,
                                            style: GoogleFonts.inter(
                                                fontSize: 9,
                                                color: isSel
                                                    ? r.color
                                                    : t.text2,
                                                fontWeight: isSel
                                                    ? FontWeight.w600
                                                    : FontWeight.w400),
                                          ),
                                        ]),
                                  ),
                                );
                              }).toList(),
                            ),

                            // ── Selected level description ─────────
                            if (selected != null && _showDesc) ...[
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: selected.color
                                      .withOpacity(0.06),
                                  borderRadius:
                                  BorderRadius.circular(8),
                                  border: Border.all(
                                      color: selected.color
                                          .withOpacity(0.2)),
                                ),
                                child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Row(children: [
                                        Container(
                                            width: 8,
                                            height: 8,
                                            decoration: BoxDecoration(
                                                color: selected.color,
                                                shape:
                                                BoxShape.circle)),
                                        const SizedBox(width: 6),
                                        Text(
                                          widget.showArabic
                                              ? selected.labelAr
                                              : selected.labelEn,
                                          style: TextStyle(
                                              fontSize: 10,
                                              fontWeight:
                                              FontWeight.w600,
                                              color: selected.color),
                                        ),
                                        const Spacer(),
                                        Text(
                                          '${(selected.pct * 100).toInt()}%',
                                          style: GoogleFonts.shareTechMono(
                                              fontSize: 10,
                                              color: selected.color),
                                        ),
                                      ]),
                                      const SizedBox(height: 5),
                                      Text(
                                        widget.showArabic
                                            ? c.levels[selected.index]
                                            .ar
                                            : c.levels[selected.index]
                                            .en,
                                        style: TextStyle(
                                            fontSize: 11,
                                            color: t.text2,
                                            height: 1.4),
                                      ),
                                    ]),
                              ),
                            ],
                          ]),
                    ),
                  ]),
            ),
          ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Rating reference table
// ─────────────────────────────────────────────────────────────
class _RatingReferenceTable extends StatelessWidget {
  final bool showArabic;
  final _T t;
  const _RatingReferenceTable(
      {required this.showArabic, required this.t});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: t.border),
      ),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(color: t.border))),
              child: Text(
                showArabic
                    ? 'مرجع مستويات التقييم'
                    : 'RATING LEVELS REFERENCE',
                style: GoogleFonts.shareTechMono(
                    fontSize: 12,
                    letterSpacing: 1,
                    color: t.text3),
              ),
            ),
            for (final r in EvalRating.values)
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  border: r != EvalRating.veryGood
                      ? Border(
                      bottom: BorderSide(
                          color: t.border, width: 0.4))
                      : null,
                ),
                child: Row(children: [
                  Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                          color: r.color,
                          borderRadius:
                          BorderRadius.circular(3))),
                  const SizedBox(width: 8),
                  Text('${r.value}',
                      style: GoogleFonts.shareTechMono(
                          fontSize: 12,
                          color: r.color,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(width: 10),
                  Expanded(
                      child: Text(
                        showArabic ? r.labelAr : r.labelEn,
                        style: TextStyle(
                            fontSize: 12, color: t.text1),
                      )),
                  Text('${(r.pct * 100).toInt()}%',
                      style: GoogleFonts.shareTechMono(
                          fontSize: 11, color: t.text2)),
                ]),
              ),
          ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Bottom action bar
// ─────────────────────────────────────────────────────────────
class _BottomActionBar extends StatelessWidget {
  final int rated, total;
  final bool allRated, showArabic;
  final double overallPct;
  final _T t;
  final VoidCallback onReset;
  final VoidCallback? onComplete;

  const _BottomActionBar({
    required this.rated,
    required this.total,
    required this.allRated,
    required this.showArabic,
    required this.overallPct,
    required this.t,
    required this.onReset,
    this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final pctInt = (overallPct * 100).toInt();
    final accentColor = pctInt >= 80
        ? AppColors.green
        : pctInt >= 60
        ? AppColors.amber
        : AppColors.red;

    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 10, 16, 10 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: t.surface,
        border: Border(top: BorderSide(color: t.border)),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Row(children: [
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    showArabic
                        ? '$rated / $total مُقيَّم'
                        : '$rated / $total rated',
                    style: TextStyle(
                        fontSize: 10, color: t.text3),
                  ),
                  Text(
                    allRated
                        ? (showArabic
                        ? 'اكتمل التقييم ✓'
                        : 'ALL RATED ✓')
                        : (showArabic
                        ? 'جارٍ التقييم...'
                        : 'IN PROGRESS...'),
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: allRated
                            ? AppColors.green
                            : t.text2),
                  ),
                ]),
          ),
          if (rated > 0) ...[
            Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    showArabic ? 'المتوسط' : 'AVG',
                    style: TextStyle(
                        fontSize: 9, color: t.text3),
                  ),
                  Text('$pctInt%',
                      style: GoogleFonts.shareTechMono(
                          fontSize: 20,
                          color: accentColor,
                          fontWeight: FontWeight.bold)),
                ]),
          ],
        ]),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(
            child: SizedBox(
              height: 44,
              child: OutlinedButton.icon(
                onPressed: onReset,
                icon: const Icon(Icons.refresh, size: 14),
                label: Text(
                  showArabic ? 'إعادة' : 'RESET',
                  style: GoogleFonts.shareTechMono(
                      fontSize: 10, letterSpacing: 1.5),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: t.text2,
                  side: BorderSide(color: t.border),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: SizedBox(
              height: 44,
              child: ElevatedButton.icon(
                onPressed: onComplete,
                icon: const Icon(Icons.arrow_forward, size: 14),
                label: Text(
                  showArabic
                      ? 'التالي: قرار الطيران ▶'
                      : 'NEXT: DECIDE ▶',
                  style: GoogleFonts.shareTechMono(
                      fontSize: 10, letterSpacing: 1.5),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                  (allRated ? AppColors.green : AppColors.cyan)
                      .withOpacity(0.15),
                  foregroundColor: allRated
                      ? AppColors.green
                      : AppColors.cyan,
                  side: BorderSide(
                      color: allRated
                          ? AppColors.green
                          : AppColors.cyan),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ),
        ]),
      ]),
    );
  }
}