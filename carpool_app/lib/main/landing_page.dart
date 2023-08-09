import 'dart:math';

import 'package:carpool_app/main/profile.dart';
import 'package:carpool_app/main/widgets/my_host_card.dart';
import 'package:carpool_app/main/widgets/ride_card.dart';
import 'package:carpool_app/main/widgets/rider_history.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:carpool_app/main/widgets/search_stream.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:google_maps_webservice/places.dart';
import 'dart:core';

import 'package:time_picker_spinner_pop_up/time_picker_spinner_pop_up.dart';
import 'package:flutter/cupertino.dart';

// LandingPage, the page that will be shown after logging in or signing up
class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  _LandingPageState createState() => _LandingPageState();
}

// LandingPageState, the class that renders the widgets and logics behind LandingPage
class _LandingPageState extends State<LandingPage> {
  /// Title of the Page
  String title = "Landing Page";

  /// Boolean to dictate whether to start search and display results
  bool _startSearch = false;

  /// Loads the API key(s) inside the .env file
  void loadEnv() async {
    await dotenv.load(fileName: "lib/.env");
  }

  /// The ScrollController for landing page
  ScrollController sc = ScrollController();

  /// The method to filter the search
  /// from the snapshot gotten from the ride post collection
  _getSearchResults() {
    /// The reference object to collect to the ride post
    CollectionReference _ridePost =
        FirebaseFirestore.instance.collection('ride-post');

    // filter the search
    // based on pick up location, done
    // based on destination location, done
    // based on the range of pick up time
    // based on the range of destination time
    // based on the range of mile radius
    // the pick up date time cannot be less than the current date time
    DateTime pickUpFrom = DateTime(_rideDate!.year, _rideDate!.month,
        _rideDate!.day, _pickUpTimeFrom!.hour, _pickUpTimeFrom!.minute);
    DateTime pickUpTo = DateTime(_rideDate!.year, _rideDate!.month,
        _rideDate!.day, _pickUpTimeTo!.hour, _pickUpTimeTo!.minute);
    DateTime destFrom = DateTime(_rideDate!.year, _rideDate!.month,
        _rideDate!.day, _destTimeFrom!.hour, _destTimeFrom!.minute);
    DateTime destTo = DateTime(_rideDate!.year, _rideDate!.month,
        _rideDate!.day, _destTimeTo!.hour, _destTimeTo!.minute);

    var searchResults = _ridePost
        .where('completed', isEqualTo: false)
        .orderBy('destinationDateTime')
        .orderBy('pickUpDateTime')
        .startAt([
      destFrom.millisecondsSinceEpoch,
      pickUpFrom.millisecondsSinceEpoch
    ]).endAt([
      destTo.millisecondsSinceEpoch,
      pickUpTo.millisecondsSinceEpoch
    ]).snapshots();

    return searchResults;
  }

  /// Make sure that the search form has all values necessary inputted
  bool _validSearchForm() {
    return _pickUpAddr != null &&
        _destAddr != null &&
        _mr != null &&
        _pickUpTimeFrom != null &&
        _pickUpTimeTo != null &&
        _destTimeFrom != null &&
        _destTimeTo != null &&
        _rideDate != null;
  }

  // representing the mile radius of the search
  int? _mr;

  final _pickUpAddrController =
      TextEditingController(); // text controller for pick up address
  String? _pickUpAddr; // the pick up address
  double? _pickUpLat; // the pick up location lat
  double? _pickUpLang; // the pick up location lang

  /// The method that sets the value of the text controller for pick up
  void fillPickUpAddr(String value) {
    _pickUpAddrController.text = value;
  }

  final _destAddrController =
      TextEditingController(); // text controller for destination address
  String? _destAddr; // the destination address
  double? _destLat; // the destination lat
  double? _destLang; // the destination lang

  /// The method that sets the value of the text controller for destination
  void fillDestAddr(String value) {
    _destAddrController.text = value;
  }

  /// pick up and destination time
  TimeOfDay? _pickUpTimeFrom;
  TimeOfDay? _pickUpTimeTo;
  TimeOfDay? _destTimeFrom;
  TimeOfDay? _destTimeTo;

  /// the ride date
  DateTime? _rideDate;

  @override
  Widget build(BuildContext context) {
    String? userId;
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    /// Helper method to filter and sort the User's upcoming rides
    Future getUpcomingRides() async {
      userId = await FirebaseAuth.instance.currentUser!.uid;
      // Get the Current User
      final userData =
          await FirebaseFirestore.instance.collection('User').doc(userId).get();

      // Determine if user is a host
      bool isHost = userData.data()!['isHostAccount'];
      // Get all rides where the User is a Passenger
      final _passengerRides = await FirebaseFirestore.instance
          .collection('ride-post')
          .where('riderIds.$userId', isEqualTo: ('accepted'))
          .get();

      // If User is a Host, get all hosted rides and add to docs for return
      if (isHost) {
        final _hostRides = await FirebaseFirestore.instance
            .collection('ride-post')
            .where('hosterId', isEqualTo: userId)
            .get();
        _hostRides.docs.addAll(_passengerRides.docs);
        _hostRides.docs.sort((a, b) =>
            a.data()['pickUpDateTime'].compareTo(b.data()['pickUpDateTime']));
        return _hostRides;
      }
      _passengerRides.docs.sort((a, b) =>
          a.data()['pickUpDateTime'].compareTo(b.data()['pickUpDateTime']));
      return _passengerRides;
    }

    loadEnv();
    return Scaffold(
        appBar: AppBar(
          title: Text(title),
          backgroundColor: Colors.red,
          actions: <Widget>[
            IconButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => ProfilePage()));
                },
                icon: const Icon(
                  Icons.person,
                  color: Colors.white,
                ))
          ],
        ),
        body: GestureDetector(
            onTap: () {
              FocusScopeNode currentFocus = FocusScope.of(context);

              if (!currentFocus.hasPrimaryFocus) {
                currentFocus.unfocus();
              }
            },
            child: SingleChildScrollView(
                controller: sc,
                child: Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: Center(
                      child: Column(
                        // column for upcoming rides
                        children: <Widget>[
                          // Expansion tile to display upcoming rides
                          FutureBuilder(
                              future: getUpcomingRides(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.done) {
                                  if (snapshot.hasError) {
                                    return Text(
                                        'Error fetching snapshot: ${snapshot.error}');
                                  } else {
                                    // Get the rides as a list of doc snapshots
                                    final _rides = snapshot.data!.docs;
                                    final rides =
                                        _rides.map((DocumentSnapshot snap) {
                                      return snap.data();
                                    }).toList();
                                    // Expandable Tile to display upcoming rides
                                    return ExpansionTile(
                                      title: Text(
                                        'Upcoming Rides',
                                        style: TextStyle(
                                          fontSize: width * 0.036,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      textColor: Colors.red,
                                      children: [
                                        ListView.builder(
                                            physics:
                                                NeverScrollableScrollPhysics(),
                                            padding: EdgeInsets.all(15),
                                            shrinkWrap: true,
                                            itemCount: rides.length,
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              if (rides[index]['hosterId'] ==
                                                  userId) {
                                                return RidesMyHostCard(
                                                    hostRideData: rides[index],
                                                    documentId:
                                                        _rides[index].id);
                                              } else {
                                                return RiderHistoryCard(
                                                    myRidesData: rides[index],
                                                    documentId:
                                                        _rides[index].id);
                                              }
                                            }),
                                      ],
                                    );
                                  }
                                } else {
                                  return const CircularProgressIndicator();
                                }
                              }),
                          Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: SizedBox(
                                height: 400, // change search filter box size
                                width: width * 0.0667 * 3710 / 275,
                                child: DecoratedBox(
                                  decoration: const BoxDecoration(
                                      color: Color(0xffEEE6E6),
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(5))),
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        top: 10,
                                        bottom: 10,
                                        left: 10,
                                        right: 10),
                                    child: Column(children: [
                                      // the title for search
                                      SizedBox(
                                        height: 31,
                                        width: width * 0.0668 * 3710 / 275,
                                        child: const DecoratedBox(
                                            decoration: BoxDecoration(
                                              color: Colors.white60,
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(5)),
                                            ),
                                            child: Center(
                                              child: Text(
                                                'Search for a Carpool!',
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            )),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 10),
                                        child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              // the mile radius input field
                                              SizedBox(
                                                height: 80,
                                                width:
                                                    width * 0.0667 * 1700 / 275,
                                                child: DecoratedBox(
                                                    decoration:
                                                        const BoxDecoration(
                                                      color: Colors.white60,
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  5)),
                                                    ),
                                                    child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                left: 5,
                                                                right: 5),
                                                        child: Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              const Text(
                                                                'Mile Radius: ',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        16,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                              SizedBox(
                                                                width: 60,
                                                                height: 40,
                                                                child:
                                                                    DecoratedBox(
                                                                  decoration:
                                                                      const ShapeDecoration(
                                                                    shape:
                                                                        RoundedRectangleBorder(
                                                                      side: BorderSide(
                                                                          width:
                                                                              0.4,
                                                                          style: BorderStyle
                                                                              .solid,
                                                                          color:
                                                                              Colors.black),
                                                                      borderRadius:
                                                                          BorderRadius.all(
                                                                              Radius.circular(5.0)),
                                                                    ),
                                                                  ),
                                                                  child: Padding(
                                                                      padding: const EdgeInsets.only(left: 5.0),
                                                                      child: DropdownButtonHideUnderline(
                                                                        child:
                                                                            DropdownButton(
                                                                          value:
                                                                              _mr,
                                                                          hint: const Text(
                                                                              '---',
                                                                              style: TextStyle(fontSize: 18)),
                                                                          items: <
                                                                              int>[
                                                                            1,
                                                                            2,
                                                                            3,
                                                                            4,
                                                                            5,
                                                                            6,
                                                                            7
                                                                          ].map((int
                                                                              val) {
                                                                            return DropdownMenuItem<int>(
                                                                              value: val,
                                                                              child: Text(val.toString(),
                                                                                  style: const TextStyle(
                                                                                    fontSize: 14.5,
                                                                                  )),
                                                                            );
                                                                          }).toList(),
                                                                          onChanged:
                                                                              (int? value) => {
                                                                            if (value !=
                                                                                null)
                                                                              {
                                                                                setState(() => {
                                                                                      _mr = value,
                                                                                      // print(_mr)
                                                                                      _startSearch = false
                                                                                    })
                                                                              }
                                                                          },
                                                                          isExpanded:
                                                                              true,
                                                                        ), // for month,
                                                                      )),
                                                                ),
                                                              ),
                                                            ]))),
                                              ),
                                              // input field for ride date
                                              SizedBox(
                                                height: 80,
                                                width:
                                                    width * 0.0667 * 1700 / 275,
                                                child: DecoratedBox(
                                                  decoration:
                                                      const BoxDecoration(
                                                    color: Colors.white60,
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(5)),
                                                  ),
                                                  child: ListView(
                                                      scrollDirection:
                                                          Axis.horizontal,
                                                      children: [
                                                        Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    left: 5),
                                                            child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  const Text(
                                                                    'Ride Date: ',
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            16,
                                                                        fontWeight:
                                                                            FontWeight.bold),
                                                                  ),
                                                                  SizedBox(
                                                                    width:
                                                                        width *
                                                                            0.32,
                                                                    height: 40,
                                                                    child:
                                                                        TimePickerSpinnerPopUp(
                                                                      mode: CupertinoDatePickerMode
                                                                          .date,
                                                                      barrierColor:
                                                                          Colors
                                                                              .black26,
                                                                      // initTime:
                                                                      //     DateTime
                                                                      //         .now(),
                                                                      onChange:
                                                                          (dateTime) {
                                                                        setState(
                                                                            () {
                                                                          _rideDate =
                                                                              dateTime;
                                                                          _startSearch =
                                                                              false;
                                                                        });
                                                                      },
                                                                    ),
                                                                  ),
                                                                ])),
                                                      ]),
                                                ),
                                              ),
                                            ]), // mile radius and date
                                      ),
                                      // the input field for pick up address and pick up time
                                      Padding(
                                        padding: const EdgeInsets.only(top: 10),
                                        child: SizedBox(
                                          height: 90,
                                          width: width * 0.0667 * 3500 / 275,
                                          child: DecoratedBox(
                                              decoration: const BoxDecoration(
                                                color: Colors.white60,
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(5)),
                                              ),
                                              child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 5, right: 5),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            const Text(
                                                                'Pick Up Address: ',
                                                                style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        16)),
                                                            // text field for pick up address
                                                            SizedBox(
                                                              width: width *
                                                                  0.0667 *
                                                                  1750 /
                                                                  275,
                                                              height: 25,
                                                              child: TextField(
                                                                controller:
                                                                    _pickUpAddrController,
                                                                onTap:
                                                                    () async {
                                                                  // show search screen
                                                                  var place =
                                                                      await PlacesAutocomplete
                                                                          .show(
                                                                    context:
                                                                        context,
                                                                    apiKey: dotenv
                                                                            .env[
                                                                        'GOOGLE_MAP_API_KEY'],
                                                                    mode: Mode
                                                                        .overlay,
                                                                    types: [],
                                                                    strictbounds:
                                                                        false,
                                                                    components: [
                                                                      Component(
                                                                          Component
                                                                              .country,
                                                                          'us'),
                                                                    ],
                                                                    onError:
                                                                        (err) {
                                                                      print(
                                                                          err);
                                                                    },
                                                                  );
                                                                  final plist =
                                                                      GoogleMapsPlaces(
                                                                    apiKey: dotenv
                                                                            .env[
                                                                        'GOOGLE_MAP_API_KEY'],
                                                                    apiHeaders:
                                                                        await const GoogleApiHeaders()
                                                                            .getHeaders(),

                                                                    //from google_api_headers package
                                                                  );
                                                                  String
                                                                      placeid =
                                                                      place!.placeId ??
                                                                          "0";
                                                                  final detail =
                                                                      await plist
                                                                          .getDetailsByPlaceId(
                                                                              placeid);
                                                                  final geometry =
                                                                      detail
                                                                          .result
                                                                          .geometry!;
                                                                  final lat =
                                                                      geometry
                                                                          .location
                                                                          .lat;
                                                                  final lang =
                                                                      geometry
                                                                          .location
                                                                          .lng;
                                                                  fillPickUpAddr(place
                                                                      .description
                                                                      .toString());
                                                                  setState(() {
                                                                    _pickUpLat =
                                                                        lat;
                                                                    _pickUpLang =
                                                                        lang;
                                                                    _pickUpAddr =
                                                                        _pickUpAddrController
                                                                            .text;
                                                                    _startSearch =
                                                                        false;
                                                                  });
                                                                },
                                                                style:
                                                                    const TextStyle(
                                                                        fontSize:
                                                                            14),
                                                                decoration:
                                                                    const InputDecoration(
                                                                  enabledBorder:
                                                                      OutlineInputBorder(
                                                                          borderSide:
                                                                              BorderSide(
                                                                    color: Colors
                                                                        .black,
                                                                    width: 1.0,
                                                                    style: BorderStyle
                                                                        .solid,
                                                                  )),
                                                                  focusedBorder:
                                                                      OutlineInputBorder(
                                                                          borderSide:
                                                                              BorderSide(
                                                                    color: Colors
                                                                        .black54,
                                                                    width: 1.0,
                                                                    style: BorderStyle
                                                                        .solid,
                                                                  )),
                                                                  contentPadding:
                                                                      EdgeInsets.only(
                                                                          top:
                                                                              0,
                                                                          bottom:
                                                                              0,
                                                                          left:
                                                                              4.0),
                                                                ),
                                                              ),
                                                            ),
                                                          ]),
                                                      // pick up time
                                                      Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  top: 10),
                                                          child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                const Text(
                                                                    'Pick Up Time: ',
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        fontSize:
                                                                            14)),
                                                                // the input field for pick up time range
                                                                Row(
                                                                  children: [
                                                                    SizedBox(
                                                                      width: width *
                                                                          0.22,
                                                                      height:
                                                                          40,
                                                                      child:
                                                                          TimePickerSpinnerPopUp(
                                                                        barrierColor:
                                                                            Colors.black26,
                                                                        initTime:
                                                                            DateTime.now(),
                                                                        onChange:
                                                                            (dateTime) {
                                                                          // Implement your logic with select dateTime
                                                                          setState(
                                                                              () {
                                                                            _pickUpTimeFrom =
                                                                                TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
                                                                            _startSearch =
                                                                                false;
                                                                          });
                                                                        },
                                                                      ),
                                                                    ),
                                                                    // dropdown for time
                                                                    const Text(
                                                                        ' to ',
                                                                        style: TextStyle(
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                            fontSize: 14)),
                                                                    SizedBox(
                                                                      width: width *
                                                                          0.22,
                                                                      height:
                                                                          40,
                                                                      child:
                                                                          TimePickerSpinnerPopUp(
                                                                        barrierColor:
                                                                            Colors.black26,
                                                                        initTime:
                                                                            DateTime.now(),
                                                                        onChange:
                                                                            (dateTime) {
                                                                          // Implement your logic with select dateTime
                                                                          setState(
                                                                              () {
                                                                            _pickUpTimeTo =
                                                                                TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
                                                                            _startSearch =
                                                                                false;
                                                                          });
                                                                        },
                                                                      ),
                                                                    ),
                                                                  ],
                                                                )

                                                                // dropdown for time
                                                              ]))
                                                    ],
                                                  ))),
                                        ),
                                      ),
                                      // the input field for destination addres and destination time range
                                      Padding(
                                        padding: const EdgeInsets.only(top: 10),
                                        child: SizedBox(
                                          height: 90,
                                          width: width * 0.0667 * 3500 / 275,
                                          child: DecoratedBox(
                                              decoration: const BoxDecoration(
                                                color: Colors.white60,
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(5)),
                                              ),
                                              child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 5, right: 5),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            const Text(
                                                                'Destination Address:',
                                                                style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        16)),
                                                            // text field for destination address
                                                            SizedBox(
                                                              width: width *
                                                                  0.0667 *
                                                                  1750 /
                                                                  275,
                                                              height: 25,
                                                              child: TextField(
                                                                controller:
                                                                    _destAddrController,
                                                                onTap:
                                                                    () async {
                                                                  // show search screen
                                                                  var place =
                                                                      await PlacesAutocomplete
                                                                          .show(
                                                                    context:
                                                                        context,
                                                                    apiKey: dotenv
                                                                            .env[
                                                                        'GOOGLE_MAP_API_KEY'],
                                                                    mode: Mode
                                                                        .overlay,
                                                                    types: [],
                                                                    strictbounds:
                                                                        false,
                                                                    components: [
                                                                      Component(
                                                                          Component
                                                                              .country,
                                                                          'us'),
                                                                    ],
                                                                    onError:
                                                                        (err) {
                                                                      print(
                                                                          err);
                                                                    },
                                                                  );
                                                                  final plist =
                                                                      GoogleMapsPlaces(
                                                                    apiKey: dotenv
                                                                            .env[
                                                                        'GOOGLE_MAP_API_KEY'],
                                                                    apiHeaders:
                                                                        await const GoogleApiHeaders()
                                                                            .getHeaders(),
                                                                    //from google_api_headers package
                                                                  );
                                                                  String
                                                                      placeid =
                                                                      place!.placeId ??
                                                                          "0";
                                                                  final detail =
                                                                      await plist
                                                                          .getDetailsByPlaceId(
                                                                              placeid);
                                                                  final geometry =
                                                                      detail
                                                                          .result
                                                                          .geometry!;
                                                                  final lat =
                                                                      geometry
                                                                          .location
                                                                          .lat;
                                                                  final lang =
                                                                      geometry
                                                                          .location
                                                                          .lng;
                                                                  fillDestAddr(place
                                                                      .description
                                                                      .toString());
                                                                  setState(() {
                                                                    _destLat =
                                                                        lat;
                                                                    _destLang =
                                                                        lang;
                                                                    _destAddr =
                                                                        _destAddrController
                                                                            .text;
                                                                    _startSearch =
                                                                        false;
                                                                  });
                                                                },
                                                                style:
                                                                    const TextStyle(
                                                                        fontSize:
                                                                            14),
                                                                decoration:
                                                                    const InputDecoration(
                                                                  enabledBorder:
                                                                      OutlineInputBorder(
                                                                          borderSide:
                                                                              BorderSide(
                                                                    color: Colors
                                                                        .black,
                                                                    width: 1.0,
                                                                    style: BorderStyle
                                                                        .solid,
                                                                  )),
                                                                  focusedBorder:
                                                                      OutlineInputBorder(
                                                                          borderSide:
                                                                              BorderSide(
                                                                    color: Colors
                                                                        .black54,
                                                                    width: 1.0,
                                                                    style: BorderStyle
                                                                        .solid,
                                                                  )),
                                                                  contentPadding:
                                                                      EdgeInsets.only(
                                                                          top:
                                                                              0,
                                                                          bottom:
                                                                              0,
                                                                          left:
                                                                              4.0),
                                                                ),
                                                              ),
                                                            ),
                                                          ]),
                                                      Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            const Text(
                                                                'Destination Time: ',
                                                                style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        14)),
                                                            // dropdown for time
                                                            Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .only(
                                                                        top:
                                                                            10),
                                                                child: Row(
                                                                  children: [
                                                                    // time picker for destination time range
                                                                    SizedBox(
                                                                      width: width *
                                                                          0.22,
                                                                      height:
                                                                          40,
                                                                      child:
                                                                          TimePickerSpinnerPopUp(
                                                                        barrierColor:
                                                                            Colors.black26,
                                                                        initTime:
                                                                            DateTime.now(),
                                                                        onChange:
                                                                            (dateTime) {
                                                                          // Implement your logic with select dateTime
                                                                          setState(
                                                                              () {
                                                                            _destTimeFrom =
                                                                                TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
                                                                            _startSearch =
                                                                                false;
                                                                          });
                                                                        },
                                                                      ),
                                                                    ),
                                                                    // dropdown for time
                                                                    const Text(
                                                                        ' to ',
                                                                        style: TextStyle(
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                            fontSize: 14)),
                                                                    SizedBox(
                                                                      width: width *
                                                                          0.22,
                                                                      height:
                                                                          40,
                                                                      child:
                                                                          TimePickerSpinnerPopUp(
                                                                        barrierColor:
                                                                            Colors.black26,
                                                                        initTime:
                                                                            DateTime.now(),
                                                                        onChange:
                                                                            (dateTime) {
                                                                          // Implement your logic with select dateTime
                                                                          setState(
                                                                              () {
                                                                            _destTimeTo =
                                                                                TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
                                                                            _startSearch =
                                                                                false;
                                                                          });
                                                                        },
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ))

                                                            // dropdown for time
                                                          ])
                                                    ],
                                                  ))),
                                        ),
                                      ),
                                      // submit button to start search
                                      ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                          ),
                                          onPressed: () async {
                                            if (_validSearchForm()) {
                                              setState(() {
                                                _startSearch = true;
                                              });
                                              sc.animateTo(height * 0.58,
                                                  duration: const Duration(
                                                      milliseconds: 700),
                                                  curve: Curves.easeIn);
                                            } else {
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
                                                              MainAxisSize.min,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: <Widget>[
                                                            const Text(
                                                                'Please fill out all fields.'),
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
                                          child: const Text('Search',
                                              style: TextStyle(
                                                color: Colors.white,
                                              )))
                                    ]),
                                  ),
                                )),
                          ),
                          // the search result
                          if (_startSearch)
                            Padding(
                                padding: const EdgeInsets.only(
                                    top: 15, left: 8, right: 8),
                                child: SizedBox(
                                    height: height * 0.7,
                                    child: SearchStream(
                                      streamSnap: _getSearchResults(),
                                      pickUpLat: _pickUpLat!,
                                      pickUpLang: _pickUpLang!,
                                      destLat: _destLat!,
                                      destLang: _destLang!,
                                      mileRadius: _mr!,
                                    ))),
                        ],
                      ),
                    )))));
  }
}
