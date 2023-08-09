import 'package:carpool_app/app_state.dart';
import 'package:carpool_app/main/widgets/my_host_card.dart';
import 'package:carpool_app/main/widgets/ride_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:carpool_app/main/profile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'auth_pages/login_page.dart';

class RidesPage extends StatelessWidget {
  const RidesPage({super.key});

  // This widget is the my rides page widget.
  @override
  Widget build(BuildContext context) {
    String title = "My Rides Page";
    String schoolAddress =
        "Northeastern University Seattle, Terry Avenue North, Seattle, WA, USA";
    return Consumer<ApplicationState>(
      builder: (context, appState, _) => appState.loggedIn &&
              appState.userPopulated
          ? Scaffold(
              appBar: AppBar(
                title: Text(title),
                backgroundColor: Colors.red,
                actions: <Widget>[
                  IconButton(
                      key: const Key('profile-button'),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ProfilePage()));
                      },
                      icon: Icon(
                        Icons.person,
                        color: Colors.white,
                      ))
                ],
              ),
              body: SingleChildScrollView(
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: FirebaseFirestore.instance
                        .collection('ride-post')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final documents = snapshot.data!.docs;
                        return Center(
                          child: Column(
                            children: [
                              ExpansionTile(
                                title: const Text(
                                  'My Host',
                                  style: TextStyle(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.bold),
                                ),
                                textColor: Colors.red,
                                children: [
                                  ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: documents.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        final documentId = documents[index].id;
                                        final documentData =
                                            documents[index].data();
                                        final riderId =
                                            documentData['hosterId'];
                                        final now = DateTime.now();
                                        if (riderId ==
                                                FirebaseAuth.instance
                                                    .currentUser!.uid &&
                                            now.isBefore(DateTime
                                                .fromMillisecondsSinceEpoch(
                                                    documentData[
                                                        'destinationDateTime']))) {
                                          return RidesMyHostCard(
                                              hostRideData: documentData,
                                              documentId: documentId);
                                        } else {
                                          return const SizedBox.shrink();
                                        }
                                      })
                                ],
                              ),
                              ExpansionTile(
                                textColor: Colors.red,
                                title: const Text(
                                  'From Campus',
                                  style: TextStyle(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.bold),
                                ),
                                children: [
                                  ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: documents.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        final String documentId =
                                            documents[index].id;
                                        final documentData =
                                            documents[index].data();
                                        final now = DateTime.now();
                                        if (documentData['pickUpAddr'] ==
                                                schoolAddress &&
                                            now.isBefore(DateTime
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
                                              return MyRidesRideCard(
                                                myRidesData: documentData,
                                                documentId: documentId,
                                              );
                                            }
                                          }
                                        }
                                        return const SizedBox.shrink();
                                      })
                                ],
                              ),
                              ExpansionTile(
                                textColor: Colors.red,
                                title: const Text(
                                  'To Campus',
                                  style: TextStyle(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.bold),
                                ),
                                children: [
                                  ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: documents.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        final String documentId =
                                            documents[index].id;
                                        final documentData =
                                            documents[index].data();
                                        final now = DateTime.now();
                                        if (documentData['destinationAddr'] ==
                                                schoolAddress &&
                                            now.isBefore(DateTime
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
                                              return MyRidesRideCard(
                                                myRidesData: documentData,
                                                documentId: documentId,
                                              );
                                            }
                                          }
                                        }
                                        return const SizedBox.shrink();
                                      })
                                ],
                              ),
                            ],
                          ),
                        );
                      }
                      return CircularProgressIndicator();
                    }),
              ))
          : LoginPage(),
    );
  }
}
