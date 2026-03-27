import 'package:flutter_test/flutter_test.dart';
import 'package:paw_sense/app.dart';

void main() {
  testWidgets('PawSense app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const PawSenseApp());
    expect(find.text('PawSense'), findsOneWidget);
  });
}
