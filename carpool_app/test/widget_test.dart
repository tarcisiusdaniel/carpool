// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:developer';

import 'package:carpool_app/app_state.dart';
import 'package:carpool_app/firebase_options.dart';
import 'package:carpool_app/main/auth_pages/login_page.dart';
import 'package:carpool_app/main/landing_page.dart';
import 'package:carpool_app/main/main_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:carpool_app/main.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('Test open app when not logged in', (WidgetTester tester) async {
    // Widget app = const MyApp();
    final state = ApplicationState();
    final app = ChangeNotifierProvider(
        create: (context) => state, builder: (context, child) => const MyApp());
    // Build our app and trigger a frame.
    await tester.pumpWidget(app);
    expect(find.byType(MyHomePage), findsOneWidget);
    expect(find.byType(LoginPage), findsOneWidget);
  });

  testWidgets('Test open app when logged in', (WidgetTester tester) async {
    // Widget app = const MyApp();
    final state = ApplicationState();
    state.loggedIn = true;
    state.userPopulated = true;
    final app = ChangeNotifierProvider(
        create: (context) => state, builder: (context, child) => const MyApp());
    // Build our app and trigger a frame.
    await tester.pumpWidget(app);
    expect(find.byType(MyHomePage), findsOneWidget);
    expect(find.byType(LoginPage), findsNothing);
    expect(find.byType(MainPage), findsOneWidget);
    expect(find.byType(LandingPage), findsOneWidget);
  });
}
