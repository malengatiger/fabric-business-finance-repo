// This is a basic Flutter widget test.
// To perform an interaction with a widget in your test, use the WidgetTester utility that Flutter
// provides. For example, you can send tap and scroll gestures. You can also use WidgetTester to
// find child widgets in the widget tree, read text, and verify that the values of widget properties
// are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:supplierv3/ui/dashboard.dart';

void main() {

  testWidgets('Test Dasshboard Widget', (WidgetTester tester) async {
    Dashboard dashboard = Dashboard(null);
    //await tester.pumpWidget(makeTestableWidget(child: dashboard));
  });
}
