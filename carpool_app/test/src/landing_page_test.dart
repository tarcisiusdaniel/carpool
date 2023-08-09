import 'package:carpool_app/main/landing_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'dart:math';

import 'package:carpool_app/app_state.dart';
import 'package:carpool_app/main.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../cheng/mock.dart';

void main() {
  Widget createWidgetForTesting() {
    return const MaterialApp(title: 'Landing Page', home: LandingPage());
  }

  testWidgets('landing page ...', (tester) async {
    // TODO: Implement test
    setupFirebaseAuthMocks();
    await Firebase.initializeApp();
    await tester.pumpWidget(createWidgetForTesting());

    expect(find.text("Landing Page"), findsOneWidget);
    expect(find.byIcon(Icons.person), findsOneWidget);
    // expect(find.text("Upcoming Rides"), findsOneWidget);
    expect(find.text("Search for a Carpool!"), findsOneWidget);
    expect(find.text("Mile Radius: "), findsOneWidget);
    expect(find.text("Ride Date: "), findsOneWidget);
    expect(find.text("Pick Up Address: "), findsOneWidget);
    expect(find.text("Pick Up Time: "), findsOneWidget);
    expect(find.text("Destination Address:"), findsOneWidget);
    expect(find.text("Destination Time: "), findsOneWidget);
    expect(find.text(" to "), findsWidgets);
    expect(find.text("Search"), findsOneWidget);
    expect(find.text("---"), findsOneWidget);
  });
}
