// lib/features/settings/settings_screen.dart
// ══════════════════════════════════════════════════════════════
// Settings — Dark/Light mode + language + app info
// ══════════════════════════════════════════════════════════════

import 'package:check_list_stress/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';


class SettingsScreen extends StatelessWidget {
  final bool showArabic;
  final ValueChanged<bool> onToggleLanguage;

  const SettingsScreen({
    super.key,
    required this.showArabic,
    required this.onToggleLanguage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final isDark = theme.isDark;
    final isAr   = showArabic;

    final bg      = isDark ? const Color(0xFF07090F) : const Color(0xFFF0F4F8);
    final surface = isDark ? const Color(0xFF0E1219) : Colors.white;
    final border  = isDark ? const Color(0xFF1E2D45) : const Color(0xFFD0DCE8);
    final text1   = isDark ? Colors.white            : const Color(0xFF0D1520);
    final text2   = isDark ? const Color(0xFFB0C8E0) : const Color(0xFF3A5070);
    const cyan    = Color(0xFF00C8F0);
    const green   = Color(0xFF00E676);
    const amber   = Color(0xFFFFB020);

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: bg,
        appBar: AppBar(
          backgroundColor: surface,
          elevation: 0,
          title: Text(
            isAr ? 'الإعدادات' : 'SETTINGS',
            style: GoogleFonts.shareTechMono(
              fontSize: 16, color: cyan,
              fontWeight: FontWeight.w700, letterSpacing: 3,
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(2),
            child: Container(height: 2, color: cyan.withOpacity(0.4)),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [

                // ── Theme Section ──────────────────────────────
                _SectionLabel(isAr ? 'المظهر' : 'APPEARANCE', text2),
                const SizedBox(height: 10),
                _SettingsCard(surface: surface, border: border, children: [
                  _ThemeTile(
                    isDark: isDark,
                    isAr: isAr,
                    text1: text1,
                    text2: text2,
                    onToggle: () => theme.toggle(),
                  ),
                ]),
                const SizedBox(height: 20),

                // ── Theme Preview ──────────────────────────────
                _ThemePreviewCards(isDark: isDark, isAr: isAr, surface: surface,
                    border: border, text1: text1, text2: text2, onSelect: (dark) => theme.setDark(dark)),
                const SizedBox(height: 24),

                // ── Language Section ───────────────────────────
                _SectionLabel(isAr ? 'اللغة' : 'LANGUAGE', text2),
                const SizedBox(height: 10),
                _SettingsCard(surface: surface, border: border, children: [
                  _LangTile(
                    isAr: isAr,
                    text1: text1,
                    text2: text2,
                    onToggle: () => onToggleLanguage(!isAr),
                  ),
                ]),
                const SizedBox(height: 24),

                // // ── Medical reference thresholds ───────────────
                // _SectionLabel(isAr ? 'نطاقات الكشف الطبي' : 'MEDICAL REFERENCE RANGES', text2),
                // const SizedBox(height: 10),
                // _MedReferenceCard(isAr: isAr, surface: surface, border: border,
                //     text1: text1, text2: text2),
                // const SizedBox(height: 24),

                // ── About ──────────────────────────────────────
                _SectionLabel(isAr ? 'عن التطبيق' : 'ABOUT', text2),
                const SizedBox(height: 10),
                _SettingsCard(surface: surface, border: border, children: [
                  _AboutTile(isAr: isAr, text1: text1, text2: text2, cyan: cyan),
                  Divider(color: border, height: 1),
                  _InfoRow(
                    icon: Icons.info_outline,
                    label: isAr ? 'الإصدار' : 'Version',
                    value: '2.1.0 — Medical Edition',
                    color: text2, text1: text1,
                  ),
                  Divider(color: border, height: 1),
                  _InfoRow(
                    icon: Icons.security_outlined,
                    label: isAr ? 'البيانات' : 'Data Storage',
                    value: isAr ? 'محلي فقط — لا يُرسل إلى الخارج' : 'Local only — never transmitted',
                    color: green, text1: text1,
                  ),
                  Divider(color: border, height: 1),
                  _InfoRow(
                    icon: Icons.gavel_outlined,
                    label: isAr ? 'المرجع' : 'Reference',
                    value: 'FAASTeam ADM Worksheet',
                    color: amber, text1: text1,
                  ),
                ]),
                const SizedBox(height: 24),

                // ── Disclaimer ─────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: amber.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: amber.withOpacity(0.25)),
                  ),
                  child: Text(
                    isAr
                        ? '⚠️ تحذير: هذا التطبيق أداة مساعدة للقرار ولا يُغني عن الفحص الطبي الرسمي من طبيب الطيران المعتمد. القرار النهائي دائماً للطيار.'
                        : '⚠️ Disclaimer: This app is a decision-support tool and does not replace official Aviation Medical Examiner certification. The final decision always rests with the pilot.',
                    style: GoogleFonts.rajdhani(
                      fontSize: 13, color: amber, height: 1.5,
                    ),
                  ),
                ),
              ]),
        ),
      ),
    );
  }
}

// ── Section label ──────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String text; final Color color;
  const _SectionLabel(this.text, this.color);
  @override
  Widget build(BuildContext context) => Text(text,
      style: GoogleFonts.shareTechMono(
          fontSize: 10, color: color, letterSpacing: 2));
}

// ── Settings card ──────────────────────────────────────────────
class _SettingsCard extends StatelessWidget {
  final Color surface, border;
  final List<Widget> children;
  const _SettingsCard({required this.surface, required this.border, required this.children});

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: surface,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: border),
    ),
    child: Column(children: children),
  );
}

// ── Theme toggle tile ──────────────────────────────────────────
class _ThemeTile extends StatelessWidget {
  final bool isDark, isAr;
  final Color text1, text2;
  final VoidCallback onToggle;
  const _ThemeTile({
    required this.isDark, required this.isAr,
    required this.text1, required this.text2, required this.onToggle,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(16),
    child: Row(children: [
      Icon(
        isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
        color: isDark ? const Color(0xFF00C8F0) : const Color(0xFFFFB020),
        size: 22,
      ),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          isAr ? (isDark ? 'الوضع الداكن' : 'الوضع الفاتح') : (isDark ? 'Dark Mode' : 'Light Mode'),
          style: GoogleFonts.rajdhani(
            fontSize: 16, color: text1, fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          isAr ? 'اضغط للتبديل بين المظهرين' : 'Tap to switch between themes',
          style: GoogleFonts.rajdhani(fontSize: 13, color: text2),
        ),
      ])),
      Switch(
        value: isDark,
        onChanged: (_) => onToggle(),
        activeColor: const Color(0xFF00C8F0),
        trackColor: MaterialStateProperty.resolveWith((states) =>
        states.contains(MaterialState.selected)
            ? const Color(0xFF00C8F0).withOpacity(0.3)
            : const Color(0xFF1E2D45)),
      ),
    ]),
  );
}

// ── Theme preview cards ────────────────────────────────────────
class _ThemePreviewCards extends StatelessWidget {
  final bool isDark, isAr;
  final Color surface, border, text1, text2;
  final ValueChanged<bool> onSelect;
  const _ThemePreviewCards({
    required this.isDark, required this.isAr, required this.surface,
    required this.border, required this.text1, required this.text2,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) => Row(children: [
    Expanded(child: _ThemeCard(
      label: isAr ? 'داكن' : 'DARK',
      icon: Icons.dark_mode_outlined,
      selected: isDark,
      bg: const Color(0xFF07090F),
      fg: Colors.white,
      accent: const Color(0xFF00C8F0),
      onTap: () => onSelect(true),
    )),
    const SizedBox(width: 12),
    Expanded(child: _ThemeCard(
      label: isAr ? 'فاتح' : 'LIGHT',
      icon: Icons.light_mode_outlined,
      selected: !isDark,
      bg: const Color(0xFFF0F4F8),
      fg: const Color(0xFF0D1520),
      accent: const Color(0xFF0090B0),
      onTap: () => onSelect(false),
    )),
  ]);
}

class _ThemeCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final Color bg, fg, accent;
  final VoidCallback onTap;
  const _ThemeCard({
    required this.label, required this.icon, required this.selected,
    required this.bg, required this.fg, required this.accent, required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      height: 90,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selected ? accent : const Color(0xFF1E2D45),
          width: selected ? 2 : 1,
        ),
        boxShadow: selected ? [BoxShadow(
          color: accent.withOpacity(0.2), blurRadius: 12,
        )] : [],
      ),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, color: accent, size: 26),
        const SizedBox(height: 6),
        Text(label, style: GoogleFonts.shareTechMono(
          fontSize: 11, color: fg, letterSpacing: 1.5,
        )),
        if (selected) ...[
          const SizedBox(height: 4),
          Icon(Icons.check_circle, color: accent, size: 14),
        ],
      ]),
    ),
  );
}

// ── Language tile ──────────────────────────────────────────────
class _LangTile extends StatelessWidget {
  final bool isAr;
  final Color text1, text2;
  final VoidCallback onToggle;
  const _LangTile({
    required this.isAr, required this.text1,
    required this.text2, required this.onToggle,
  });

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onToggle,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Row(children: [
        Text(isAr ? '🇸🇦' : '🇺🇸', style: const TextStyle(fontSize: 22)),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            isAr ? 'العربية' : 'English',
            style: GoogleFonts.rajdhani(
              fontSize: 16, color: text1, fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            isAr ? 'اضغط للتبديل إلى الإنجليزية' : 'Tap to switch to Arabic',
            style: GoogleFonts.rajdhani(fontSize: 13, color: text2),
          ),
        ])),
        Icon(Icons.swap_horiz_outlined, color: const Color(0xFF00C8F0), size: 22),
      ]),
    ),
  );
}

// ── Medical reference quick view ───────────────────────────────
class _MedReferenceCard extends StatelessWidget {
  final bool isAr;
  final Color surface, border, text1, text2;
  const _MedReferenceCard({
    required this.isAr, required this.surface, required this.border,
    required this.text1, required this.text2,
  });

  @override
  Widget build(BuildContext context) {
    final rows = [
      _MedRef(isAr ? '❤️ ضربات القلب' : '❤️ Heart Rate',
          isAr ? '60 – 100 ضربة/دقيقة' : '60 – 100 bpm'),
      _MedRef(isAr ? '🩺 ضغط الدم' : '🩺 Blood Pressure',
          isAr ? '90–120 / 60–80 ملم زئبق' : '90–120 / 60–80 mmHg'),
      _MedRef(isAr ? '🩸 سكر الدم' : '🩸 Blood Sugar',
          isAr ? '70 – 99 ملغ/ديسيلتر (صيام)' : '70 – 99 mg/dL (fasting)'),
      _MedRef(isAr ? '🌡️ درجة الحرارة' : '🌡️ Body Temperature',
          isAr ? '36.1 – 37.2 درجة مئوية' : '36.1 – 37.2 °C'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      child: Column(
        children: rows.asMap().entries.map((e) => Column(children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(children: [
              Expanded(child: Text(e.value.label,
                  style: GoogleFonts.rajdhani(
                      fontSize: 14, color: text1, fontWeight: FontWeight.w600))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF00E676).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFF00E676).withOpacity(0.3)),
                ),
                child: Text(e.value.value,
                    style: GoogleFonts.shareTechMono(
                        fontSize: 10, color: const Color(0xFF00E676))),
              ),
            ]),
          ),
          if (e.key < rows.length - 1) Divider(color: border, height: 1),
        ])).toList(),
      ),
    );
  }
}

class _MedRef { final String label, value; const _MedRef(this.label, this.value); }

// ── About tile ─────────────────────────────────────────────────
class _AboutTile extends StatelessWidget {
  final bool isAr;
  final Color text1, text2, cyan;
  const _AboutTile({
    required this.isAr, required this.text1,
    required this.text2, required this.cyan,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(16),
    child: Row(children: [
      Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: cyan.withOpacity(0.1),
          border: Border.all(color: cyan.withOpacity(0.4)),
        ),
        child: const Center(child: Text('✈️', style: TextStyle(fontSize: 20))),
      ),
      const SizedBox(width: 14),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('ADM PILOT', style: GoogleFonts.shareTechMono(
            fontSize: 15, color: cyan,
            fontWeight: FontWeight.w700, letterSpacing: 2)),
        Text(
          isAr ? 'نظام دعم قرار الطيار المتقدم' : 'Advanced Pilot Decision Support',
          style: GoogleFonts.rajdhani(fontSize: 13, color: text2),
        ),
      ]),
    ]),
  );
}

// ── Info row ───────────────────────────────────────────────────
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color color, text1;
  const _InfoRow({
    required this.icon, required this.label, required this.value,
    required this.color, required this.text1,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    child: Row(children: [
      Icon(icon, color: color, size: 18),
      const SizedBox(width: 12),
      Expanded(child: Text(label,
          style: GoogleFonts.rajdhani(fontSize: 14, color: text1,
              fontWeight: FontWeight.w600))),
      Text(value,
          style: GoogleFonts.rajdhani(fontSize: 12, color: color)),
    ]),
  );
}