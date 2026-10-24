import 'package:flutter_test/flutter_test.dart';
import 'package:cases/main.dart';

void main() {
  testWidgets('shows the case simulator home screen', (tester) async {
    await tester.pumpWidget(const CaseSimulatorApp());
    expect(find.text('CASE LAB'), findsOneWidget);
    expect(find.text('SELECT A CASE'), findsOneWidget);
    expect(find.text('YOUR INVENTORY'), findsOneWidget);
    expect(find.textContaining('OPEN CASE'), findsOneWidget);
  });
}
