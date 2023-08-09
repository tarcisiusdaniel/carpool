import 'package:carpool_app/main/edit_profile.dart';
import 'package:carpool_app/main/profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

class MockFirestore extends Mock implements FirebaseFirestore {}

void main() {
  testWidgets('User Profile Page Test', (WidgetTester tester) async {
    // Initialize fields
    final mockObserver = MockNavigatorObserver();
    final test_firebase_model = {
      "email": "test@gmail.com",
      "firstName": 'John',
      "homeAddress": '555 Testing Avenue',
      "lastName": 'Doe',
      "pfpif": 1,
      "phoneNumber": 20612345657,
      "photoIndex": "testing_url",
      "rideIds": {0: 1, 1: 2},
      "savedLocations": {
        'home': "555 Testing Avenue",
        "school": "555 School Avenue"
      }
    };

    // final instance = MockFirestore();
    // // await instance.collection('Users').doc('test_doc').set(test_firebase_model);
    // // final test_snapshot =
    // //     await instance.collection('Users').doc('test_doc').get();

    // await tester.pumpWidget(MaterialApp(
    //   home: const ProfilePage(),
    //   navigatorObservers: [mockObserver],
    // ));

    // // Test Edit Profile Button Navigator
    // expect(
    //     find.byType(
    //       ElevatedButton,
    //     ),
    //     findsOneWidget);
    // await tester.tap(find.byType(ElevatedButton));
    // await tester.pumpAndSettle();

    // verify(mockObserver.didPush(
    //     MaterialPageRoute(builder: (context) => EditProfilePage(test_snapshot)),
    //     MaterialPageRoute(builder: (context) => const ProfilePage())));

    // expect(find.byType(EditProfilePage), findsOneWidget);
  });
}
