import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:cases/main.dart';

void main() {
  testWidgets('shows the case simulator home screen', (tester) async {
    tester.view.physicalSize = const Size(430, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const CaseSimulatorApp());
    expect(find.text('CASE LAB'), findsOneWidget);
    expect(find.text('CHOOSE A CASE'), findsOneWidget);
    expect(find.textContaining('OPEN CASE'), findsOneWidget);
  });
}
