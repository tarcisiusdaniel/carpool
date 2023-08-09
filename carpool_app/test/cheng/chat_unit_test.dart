import 'package:carpool_app/main/auth_pages/login_page.dart';
import 'package:carpool_app/main/chat_page.dart';
import 'package:carpool_app/main/utils/chat_page_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'chat_unit_test.mocks.dart';
import 'mock.dart';

@GenerateMocks([
  FirebaseFirestore,
  CollectionReference,
  DocumentReference,
  DocumentSnapshot,
  FirebaseApp,
  FirebaseAuth,
  User,
  UserCredential
])
void main() {
  setupFirebaseAuthMocks();
  group('updateRideStatus', () {
    late MockFirebaseApp app;
    late MockFirebaseFirestore instance;
    late MockDocumentSnapshot<Map<String, dynamic>> documentSnapshot;
    late MockCollectionReference<Map<String, dynamic>> collectionReference;
    late MockDocumentReference<Map<String, dynamic>> docReference;
    final documentId = 'testDocumentId';
    final riderId = 'testRiderId';
    final status = 'pending';

    setUp(() async {
      instance = MockFirebaseFirestore();
      documentSnapshot = MockDocumentSnapshot();
      collectionReference = MockCollectionReference();
      docReference = MockDocumentReference();
      when(instance.collection('ride-post')).thenReturn(collectionReference);
    });
    // test('update ride status correctly', () async {
    //   await Firebase.initializeApp();
    //   // set up mocks for the test
    //   // call the function being tested
    //   when(collectionReference.doc(documentId)).thenReturn(docReference);
    //   when(docReference.get()).thenAnswer((_) async => documentSnapshot);
    //   when(documentSnapshot.exists).thenReturn(true);
    //   await updateRideStatus(documentId, riderId, status);

    //   verify(collectionReference.doc(documentId)).called(1);
    //   verify(docReference.get()).called(1);
    //   verify(docReference.update({
    //     'riderIds.$riderId': FieldValue.delete(),
    //     'riderIds.$riderId': status
    //   })).called(1);
    // });

    test('getFormattedTime should return properly formatted date string',
        () async {
      const millisecondsSinceEpoch = 1620000000000;
      final formattedDate = getFormattedTime(millisecondsSinceEpoch);
      expect(formattedDate, 'Mon, 12 AM, May 3');
    });

    test(
        'getFormattedTimeWithYear should return properly formatted date string',
        () async {
      const millisecondsSinceEpoch = 1682113245835;
      final formattedDate = getFormattedTimeWithYear(millisecondsSinceEpoch);
      expect(formattedDate, 'Fri, 9 PM, Apr 21 2023');
    });
  });
}
