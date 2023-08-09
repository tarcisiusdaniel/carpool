import 'package:carpool_app/app_state.dart';

import 'package:carpool_app/main/rides_page.dart';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:provider/provider.dart';

void main() {
  Widget createWidgetForTesting() {
    return MaterialApp(
        title: 'Rides Page',
        home: ChangeNotifierProvider(
          create: (context) => ApplicationState(),
          builder: ((context, child) => const RidesPage()),
        ));
  }

  ;

  testWidgets("My rides page widget test", (WidgetTester tester) async {
    // pump my App
    await tester.pumpWidget(createWidgetForTesting());
    expect(find.text('HuskyExpress Login'), findsOneWidget);
    expect(find.text('404'), findsNothing);
    // test all text widgets are displaying as expected
    await tester.pumpAndSettle(const Duration(milliseconds: 100));
    expect(find.text('Northeastern Email or Gmail'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Forgot Password?'), findsOneWidget);
    expect(find.text('Sign Up'), findsOneWidget);

    await tester.enterText(
        find.byType(TextFormField).at(0), "athecheng1010@gmail.com");
    await tester.enterText(find.byType(TextFormField).at(1), "Yangwawa1010!");
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle(const Duration(milliseconds: 100));
    // MockFirebaseAuth auth = MockFirebaseAuth();
    // MockUserCredential userCredential = MockUserCredential();
    // when(auth.signInWithEmailAndPassword(email: "email", password: "password"))
    //     .thenAnswer((invocation) => Future.value(userCredential));
    // LoginPage loginPage = LoginPage();
    // loginPage.signIn("email", "password");
  });
}
