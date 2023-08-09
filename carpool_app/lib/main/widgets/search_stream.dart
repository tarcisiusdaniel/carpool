import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carpool_app/main/post_detail_page.dart';
import 'dart:core';

// SearchStream, the class that handles getting the search result for the search in LandingPage
class SearchStream extends StatefulWidget {
  // ignore: prefer_typing_uninitialized_variables
  final streamSnap;
  final double pickUpLat;
  final double pickUpLang;
  final double destLang;
  final double destLat;
  final int mileRadius;
  const SearchStream(
      {Key? key,
      required this.streamSnap,
      required this.pickUpLat,
      required this.pickUpLang,
      required this.destLat,
      required this.destLang,
      required this.mileRadius})
      : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _SearchStreamState createState() => _SearchStreamState();
}

// SearchStreamState, handles rendering the widgets and logic of filtering by mile radius
class _SearchStreamState extends State<SearchStream> {
  // the reference object to refer to the User collection in Firestore
  final CollectionReference _user =
      FirebaseFirestore.instance.collection('User');

  /// The method to get the collection of a User by the collection's id
  getUsers(String userId) async {
    var user = await _user.doc(userId).get();
    return user;
  }

  // The months list
  List<String> months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];

  // The list to help rendering time view
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

  /// The method to calculate the mile radius between two place
  /// by using the two locations' langitude and latitude
  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    // stream builder that get the snapshot of the ride post search reult
    var streamBuilder = StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: widget.streamSnap,
        builder: (BuildContext context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> streamSnapshot) {
          if (streamSnapshot.hasData) {
            // filter the data gotten based on mile radius
            var searchData = streamSnapshot.data!.docs.where((element) =>
                calculateDistance(
                        element.get("pickUpLat"),
                        element.get("pickUpLang"),
                        widget.pickUpLat,
                        widget.pickUpLang) <=
                    widget.mileRadius &&
                double.parse(element
                        .get("destinationLat")
                        .toStringAsExponential(3)) ==
                    double.parse(widget.destLat.toStringAsExponential(3)) &&
                double.parse(element
                        .get("destinationLang")
                        .toStringAsExponential(3)) ==
                    double.parse(widget.destLang.toStringAsExponential(3)));
            // the search result
            return Padding(
              padding: const EdgeInsets.only(left: 12, right: 12),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: Text('Search Result: ${searchData.length}'),
                    ),
                    SizedBox(
                        height: 450,
                        width: screenWidth * 0.0667 * 3550 / 275,
                        child: DecoratedBox(
                            decoration: const BoxDecoration(
                              color: Colors.white38,
                            ),
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // loop the search data and render all of them
                                        for (var doc in searchData)
                                          FutureBuilder(
                                            future: getUsers(
                                                doc["hosterId"].toString()),
                                            builder: (BuildContext context,
                                                AsyncSnapshot snapshot) {
                                              if (snapshot.hasData) {
                                                var hoster = snapshot.data;
                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                    top: 10,
                                                  ),
                                                  // each of the search data, clickable
                                                  child: GestureDetector(
                                                      onTap: () {
                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder: (context) =>
                                                                    PostDetailPage(
                                                                        postId: doc
                                                                            .id
                                                                            .toString())));
                                                      },
                                                      child: SizedBox(
                                                          height: 100,
                                                          width: screenWidth *
                                                              0.0667 *
                                                              3550 /
                                                              275,
                                                          child: DecoratedBox(
                                                            decoration: const BoxDecoration(
                                                                color: Color(
                                                                    0xffEEE6E6),
                                                                borderRadius: BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            5))),
                                                            child: Row(
                                                                children: [
                                                                  Padding(
                                                                    padding:
                                                                        EdgeInsets
                                                                            .only(
                                                                      left: hoster.get("photoIndex") ==
                                                                              ""
                                                                          ? 10
                                                                          : 15,
                                                                    ),
                                                                    child: hoster.get("photoIndex") ==
                                                                            ""
                                                                        ? const Icon(
                                                                            Icons
                                                                                .account_circle_rounded,
                                                                            size:
                                                                                65)
                                                                        : CircleAvatar(
                                                                            radius:
                                                                                27,
                                                                            backgroundImage:
                                                                                NetworkImage(hoster.get('photoIndex').toString()),
                                                                          ),
                                                                  ),
                                                                  Padding(
                                                                      padding: EdgeInsets.only(
                                                                          left: hoster.get("photoIndex") == ""
                                                                              ? 10
                                                                              : 15,
                                                                          right:
                                                                              10),
                                                                      child:
                                                                          SizedBox(
                                                                        width: MediaQuery.of(context).size.width *
                                                                            0.50,
                                                                        child:
                                                                            Column(
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.center,
                                                                          children: [
                                                                            // the ride date
                                                                            Text('Driver: ${hoster.get("firstName")} ${hoster.get("lastName")[0]}',
                                                                                overflow: TextOverflow.ellipsis,
                                                                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                                                            Text('${months[DateTime.fromMillisecondsSinceEpoch(doc["destinationDateTime"]).month - 1]}, ${DateTime.fromMillisecondsSinceEpoch(doc["destinationDateTime"]).day.toString()}, ${DateTime.fromMillisecondsSinceEpoch(doc["destinationDateTime"]).year.toString()}',
                                                                                overflow: TextOverflow.ellipsis,
                                                                                style: const TextStyle(fontSize: 12)),
                                                                            // ride's time

                                                                            Text('Ride\'s Time Interval: ${(DateTime.fromMillisecondsSinceEpoch(doc["pickUpDateTime"]).hour < 10) ? time[DateTime.fromMillisecondsSinceEpoch(doc["pickUpDateTime"]).hour] : DateTime.fromMillisecondsSinceEpoch(doc["pickUpDateTime"]).hour.toString()}.${(DateTime.fromMillisecondsSinceEpoch(doc["pickUpDateTime"]).minute < 10) ? time[DateTime.fromMillisecondsSinceEpoch(doc["pickUpDateTime"]).minute] : DateTime.fromMillisecondsSinceEpoch(doc["pickUpDateTime"]).minute.toString()} - ${(DateTime.fromMillisecondsSinceEpoch(doc["destinationDateTime"]).hour < 10) ? time[DateTime.fromMillisecondsSinceEpoch(doc["destinationDateTime"]).hour] : DateTime.fromMillisecondsSinceEpoch(doc["destinationDateTime"]).hour.toString()}.${(DateTime.fromMillisecondsSinceEpoch(doc["destinationDateTime"]).minute < 10) ? time[DateTime.fromMillisecondsSinceEpoch(doc["destinationDateTime"]).minute] : DateTime.fromMillisecondsSinceEpoch(doc["destinationDateTime"]).minute.toString()}',
                                                                                overflow: TextOverflow.ellipsis,
                                                                                style: const TextStyle(fontSize: 12)),

                                                                            // pick up address
                                                                            Text(
                                                                              'From: ${doc['pickUpAddr']}',
                                                                              overflow: TextOverflow.ellipsis,
                                                                              style: const TextStyle(
                                                                                fontSize: 12,
                                                                              ),
                                                                            ),

                                                                            // Destination Address
                                                                            Text(
                                                                              'To: ${doc['destinationAddr']}',
                                                                              overflow: TextOverflow.ellipsis,
                                                                              style: const TextStyle(fontSize: 12),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ))
                                                                ]),
                                                          ))),
                                                );
                                              }
                                              return const Text('');
                                            },
                                          )
                                      ]),
                                ],
                              ),
                            )))
                  ]),
            );
          }
          return const Padding(
            padding: EdgeInsets.only(top: 10.0),
            child: Center(child: CircularProgressIndicator()),
          );
        });
    return streamBuilder;
  }
}
