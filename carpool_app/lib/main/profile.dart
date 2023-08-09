import 'package:carpool_app/main/widgets/host_history.dart';
import 'package:carpool_app/main/widgets/rider_history.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:io';

import 'edit_profile.dart';
import 'saved_locations.dart';
import 'ride_history.dart';

class ProfilePage extends StatefulWidget {
  // UserData user = UserData();
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePage();
}

class _ProfilePage extends State<ProfilePage> {
  late String? imageUrl;
  late File? image;

  DocumentSnapshot? _snapshot;
  late Map<String, dynamic> savedLocation;

  @override
  initState() {
    super.initState();
  }

  Future<DocumentSnapshot?> getData() async {
    try {
      _snapshot = await FirebaseFirestore.instance
          .collection("User")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();

      savedLocation = _snapshot?.get('savedLocations') as Map<String, dynamic>;

      setState(() {
        imageUrl = _snapshot?.get('photoIndex');
      });

      return _snapshot;
    } catch (e) {
      print(e);
    }
  }

  Widget build(BuildContext context) {
    String title = "Profile Page";
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(
          title: Text(title),
          backgroundColor: Colors.red,
        ),
        body: FutureBuilder(
            future: getData(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.all(60),
                    child: Column(children: [
                      Container(
                        height: width * 0.32,
                        width: width * 0.32,
                        decoration: BoxDecoration(
                            // shape: BoxShape.circle,

                            borderRadius: BorderRadius.circular(
                              width * 0.16,
                            ),
                            border: Border.all(
                              color: Colors.red,
                              width: 2,
                            )),
                        child: imageUrl != ""
                            ? CircleAvatar(
                                radius: width * 0.16,
                                backgroundImage:
                                    NetworkImage(imageUrl.toString()),
                              )
                            : const Center(
                                child: Icon(Icons.person,
                                    size: 96, color: Colors.grey)),
                      ),
                      const Padding(padding: EdgeInsets.all(10)),
                      Text(
                        snapshot.data!["firstName"],
                        style: const TextStyle(fontSize: 20),
                      ),
                      Text(
                        snapshot.data!["lastName"],
                        style: const TextStyle(fontSize: 20),
                      ),
                      const Padding(padding: EdgeInsets.all(10)),
                      SizedBox(
                          width: width * .3,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[300]),
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          EditProfilePage(_snapshot!)));
                            },
                            icon: const Icon(
                              Icons.edit,
                              color: Colors.black,
                              size: 14,
                            ),
                            label: const Text(
                              'Edit Profile',
                              style:
                                  TextStyle(fontSize: 14, color: Colors.black),
                            ),
                          )),
                      const Divider(),
                      ExpansionTile(
                          title: const Text("Saved Locations"),
                          controlAffinity: ListTileControlAffinity.leading,
                          trailing: IconButton(
                            icon: const Icon(Icons.add),
                            tooltip: 'Add a new saved location',
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          SavedLocationsPage(_snapshot!)));
                            },
                          ),
                          children: <Widget>[
                            SingleChildScrollView(
                                padding: const EdgeInsets.all(10),
                                child: Column(children: [
                                  ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: savedLocation.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        var names = savedLocation.keys.toList();
                                        return ListTile(
                                          title: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Column(
                                                children: [
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      color: Colors.grey[200],
                                                      borderRadius:
                                                          const BorderRadius
                                                                  .all(
                                                              Radius.circular(
                                                                  5)),
                                                    ),
                                                    padding: EdgeInsets.all(
                                                        width * .015),
                                                    child: SizedBox(
                                                        width: width * 0.5,
                                                        child: Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                names[index]
                                                                    .toUpperCase(),
                                                                style: const TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                              Text(savedLocation[
                                                                      names[
                                                                          index]]
                                                                  .toString()),
                                                            ])),
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                        );
                                      })
                                ])),
                          ]),
                      ExpansionTile(
                        title: const Text("Ride History"),
                        controlAffinity: ListTileControlAffinity.leading,
                        children: <Widget>[
                          SingleChildScrollView(
                              child: StreamBuilder<
                                  QuerySnapshot<Map<String, dynamic>>>(
                            stream: FirebaseFirestore.instance
                                .collection('ride-post')
                                .orderBy('destinationDateTime',
                                    descending: true)
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                final documents = snapshot.data!.docs;
                                return Center(
                                  child: Column(children: [
                                    ListView.builder(
                                        shrinkWrap: true,
                                        itemCount: documents.length,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          final documentData =
                                              documents[index].data();
                                          final documentId =
                                              documents[index].id;
                                          final riderId =
                                              documentData['hosterId'];
                                          final now = DateTime.now();
                                          if (now.isAfter(DateTime
                                              .fromMillisecondsSinceEpoch(
                                                  documentData[
                                                      'destinationDateTime']))) {
                                            for (int i = 0;
                                                i <
                                                    documentData['riderIds']
                                                        .length;
                                                i++) {
                                              if (documentData['riderIds']
                                                  .containsKey(FirebaseAuth
                                                      .instance
                                                      .currentUser!
                                                      .uid)) {
                                                return RiderHistoryCard(
                                                  myRidesData: documentData,
                                                  documentId: documentId,
                                                );
                                              }
                                            }

                                            if (riderId ==
                                                FirebaseAuth.instance
                                                    .currentUser!.uid) {
                                              return HostHistoryCard(
                                                hostRideData: documentData,
                                                documentId: documentId,
                                              );
                                            } else {
                                              return const SizedBox.shrink();
                                            }
                                          } else {
                                            return const SizedBox.shrink();
                                          }
                                        }),
                                  ]),
                                );
                              }
                              return const ListTile(title: Text('No Rides'));
                            },
                          )),
                          ListTile(
                              title: IconButton(
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                RideHistoryPage()));
                                  },
                                  tooltip: 'Ride History',
                                  icon: const Icon(Icons.more_horiz)))
                        ],
                      ),
                    ]),
                  ),
                );
              } else {
                return const SizedBox.shrink();
              }
            }));
  }
}
