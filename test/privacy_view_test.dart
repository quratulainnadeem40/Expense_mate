import 'package:expense_mate/term_privacy/privacy.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('privacy page fits a narrow screen without a theme toggle', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
        themeMode: ThemeMode.light,
        home: const PrivacyView(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Your money, your data.'), findsOneWidget);
    expect(find.text('Toggle light or dark theme'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('privacy page follows app dark mode and contents links work', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
        themeMode: ThemeMode.dark,
        home: const PrivacyView(),
      ),
    );
    await tester.pumpAndSettle();

    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
    expect(scaffold.backgroundColor, ThemeData.dark().scaffoldBackgroundColor);

    await tester.tap(find.text('11. Contact us'));
    await tester.pumpAndSettle();

    expect(find.text('innovexa.technologies01@gmail.com'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('privacy page lays out on a wide screen', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1440, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MaterialApp(home: PrivacyView()));
    await tester.pumpAndSettle();

    expect(find.text('CONTENTS'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
