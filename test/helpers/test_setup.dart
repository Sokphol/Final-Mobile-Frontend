import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void setUpTestEnvironment() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
}

extension TestViewport on WidgetTester {
  void setViewport(Size logicalSize, {double devicePixelRatio = 1}) {
    view.devicePixelRatio = devicePixelRatio;
    view.physicalSize = logicalSize * devicePixelRatio;
  }

  void resetViewport() {
    view.resetPhysicalSize();
    view.resetDevicePixelRatio();
  }
}
