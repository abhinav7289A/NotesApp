import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:marginalia/app.dart';

void main() {
  testWidgets('app boots to the library screen and lists the seed documents',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MarginaliaApp()));
    await tester.pumpAndSettle();

    expect(find.text('Your library'), findsOneWidget);
    expect(find.text('Physics XII, Chapter 9: Ray Optics'), findsOneWidget);
    expect(find.text('Biology XI, Chapter 5: Cell Structure and Function'), findsOneWidget);
    expect(find.text('Add a document'), findsOneWidget);
  });
}
