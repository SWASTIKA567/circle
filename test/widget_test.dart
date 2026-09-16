import 'package:flutter_test/flutter_test.dart';
import 'package:college_notes/main.dart';

void main() {
  testWidgets('Circle app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const CircleApp());

    // Verify Circle title is present
    expect(find.text('Circle'), findsWidgets);
  });
}
