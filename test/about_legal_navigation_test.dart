import 'package:expense_mate/Core/routes/page_routes.dart';
import 'package:expense_mate/Feature/about/view/about_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  testWidgets('About legal rows open their matching Dart screens', (
    tester,
  ) async {
    await tester.pumpWidget(
      GetMaterialApp(
        initialRoute: '/test-about',
        getPages: [
          GetPage(name: '/test-about', page: () => const AboutView()),
          ...AppPages.pages,
        ],
      ),
    );
    await tester.pumpAndSettle();

    final privacyRow = find.text('Privacy policy');
    await tester.scrollUntilVisible(
      privacyRow,
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(privacyRow);
    await tester.pumpAndSettle();
    await tester.tap(privacyRow);
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byType(AppBar).last,
        matching: find.text('Privacy Policy'),
      ),
      findsOneWidget,
    );

    Get.back();
    await tester.pumpAndSettle();

    final termsRow = find.text('Terms of service');
    await tester.scrollUntilVisible(
      termsRow,
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(termsRow);
    await tester.pumpAndSettle();
    await tester.tap(termsRow);
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byType(AppBar).last,
        matching: find.text('Terms & Conditions'),
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
