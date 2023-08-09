import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> addRider(String documentId, String riderId) async {
  try {
    final DocumentReference documentReference =
        FirebaseFirestore.instance.collection('ride-post').doc(documentId);

    final DocumentSnapshot documentSnapshot = await documentReference.get();
    if (!documentSnapshot.exists) {
      return;
    }

    Map<String, dynamic> documentData =
        documentSnapshot.data() as Map<String, dynamic>;

    final Map<String, dynamic> existingMap = documentData['riderIds'];

    final Map<String, dynamic> updatedMap = Map.from(existingMap)
      ..addAll({riderId: "pending"});

    await documentReference.update({'riderIds': updatedMap});

    print('Document updated successfully.');
  } catch (error) {
    print('Failed to update document: $error');
  }
}
