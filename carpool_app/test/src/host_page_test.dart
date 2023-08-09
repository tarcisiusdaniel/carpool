import 'package:carpool_app/main/host_page.dart';
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
    return const MaterialApp(title: 'Host Page', home: HostPage());
  }

  // List that helps viewing the time
  List<String> time = [
    "00",
    "01",
    "02",
    "03",
    "04",
    "05",
    "06",
    "07",
    "08",
    "09"
  ];

  testWidgets('host page ...', (tester) async {
    setupFirebaseAuthMocks();
    await Firebase.initializeApp();
    await tester.pumpWidget(createWidgetForTesting());

    // title of page
    expect(find.text("Host Page"), findsOneWidget);

    // title of each passage
    expect(find.text('Ride\'s Time and Date'), findsOneWidget);
    expect(find.text('Pick Up Information'), findsOneWidget);
    expect(find.text('Destination Address'), findsOneWidget);
    expect(find.text('Vehicle Details'), findsOneWidget);

    // header of each field
    expect(find.text('Arrival Date'), findsOneWidget);
    expect(find.text('Arrival Time'), findsOneWidget);
    expect(find.text('Address'), findsOneWidget);
    expect(find.text('Pick-up Time'), findsOneWidget);
    expect(find.text('Details'), findsOneWidget);
    expect(find.text('Car Make and Model'), findsOneWidget);
    expect(find.text('Color'), findsOneWidget);
    expect(find.text('License Plate'), findsOneWidget);
    expect(find.text('Available Seats'), findsOneWidget);
    expect(find.text("Month"), findsOneWidget);
    expect(find.text("Years"), findsOneWidget);

    // placeholder of the inputs
    expect(find.text("Date"), findsOneWidget);
    expect(find.text("Month"), findsOneWidget);
    expect(find.text("Years"), findsOneWidget);
    // expect(find.textContaining(":"), findsOneWidget);
    expect(find.text("Enter Address"), findsWidgets);
    expect(find.text("Enter Details"), findsOneWidget);
    expect(find.text("i.e. Toyota Camry"), findsOneWidget);
    expect(find.text("i.e. Yellow"), findsOneWidget);
    expect(find.text("Enter License Plate Number"), findsOneWidget);
    expect(find.text("Select a Number"), findsOneWidget);
    expect(find.text("Next"), findsOneWidget);
    expect(find.byIcon(Icons.arrow_forward_ios_rounded), findsOneWidget);

    // click the button, you will be able to see the error
    // await tester.runAsync(() async {
    await tester.tap(find.byKey(const Key("Submit Post")));
    // });

    // Rebuild the widget after the state has changed.
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // Test the Dialog
    // expect(
    //     find.text('Please complete all the questions asked.'), findsOneWidget);
    // expect(find.text("Date, Month, and Years cannot be empty"), findsOneWidget);
  });
}
