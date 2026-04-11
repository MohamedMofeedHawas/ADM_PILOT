

import 'package:flutter/material.dart';

abstract class CameraPlatformController {
  Future<void> init();
  Future<Map<String, dynamic>> analyzeFrame();
  Widget buildPreview();
  void dispose();
}