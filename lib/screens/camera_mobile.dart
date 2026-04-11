// lib/screens/camera_mobile.dart
// Android — ML Kit Face Detection
// ✅ implements CameraPlatformController من camera_platform.dart

import 'dart:math' as math;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import '../models/ai_recommendations.dart';
import 'camera_platform.dart'; // ✅ import الـ interface من نفس الـ package

class MobileCameraController implements CameraPlatformController {
  CameraController? _controller;
  FaceDetector? _faceDetector;
  bool _initialized = false;

  @override
  Future<void> init() async {
    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        enableClassification: true,
        enableLandmarks: true,
        enableContours: false,
        minFaceSize: 0.15,
        performanceMode: FaceDetectorMode.accurate,
      ),
    );

    final cameras = await availableCameras();
    if (cameras.isEmpty) throw Exception('No cameras found');

    final frontCam = cameras.firstWhere(
          (c) => c.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    _controller = CameraController(
      frontCam,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.nv21,
    );

    await _controller!.initialize();
    _initialized = true;
  }

  @override
  Future<Map<String, dynamic>> analyzeFrame() async {
    if (!_initialized || _controller == null || _faceDetector == null) {
      return _fallbackResult();
    }
    try {
      final XFile imageFile = await _controller!.takePicture();
      final inputImage = InputImage.fromFilePath(imageFile.path);
      final faces = await _faceDetector!.processImage(inputImage);

      if (faces.isEmpty) return _noFaceResult();

      final face = faces.reduce((a, b) =>
      a.boundingBox.width > b.boundingBox.width ? a : b);

      return _buildResultFromFace(face);
    } catch (e) {
      debugPrint('ML Kit error: $e');
      return _fallbackResult();
    }
  }

  Map<String, dynamic> _buildResultFromFace(Face face) {
    final leftEyeOpen  = face.leftEyeOpenProbability  ?? 0.8;
    final rightEyeOpen = face.rightEyeOpenProbability ?? 0.8;
    final avgEyeOpen   = (leftEyeOpen + rightEyeOpen) / 2.0;
    final eyeScore     = (avgEyeOpen * 100).round().clamp(0, 100);

    final smileProbability = face.smilingProbability ?? 0.5;
    final headEulerY = (face.headEulerAngleY ?? 0.0).abs();
    final headEulerZ = (face.headEulerAngleZ ?? 0.0).abs();
    final headTension = ((headEulerY + headEulerZ) / 60.0).clamp(0.0, 1.0);

    final stressRaw = ((1.0 - smileProbability) * 0.35 +
        (1.0 - avgEyeOpen)       * 0.35 +
        headTension              * 0.30)
        .clamp(0.0, 1.0);

    final stressIndex = (stressRaw * 100).round();
    final stressLevel = stressIndex >= 60 ? 'HIGH'
        : stressIndex >= 35 ? 'MEDIUM' : 'LOW';

    final fatigueRaw = ((1.0 - avgEyeOpen) * 0.70 +
        headTension        * 0.30)
        .clamp(0.0, 1.0);

    final fatigueIndex = (fatigueRaw * 100).round();
    final fatigueLevel = fatigueIndex >= 60 ? 'HIGH'
        : fatigueIndex >= 35 ? 'MEDIUM' : 'LOW';

    final area = face.boundingBox.width * face.boundingBox.height;
    final confidence = ((area / 40000.0).clamp(0.5, 1.0) * 95)
        .round().clamp(70, 95);

    return {
      'stressLevel':      stressLevel,
      'fatigueLevel':     fatigueLevel,
      'stressIndex':      stressIndex,
      'fatigueIndex':     fatigueIndex,
      'eyeOpennessScore': eyeScore,
      'confidence':       confidence,
      'isRealAnalysis':   true,
      'leftEyeOpen':      (leftEyeOpen  * 100).round(),
      'rightEyeOpen':     (rightEyeOpen * 100).round(),
      'smileProbability': (smileProbability * 100).round(),
    };
  }

  Map<String, dynamic> _noFaceResult() => {
    'stressLevel': 'MEDIUM', 'fatigueLevel': 'MEDIUM',
    'stressIndex': 50, 'fatigueIndex': 50,
    'eyeOpennessScore': 50, 'confidence': 30,
    'isRealAnalysis': false,
    'error': 'No face detected — position face in frame',
  };

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
    if (!_initialized || _controller == null) {
      return const Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          CircularProgressIndicator(color: Color(0xFF00C8F0)),
          SizedBox(height: 12),
          Text('Initializing camera...',
              style: TextStyle(color: Color(0xFF6B8CAE), fontSize: 12)),
        ]),
      );
    }
    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width:  _controller!.value.previewSize!.height,
          height: _controller!.value.previewSize!.width,
          child:  CameraPreview(_controller!),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    _faceDetector?.close();
  }
}