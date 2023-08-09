import 'package:cloud_firestore/cloud_firestore.dart';

/// delete existing ride
Future<void> deleteExistingRide(String documentId) async {
  final docRef =
      FirebaseFirestore.instance.collection('ride-post').doc(documentId);
  final docSnapshot = await docRef.get();
  if (docSnapshot.exists) {
    await docRef.delete();
  } else {
    print('Document does not exist');
  }
}

///delete existing rider
Future<void> deleteExistingRider(String documentId, String? riderId) async {
  final docRef =
      FirebaseFirestore.instance.collection('ride-post').doc(documentId);
  final docSnapshot = await docRef.get();
  if (docSnapshot.exists) {
    await docRef.update({
      'riderIds.$riderId': FieldValue.delete(),
    });
  } else {
    print('Document does not exist');
  }
}
