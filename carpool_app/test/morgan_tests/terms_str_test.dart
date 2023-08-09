import 'package:carpool_app/main/utils/terms_as_str.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Test get term section Titles', () {
    expect(TermsOfService.getTermSectionTitles().runtimeType, List<String>);
    expect(TermsOfService.getTermSectionTitles().contains('1. Introduction'),
        true);
    expect(TermsOfService.getTermSectionTitles().contains('1. Intro'), false);
    expect(TermsOfService.getTermSectionTitles().length, 27);
  });

  test('Test get term section Contents', () {
    expect(TermsOfService.getTermSectionContents().runtimeType, List<String>);
    expect(TermsOfService.getTermSectionContents().contains("""
  Currently there are no purchases in the application and therefore no purchase cancellation policy.
"""), true);
    expect(
        TermsOfService.getTermSectionContents()
            .contains("""There are no term section contents here!"""),
        false);
    expect(TermsOfService.getTermSectionContents().length, 27);
  });

  testWidgets('Test formatted Term Section Widget creator method',
      (WidgetTester wt) async {
    String title = "7. Cancellation";
    String contents = """
      Currently there are no purchases in the application and therefore no purchase cancellation policy.
    """;

    Widget section =
        Scaffold(body: TermsOfService.getFormattedTermSection(title, contents));
    await wt.pumpWidget(MaterialApp(home: section));

    expect(find.text("\t7. CANCELLATION\n"), findsOneWidget);
    expect(find.text("""
      Currently there are no purchases in the application and therefore no purchase cancellation policy.
    """), findsOneWidget);
    expect(find.byType(SizedBox), findsOneWidget);
    expect(find.byType(Column), findsOneWidget);
  });
}
