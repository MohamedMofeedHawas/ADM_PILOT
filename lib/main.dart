// lib/main.dart  — UPDATED: full Light + Dark mode support
// ══════════════════════════════════════════════════════════════

import 'package:check_list_stress/screens/medical_assessment.dart';
import 'package:check_list_stress/screens/medical_provider.dart';
import 'package:check_list_stress/screens/pilot_eval_controller.dart';
import 'package:check_list_stress/screens/pilot_eval_screen.dart';
import 'package:check_list_stress/screens/settings_screen.dart';
import 'package:check_list_stress/theme/app_theme_colors.dart';
import 'package:check_list_stress/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'theme/theme.dart';
import 'models/models.dart';
import 'screens/imsafe_screen.dart';
import 'screens/pave_screen.dart';
import 'screens/decide_screen.dart';
import 'screens/report_screen.dart';
import 'screens/pilot_info_screen.dart';

import 'core/storage/hive_service.dart';
import 'core/storage/assessment_provider.dart';
import 'features/profile/profile_provider.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/history/history_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.init();

  final profile = ProfileProvider();
  await profile.init();

  final themeProvider = ThemeProvider();
  await themeProvider.init();

  final medicalProvider = MedicalProvider();
  await medicalProvider.init();

  runApp(AdmPilotApp(
    profile:         profile,
    themeProvider:   themeProvider,
    medicalProvider: medicalProvider,
  ));
}

class AdmPilotApp extends StatelessWidget {
  final ProfileProvider profile;
  final ThemeProvider   themeProvider;
  final MedicalProvider medicalProvider;

  const AdmPilotApp({
    super.key,
    required this.profile,
    required this.themeProvider,
    required this.medicalProvider,
  });

  @override
  Widget build(BuildContext context) => MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: profile),
      ChangeNotifierProvider.value(value: themeProvider),
      ChangeNotifierProvider.value(value: medicalProvider),
      ChangeNotifierProvider(create: (_) => AssessmentProvider()..load()),
    ],
    child: Consumer<ThemeProvider>(
      builder: (_, tp, __) => MaterialApp(
        title: 'ADM Pilot',
        debugShowCheckedModeBanner: false,
        theme: tp.currentTheme,
        home: const HomeShell(),
      ),
    ),
  );
}

// ══════════════════════════════════════════════════════════════
// Page flow:
//  -2 = Welcome
//  -1 = PilotInfo
//  -3 = MEDICAL (initial — mandatory first run, after PilotInfo)
//   0 = IMSAFE
//   1 = PAVE
//   2 = DECIDE
//   3 = REPORT
//   4 = DASHBOARD
//   5 = HISTORY
//   6 = MEDICAL (re-access from nav)
//   7 = SETTINGS
// ══════════════════════════════════════════════════════════════

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  late final PilotEvalController _pilotEvalCtrl;

  int  _page             = -2;
  bool _showArabic       = false;
  bool _savedThisSession = false;

  late List<ImsafeItem> _imsafe;
  late List<PaveItem>   _pave;
  late List<DecideStep> _decide;
  PilotInfo? _pilotInfo;

  @override
  void initState() {
    super.initState();
    _pilotEvalCtrl = PilotEvalController();
    _resetData();
  }

  @override
  void dispose() {
    _pilotEvalCtrl.dispose();
    super.dispose();
  }

  void _resetData() {
    _imsafe = buildImsafeItems();
    _pave   = buildPaveItems();
    _decide = buildDecideSteps();
  }

  void _resetAll() => setState(() {
    _page             = -2;
    _pilotInfo        = null;
    _savedThisSession = false;
    _resetData();
  });

  void _onImsafeChanged(int i, String rating, String notes) => setState(() {
    _imsafe[i].rating = rating;
    _imsafe[i].notes  = notes;
  });

  void _onPaveToggled(int item, int cp) => setState(() {
    _pave[item].checkpoints[cp].checked =
    !_pave[item].checkpoints[cp].checked;
  });

  void _onDecideCompleted(int i, String input) => setState(() {
    _decide[i].userInput = input;
    _decide[i].completed = true;
  });

  void _saveToHistory() {
    if (_savedThisSession) return;
    _savedThisSession = true;

    double _rs(String r) =>
        r == 'HIGH' ? 100.0 : r == 'MEDIUM' ? 50.0 : 0.0;

    final illness    = _imsafe.length > 0 ? _rs(_imsafe[0].rating) : 0.0;
    final medication = _imsafe.length > 1 ? _rs(_imsafe[1].rating) : 0.0;
    final stress     = _imsafe.length > 2 ? _rs(_imsafe[2].rating) : 0.0;
    final alcohol    = _imsafe.length > 3 ? _rs(_imsafe[3].rating) : 0.0;
    final fatigue    = _imsafe.length > 4 ? _rs(_imsafe[4].rating) : 0.0;
    final emotion    = _imsafe.length > 5 ? _rs(_imsafe[5].rating) : 0.0;
    final imsafeAvg  = (illness + medication + stress + alcohol + fatigue + emotion) / 6;

    double _pv(PaveItem item) {
      if (item.checkpoints.isEmpty) return 0;
      final done = item.checkpoints.where((c) => c.checked).length;
      return (1 - done / item.checkpoints.length) * 100;
    }
    final pilotS    = _pave.length > 0 ? _pv(_pave[0]) : 0.0;
    final aircraftS = _pave.length > 1 ? _pv(_pave[1]) : 0.0;
    final envS      = _pave.length > 2 ? _pv(_pave[2]) : 0.0;
    final extS      = _pave.length > 3 ? _pv(_pave[3]) : 0.0;
    final paveAvg   = (pilotS + aircraftS + envS + extS) / 4;

    final totalRisk = (imsafeAvg * 0.5 + paveAvg * 0.5).clamp(0.0, 100.0);
    final decision  = totalRisk >= 75
        ? 'no_go'
        : totalRisk >= 40
        ? 'caution'
        : 'go';

    final notes = _decide
        .where((s) => s.completed && s.userInput.isNotEmpty)
        .map((s) => '${s.key}: ${s.userInput}')
        .join('\n');

    final medLatest = context.read<MedicalProvider>().latest;
    final medNotes  = medLatest != null
        ? '\n[MEDICAL] ${medLatest.decisionLabel} (risk: ${medLatest.overallScore.toStringAsFixed(0)}%)'
        : '';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AssessmentProvider>().saveCurrentAssessment(
        imsafeTotal:   imsafeAvg,
        paveTotal:     paveAvg,
        totalRisk:     totalRisk,
        decision:      decision,
        illness:       illness,
        medication:    medication,
        stress:        stress,
        alcohol:       alcohol,
        fatigue:       fatigue,
        emotion:       emotion,
        pilotScore:    pilotS,
        aircraftScore: aircraftS,
        envScore:      envS,
        extScore:      extS,
        pilotName:     _pilotInfo?.pilotName ?? '',
        flightId:      _pilotInfo?.flightNumber ?? '',
        notes:         notes + medNotes,
        phase:         'pre_flight',
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;

    // ── Welcome ────────────────────────────────────────────
    if (_page == -2) {
      return _WelcomeScreen(
        showArabic:       _showArabic,
        onToggleLanguage: () => setState(() => _showArabic = !_showArabic),
        onStart:          () => setState(() => _page = -1),
      );
    }

    // ── Pilot Info ─────────────────────────────────────────
    if (_page == -1) {
      return PilotInfoScreen(
        showArabic: _showArabic,
        existing:   _pilotInfo,
        onSave: (info) => setState(() {
          _pilotInfo = info;
          _page      = -3;
        }),
      );
    }

    // ── Initial Medical Assessment ─────────────────────────
    if (_page == -3) {
      return _InitialMedicalWrapper(
        showArabic: _showArabic,
        pilotInfo:  _pilotInfo,
        onFinished: () => setState(() => _page = 0),
      );
    }

    // ── Main shell with bottom nav ─────────────────────────
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: c.bg,
      body: Column(
        children: [
          Expanded(child: _buildPage()),
          _BottomNav(
            currentIndex: _page,
            showArabic:   _showArabic,
            onTap: (i) {
              if (i == 3) _saveToHistory();
              setState(() => _page = i);
            },
            imsafe:      _imsafe,
            pave:        _pave,
            decide:      _decide,
            pilotInfo:   _pilotInfo,
            onEditPilot: () => setState(() => _page = -1),
          ),
        ],
      ),
    );
  }

  Widget _buildPage() {
    switch (_page) {
      case 0:
        return ImsafeScreenV2(
          items:         _imsafe,
          showArabic:    _showArabic,
          onItemChanged: _onImsafeChanged,
          onComplete:    () => setState(() => _page = 1),
        );
      case 1:
        return PaveScreen(
          items:               _pave,
          showArabic:          _showArabic,
          onCheckpointToggled: _onPaveToggled,
          onComplete:          () => setState(() => _page = 2),
          onOpenPilotEval: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ListenableBuilder(
                  listenable: _pilotEvalCtrl,
                  builder: (_, __) => PilotEvalScreen(
                    controller: _pilotEvalCtrl,
                    showArabic: _showArabic,
                    onComplete: () => Navigator.pop(context),
                  ),
                ),
              ),
            );
          },
        );
      case 2:
        return DecideScreen(
          steps:           _decide,
          showArabic:      _showArabic,
          onStepCompleted: _onDecideCompleted,
          onComplete: () {
            _saveToHistory();
            setState(() => _page = 3);
          },
        );
      case 3:
        return ReportScreen(
          imsafe:    _imsafe,
          pave:      _pave,
          decide:    _decide,
          showArabic: _showArabic,
          pilotInfo:  _pilotInfo,
          onRestart:  _resetAll,
        );
      case 4:
        return DashboardScreen(showArabic: _showArabic);
      case 5:
        return HistoryScreen(showArabic: _showArabic);
      case 6:
        return MedicalAssessmentScreen(
          showArabic: _showArabic,
          onFinished: () {
            setState(() => _page = 0);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              backgroundColor: const Color(0xFF00E676),
              content: Text(
                _showArabic
                    ? '✅ تم حفظ الكشف الطبي — متابعة IMSAFE'
                    : '✅ Medical check saved — continuing to IMSAFE',
                style: GoogleFonts.rajdhani(
                  fontSize: 14,
                  color:    Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              duration: const Duration(seconds: 3),
            ));
          },
        );
      case 7:
        return SettingsScreen(
          showArabic:       _showArabic,
          onToggleLanguage: (v) => setState(() => _showArabic = v),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

// ══════════════════════════════════════════════════════════════
// ── Initial Medical Wrapper
// ══════════════════════════════════════════════════════════════
class _InitialMedicalWrapper extends StatelessWidget {
  final bool      showArabic;
  final PilotInfo? pilotInfo;
  final VoidCallback onFinished;

  const _InitialMedicalWrapper({
    required this.showArabic,
    required this.pilotInfo,
    required this.onFinished,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Scaffold(
      backgroundColor: c.bg,
      body: Column(children: [
        SafeArea(
          bottom: false,
          child: _PilotHeaderStrip(
            pilotInfo:  pilotInfo,
            showArabic: showArabic,
          ),
        ),
        Expanded(
          child: MedicalAssessmentScreen(
            showArabic:     showArabic,
            onFinished:     onFinished,
            isInitialFlow:  true,
            wrapInScaffold: false,
          ),
        ),
      ]),
    );
  }
}

class _PilotHeaderStrip extends StatelessWidget {
  final PilotInfo? pilotInfo;
  final bool       showArabic;

  const _PilotHeaderStrip({
    required this.pilotInfo,
    required this.showArabic,
  });

  @override
  Widget build(BuildContext context) {
    final c    = context.appColors;
    const cyan = AppThemeColors.cyan;

    return Container(
      decoration: BoxDecoration(
        color:  c.surface,
        border: Border(bottom: BorderSide(color: c.border)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(children: [
        // Step indicator
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color:        cyan.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
            border:       Border.all(color: cyan.withOpacity(0.3)),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            _StepDot(active: true,  color: cyan),
            const SizedBox(width: 3),
            _StepDot(active: false, color: cyan),
            const SizedBox(width: 3),
            _StepDot(active: false, color: cyan),
            const SizedBox(width: 3),
            _StepDot(active: false, color: cyan),
            const SizedBox(width: 8),
            Text(
              showArabic ? 'خطوة ١ من ٤' : 'STEP 1 / 4',
              style: GoogleFonts.shareTechMono(
                  fontSize: 9, color: cyan, letterSpacing: 1),
            ),
          ]),
        ),
        const SizedBox(width: 12),
        if (pilotInfo != null) ...[
          pilotInfo!.photoBytes != null
              ? CircleAvatar(
            radius: 14,
            backgroundImage: MemoryImage(pilotInfo!.photoBytes!),
          )
              : Container(
            width: 28, height: 28,
            decoration: BoxDecoration(
              shape:  BoxShape.circle,
              color:  cyan.withOpacity(0.1),
              border: Border.all(color: cyan.withOpacity(0.3)),
            ),
            child: const Icon(Icons.person, size: 14, color: AppThemeColors.cyan),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize:       MainAxisSize.min,
              children: [
                Text(
                  pilotInfo!.pilotName,
                  style: GoogleFonts.shareTechMono(
                    fontSize:   11,
                    color:      c.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (pilotInfo!.flightNumber.isNotEmpty)
                  Text(
                    pilotInfo!.flightNumber,
                    style: GoogleFonts.rajdhani(
                        fontSize: 10, color: c.textSecondary),
                  ),
              ],
            ),
          ),
        ] else
          Expanded(
            child: Text(
              showArabic ? 'الكشف الطبي الإلزامي' : 'MANDATORY MEDICAL CHECK',
              style: GoogleFonts.shareTechMono(
                  fontSize: 10, color: c.textSecondary),
            ),
          ),
      ]),
    );
  }
}

class _StepDot extends StatelessWidget {
  final bool  active;
  final Color color;
  const _StepDot({required this.active, required this.color});

  @override
  Widget build(BuildContext context) => AnimatedContainer(
    duration: const Duration(milliseconds: 300),
    width:  active ? 16 : 6,
    height: 6,
    decoration: BoxDecoration(
      color:        active ? color : color.withOpacity(0.3),
      borderRadius: BorderRadius.circular(3),
    ),
  );
}

// ══════════════════════════════════════════════════════════════
// ── Bottom Navigation Bar
// ══════════════════════════════════════════════════════════════
class _BottomNav extends StatelessWidget {
  final int              currentIndex;
  final bool             showArabic;
  final ValueChanged<int> onTap;
  final List<ImsafeItem> imsafe;
  final List<PaveItem>   pave;
  final List<DecideStep> decide;
  final PilotInfo?       pilotInfo;
  final VoidCallback     onEditPilot;

  const _BottomNav({
    required this.currentIndex,
    required this.showArabic,
    required this.onTap,
    required this.imsafe,
    required this.pave,
    required this.decide,
    required this.pilotInfo,
    required this.onEditPilot,
  });

  double get _imsafePct =>
      imsafe.where((i) => i.rating != 'LOW').length / imsafe.length;

  double get _pavePct {
    final tot = pave.fold(0, (s, i) => s + i.checkpoints.length);
    final chk = pave.fold(
        0, (s, i) => s + i.checkpoints.where((c) => c.checked).length);
    return tot == 0 ? 0 : chk / tot;
  }

  double get _decidePct =>
      decide.where((s) => s.completed).length / decide.length;

  @override
  Widget build(BuildContext context) {
    final c  = context.appColors;
    final mp = context.watch<MedicalProvider>();

    final medDone  = mp.allFilled;
    final medColor = medDone
        ? (mp.currentDecision == 'no_go'
        ? AppThemeColors.red
        : mp.currentDecision == 'caution'
        ? AppThemeColors.amber
        : AppThemeColors.green)
        : AppThemeColors.cyan;

    final tabs = [
      _NavTab(idx: 0, label: showArabic ? 'IMSAFE'  : 'IMSAFE',
          icon: Icons.person_outline,         activeIcon: Icons.person,
          color: AppThemeColors.cyan,          progress: _imsafePct),
      _NavTab(idx: 1, label: 'PAVE',
          icon: Icons.checklist_outlined,     activeIcon: Icons.checklist,
          color: AppThemeColors.green,         progress: _pavePct),
      _NavTab(idx: 2, label: showArabic ? 'DECIDE'  : 'DECIDE',
          icon: Icons.psychology_outlined,    activeIcon: Icons.psychology,
          color: AppThemeColors.amber,         progress: _decidePct),
      _NavTab(idx: 3, label: showArabic ? 'تقرير'  : 'REPORT',
          icon: Icons.summarize_outlined,     activeIcon: Icons.summarize,
          color: AppThemeColors.purple,        progress: 0),
      _NavTab(idx: 4, label: showArabic ? 'لوحة'   : 'DASH',
          icon: Icons.dashboard_outlined,     activeIcon: Icons.dashboard,
          color: const Color(0xFF00BCD4),      progress: 0),
      _NavTab(idx: 5, label: showArabic ? 'سجل'    : 'LOG',
          icon: Icons.history_outlined,       activeIcon: Icons.history,
          color: const Color(0xFF9C27B0),      progress: 0),
      _NavTab(idx: 6, label: showArabic ? 'طبي'    : 'MEDICAL',
          icon: Icons.monitor_heart_outlined, activeIcon: Icons.monitor_heart,
          color: medColor,                    progress: medDone ? 1.0 : 0,
          badge: medDone ? mp.currentDecision.toUpperCase() : null),
      _NavTab(idx: 7, label: showArabic ? 'ضبط'    : 'CONFIG',
          icon: Icons.settings_outlined,      activeIcon: Icons.settings,
          color: const Color(0xFF8090A0),      progress: 0),
    ];

    return Container(
      decoration: BoxDecoration(
        color:  c.surface,
        border: Border(top: BorderSide(color: c.border)),
      ),
      child: SafeArea(
        top: false,
        child: Row(children: [
          // ── Pilot avatar ───────────────────────────────
          GestureDetector(
            onTap: onEditPilot,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
              child: Column(children: [
                Container(
                  width: 28, height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:  c.elevated,
                    border: Border.all(
                        color: AppThemeColors.cyan.withOpacity(0.5), width: 1.5),
                    image: pilotInfo?.photoBytes != null
                        ? DecorationImage(
                        image: MemoryImage(pilotInfo!.photoBytes!),
                        fit:   BoxFit.cover)
                        : null,
                  ),
                  child: pilotInfo?.photoBytes == null
                      ? Icon(Icons.person, size: 15, color: c.textTertiary)
                      : null,
                ),
                const SizedBox(height: 2),
                Text(
                  pilotInfo?.pilotName.split(' ').first ??
                      (showArabic ? 'طيار' : 'PILOT'),
                  style: GoogleFonts.shareTechMono(
                      fontSize: 6,
                      color: AppThemeColors.cyan,
                      letterSpacing: 0.4),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ]),
            ),
          ),
          // ── Tabs ────────────────────────────────────────
          ...tabs.map((tab) {
            final active = currentIndex == tab.idx;
            final color  = active ? tab.color : c.textTertiary;
            return Expanded(
              child: GestureDetector(
                onTap:     () => onTap(tab.idx),
                behavior:  HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Column(children: [
                    if (tab.badge != null && !active)
                      Container(
                        margin: const EdgeInsets.only(bottom: 2),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color:        tab.color.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Text(
                          tab.badge!.length > 4
                              ? tab.badge!.substring(0, 4)
                              : tab.badge!,
                          style: GoogleFonts.shareTechMono(
                            fontSize:   6,
                            color:      tab.color,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    Icon(active ? tab.activeIcon : tab.icon,
                        size: 19, color: color),
                    const SizedBox(height: 2),
                    Text(
                      tab.label,
                      style: GoogleFonts.shareTechMono(
                        fontSize:   6.5,
                        letterSpacing: 0.5,
                        color:      color,
                        fontWeight: active
                            ? FontWeight.w700
                            : FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 3),
                    if (tab.idx <= 2 || tab.idx == 6)
                      SizedBox(
                        width: 28,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: LinearProgressIndicator(
                            value:            tab.progress,
                            minHeight:        2,
                            backgroundColor:  c.border,
                            valueColor: AlwaysStoppedAnimation(
                                tab.color.withOpacity(0.8)),
                          ),
                        ),
                      ),
                  ]),
                ),
              ),
            );
          }),
        ]),
      ),
    );
  }
}

class _NavTab {
  final int      idx;
  final String   label;
  final IconData icon, activeIcon;
  final Color    color;
  final double   progress;
  final String?  badge;

  const _NavTab({
    required this.idx,
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.color,
    required this.progress,
    this.badge,
  });
}

// ══════════════════════════════════════════════════════════════
// ── Welcome Screen
// ══════════════════════════════════════════════════════════════
class _WelcomeScreen extends StatelessWidget {
  final bool         showArabic;
  final VoidCallback onToggleLanguage;
  final VoidCallback onStart;

  const _WelcomeScreen({
    required this.showArabic,
    required this.onToggleLanguage,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    final w      = MediaQuery.of(context).size.width;
    final isWide = w >= 700;
    final c      = context.appColors;

    return Scaffold(
      backgroundColor: c.bg,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(child: CustomPaint(painter: _GridPainter(c.border))),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                    horizontal: isWide ? w * 0.2 : 28, vertical: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Language toggle
                    Align(
                      alignment: Alignment.topRight,
                      child: TextButton(
                        onPressed: onToggleLanguage,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            border:       Border.all(color: c.border),
                            borderRadius: BorderRadius.circular(6),
                            color:        c.surface,
                          ),
                          child: Text(
                            showArabic ? '🇺🇸 EN' : '🇸🇦 AR',
                            style: GoogleFonts.shareTechMono(
                                fontSize:    11,
                                color:       c.textSecondary,
                                letterSpacing: 1),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    _HeroGraphic()
                        .animate()
                        .fadeIn(duration: 800.ms)
                        .slideY(begin: -0.2, duration: 800.ms,
                        curve: Curves.easeOutCubic),
                    const SizedBox(height: 24),

                    Text(
                      'ADM PILOT',
                      style: GoogleFonts.shareTechMono(
                        fontSize:   36,
                        color:      AppThemeColors.cyan,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 6,
                      ),
                    ).animate().fadeIn(delay: 200.ms),
                    const SizedBox(height: 8),

                    Text(
                      showArabic
                          ? 'نظام اتخاذ القرار الجوي المتقدم'
                          : 'Advanced Decision Making System',
                      style: GoogleFonts.rajdhani(
                          fontSize:    14,
                          color:       c.textSecondary,
                          letterSpacing: 2),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(delay: 400.ms),
                    const SizedBox(height: 20),

                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color:        AppThemeColors.cyan.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(100),
                        border:       Border.all(
                            color: AppThemeColors.cyan.withOpacity(0.2)),
                      ),
                      child: Text(
                        showArabic
                            ? 'حلّق بذكاء. قرّر بثقة. وابقَ في أمان..'
                            : 'Fly Smarter. Decide Better. Stay Safe.',
                        style: const TextStyle(
                          fontSize:   12,
                          fontWeight: FontWeight.w600,
                          color:      AppThemeColors.cyan,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ).animate(delay: 400.ms).fadeIn(duration: 500.ms),
                    const SizedBox(height: 30),

                    // ── Flow cards ─────────────────────────────
                    _FlowCard(
                        step: '01', emoji: '🏥', title: 'MEDICAL',
                        arabicTitle: 'الكشف الطبي',
                        color: AppThemeColors.red, delay: 450,
                        showArabic: showArabic,
                        desc: showArabic
                            ? 'القلب • الضغط • السكر • الحرارة'
                            : 'Heart Rate • Blood Pressure • Sugar • Temperature'),
                    const SizedBox(height: 10),
                    _FlowCard(
                        step: '02', emoji: '🧑‍✈️', title: 'IMSAFE',
                        arabicTitle: 'تقييم الطيار الشخصي',
                        color: AppThemeColors.cyan, delay: 500,
                        showArabic: showArabic,
                        desc: showArabic
                            ? 'مرض • دواء • إجهاد • كحول • إرهاق • عواطف'
                            : 'Illness • Medication • Stress • Alcohol • Fatigue • Emotions'),
                    const SizedBox(height: 10),
                    _FlowCard(
                        step: '03', emoji: '✈️', title: 'PAVE',
                        arabicTitle: 'تقييم بيئة الرحلة',
                        color: AppThemeColors.green, delay: 600,
                        showArabic: showArabic,
                        desc: showArabic
                            ? 'طيار • طائرة • بيئة • ضغوط خارجية'
                            : 'Pilot • Aircraft • enVironment • External Pressures'),
                    const SizedBox(height: 10),
                    _FlowCard(
                        step: '04', emoji: '🎯', title: 'DECIDE',
                        arabicTitle: 'نموذج اتخاذ القرار',
                        color: AppThemeColors.amber, delay: 700,
                        showArabic: showArabic,
                        desc: showArabic
                            ? 'اكتشف • قيّم • فكّر • ادمج • قرّر • نفّذ وراجع'
                            : 'Detect • Evaluate • Consider • Integrate • Decide • Execute'),
                    const SizedBox(height: 36),

                    SizedBox(
                      width: double.infinity, height: 56,
                      child: ElevatedButton(
                        onPressed: onStart,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppThemeColors.cyan.withOpacity(0.15),
                          foregroundColor: AppThemeColors.cyan,
                          side: const BorderSide(
                              color: AppThemeColors.cyan, width: 1.5),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              showArabic ? 'ابدأ رحلتك معنا' : 'GET STARTED',
                              style: GoogleFonts.shareTechMono(
                                  fontSize:    16,
                                  letterSpacing: 3,
                                  color:       AppThemeColors.cyan),
                            ),
                            const SizedBox(width: 10),
                            const Icon(Icons.arrow_forward, size: 18),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(delay: 900.ms).slideY(begin: 0.3),
                    const SizedBox(height: 16),

                    Text(
                      showArabic
                          ? 'مبني على ورقة عمل (FAASTeam ADM)'
                          : 'Based on (FAASTeam ADM) Worksheet',
                      style: TextStyle(
                          fontSize: 13,
                          color:    c.textTertiary,
                          letterSpacing: 1),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(delay: 1100.ms),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Flow card ─────────────────────────────────────────────────
class _FlowCard extends StatelessWidget {
  final String step, emoji, title, arabicTitle, desc;
  final Color  color;
  final int    delay;
  final bool   showArabic;

  const _FlowCard({
    required this.step,
    required this.emoji,
    required this.title,
    required this.arabicTitle,
    required this.desc,
    required this.color,
    required this.delay,
    required this.showArabic,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Container(
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border:       Border.all(color: c.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(9),
        child: IntrinsicHeight(
          child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Container(width: 3, color: color),
            Expanded(
              child: Container(
                color:   c.surface,
                padding: const EdgeInsets.all(14),
                child: Row(children: [
                  // Step badge
                  Container(
                    width: 28, height: 28,
                    decoration: BoxDecoration(
                      shape:  BoxShape.circle,
                      color:  color.withOpacity(0.15),
                      border: Border.all(color: color.withOpacity(0.4)),
                    ),
                    child: Center(
                      child: Text(step,
                          style: GoogleFonts.shareTechMono(
                              fontSize:   9,
                              color:      color,
                              fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(emoji, style: const TextStyle(fontSize: 22)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize:       MainAxisSize.min,
                      children: [
                        Row(children: [
                          Text(title,
                              style: GoogleFonts.shareTechMono(
                                  fontSize:   13,
                                  color:      color,
                                  letterSpacing: 2,
                                  fontWeight: FontWeight.w700)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              showArabic ? arabicTitle : '',
                              style: TextStyle(
                                  fontSize: 11, color: c.textTertiary),
                              maxLines:  1,
                              overflow:  TextOverflow.ellipsis,
                            ),
                          ),
                        ]),
                        const SizedBox(height: 3),
                        Text(desc,
                            maxLines:  2,
                            overflow:  TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 11,
                                color:    c.textSecondary,
                                height:   1.4)),
                      ],
                    ),
                  ),
                ]),
              ),
            ),
          ]),
        ),
      ),
    ).animate()
        .fadeIn(delay: Duration(milliseconds: delay))
        .slideX(begin: -0.1);
  }
}

// ── Grid background painter ────────────────────────────────────
class _GridPainter extends CustomPainter {
  final Color borderColor;
  const _GridPainter(this.borderColor);

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color      = borderColor.withOpacity(0.35)
      ..strokeWidth = 0.5;
    const step = 44.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
  }

  @override
  bool shouldRepaint(_GridPainter old) => old.borderColor != borderColor;
}

// ── Hero graphic ───────────────────────────────────────────────
class _HeroGraphic extends StatelessWidget {
   _HeroGraphic();

  @override
  Widget build(BuildContext context) => Container(
    width: 160, height: 160,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end:   Alignment.bottomRight,
        colors: [Color(0xFF1E3A6E), Color(0xFF0C2247)],
      ),
      boxShadow: [
        BoxShadow(
          color:       AppThemeColors.cyan.withOpacity(0.25),
          blurRadius:  40,
          spreadRadius: 0,
          offset:      const Offset(0, 16),
        ),
      ],
    ),
    child: const Icon(Icons.flight_rounded,
        size: 72, color: AppThemeColors.cyan),
  );
}