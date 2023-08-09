import 'package:carpool_app/main/auth_pages/forgot_password.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:google_sign_in_mocks/google_sign_in_mocks.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockUserCredential extends Mock implements UserCredential {}

class MockUser extends Mock implements User {}

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

void main() {
  testWidgets('Forgot Password Page Test', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: ForgotPasswordPage()));

    final titleMsg =
        find.text('Oh No!\n Looks like your forgot your Password!');
    expect(titleMsg, findsOneWidget);

    final sendButtonMsg = find.text('Send Password Reset Email');
    expect(sendButtonMsg, findsOneWidget);

    final signupButtonMsg = find.text('Back to Sign-In');
    expect(signupButtonMsg, findsOneWidget);

    final provideEmailMsg =
        find.text('* Must provide your email to reset your password');
    expect(provideEmailMsg, findsOneWidget);

    // Test invalid email
    final emailField = find.ancestor(
        of: find.text('Email Address'), matching: find.byType(TextFormField));
    final invalidEmailMsg = find.text('Provided Email format is invalid');
    await tester.enterText(emailField, 'invalid@northeastern.com');
    await tester.pump(const Duration(milliseconds: 100));
    expect(invalidEmailMsg, findsOneWidget);
    // Test valid email
    await tester.enterText(emailField, 'testing.levy@gmail.com');
    await tester.pump(const Duration(milliseconds: 100));
    expect(invalidEmailMsg, findsNothing);
  });
}
