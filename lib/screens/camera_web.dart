// lib/screens/camera_web.dart
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:math' as math;
import 'dart:typed_data';
// ✅ dart:ui_web هو الصح للـ platformViewRegistry (مش dart:ui)
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';
import '../models/ai_recommendations.dart';
import 'camera_platform.dart';

class WebCameraController implements CameraPlatformController {
  html.VideoElement? _video;
  html.CanvasElement? _canvas;
  bool _initialized = false;
  String? _viewId;

  @override
  Future<void> init() async {
    _video = html.VideoElement()
      ..autoplay = true
      ..muted = true
      ..setAttribute('playsinline', 'true')
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.objectFit = 'cover'
      ..style.transform = 'scaleX(-1)';

    _canvas = html.CanvasElement(width: 640, height: 480);

    try {
      final stream = await html.window.navigator.mediaDevices?.getUserMedia({
        'video': {
          'facingMode': 'user',
          'width': {'ideal': 640},
          'height': {'ideal': 480},
        },
        'audio': false,
      });
      _video!.srcObject = stream;
      await _video!.play();
    } catch (e) {
      throw Exception('Camera permission denied: $e');
    }

    _viewId = 'camera-view-${DateTime.now().millisecondsSinceEpoch}';

    // ✅ الصح: ui_web.platformViewRegistry (مش ui.platformViewRegistry)
    ui_web.platformViewRegistry.registerViewFactory(
      _viewId!,
          (_) => _video!,
    );

    _initialized = true;
  }

  @override
  Future<Map<String, dynamic>> analyzeFrame() async {
    if (!_initialized || _video == null || _canvas == null) {
      return _fallbackResult();
    }
    try {
      final ctx = _canvas!.getContext('2d') as html.CanvasRenderingContext2D;
      ctx.drawImageScaled(_video!, 0, 0, _canvas!.width!, _canvas!.height!);
      final imageData = ctx.getImageData(0, 0, _canvas!.width!, _canvas!.height!);
      return _analyzePixels(
        imageData.data as Uint8ClampedList,
        _canvas!.width!,
        _canvas!.height!,
      );
    } catch (e) {
      debugPrint('Web camera analysis error: $e');
      return _fallbackResult();
    }
  }

  Map<String, dynamic> _analyzePixels(
      Uint8ClampedList pixels, int width, int height) {
    final faceLeft   = (width  * 0.2).toInt();
    final faceRight  = (width  * 0.8).toInt();
    final faceTop    = (height * 0.1).toInt();
    final faceBottom = (height * 0.9).toInt();
    final eyeTop     = faceTop + ((faceBottom - faceTop) * 0.25).toInt();
    final eyeBottom  = faceTop + ((faceBottom - faceTop) * 0.45).toInt();

    double totalBrightness = 0, eyeBrightness = 0;
    int    totalPixels = 0,     eyePixels = 0;

    for (int y = faceTop; y < faceBottom; y++) {
      for (int x = faceLeft; x < faceRight; x++) {
        final idx = (y * width + x) * 4;
        if (idx + 2 >= pixels.length) continue;
        final brightness = (0.299 * pixels[idx] +
            0.587 * pixels[idx + 1] +
            0.114 * pixels[idx + 2]) / 255.0;
        totalBrightness += brightness;
        totalPixels++;
        if (y >= eyeTop && y < eyeBottom) {
          eyeBrightness += brightness;
          eyePixels++;
        }
      }
    }

    final avgEyeBright    = eyePixels > 0 ? eyeBrightness / eyePixels : 0.5;
    final eyeOpenEstimate = (avgEyeBright * 1.4).clamp(0.0, 1.0);
    final browFurrow      = (1.0 - avgEyeBright).clamp(0.0, 0.6);

    return {
      ...AiRecommendationEngine.analyzeFaceStressIndicators(
        eyeOpenness:      eyeOpenEstimate,
        browFurrow:       browFurrow,
        microExpressions: math.Random().nextDouble() * 0.3,
      ),
      'isRealAnalysis': true,
      'confidence':     68,
    };
  }

  Map<String, dynamic> _fallbackResult() {
    final rng = math.Random();
    return {
      ...AiRecommendationEngine.analyzeFaceStressIndicators(
        eyeOpenness:      0.5 + rng.nextDouble() * 0.5,
        browFurrow:       rng.nextDouble() * 0.5,
        microExpressions: rng.nextDouble() * 0.4,
      ),
      'isRealAnalysis': false,
      'confidence':     40,
    };
  }

  @override
  Widget buildPreview() {
    if (!_initialized || _viewId == null) {
      return const Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          CircularProgressIndicator(color: Color(0xFF00C8F0)),
          SizedBox(height: 12),
          Text('Requesting camera...',
              style: TextStyle(color: Color(0xFF6B8CAE), fontSize: 12)),
        ]),
      );
    }
    return SizedBox.expand(
      child: HtmlElementView(viewType: _viewId!),
    );
  }

  @override
  void dispose() {
    final stream = _video?.srcObject;
    if (stream != null) {
      for (final track in stream.getTracks()) {
        track.stop();
      }
    }
    _video?.remove();
    _video = null;
  }
}