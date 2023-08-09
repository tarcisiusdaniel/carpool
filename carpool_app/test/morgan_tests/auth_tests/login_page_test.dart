import 'package:carpool_app/main/auth_pages/forgot_password.dart';
import 'package:carpool_app/main/auth_pages/login_page.dart';
import 'package:carpool_app/main/auth_pages/signup_page.dart';
import 'package:carpool_app/main/main_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
// Testing dependencies
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in_mocks/google_sign_in_mocks.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import '../../user_profile_test/user_profile_test.dart';

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() {
  group('Login Page Tests', () {
    testWidgets('Test Login Page Widgets', (WidgetTester tester) async {
      // Widget login = LoginPage();
      // await tester.pumpWidget(MaterialApp(home: login));

      final mockObserver = MockNavigatorObserver();
      // Specify routing for button nav
      await tester.pumpWidget(MaterialApp(
        initialRoute: '/sign-in',
        routes: {
          '/sign-in': (context) => LoginPage(),
          '/home': (context) => MainPage(),
          '/sign-up': (context) => SignUpPage(),
          '/sign-in/forgot-password': (context) => ForgotPasswordPage()
        },
        navigatorObservers: [mockObserver],
      ));
      // Verify expected detail and struct widgets loaded
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.text('HuskyExpress Login'), findsOneWidget);
      expect(find.text('Welcome to HuskyExpress!'), findsOneWidget);

      // Find the Login Button
      final loginButtonFinder = find.text('Login');

      // Test that empty fields and Login Press return empty field error message
      final emptyFieldMsgFinder = find.text('* Required Field');
      await tester.tap(loginButtonFinder);
      await tester.pump(const Duration(milliseconds: 100));
      expect(emptyFieldMsgFinder, findsWidgets);

      // Test that invalid email and Login Press return invalid email error message
      final invalidEmailMsgFinder =
          find.text("Enter a valid NEU Email or Gmail Address");
      final emailField = find.ancestor(
          of: find.text('Northeastern Email or Gmail'),
          matching: find.byType(TextFormField));
      await tester.enterText(emailField, 'invalidemail@northeastern.com');
      await tester.tap(loginButtonFinder);
      await tester.pump(const Duration(milliseconds: 100));
      expect(invalidEmailMsgFinder, findsOneWidget);

      // Test that invalid password and Login Press return invalid pwd error message
      final invalidPasswordMsgFinder =
          find.text("* At least 1 letter, 1 number, and 1 special character");
      final passwordField = find.ancestor(
          of: find.text('Password'), matching: find.byType(TextFormField));
      await tester.enterText(passwordField, 'InvalidPwd');
      await tester.tap(loginButtonFinder);
      await tester.pump(const Duration(milliseconds: 100));
      expect(invalidPasswordMsgFinder, findsOneWidget);

      // Test valid email and password fields
      await tester.enterText(emailField, 'testing.levy@gmail.com');
      await tester.enterText(passwordField, 'Alpha1!');
      await tester.pump(const Duration(milliseconds: 100));
      expect(emptyFieldMsgFinder, findsNothing);
      expect(invalidEmailMsgFinder, findsNothing);
      expect(invalidPasswordMsgFinder, findsNothing);

      // Find the forgot password button
      // final forgotPwdButtonFinder = find.text('Forgot Password?');

      // // Find the signup button
      // final signupButtonFinder = find.text('Sign Up');

      // // verify changed page
      // await tester.tap(loginButtonFinder);
      // await tester.pumpAndSettle();
      // verify(mockObserver.didPush());
    });
  });
}
