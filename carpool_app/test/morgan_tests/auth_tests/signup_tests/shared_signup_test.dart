import 'dart:ui';

import 'package:carpool_app/main/auth_pages/signup_widgets/shared_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('SignUp Title test', (WidgetTester wt) async {
    Widget titleWidget = const Scaffold(body: SignupTitle('title', 'subtitle'));
    await wt.pumpWidget(MaterialApp(home: titleWidget));

    expect(find.text('title'), findsOneWidget);
    expect(find.text('subtitle'), findsOneWidget);
  });

  test('UserData init test', () {
    UserData data = UserData();
    expect(data.userDocId, '');
    expect(data.email, '');
    expect(data.nuid, '');
    expect(data.password, '');
    expect(data.agreedToTerms, true);
    expect(data.emailVerified, false);
    expect(data.photoInd, '');
    expect(data.firstName, '');
    expect(data.lastName, '');
    expect(data.phoneNo, '');
    expect(data.isHostAccount, false);
    expect(data.pfpId, '');
    expect(data.savedLocations, {});
    expect(data.rideIds, []);
  });
}
