import 'package:expense_mate/term_privacy/term.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('terms page fits a narrow screen and has no theme toggle', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
        themeMode: ThemeMode.light,
        home: const TermsView(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Last updated: 4 October 2026'), findsOneWidget);
    expect(find.text('Toggle light or dark theme'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('terms page follows the app dark theme and contents links work', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
        themeMode: ThemeMode.dark,
        home: const TermsView(),
      ),
    );
    await tester.pumpAndSettle();

    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
    expect(scaffold.backgroundColor, ThemeData.dark().scaffoldBackgroundColor);

    await tester.tap(find.text('15. Contact us'));
    await tester.pumpAndSettle();

    expect(find.text('innovexa.technologies01@gmail.com'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('terms page lays out on a wide screen', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1440, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MaterialApp(home: TermsView()));
    await tester.pumpAndSettle();

    expect(find.text('CONTENTS'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
