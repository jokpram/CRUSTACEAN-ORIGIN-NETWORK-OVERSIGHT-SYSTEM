import 'package:flutter_test/flutter_test.dart';

import 'package:fluttermultiplatform/main.dart';

void main() {
  testWidgets('App loads smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const CronosApp());
  });
}
