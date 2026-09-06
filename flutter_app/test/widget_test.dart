import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_app/main.dart';

void main() {
  testWidgets('Farmayopin app boots', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('farmayopin'), findsOneWidget);
  });
}
