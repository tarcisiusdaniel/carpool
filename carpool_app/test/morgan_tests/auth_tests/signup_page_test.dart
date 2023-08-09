import 'package:carpool_app/app_state.dart';
import 'package:carpool_app/main/auth_pages/signup_page.dart';
import 'package:carpool_app/main/auth_pages/signup_widgets/0_term_agreement.dart';
import 'package:carpool_app/main/auth_pages/signup_widgets/1_provide_email.dart';
import 'package:carpool_app/main/auth_pages/signup_widgets/2_provide_password.dart';
import 'package:carpool_app/main/auth_pages/signup_widgets/3_attemptVerify.dart';
import 'package:carpool_app/main/auth_pages/signup_widgets/4_provide_info.dart';
import 'package:carpool_app/main/auth_pages/signup_widgets/5_review_profile.dart';
import 'package:carpool_app/main/auth_pages/signup_widgets/shared_widgets.dart';
import 'package:checkbox_formfield/checkbox_formfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  UserData user = UserData();

  testWidgets('Test SignUp Page Widgets', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: SignUpPage()));

    // STEP 1 TEST
    // Verify expected widgets present
    expect(find.text('Agree to Terms of Service - Step 1 / 6'), findsOneWidget);

    final checkboxFinder = find.byType(CheckboxListTileFormField);

    expect(checkboxFinder, findsOneWidget);
  });

  // STEP 2 TEST
  testWidgets('Provide Email Page Test', (WidgetTester tester) async {
    GlobalKey<FormState> key = GlobalKey();
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: ProvideEmail(user: user, formKey: key))));

    final emptyFieldMessage = find.text('* Required Field');
    expect(emptyFieldMessage, findsWidgets);

    // Test invalid Email
    final invalidEmailMsg =
        find.text('Enter valid email (e.g. example@northeastern.edu)');
    final emailField = find.ancestor(
        of: find.text('Enter your Gmail or NEU Email Address'),
        matching: find.byType(TextFormField));
    await tester.enterText(emailField, 'invalidemail@northeastern.com');
    await tester.pump(const Duration(milliseconds: 100));
    expect(invalidEmailMsg, findsOneWidget);

    // Test invalid confirm email
    final confirmField = find.ancestor(
        of: find.text('Confirm your Email Address'),
        matching: find.byType(TextFormField));
    await tester.enterText(emailField, 'testing.levy@gmail.com');
    await tester.pump(const Duration(milliseconds: 100));
    expect(invalidEmailMsg, findsNothing);
    await tester.enterText(confirmField, 'invalidemail@northeastern.com');
    await tester.pump(const Duration(milliseconds: 100));
    expect(invalidEmailMsg, findsOneWidget);

    // Test email inputs do not match
    final nonMatchingMsg = find.text('Email inputs must Match');
    await tester.enterText(confirmField, 'testing@gmail.com');
    await tester.pump(const Duration(milliseconds: 100));
    expect(nonMatchingMsg, findsOneWidget);
    await tester.enterText(confirmField, 'testing.levy@gmail.com');
    await tester.pump(const Duration(milliseconds: 100));
    expect(nonMatchingMsg, findsNothing);

    // Test invalid nuid
    final invalidNuidMsg = find.text('Enter valid 9-digit NUID');
    final nuidField = find.ancestor(
        of: find.text('Enter your 9-digit NUID'),
        matching: find.byType(TextFormField));
    await tester.enterText(nuidField, '123');
    await tester.pump(const Duration(milliseconds: 100));
    expect(invalidNuidMsg, findsOneWidget);
    await tester.enterText(nuidField, '123456789');
    await tester.pump(const Duration(milliseconds: 100));
    expect(invalidNuidMsg, findsNothing);
  });

  // STEP 3 TEST
  testWidgets('Provide Password Page', (WidgetTester tester) async {
    GlobalKey<FormState> key = GlobalKey();
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: ProvidePassword(user: user, formKey: key))));

    final emptyFieldMessage = find.text('* Required Field');
    expect(emptyFieldMessage, findsWidgets);

    // Test invalid password format
    final invalidPwd = find.text(
        'Password must have at least 1 number, 1 letter, and 1 special character');
    final pwdField = find.ancestor(
        of: find.text('Enter your new Password'),
        matching: find.byType(TextFormField));
    await tester.enterText(pwdField, 'InvalidPwd');
    await tester.pump(const Duration(milliseconds: 100));
    expect(invalidPwd, findsOneWidget);
    await tester.enterText(pwdField, 'Alpha1!');
    await tester.pump(const Duration(milliseconds: 100));
    expect(invalidPwd, findsNothing);

    // Test non matching password inputs
    final nonmatchingPwds = find.text('Password inputs must Match');
    final confirmField = find.ancestor(
        of: find.text('Confirm your new Password'),
        matching: find.byType(TextFormField));
    await tester.enterText(confirmField, 'NonMatch1!');
    await tester.pump(const Duration(milliseconds: 100));
    expect(nonmatchingPwds, findsOneWidget);
    await tester.enterText(confirmField, 'Alpha1!');
    await tester.pump(const Duration(milliseconds: 100));
    expect(nonmatchingPwds, findsNothing);
  });

  // STEP 4 TEST
  testWidgets('Attempt Verify Page', (WidgetTester tester) async {
    GlobalKey<FormState> key = GlobalKey();
    final state = ApplicationState();
    final app = ChangeNotifierProvider(
        create: (context) => state,
        builder: ((context, child) => MaterialApp(
            home: Scaffold(body: VerifyEmail(user: user, formKey: key)))));

    await tester.pumpWidget(app);
    final sendEmailButton = find.text('Send Verification Email');
    expect(sendEmailButton, findsOneWidget);
    final lockIcon = find.byType(Icon);
    expect(lockIcon, findsOneWidget);

    final unverifiedMessage =
        find.text('Send and check your email to verify your Account');
    expect(unverifiedMessage, findsOneWidget);

    state.emailVerified = true;
    state.loggedIn = true;
    state.userPopulated = false;
    final _app = ChangeNotifierProvider(
        create: (context) => state,
        builder: ((context, child) => MaterialApp(
            home: Scaffold(body: VerifyEmail(user: user, formKey: key)))));
    await tester.pumpWidget(_app);
    final verifiedMessage =
        find.text('Congratulations, you have verified your email!');
    expect(verifiedMessage, findsOneWidget);
  });

  // STEP 5 TEST
  testWidgets('Provide Info Page', (WidgetTester tester) async {
    GlobalKey<FormState> key = GlobalKey();
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: ProvideInfo(user: user, formKey: key))));

    final emptyFieldMessage = find.text('* Required Field');
    expect(emptyFieldMessage, findsWidgets);

    // Test updated user first name
    final firstNameField = find.ancestor(
        of: find.text('First Name'), matching: find.byType(TextFormField));
    await tester.enterText(firstNameField, 'John');
    await tester.pump(const Duration(milliseconds: 100));
    expect(user.firstName, 'John');

    // Test updated user last name
    final lastNameField = find.ancestor(
        of: find.text('Last Name'), matching: find.byType(TextFormField));
    await tester.enterText(lastNameField, 'Doe');
    await tester.pump(const Duration(milliseconds: 100));
    expect(user.lastName, 'Doe');

    // Test invalid phone # format
    final phoneNoField = find.ancestor(
        of: find.text('Phone #'), matching: find.byType(TextFormField));
    final invalidPhoneFormat =
        find.text('Input does not appear to be a valid Phone No.');
    await tester.enterText(phoneNoField, '123-34@-2341');
    await tester.pump(const Duration(milliseconds: 100));
    expect(invalidPhoneFormat, findsOneWidget);
    await tester.enterText(phoneNoField, '123-345-2341');
    await tester.pump(const Duration(milliseconds: 100));
    expect(invalidPhoneFormat, findsNothing);
    // Test updated user phone
    expect(user.phoneNo, '123-345-2341');

    // Test updated user address
    final addressField = find.ancestor(
        of: find.text('Home Address'), matching: find.byType(TextFormField));
    await tester.enterText(addressField, '100 Main St., Seattle, WA, 98123');
    await tester.pump(const Duration(milliseconds: 100));
    expect(user.savedLocations, {'home': '100 Main St., Seattle, WA, 98123'});
  });

  testWidgets('Review Profile Page', (WidgetTester tester) async {
    GlobalKey<FormState> key = GlobalKey();
    user.firstName = "John";
    user.lastName = "Test";
    user.phoneNo = "555-555-5555";
    user.savedLocations = {'home': '100 Royal Vista Dr., Los Angeles, CA'};
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: ReviewProfile(user: user, formKey: key))));

    final nameValue = find.textContaining(
        'Name: ${user.firstName} ${user.lastName[0].toUpperCase()}.',
        findRichText: true);
    expect(nameValue, findsOneWidget);

    final phoneNoValue =
        find.textContaining('Phone: ${user.phoneNo}', findRichText: true);
    expect(phoneNoValue, findsOneWidget);

    final addressValue = find.textContaining(
        'Address: ${user.savedLocations['home']}',
        findRichText: true);
    expect(addressValue, findsOneWidget);
  });

  testWidgets('Navigation Test', (WidgetTester tester) async {
    UserData user = UserData();

    final state = ApplicationState();
    final signup = SignUpPage();
    final app = ChangeNotifierProvider(
        create: (context) => state,
        builder: ((context, child) =>
            MaterialApp(home: Scaffold(body: signup))));
    await tester.pumpWidget(app);

    expect(find.byType(TermAgreement), findsOneWidget);

    final backFloatButtonFinder = find.byKey(Key('backwardNav'));
    expect(backFloatButtonFinder, findsOneWidget);
    final forwardFloatButtonFinder = find.byKey(Key('forwardNav'));
    expect(forwardFloatButtonFinder, findsOneWidget);

    final checkboxFinder = find.ancestor(
        of: find.text(' I Agree to these Terms of Service'),
        matching: find.byType(CheckboxListTileFormField));

    // Test forward nav
    await tester.tap(forwardFloatButtonFinder);
    await tester.pumpAndSettle();
    expect(find.byType(ProvideEmail), findsOneWidget);
    // Test backward nav once
    await tester.tap(backFloatButtonFinder);
    await tester.pumpAndSettle();
    expect(find.byType(TermAgreement), findsOneWidget);
    // Continue on with nav through process
    await tester.tap(forwardFloatButtonFinder);
    await tester.pumpAndSettle();
    expect(find.byType(ProvideEmail), findsOneWidget);

    // Provide Email Fields
    final emailField = find.ancestor(
        of: find.text('Enter your Gmail or NEU Email Address'),
        matching: find.byType(TextFormField));
    await tester.enterText(emailField, 'testing.levy@gmail.com');
    await tester.pump(const Duration(milliseconds: 100));
    final confirmField = find.ancestor(
        of: find.text('Confirm your Email Address'),
        matching: find.byType(TextFormField));
    await tester.enterText(confirmField, 'testing.levy@gmail.com');
    await tester.pump(const Duration(milliseconds: 100));
    final nuidField = find.ancestor(
        of: find.text('Enter your 9-digit NUID'),
        matching: find.byType(TextFormField));
    await tester.enterText(nuidField, '123456789');
    await tester.pump(const Duration(milliseconds: 100));

    // Move to Provide Password and Confirm
    await tester.tap(forwardFloatButtonFinder);
    await tester.pumpAndSettle();
    expect(find.byType(ProvidePassword), findsOneWidget);
    final pwdField = find.ancestor(
        of: find.text('Enter your new Password'),
        matching: find.byType(TextFormField));
    await tester.enterText(pwdField, 'Alpha1!');
    await tester.pump(const Duration(milliseconds: 100));
    final confirmPwdField = find.ancestor(
        of: find.text('Confirm your new Password'),
        matching: find.byType(TextFormField));
    await tester.enterText(confirmPwdField, 'Alpha1!');
    await tester.pump(const Duration(milliseconds: 100));
  });
}
