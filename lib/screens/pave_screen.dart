import 'package:check_list_stress/screens/pilot_eval_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/models.dart';
import '../theme/theme.dart';
import '../widgets/widgets.dart';

class PaveScreen extends StatefulWidget {
  final List<PaveItem> items;
  final bool showArabic;
  final Function(int itemIndex, int checkpointIndex) onCheckpointToggled;
  final VoidCallback? onComplete;
  final VoidCallback? onOpenPilotEval;
  final PilotEvalController? pilotEvalController;

  const PaveScreen({
    super.key,
    required this.items,
    required this.showArabic,
    required this.onCheckpointToggled,
    this.onComplete, this.onOpenPilotEval, this.pilotEvalController,
  });

  @override
  State<PaveScreen> createState() => _PaveScreenState();
}

class _PaveScreenState extends State<PaveScreen> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  static const List<Color> _colors = [
    AppColors.cyan, AppColors.green, AppColors.amber, AppColors.red,
  ];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: widget.items.length, vsync: this);
  }

  @override
  void dispose() { _tabCtrl.dispose(); super.dispose(); }

  List<PaveItem> get items => widget.items;

  int checkedCount(PaveItem item) => item.checkpoints.where((c) => c.checked).length;
  double completionPct(PaveItem item) => checkedCount(item) / item.checkpoints.length;
  bool isItemComplete(PaveItem item) => item.checkpoints.every((c) => c.checked);
  bool get allComplete => items.every(isItemComplete);

  num get totalChecked =>
      items.fold(0, (s, i) => s + checkedCount(i)) +
          (widget.pilotEvalController?.totalRated ?? 0);   // ← merged

  num get totalItems =>
      items.fold(0, (s, i) => s + i.checkpoints.length) +
          (widget.pilotEvalController?.totalCriteria ?? 0);


  @override
  Widget build(BuildContext context) {
    final isDark   = Theme.of(context).brightness == Brightness.dark;
    final bg       = isDark ? AppColors.bg      : const Color(0xFFF0F4F8);
    final surface  = isDark ? AppColors.surface : Colors.white;
    final borderC  = isDark ? AppColors.border  : const Color(0xFFD0DCE8);
    final textSec  = isDark ? AppColors.textSecondary : const Color(0xFF3A5070);
    return Directionality(
      textDirection: widget.showArabic ? TextDirection.rtl : TextDirection.ltr,

      child: Scaffold(
        backgroundColor: bg,
        appBar: AppBar(
          title: const Text('PAVE CHECKLIST'),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(52),
            child: Container(
              color: surface,
              child: TabBar(
                controller: _tabCtrl,
                isScrollable: false,
                indicatorColor: AppColors.cyan,
                indicatorWeight: 2,
                labelStyle: GoogleFonts.inter(fontSize: 9, letterSpacing: 1.5),
                unselectedLabelStyle: GoogleFonts.inter(fontSize: 9, letterSpacing: 1),
                labelColor: AppColors.cyan,
                unselectedLabelColor: AppColors.textTertiary,
                tabs: items.asMap().entries.map((e) {
                  final item  = e.value;
                  final color = _colors[e.key];
                  return Tab(
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Text(item.iconEmoji, style: const TextStyle(fontSize: 13)),
                      const SizedBox(width: 4),
                      Text(item.title),
                      if (isItemComplete(item)) ...[
                        const SizedBox(width: 3),
                        Icon(Icons.check_circle, size: 10, color: color),
                      ],
                    ]),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
        body: Column(
          children: [
            // ── Overall progress bar
            Container(
              color: surface,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Text('$totalChecked / $totalItems ${widget.showArabic ? "مكتمل" : "checked"}',
                      style: TextStyle(fontSize: 11, color: textSec)),
                  const Spacer(),
                  Text('${(totalChecked / totalItems * 100).toInt()}%',
                      style: const TextStyle(fontSize: 11, color: AppColors.green, fontFamily: 'ShareTechMono')),
                ]),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: totalItems == 0 ? 0 : totalChecked / totalItems,
                    minHeight: 4,
                    backgroundColor: AppColors.elevated,
                    valueColor: const AlwaysStoppedAnimation(AppColors.green),
                  ),
                ),
              ]),
            ),
             Divider(height: 1, color: borderC),

            // ── Tab views
            Expanded(
              child: TabBarView(
                controller: _tabCtrl,
                children: items.asMap().entries.map((e) {
                  return _PaveTabContent(
                    item: e.value,
                    itemIndex: e.key,
                    color: _colors[e.key],
                    showArabic: widget.showArabic,
                    onToggle: (cpIdx) {
                      setState(() {}); // refresh UI
                      widget.onCheckpointToggled(e.key, cpIdx);
                    },
                    onOpenEval: e.key == 0 ? widget.onOpenPilotEval : null,
                  ).animate().fadeIn(duration: 350.ms);
                }).toList(),
              ),
            ),

            // ── Bottom bar
            _BottomBar(
              totalChecked: totalChecked.toInt(),
              totalItems: totalItems.toInt(),
              allComplete: allComplete,
              showArabic: widget.showArabic,
              onComplete: widget.onComplete,
              onReset: () {
                setState(() {
                  for (int i = 0; i < items.length; i++) {
                    for (int j = 0; j < items[i].checkpoints.length; j++) {
                      if (items[i].checkpoints[j].checked) {
                        items[i].checkpoints[j].checked = false;
                        widget.onCheckpointToggled(i, j);
                        // toggle back
                        items[i].checkpoints[j].checked = false;
                      }
                    }
                  }
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _PaveTabContent extends StatelessWidget {
  final PaveItem item;
  final int itemIndex;
  final Color color;
  final bool showArabic;
  final ValueChanged<int> onToggle;
  final VoidCallback? onOpenEval;
  const _PaveTabContent({required this.item, required this.itemIndex, required this.color,
      required this.showArabic, required this.onToggle, this.onOpenEval});

  int get checked => item.checkpoints.where((c) => c.checked).length;
  double get pct   => checked / item.checkpoints.length;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: R.pad(context),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        // Header card
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: color.withOpacity(0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Row(children: [
            Text(item.iconEmoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text(item.key, style: GoogleFonts.shareTechMono(
                    fontSize: 10, color: color.withOpacity(0.6), letterSpacing: 2)),
                const SizedBox(width: 8),
                Flexible(child: Text(showArabic ? item.arabicTitle : item.title,
                    style: GoogleFonts.rajdhani(fontSize: 18, color: color, fontWeight: FontWeight.w700))),
              ]),
              const SizedBox(height: 3),
              Text(showArabic ? item.arabicDescription : item.description,
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, height: 1.3)),
              const SizedBox(height: 8),
              AProgressBar(value: pct, color: color,
                  label: '$checked / ${item.checkpoints.length} ${showArabic ? "مكتمل" : "completed"}'),
            ])),
          ]),
        ),
        const SizedBox(height: 14),

        // Checkpoints
        APanel(
          title: showArabic ? 'نقاط التحقق' : 'CHECKPOINTS',
          accent: color,
          padding: EdgeInsets.zero,
          child: Column(
            children: item.checkpoints.asMap().entries.map((e) {
              final idx = e.key;
              final cp  = e.value;
              final isLast = idx == item.checkpoints.length - 1;
              return _CheckpointTile(
                text: showArabic ? cp.arabicText : cp.text,
                checked: cp.checked,
                color: color,
                isLast: isLast,
                onTap: () => onToggle(idx),
              );
            }).toList(),
          ),
        ),
        if (itemIndex == 0 && onOpenEval != null) ...[
          const SizedBox(height: 12),
          _PilotEvalBanner(
            showArabic: showArabic,
            color: color,
            onTap: onOpenEval!,
          ),
        ],

        // const SizedBox(height: 40),
        const SizedBox(height: 40),
      ]),
    );
  }
}
class _PilotEvalBanner extends StatelessWidget {
  final bool showArabic;
  final Color color;
  final VoidCallback onTap;

  const _PilotEvalBanner({
    required this.showArabic,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text('📊', style: const TextStyle(fontSize: 18)),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              showArabic ? 'تقييم مستوى الطيار' : 'PILOT LEVEL ASSESSMENT',
              style: GoogleFonts.rajdhani(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            Text(
              showArabic
                  ? '17 معيار • 3 أقسام • القدرات والصفات والأداء'
                  : '17 criteria • 3 sections • Capabilities, Qualities & Performance',
              style: const TextStyle(fontSize: 10, color: AppColors.textTertiary),
            ),
          ])),
          Icon(Icons.arrow_forward_ios, size: 12, color: color.withOpacity(0.6)),
        ]),
      ),
    );
  }
}

class _CheckpointTile extends StatelessWidget {
  final String text;
  final bool checked;
  final Color color;
  final bool isLast;
  final VoidCallback onTap;
  const _CheckpointTile({required this.text, required this.checked, required this.color,
      required this.isLast, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          color: checked ? color.withOpacity(0.05) : Colors.transparent,
          border: isLast ? null : const Border(bottom: BorderSide(color: AppColors.border, width: 0.5)),
        ),
        child: Row(children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 22, height: 22,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: checked ? color.withOpacity(0.15) : AppColors.elevated,
              border: Border.all(color: checked ? color : AppColors.border),
            ),
            child: checked ? Icon(Icons.check, size: 13, color: color) : null,
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text,
              style: TextStyle(
                  fontSize: 12,
                  color: checked ? AppColors.textPrimary : AppColors.textSecondary,
                  fontWeight: checked ? FontWeight.w500 : FontWeight.w400))),
        ]),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final int totalChecked, totalItems;
  final bool allComplete, showArabic;
  final VoidCallback? onComplete, onReset;
  const _BottomBar({required this.totalChecked, required this.totalItems,
      required this.allComplete, required this.showArabic,
      this.onComplete, this.onReset});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 10, 16, 10 + MediaQuery.of(context).padding.bottom),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('$totalChecked / $totalItems ${showArabic ? "مكتمل" : "checked"}',
                style: const TextStyle(fontSize: 10, color: AppColors.textTertiary)),
            Text(allComplete
                ? (showArabic ? 'اكتمل الفحص ✓' : 'ALL COMPLETE ✓')
                : (showArabic ? 'جارٍ...' : 'IN PROGRESS...'),
                style: TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w600,
                    color: allComplete ? AppColors.green : AppColors.textSecondary)),
          ])),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: SizedBox(
            height: 44,
            child: OutlinedButton.icon(
              onPressed: onReset,
              icon: const Icon(Icons.refresh, size: 14),
              label: Text(showArabic ? 'إعادة' : 'RESET',
                  style: GoogleFonts.shareTechMono(fontSize: 10, letterSpacing: 1.5),
                  overflow: TextOverflow.ellipsis),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
                side: const BorderSide(color: AppColors.border),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          )),
          const SizedBox(width: 10),
          Expanded(flex: 2, child: SizedBox(
            height: 44,
            child: ElevatedButton.icon(
              onPressed: onComplete,
              icon: const Icon(Icons.arrow_forward, size: 14),
              label: Text(showArabic ? 'التالي: DECIDE ▶' : 'NEXT: DECIDE ▶',
                  style: GoogleFonts.shareTechMono(fontSize: 10, letterSpacing: 1.5),
                  overflow: TextOverflow.ellipsis, maxLines: 1),
              style: ElevatedButton.styleFrom(
                backgroundColor: (allComplete ? AppColors.green : AppColors.cyan).withOpacity(0.15),
                foregroundColor: allComplete ? AppColors.green : AppColors.cyan,
                side: BorderSide(color: allComplete ? AppColors.green : AppColors.cyan),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          )),
        ]),
      ]),
    );
  }
}
