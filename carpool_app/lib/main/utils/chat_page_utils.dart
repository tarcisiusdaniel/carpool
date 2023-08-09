import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

/// Returns a formatted date string
String getFormattedTime(int millisecondsSinceEpoch) {
  String formattedDate = "";
  DateTime dateTime =
      DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch);
  formattedDate = DateFormat('E, h a, MMM d').format(dateTime);
  return formattedDate;
}

/// Returns a formatted date string with year
String getFormattedTimeWithYear(int millisecondsSinceEpoch) {
  String formattedDate = "";
  DateTime dateTime =
      DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch);
  formattedDate = DateFormat('E, h a, MMM d y').format(dateTime);
  return formattedDate;
}

///update ride status
Future<void> updateRideStatus(
    String documentId, String? riderId, String status) async {
  final docRef =
      FirebaseFirestore.instance.collection('ride-post').doc(documentId);
  final docSnapshot = await docRef.get();
  if (docSnapshot.exists) {
    await docRef.update({
      'riderIds.$riderId': FieldValue.delete(),
      'riderIds.$riderId': status
    });
  } else {
    print('Document does not exist');
  }
}

/// Returns a list of documents that match the filter
Future<List<DocumentSnapshot>> getDocumentsByFilter(
    String collectionPath, String fieldName, dynamic filterValue) async {
  QuerySnapshot querySnapshot = await FirebaseFirestore.instance
      .collection(collectionPath)
      .where(fieldName, isEqualTo: filterValue)
      .get();
  List<DocumentSnapshot> documents = querySnapshot.docs;
  return documents;
}
