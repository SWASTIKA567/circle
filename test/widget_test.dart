import 'package:flutter_test/flutter_test.dart';
import 'package:college_notes/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Circle app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const CircleApp());

    // Verify Circle title is present
    expect(find.text('Circle'), findsWidgets);

    // Settle splash navigation timers
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
  });
}
