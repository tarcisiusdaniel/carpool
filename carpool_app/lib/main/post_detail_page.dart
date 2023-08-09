import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'messages_page.dart';

// PostDetailPage, the page that will show the information of a post ride
class PostDetailPage extends StatefulWidget {
  final String postId;
  const PostDetailPage({Key? key, required this.postId}) : super(key: key);

  @override
  PostDetailPageState createState() => PostDetailPageState();
}

// PostDetailPageState, the class that renders the widgets and logics behind PostDetailPage
class PostDetailPageState extends State<PostDetailPage> {
  /// Load the API keys in the .env file
  loadEnv() async {
    await dotenv.load(fileName: "lib/.env");
    return dotenv.env;
  }

  // the reference object to the ride-post collection
  final CollectionReference _ridePost =
      FirebaseFirestore.instance.collection('ride-post');

  // the reference object to the User collection
  final CollectionReference _user =
      FirebaseFirestore.instance.collection('User');

  // the states of the ride post
  bool? _rideCompleted; // if the ride is completed or not
  DocumentSnapshot? onViewPost; // get the ride post data
  DocumentSnapshot? hoster; // get the ride post's hoster data
  LatLng pickUpLatLng =
      const LatLng(37.02153213, -122.06747172); // the lat and lang for pick up
  LatLng destLatLng = const LatLng(
      37.03645724, -122.01367812); // the lat and lang for destination
  bool userRequested = false; // the request from the user to join the ride

  /// The method to get the collection of a ride post by using its id
  getCurrPost(String postId) async {
    var currPost = await _ridePost.doc(postId).get();
    return currPost;
  }

  /// The method to get the collection of a User by using its id
  getCurrHoster(String hosterId) async {
    var hoster = await _user.doc(hosterId).get();
    return hoster;
  }

  /// The method to get the snapshot of the user by using the user id
  Future<DocumentSnapshot<Map<String, dynamic>>> getUserInfo(
      String userId) async {
    DocumentSnapshot<Map<String, dynamic>> snapshot =
        await FirebaseFirestore.instance.collection('User').doc(userId).get();
    return snapshot;
  }

  /// The method to add the user as the rider
  Future<void> _addRider() async {
    // update using our new map

    final docRef = _ridePost.doc(widget.postId);
    final docSnapshot = await docRef.get();
    if (docSnapshot.exists) {
      await docRef.update({
        'riderIds.${FirebaseAuth.instance.currentUser!.uid.toString()}':
            "pending",
      });
    } else {
      print('Document does not exist');
    }
  }

  /// The method to mark the ride post as completed
  /// Can only be done by the hoster
  Future<void> _completeRide() async {
    // update using our new map

    final docRef = _ridePost.doc(widget.postId);
    final docSnapshot = await docRef.get();
    if (docSnapshot.exists) {
      await docRef.update({
        'completed': true,
      });
    } else {
      print('Document does not exist');
    }
  }

  // List of the months
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

  // All the variables necessary for Google Maps map view
  List<LatLng> polylineCoor = [];

  /// Get the Google Map API key and use it to make lines between
  /// the pick up and destination location in map
  void getPolyPointsWithEnv() async {
    loadEnv().then((env) {
      getPolyPoints(env['GOOGLE_MAP_API_KEY']);
    });
  }

  /// Get the points of the pick up and destination address
  /// To make the line for the route between them
  void getPolyPoints(String apiKey) async {
    PolylinePoints polylinePoints = PolylinePoints();

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        apiKey,
        PointLatLng(pickUpLatLng.latitude, pickUpLatLng.longitude),
        PointLatLng(destLatLng.latitude, destLatLng.longitude));

    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) => polylineCoor.add(
            LatLng(point.latitude, point.longitude),
          ));
      setState(() {});
    }
  }

  // animation controller
  late AnimationController ac;

  // initiate the initial state
  @override
  initState() {
    getCurrPost(widget.postId).then((postVal) {
      setState(() {
        onViewPost = postVal;
        _rideCompleted = onViewPost!.get("completed");
      });
      getCurrHoster(postVal.get("hosterId")).then((hosterVal) {
        setState(() {
          hoster = hosterVal;
        });
      });

      pickUpLatLng =
          LatLng(postVal.get("pickUpLat"), postVal.get("pickUpLang"));
      destLatLng =
          LatLng(postVal.get("destinationLat"), postVal.get("destinationLang"));

      getPolyPointsWithEnv();
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String title = "Post Detail Page";

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    if (onViewPost == null || hoster == null) {
      return Scaffold(
          appBar: AppBar(
            title: Text(title),
            backgroundColor: Colors.red,
          ),
          body: const Center(
            child: Text('Loading...'),
          ));
    } else {
      return Scaffold(
          appBar: AppBar(
            title: Text(title),
            backgroundColor: Colors.red,
          ),
          body: SingleChildScrollView(
              child: Center(
                  child: Padding(
            padding: const EdgeInsets.only(
              top: 10,
              bottom: 10,
            ),
            child: Column(children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 15),
                // the google map showing gthe place of pick up and destination
                child: SizedBox(
                  width: screenWidth * 0.0665 * 3650 / 275,
                  height: screenHeight * 0.007 * 36.2,
                  child: GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: pickUpLatLng,
                        zoom: 11.0,
                      ),
                      polylines: {
                        Polyline(
                          polylineId: const PolylineId("route"),
                          points: polylineCoor,
                          color: Colors.blue,
                          width: 3,
                        )
                      },
                      markers: {
                        Marker(
                          markerId: const MarkerId("Pick Up"),
                          position: pickUpLatLng,
                        ),
                        Marker(
                          markerId: const MarkerId("Destination"),
                          position: destLatLng,
                        ),
                      }),
                ),
              ),
              // the information of the hosters
              SizedBox(
                  width: screenWidth * 0.0665 * 3650 / 275,
                  height: (FirebaseAuth.instance.currentUser!.uid.toString() ==
                          onViewPost!.get("hosterId"))
                      ? screenHeight * 0.007 * 130
                      : screenHeight * 0.007 * 130,
                  child: DecoratedBox(
                      decoration: const BoxDecoration(
                          color: Color(0xffEEE6E6),
                          borderRadius: BorderRadius.all(Radius.circular(5))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                              padding: const EdgeInsets.only(
                                bottom: 25,
                                left: 20,
                                top: 20,
                                right: 20,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        const Text('Host:',
                                            key: Key("Host"),
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold)),
                                        Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 10),
                                            child: Text(
                                                '${hoster!.get("firstName")} ${hoster!.get("lastName")[0].toUpperCase()}',
                                                style: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.bold))),
                                        Text(
                                            'Rides hosted: ${hoster!.get("rideIds").length}') // need to be fixed
                                      ]),
                                  Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        hoster!.get("photoIndex") == ""
                                            ? const Icon(
                                                Icons.account_circle_rounded,
                                                size: 119,
                                              )
                                            : Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 10,
                                                    bottom: 10,
                                                    left: 10,
                                                    right: 10),
                                                child: CircleAvatar(
                                                  radius: 49.5,
                                                  backgroundImage: NetworkImage(
                                                      hoster!
                                                          .get("photoIndex")
                                                          .toString()),
                                                ), // user profile
                                              ),
                                        // if the user is not the driver,render contact button
                                        if (FirebaseAuth
                                                .instance.currentUser!.uid
                                                .toString() !=
                                            onViewPost!
                                                .get("hosterId")
                                                .toString())
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    const Color.fromARGB(
                                                        255, 171, 163, 163),
                                                fixedSize:
                                                    const Size(110.0, 25.0)),
                                            onPressed: () {
                                              // check if the driver has requested for a ride (at least)
                                              if (onViewPost!
                                                  .get("riderIds")
                                                  .containsKey(FirebaseAuth
                                                      .instance.currentUser!.uid
                                                      .toString())) {
                                                // check if the user is already accepted to the ride
                                                if (onViewPost!.get("riderIds")[
                                                        FirebaseAuth.instance
                                                            .currentUser!.uid
                                                            .toString()] ==
                                                    "accepted") {
                                                  // go to the chat with the driver

                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder:
                                                              (_) =>
                                                                  MessagesPage(
                                                                    peerId:
                                                                        // the id of the person you want to chat with (the driver)
                                                                        onViewPost!
                                                                            .get("hosterId"),
                                                                    peerNickname:
                                                                        hoster!.get(
                                                                            "firstName"),
                                                                    // the first name of the person you want to chat with (the driver)
                                                                  )));
                                                } else {
                                                  // show dialog that his request is still pending
                                                  showDialog(
                                                    context: context,
                                                    builder: (context) {
                                                      return Dialog(
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5)),
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(15.0),
                                                            child: Column(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: <
                                                                  Widget>[
                                                                const Text(
                                                                    'Your request is still pending. Unable to contact the driver.'),
                                                                const SizedBox(
                                                                    height: 15),
                                                                Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .end,
                                                                    children: [
                                                                      TextButton(
                                                                        onPressed:
                                                                            () {
                                                                          Navigator.pop(
                                                                              context);
                                                                        },
                                                                        child:
                                                                            const Text(
                                                                          'Close',
                                                                        ),
                                                                      ),
                                                                    ]),
                                                              ],
                                                            ),
                                                          ));
                                                    },
                                                  );
                                                }
                                              } else {
                                                // show dialog that he is not a rider yet
                                                showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    return Dialog(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            5)),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(15.0),
                                                          child: Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: <Widget>[
                                                              const Text(
                                                                  'You are not an accepted or pending rider to this ride. Unable to contact the driver.'),
                                                              const SizedBox(
                                                                  height: 15),
                                                              Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .end,
                                                                  children: [
                                                                    TextButton(
                                                                      onPressed:
                                                                          () {
                                                                        Navigator.pop(
                                                                            context);
                                                                      },
                                                                      child:
                                                                          const Text(
                                                                        'Close',
                                                                      ),
                                                                    ),
                                                                  ]),
                                                            ],
                                                          ),
                                                        ));
                                                  },
                                                );
                                              }
                                            },
                                            child: const Text('Contact Driver',
                                                style: TextStyle(fontSize: 12)),
                                          )
                                      ]),
                                ],
                              )),
                          // the information of the rides
                          Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(bottom: 20),
                                    child: Text('Carpools Details',
                                        style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                  Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 15),
                                      child: Text(
                                          'Date: ${months[DateTime.fromMillisecondsSinceEpoch(onViewPost!.get("pickUpDateTime")).month]} ${DateTime.fromMillisecondsSinceEpoch(onViewPost!.get("pickUpDateTime")).day.toString()}, ${DateTime.fromMillisecondsSinceEpoch(onViewPost!.get("pickUpDateTime")).year.toString()}')),
                                  Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 15),
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                                'Pick Up Location: ${onViewPost!.get("pickUpAddr")}'),
                                            Text(
                                                'Pick Up Time: ${(DateTime.fromMillisecondsSinceEpoch(onViewPost!.get("pickUpDateTime")).hour < 10) ? time[DateTime.fromMillisecondsSinceEpoch(onViewPost!.get("pickUpDateTime")).hour] : DateTime.fromMillisecondsSinceEpoch(onViewPost!.get("pickUpDateTime")).hour.toString()}.${(DateTime.fromMillisecondsSinceEpoch(onViewPost!.get("pickUpDateTime")).minute < 10) ? time[DateTime.fromMillisecondsSinceEpoch(onViewPost!.get("pickUpDateTime")).minute] : DateTime.fromMillisecondsSinceEpoch(onViewPost!.get("pickUpDateTime")).minute.toString()}')
                                          ])),
                                  Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 15),
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                                'Destination: ${onViewPost!.get("destinationAddr")}'),
                                            Text(
                                                'Arrival Time: ${(DateTime.fromMillisecondsSinceEpoch(onViewPost!.get("destinationDateTime")).hour < 10) ? time[DateTime.fromMillisecondsSinceEpoch(onViewPost!.get("destinationDateTime")).hour] : DateTime.fromMillisecondsSinceEpoch(onViewPost!.get("destinationDateTime")).hour.toString()}.${(DateTime.fromMillisecondsSinceEpoch(onViewPost!.get("destinationDateTime")).minute < 10) ? time[DateTime.fromMillisecondsSinceEpoch(onViewPost!.get("destinationDateTime")).minute] : DateTime.fromMillisecondsSinceEpoch(onViewPost!.get("destinationDateTime")).minute.toString()}')
                                          ])),
                                  Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 30),
                                      child: Text(
                                          'Notes on Pick Up: ${onViewPost!.get("pickUpDetails").toString()}')),
                                  const Padding(
                                    padding: EdgeInsets.only(bottom: 20),
                                    child: Text('Vehicle Details',
                                        style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                  Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 15),
                                      child: Text(
                                          'Vehicle: ${onViewPost!.get("carColor")} ${onViewPost!.get("carMakeAndModel")}')),
                                  Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 15),
                                      child: Text(
                                          'License Plate: ${onViewPost!.get("carLicensePlate")}')),
                                  // if current user is the driver, render the button
                                  if (FirebaseAuth.instance.currentUser!.uid
                                          .toString() ==
                                      onViewPost!.get("hosterId").toString())
                                    Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 10),
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  const Color.fromARGB(
                                                      255, 171, 163, 163),
                                              fixedSize:
                                                  const Size(120.0, 25.0)),
                                          onPressed: _rideCompleted!
                                              ? null
                                              : () async {
                                                  _completeRide();
                                                  setState(() {
                                                    _rideCompleted =
                                                        !_rideCompleted!;
                                                  });
                                                },
                                          child: (_rideCompleted == true)
                                              ? const Text('Ride Completed',
                                                  style:
                                                      TextStyle(fontSize: 12))
                                              : const Text('Mark Complete',
                                                  style:
                                                      TextStyle(fontSize: 12)),
                                        ))
                                ],
                              )),
                        ],
                      ))),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: SizedBox(
                    width: screenWidth * 0.067 * 3650 / 275,
                    height: screenHeight * 0.007 * 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 11, top: 5, bottom: 10),
                          child: Text(
                            'Remaining Ride Capacity: ${onViewPost!.get("availableSeats") - onViewPost!.get("riderIds").values.where((v) => v.toString() == "accepted").length}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Padding(
                            padding: const EdgeInsets.only(
                                top: 0, left: 11, right: 11),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    for (MapEntry<String, dynamic> rider
                                        in onViewPost!.get("riderIds").entries)
                                      if (rider.value.toString() == "accepted")
                                        // get the photoIndex of the rider using rider.key.toString()
                                        // if (refers to photoindex of the user in each map) == ''
                                        // render the icon
                                        FutureBuilder<
                                            DocumentSnapshot<
                                                Map<String, dynamic>>>(
                                          future:
                                              getUserInfo(rider.key.toString()),
                                          builder: (BuildContext context,
                                              AsyncSnapshot<
                                                      DocumentSnapshot<
                                                          Map<String, dynamic>>>
                                                  snapshot) {
                                            if (snapshot.hasData) {
                                              // print(snapshot.data!.data());
                                              Map<String, dynamic> userInfo =
                                                  snapshot.data!.data()!;
                                              if (userInfo['photoIndex'] !=
                                                  "") {
                                                return GestureDetector(
                                                  onLongPress: () {},
                                                  child: CircleAvatar(
                                                    radius: 20.5,
                                                    backgroundImage:
                                                        NetworkImage(userInfo[
                                                                'photoIndex']
                                                            .toString()),
                                                  ),
                                                );
                                              } else {
                                                return GestureDetector(
                                                    child: const Icon(
                                                        Icons
                                                            .account_circle_rounded,
                                                        size: 49),
                                                    onLongPress: () {
                                                      print('ngentot');
                                                    });
                                              }
                                            }
                                            return const CircularProgressIndicator();
                                          },
                                        ),

                                    // if the ride is full, do not render the button
                                    // if both are false, render the button
                                    // the ride is full
                                    if (onViewPost!.get("availableSeats") -
                                                onViewPost!
                                                    .get("riderIds")
                                                    .values
                                                    .where((v) =>
                                                        v.toString() ==
                                                        "accepted")
                                                    .length >
                                            0 &&
                                        !(onViewPost!
                                            .get("riderIds")
                                            .containsKey(FirebaseAuth
                                                .instance.currentUser!.uid
                                                .toString())) &&
                                        !userRequested &&
                                        FirebaseAuth.instance.currentUser!.uid
                                                .toString() !=
                                            onViewPost!
                                                .get("hosterId")
                                                .toString())
                                      GestureDetector(
                                        child: const Icon(
                                            Icons.add_circle_outline,
                                            size: 49),
                                        onTap: () async {
                                          setState(() {
                                            userRequested = true;
                                          });
                                          _addRider();
                                          showDialog(
                                            context: context,
                                            builder: (context) {
                                              return Dialog(
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5)),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            15.0),
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: <Widget>[
                                                        const Text(
                                                            'Request sent.'),
                                                        const SizedBox(
                                                            height: 15),
                                                        Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .end,
                                                            children: [
                                                              TextButton(
                                                                onPressed: () {
                                                                  Navigator.pop(
                                                                      context);
                                                                },
                                                                child:
                                                                    const Text(
                                                                  'Close',
                                                                ),
                                                              ),
                                                            ]),
                                                      ],
                                                    ),
                                                  ));
                                            },
                                          );
                                          // }
                                        },
                                      ),
                                  ],
                                ),
                              ],
                            )),
                      ],
                    )),
              ),
            ]),
          ))));
    }
  }
}
