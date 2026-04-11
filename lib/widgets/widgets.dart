import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/theme.dart';

// ─── PANEL ─────────────────────────────────────────────────────────────────────
class APanel extends StatelessWidget {
  final String title;
  final Widget child;
  final Color? accent;
  final Widget? trailing;
  final EdgeInsets? padding;

  const APanel({super.key, required this.title, required this.child,
    this.accent, this.trailing, this.padding});

  @override
  Widget build(BuildContext context) {
    final accentColor = accent ?? AppColors.cyan;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(11),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(height: 2, color: accentColor),
            Container(
              color: AppColors.surface,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(children: [
                Expanded(child: Text(title,
                    style: GoogleFonts.shareTechMono(
                        fontSize: 10, color: AppColors.textSecondary, letterSpacing: 2))),
                if (trailing != null) trailing!,
              ]),
            ),
            Container(height: 1, color: AppColors.border),
            Container(
              color: AppColors.surface,
              padding: padding ?? const EdgeInsets.all(16),
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── RISK BADGE ────────────────────────────────────────────────────────────────
class RiskBadge extends StatelessWidget {
  final String level;
  final double fontSize;
  const RiskBadge(this.level, {super.key, this.fontSize = 10});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.riskColor(level);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.riskDim(level),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(level,
        style: GoogleFonts.shareTechMono(
          fontSize: fontSize, color: color, letterSpacing: 1.5, fontWeight: FontWeight.w600)),
    );
  }
}

// ─── RISK SELECTOR ─────────────────────────────────────────────────────────────
class RiskSelector extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;
  const RiskSelector({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: ['LOW', 'MEDIUM', 'HIGH'].map((lvl) {
        final selected = value == lvl;
        final color = AppColors.riskColor(lvl);
        return GestureDetector(
          onTap: () => onChanged(lvl),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(right: 6),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: selected ? color.withOpacity(0.15) : AppColors.elevated,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: selected ? color : AppColors.border),
            ),
            child: Text(lvl,
              style: GoogleFonts.shareTechMono(
                fontSize: 10,
                color: selected ? color : AppColors.textTertiary,
                letterSpacing: 1.5,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
              )),
          ),
        );
      }).toList(),
    );
  }
}

// ─── STEP CIRCLE ───────────────────────────────────────────────────────────────
class StepCircle extends StatelessWidget {
  final String label;
  final Color color;
  final bool active;
  final bool completed;
  const StepCircle({super.key, required this.label, required this.color,
    this.active = false, this.completed = false});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 40, height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: completed ? color.withOpacity(0.2) : active ? color.withOpacity(0.1) : AppColors.elevated,
        border: Border.all(
          color: completed || active ? color : AppColors.border,
          width: active ? 2 : 1,
        ),
        boxShadow: active ? [BoxShadow(color: color.withOpacity(0.3), blurRadius: 8)] : [],
      ),
      child: Center(
        child: completed
          ? Icon(Icons.check, size: 16, color: color)
          : Text(label,
              style: GoogleFonts.shareTechMono(
                fontSize: 12, color: active || completed ? color : AppColors.textTertiary,
                fontWeight: FontWeight.w700)),
      ),
    );
  }
}

// ─── COCKPIT BUTTON ────────────────────────────────────────────────────────────
class CBtn extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color? color;
  final bool outlined;
  final IconData? icon;

  const CBtn({super.key, required this.label, this.onPressed,
    this.color, this.outlined = false, this.icon});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.cyan;
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: outlined ? Colors.transparent : c.withOpacity(0.15),
          foregroundColor: c,
          side: BorderSide(color: onPressed == null ? AppColors.border : c),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[Icon(icon, size: 16), const SizedBox(width: 6)],
            Text(label, style: GoogleFonts.shareTechMono(
              fontSize: 12, letterSpacing: 2,
              color: onPressed == null ? AppColors.textTertiary : c)),
          ],
        ),
      ),
    );
  }
}

// ─── SECTION HEADER ────────────────────────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final String emoji;
  final Color color;
  const SectionHeader({super.key, required this.title, required this.subtitle,
    required this.emoji, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [color.withOpacity(0.12), color.withOpacity(0.04)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 32)),
          const SizedBox(width: 16),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.shareTechMono(
                fontSize: 18, color: color, letterSpacing: 2, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(subtitle, style: GoogleFonts.rajdhani(
                fontSize: 13, color: AppColors.textSecondary, height: 1.4)),
            ],
          )),
        ],
      ),
    );
  }
}

// ─── PROGRESS BAR ──────────────────────────────────────────────────────────────
class AProgressBar extends StatelessWidget {
  final double value;
  final Color color;
  final String label;
  const AProgressBar({super.key, required this.value, required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          Text('${(value * 100).toInt()}%', style: TextStyle(
            fontSize: 11, color: color, fontFamily: 'ShareTechMono')),
        ]),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: value, minHeight: 4,
            backgroundColor: AppColors.elevated,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }
}

// ─── GRID HELPER ──────────────────────────────────────────────────────────────
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final int mobileCols;
  final int tabletCols;
  final int desktopCols;
  final double spacing;

  const ResponsiveGrid({super.key, required this.children,
    this.mobileCols = 1, this.tabletCols = 2, this.desktopCols = 3, this.spacing = 12});

  @override
  Widget build(BuildContext context) {
    final cols = R.cols(context, m: mobileCols, t: tabletCols, d: desktopCols);
    return LayoutBuilder(builder: (context, constraints) {
      final itemW = (constraints.maxWidth - spacing * (cols - 1)) / cols;
      return Wrap(spacing: spacing, runSpacing: spacing,
        children: children.map((c) => SizedBox(width: itemW, child: c)).toList());
    });
  }
}
