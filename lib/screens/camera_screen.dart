// lib/screens/camera_screen.dart
// ✅ الحل الصح — بدل conditional imports نستخدم kIsWeb في runtime
// كده بنتجنب مشكلة "file not found" في الـ compiler تماماً

import 'dart:io';
import 'dart:math' as math;
import 'camera_mobile.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/theme.dart';
import '../widgets/widgets.dart';
import '../models/ai_recommendations.dart';
import 'camera_platform.dart';

// ✅ Import الاتنين — الـ compiler بيشوفهم بس kIsWeb بيقرر أي واحد يتنفذ
import 'camera_web.dart';
//if (dart.library.io) 'camera_controller_mobile.dart';

class CameraAnalysisScreen extends StatefulWidget {
  final Function(Map<String, dynamic> result) onAnalysisComplete;
  final bool showArabic;

  const CameraAnalysisScreen({
    super.key,
    required this.onAnalysisComplete,
    required this.showArabic,
  });

  @override
  State<CameraAnalysisScreen> createState() => _CameraAnalysisScreenState();
}

class _CameraAnalysisScreenState extends State<CameraAnalysisScreen>
    with TickerProviderStateMixin {
  bool _analyzing = false;
  bool _done = false;
  bool _cameraReady = false;
  Map<String, dynamic>? _result;
  double _scanProgress = 0;
  late AnimationController _pulseCtrl;
  late CameraPlatformController? _cameraCtrl;

  @override
  void initState() {
    super.initState();

    // إعداد الأنيميشن
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    // استدعاء دالة تهيئة الكاميرا
    initCameraController();
  }

  // دالة تهيئة الكاميرا حسب المنصة
  void initCameraController() {
    if (kIsWeb) {
      _cameraCtrl = WebCameraController(); // كود للويب
    } else if (Platform.isAndroid || Platform.isIOS) {
      _cameraCtrl = MobileCameraController(); // كود للموبايل
    } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      _cameraCtrl = null; // على Desktop، لا توجد كاميرا
      print("Camera not supported on Desktop yet");
    }

    // استدعاء _initCamera لو الكاميرا موجودة
    if (_cameraCtrl != null) {
      _initCamera();
    }
  }

  // دالة init للكاميرا
  Future<void> _initCamera() async {
    try {
      await _cameraCtrl?.init();
      if (mounted) setState(() => _cameraReady = true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Camera error: $e'),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    // تأكد من وجود الكاميرا قبل التخلص منها
    _cameraCtrl?.dispose();
    super.dispose();
  }

  Future<void> _startAnalysis() async {
    setState(() {
      _analyzing = true;
      _done = false;
      _result = null;
      _scanProgress = 0;
    });

    try {
      for (int i = 0; i <= 100; i++) {
        await Future.delayed(const Duration(milliseconds: 30));
        if (!mounted) return;
        setState(() => _scanProgress = i / 100.0);
      }

      final result = await _cameraCtrl?.analyzeFrame();
      if (!mounted) return;
      setState(() {
        _analyzing = false;
        _done = true;
        _result = result;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _analyzing = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Analysis failed: $e'),
        backgroundColor: AppColors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: Text(widget.showArabic
            ? 'تحليل الوجه بالذكاء الاصطناعي'
            : 'AI FACE STRESS ANALYSIS'),
      ),
      body: SingleChildScrollView(
        padding: R.pad(context),
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          // ── Info banner ───────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.cyan.withOpacity(0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.cyan.withOpacity(0.2)),
            ),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Text('🤖', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.showArabic
                        ? 'تحليل الضغط النفسي بالكاميرا الحقيقية'
                        : 'Live Camera Stress & Fatigue Detection',
                    style: GoogleFonts.shareTechMono(
                        fontSize: 12, color: AppColors.cyan, letterSpacing: 1),
                  ),
                ),
                // Platform badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(3),
                    border: Border.all(color: AppColors.green.withOpacity(0.3)),
                  ),
                  child: Text(
                    kIsWeb ? 'WEB CAM' : 'ML KIT',
                    style: GoogleFonts.shareTechMono(
                        fontSize: 8, color: AppColors.green, letterSpacing: 1),
                  ),
                ),
              ]),
              const SizedBox(height: 8),
              Text(
                widget.showArabic
                    ? 'يستخدم النظام الكاميرا الأمامية مع ${kIsWeb ? "WebRTC" : "ML Kit"} لتحليل الوجه حقيقياً.'
                    : 'Uses front camera with ${kIsWeb ? "WebRTC pixel analysis" : "ML Kit Face Detection"} for real analysis.',
                style: const TextStyle(
                    fontSize: 11, color: AppColors.textSecondary, height: 1.5),
              ),
            ]),
          ).animate().fadeIn(),

          const SizedBox(height: 20),

          // ── Camera viewport ───────────────────────────────────────────────
          Container(
            height: 500,
            width: 200,
            decoration: BoxDecoration(
              color: const Color(0xFF050810),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _analyzing ? AppColors.cyan : AppColors.border,
                width: _analyzing ? 2 : 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Stack(children: [
                // ✅ Real camera preview
                _cameraCtrl != null
                    ? _cameraCtrl!.buildPreview()
                    : Center(
                        child: Text(
                          'Camera not available on Desktop',
                          style: TextStyle(color: Colors.white54, fontSize: 14),
                        ),
                      ),
                // Grid overlay
                CustomPaint(
                  size: const Size(double.infinity, 320),
                  painter:
                      _FaceGridPainter(progress: _scanProgress, done: _done),
                ),

                // Face oval outline
                Center(
                  child: AnimatedBuilder(
                    animation: _pulseCtrl,
                    builder: (_, __) => Container(
                      width: 220,
                      height: 200,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _done
                              ? (_result?['stressLevel'] == 'HIGH'
                                  ? AppColors.red
                                  : _result?['stressLevel'] == 'MEDIUM'
                                      ? AppColors.amber
                                      : AppColors.green)
                              : AppColors.cyan.withOpacity(_analyzing
                                  ? 0.4 + _pulseCtrl.value * 0.6
                                  : 0.3),
                          width: 2,
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(80),
                          topRight: Radius.circular(80),
                          bottomLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30),
                        ),
                      ),
                    ),
                  ),
                ),

                // Scan line
                if (_analyzing)
                  Positioned(
                    top: _scanProgress * 300,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 2,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [
                          Colors.transparent,
                          AppColors.cyan.withOpacity(0.8),
                          AppColors.cyan,
                          AppColors.cyan.withOpacity(0.8),
                          Colors.transparent,
                        ]),
                      ),
                    ),
                  ),

                // Corner markers
                ..._buildCorners(),

                // Status bar at bottom
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.bg.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _done
                              ? AppColors.green
                              : _cameraReady
                                  ? (_analyzing
                                      ? AppColors.cyan
                                      : AppColors.amber)
                                  : AppColors.textTertiary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _done
                              ? (widget.showArabic
                                  ? 'اكتمل التحليل'
                                  : 'ANALYSIS COMPLETE')
                              : _analyzing
                                  ? (widget.showArabic
                                      ? 'جارٍ التحليل...'
                                      : 'ANALYZING...')
                                  : _cameraReady
                                      ? (widget.showArabic
                                          ? 'الكاميرا جاهزة'
                                          : 'CAMERA READY')
                                      : (widget.showArabic
                                          ? 'تهيئة الكاميرا...'
                                          : 'INITIALIZING...'),
                          style: GoogleFonts.shareTechMono(
                            fontSize: 10,
                            color: _done
                                ? AppColors.green
                                : _cameraReady
                                    ? (_analyzing
                                        ? AppColors.cyan
                                        : AppColors.amber)
                                    : AppColors.textTertiary,
                            letterSpacing: 1.5,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (_analyzing) ...[
                        const SizedBox(width: 8),
                        Text('${(_scanProgress * 100).toInt()}%',
                            style: GoogleFonts.shareTechMono(
                                fontSize: 10, color: AppColors.cyan)),
                      ],
                    ]),
                  ),
                ),
              ]),
            ),
          ).animate().fadeIn(delay: 100.ms),

          const SizedBox(height: 12),

          if (_analyzing)
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: _scanProgress,
                minHeight: 6,
                backgroundColor: AppColors.elevated,
                valueColor: const AlwaysStoppedAnimation(AppColors.cyan),
              ),
            ),

          const SizedBox(height: 20),

          // Results panel
          if (_done && _result != null)
            _ResultsPanel(result: _result!, showArabic: widget.showArabic),

          const SizedBox(height: 20),

          // Buttons
          if (!_done)
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed:
                    (_analyzing || !_cameraReady) ? null : _startAnalysis,
                icon: _analyzing
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: AppColors.cyan))
                    : const Icon(Icons.camera_alt_outlined, size: 18),
                label: Text(
                  _analyzing
                      ? (widget.showArabic ? 'جارٍ التحليل...' : 'SCANNING...')
                      : !_cameraReady
                          ? (widget.showArabic
                              ? 'جارٍ تهيئة الكاميرا...'
                              : 'INITIALIZING...')
                          : (widget.showArabic
                              ? 'ابدأ مسح الوجه'
                              : 'START FACE SCAN'),
                  style:
                      GoogleFonts.shareTechMono(fontSize: 13, letterSpacing: 2),
                  overflow: TextOverflow.ellipsis,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.cyan.withOpacity(0.15),
                  foregroundColor: AppColors.cyan,
                  side: const BorderSide(color: AppColors.cyan),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
              ),
            )
          else ...[
            Row(children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () => setState(() {
                      _done = false;
                      _result = null;
                    }),
                    icon: const Icon(Icons.refresh, size: 16),
                    label: Text(widget.showArabic ? 'إعادة المسح' : 'RESCAN',
                        style: GoogleFonts.shareTechMono(
                            fontSize: 11, letterSpacing: 1.5)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () => widget.onAnalysisComplete(_result!),
                    icon: const Icon(Icons.check, size: 16),
                    label: Text(
                      widget.showArabic ? 'إضافة للتقرير ▶' : 'ADD TO REPORT ▶',
                      style: GoogleFonts.shareTechMono(
                          fontSize: 11, letterSpacing: 1.5),
                      overflow: TextOverflow.ellipsis,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.green.withOpacity(0.15),
                      foregroundColor: AppColors.green,
                      side: const BorderSide(color: AppColors.green),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ),
            ]),
          ],
          const SizedBox(height: 40),
        ]),
      ),
    );
  }

  List<Widget> _buildCorners() {
    final c = _analyzing ? AppColors.cyan : AppColors.border;
    return [
      Positioned(top: 10, left: 10, child: _Corner(color: c, rotation: 0)),
      Positioned(top: 10, right: 10, child: _Corner(color: c, rotation: 1)),
      Positioned(bottom: 10, left: 10, child: _Corner(color: c, rotation: 3)),
      Positioned(bottom: 10, right: 10, child: _Corner(color: c, rotation: 2)),
    ];
  }
}

// ─── Painters ────────────────────────────────────────────────────────────────

class _Corner extends StatelessWidget {
  final Color color;
  final int rotation;
  const _Corner({required this.color, required this.rotation});
  @override
  Widget build(BuildContext context) => Transform.rotate(
        angle: rotation * math.pi / 2,
        child: SizedBox(
            width: 20,
            height: 20,
            child: CustomPaint(painter: _CornerPainter(color: color))),
      );
}

class _CornerPainter extends CustomPainter {
  final Color color;
  const _CornerPainter({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset.zero, Offset(size.width, 0), p);
    canvas.drawLine(Offset.zero, Offset(0, size.height), p);
  }

  @override
  bool shouldRepaint(_) => false;
}

class _FaceGridPainter extends CustomPainter {
  final double progress;
  final bool done;
  const _FaceGridPainter({required this.progress, required this.done});
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = AppColors.cyan.withOpacity(0.05)
      ..strokeWidth = 0.5;
    const step = 30.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
  }

  @override
  bool shouldRepaint(_FaceGridPainter old) => old.progress != progress;
}

// ─── Results Panel ────────────────────────────────────────────────────────────

class _ResultsPanel extends StatelessWidget {
  final Map<String, dynamic> result;
  final bool showArabic;
  const _ResultsPanel({required this.result, required this.showArabic});

  @override
  Widget build(BuildContext context) {
    final stressLevel = result['stressLevel'] as String;
    final fatigueLevel = result['fatigueLevel'] as String;
    final stressIdx = result['stressIndex'] as int;
    final fatigueIdx = result['fatigueIndex'] as int;
    final eyeScore = result['eyeOpennessScore'] as int;
    final confidence = result['confidence'] as int;
    final isReal = result['isRealAnalysis'] as bool? ?? false;

    final stressColor = AppColors.riskColor(stressLevel);
    final fatigueColor = AppColors.riskColor(fatigueLevel);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          height: 2,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            gradient:
                LinearGradient(colors: [AppColors.cyan, AppColors.purple]),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(14),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Text('🤖', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  showArabic
                      ? 'نتائج التحليل الحقيقي'
                      : 'LIVE ANALYSIS RESULTS',
                  style: GoogleFonts.shareTechMono(
                      fontSize: 10,
                      color: AppColors.textSecondary,
                      letterSpacing: 2),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: (isReal ? AppColors.green : AppColors.amber)
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(
                      color: (isReal ? AppColors.green : AppColors.amber)
                          .withOpacity(0.3)),
                ),
                child: Text(
                  isReal ? '✓ REAL  $confidence%' : '~ EST  $confidence%',
                  style: GoogleFonts.shareTechMono(
                      fontSize: 8,
                      color: isReal ? AppColors.green : AppColors.amber,
                      letterSpacing: 1),
                ),
              ),
            ]),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(
                  child: _MetricTile(
                label: showArabic ? 'الإجهاد' : 'STRESS',
                value: stressLevel,
                score: stressIdx,
                color: stressColor,
                icon: '🧠',
              )),
              const SizedBox(width: 8),
              Expanded(
                  child: _MetricTile(
                label: showArabic ? 'الإرهاق' : 'FATIGUE',
                value: fatigueLevel,
                score: fatigueIdx,
                color: fatigueColor,
                icon: '😴',
              )),
              const SizedBox(width: 8),
              Expanded(
                  child: _MetricTile(
                label: showArabic ? 'انتباه العين' : 'EYE',
                value: eyeScore > 70
                    ? 'ALERT'
                    : eyeScore > 40
                        ? 'TIRED'
                        : 'LOW',
                score: eyeScore,
                color: eyeScore > 70
                    ? AppColors.green
                    : eyeScore > 40
                        ? AppColors.amber
                        : AppColors.red,
                icon: '👁️',
              )),
            ]),
            const SizedBox(height: 12),
            AProgressBar(
              value: stressIdx / 100.0,
              color: stressColor,
              label:
                  showArabic ? 'الإجهاد: $stressIdx%' : 'Stress: $stressIdx%',
            ),
            const SizedBox(height: 6),
            AProgressBar(
              value: fatigueIdx / 100.0,
              color: fatigueColor,
              label: showArabic
                  ? 'الإرهاق: $fatigueIdx%'
                  : 'Fatigue: $fatigueIdx%',
            ),
            const SizedBox(height: 6),
            AProgressBar(
              value: eyeScore / 100.0,
              color: eyeScore > 70
                  ? AppColors.green
                  : eyeScore > 40
                      ? AppColors.amber
                      : AppColors.red,
              label: showArabic
                  ? 'انتباه العين: $eyeScore%'
                  : 'Eye Alertness: $eyeScore%',
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.elevated,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.border),
              ),
              child:
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Icon(
                  isReal ? Icons.check_circle_outline : Icons.info_outline,
                  size: 14,
                  color: isReal ? AppColors.green : AppColors.amber,
                ),
                const SizedBox(width: 8),
                Expanded(
                    child: Text(
                  isReal
                      ? (kIsWeb
                          ? (showArabic
                              ? 'تم التحليل بالكاميرا الحقيقية عبر WebRTC (Chrome).'
                              : 'Analyzed using live camera via WebRTC (Chrome).')
                          : (showArabic
                              ? 'تم التحليل بـ ML Kit Face Detection على Android.'
                              : 'Analyzed using ML Kit Face Detection (Android).'))
                      : (showArabic
                          ? 'الكاميرا غير متاحة — تم استخدام بيانات تقديرية.'
                          : 'Camera unavailable — estimation used as fallback.'),
                  style: TextStyle(
                      fontSize: 10,
                      color: isReal ? AppColors.green : AppColors.textTertiary,
                      height: 1.4),
                )),
              ]),
            ),
          ]),
        ),
      ]),
    ).animate().fadeIn().slideY(begin: 0.1);
  }
}

class _MetricTile extends StatelessWidget {
  final String label, value, icon;
  final int score;
  final Color color;
  const _MetricTile(
      {required this.label,
      required this.value,
      required this.score,
      required this.color,
      required this.icon});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.06),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(children: [
          Text(icon, style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 4),
          Text(value,
              style: GoogleFonts.shareTechMono(
                  fontSize: 12, color: color, fontWeight: FontWeight.w700)),
          Text(label,
              style: const TextStyle(
                  fontSize: 8,
                  color: AppColors.textTertiary,
                  letterSpacing: 0.5)),
        ]),
      );
}
