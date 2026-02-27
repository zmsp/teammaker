import 'package:flutter_test/flutter_test.dart';
import 'package:teammaker/main.dart';

void main() {
  testWidgets('App launches smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const TeamMakerApp());
    expect(find.byType(TeamMakerApp), findsOneWidget);
  });
}
