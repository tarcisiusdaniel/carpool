import 'package:carpool_app/main/main_page.dart';
import 'package:carpool_app/main/profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'dart:core';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:time_picker_spinner_pop_up/time_picker_spinner_pop_up.dart';

// HostPage, the page to host a ride
class HostPage extends StatefulWidget {
  const HostPage({super.key});
  @override
  HostPageState createState() => HostPageState();
}

// HostPageState, the class that handles rendeering the widgets and logic behind HostPage
class HostPageState extends State<HostPage> {
  // This widget is the host page widget.
  // the values for each input

  // ride time and date

  /// This method loads the API key(s) necessary for this app to run
  void loadEnv() async {
    await dotenv.load(fileName: "lib/.env");
  }

  // The states needed for posting a ride

  // The state for arrival or destination
  bool initialState =
      true; // indicate if the user has tried to submit things or not
  int? _rideArrivalDate;
  bool rideArrivalDateDone = false;
  int? _rideArrivalMonth;
  bool rideArrivalMonthDone = false;
  int? _rideArrivalYears;
  bool rideArrivalYearsDone = false;
  TimeOfDay _rideArrivalTime = TimeOfDay.now();
  int _rideArrivalTimeValue =
      TimeOfDay.now().hour * 60 + TimeOfDay.now().minute;

  // The states for pick up information
  String? _pickUpAddress;
  double? _pickUpLat;
  double? _pickUpLang;
  bool pickUpAddressDone = false;
  TimeOfDay _ridePickUpTime = TimeOfDay.now();
  int _ridePickUpTimeValue = TimeOfDay.now().hour * 60 + TimeOfDay.now().minute;
  String? _pickUpDetails = '';
  bool pickUpDetailsDone = false;

  bool ridePickUpArrivalTimeDone = false;

  // destination address
  String? _destinationAddress;
  double? _destLat;
  double? _destLang;
  bool destinationAddressDone = false;

  // vehicle details
  String? _carMakeAndModel;
  bool carMakeAndModelDone = false;
  String? _carColor;
  bool carColorDone = false;
  String? _carLicensePlate;
  bool carLicensePlateDone = false;
  int? _numberOfRiders;
  bool numberOfRidersDone = false;

  /// The condition needed to be fulfilled to create a ride post
  /// Make sure that all the field needed for a creating a post is populated
  bool _createCondition() {
    setState(() {
      // make sure the arrival information is filled
      // make sure the pick up information is filled
      // make sure the vehicle details information is filled
      initialState = false;
      rideArrivalDateDone = (_rideArrivalDate != null);
      rideArrivalMonthDone = (_rideArrivalMonth != null);
      rideArrivalYearsDone = (_rideArrivalYears != null);

      pickUpAddressDone = (_pickUpAddress != null);

      destinationAddressDone = (_destinationAddress != null);

      carMakeAndModelDone = (_carMakeAndModel != null);
      carColorDone = (_carColor != null);
      carLicensePlateDone = (_carLicensePlate != null);
      numberOfRidersDone = (_numberOfRiders != null);

      ridePickUpArrivalTimeDone =
          (_rideArrivalTimeValue > _ridePickUpTimeValue);
    });

    return rideArrivalDateDone &&
        rideArrivalMonthDone &&
        rideArrivalYearsDone &&
        pickUpAddressDone &&
        destinationAddressDone &&
        carMakeAndModelDone &&
        carColorDone &&
        carLicensePlateDone &&
        numberOfRidersDone &&
        ridePickUpArrivalTimeDone;
  }

  /// Create a ride post using the data of the states needed for posting a ride
  Future<void> _create() async {
    // the date and time to reach the destination
    DateTime rideFullArrivalDateTime = DateTime(
        _rideArrivalYears!,
        _rideArrivalMonth!,
        _rideArrivalDate!,
        _rideArrivalTime.hour,
        _rideArrivalTime.minute);
    // the date and time for picking up the riders
    DateTime rideFullPickUpDateTime = DateTime(
        _rideArrivalYears!,
        _rideArrivalMonth!,
        _rideArrivalDate!,
        _ridePickUpTime.hour,
        _ridePickUpTime.minute);

    // add the ride post created to the ride posts collection in the Firestore
    await _ridePost
        .add({
          "hosterId": FirebaseAuth.instance.currentUser!.uid,
          "ridesDriven": 3,
          "completed": false,
          "riderIds": <String, String>{},
          "carMakeAndModel": _carMakeAndModel,
          "carColor": _carColor,
          "carLicensePlate": _carLicensePlate,
          "availableSeats": _numberOfRiders,
          "destinationAddr": _destinationAddress,
          "destinationLat": _destLat,
          "destinationLang": _destLang,
          "destinationDateTime": rideFullArrivalDateTime.millisecondsSinceEpoch,
          "pickUpAddr": _pickUpAddress,
          "pickUpLat": _pickUpLat,
          "pickUpLang": _pickUpLang,
          "pickUpDateTime": rideFullPickUpDateTime.millisecondsSinceEpoch,
          "pickUpDetails": _pickUpDetails,
        })
        .then((value) => print("ride post added"))
        .catchError((value) => print("adding ride post not succeeded"));
  }

  // for pick up address
  // the text controller to listen to the user input for the addresses
  final _pickUpAddrController = TextEditingController(); // pick up address
  final _destAddrController = TextEditingController(); // destination address

  /// The method used to listen to the pick up address' controller's value
  void fillPickUpAddr(String value) {
    _pickUpAddrController.text = value;
  }

  // for destination address

  /// The method used to listen to the destination address' controller's value
  void fillDestAddr(String value) {
    _destAddrController.text = value;
  }

  // The reference object to the collection that holds the ride posts for this app
  final CollectionReference _ridePost =
      FirebaseFirestore.instance.collection('ride-post');

  // The scroll controller for the app
  ScrollController sc = ScrollController();

  @override
  void initState() {
    super.initState();
    Firebase.initializeApp().whenComplete(() {
      print("completed");
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    // connection to Firestore collection
    // 'User' and 'ride-post'
    loadEnv(); // load the API key(s) everytime the page is rendered
    String title = "Host Page"; // page title

    // make the list for all the dates
    var datesArray = <DropdownMenuItem<int>>[];
    for (int i = 1; i <= 31; i++) {
      datesArray.add(DropdownMenuItem<int>(
        value: i,
        child: Text(i.toString()),
      ));
    }
    List<DropdownMenuItem<int>> dates = datesArray.toList();

    // make the list for months
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
    List<DropdownMenuItem<int>> months0 = [];
    for (int i = 1; i <= 12; i++) {
      months0.insert(
          i - 1,
          DropdownMenuItem(
            value: i,
            child: Text(months.elementAt(i - 1).substring(0, 3)),
          ));
    }

    // make the list for years
    final int currYear = DateTime.now().year;
    List<DropdownMenuItem<int>> years = [];
    for (int i = 1; i <= 50; i++) {
      int y = i - 1 + currYear;
      years.insert(
          i - 1,
          DropdownMenuItem(
            value: y,
            child: Text('$y'),
          ));
    }

    // the media query of the device's width and height
    // for responsive size
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
        appBar: AppBar(
          title: Text(title),
          backgroundColor: Colors.red,
          actions: <Widget>[
            // icon to go to profile page
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
          child: ListView(
            controller: sc,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    left: 27.5, right: 27.5, top: 5, bottom: 5),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // ride's time and date
                    const Text(
                      'Ride\'s Time and Date',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                    ),
                    const Text(
                      'Arrival Date',
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    // row for date month and years for ride's time and date
                    Padding(
                      padding: const EdgeInsets.only(top: 10, bottom: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // input date for the destination date
                                SizedBox(
                                  width: screenWidth * 0.067 * 1000 / 275,
                                  height: screenHeight * 0.007 * 2 * 4.3,
                                  child: DecoratedBox(
                                    decoration: const ShapeDecoration(
                                      shape: RoundedRectangleBorder(
                                        side: BorderSide(
                                            width: 1.0,
                                            style: BorderStyle.solid,
                                            color: Colors.black),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(5.0)),
                                      ),
                                    ),
                                    child: Padding(
                                        padding:
                                            const EdgeInsets.only(left: 5.0),
                                        child: DropdownButtonHideUnderline(
                                          child: DropdownButton<int>(
                                            hint: const Text('Date'),
                                            value: _rideArrivalDate,
                                            items: dates,
                                            onChanged: (int? value) {
                                              setState(() {
                                                _rideArrivalDate = value!;
                                                // print(_rideArrivalDate);
                                              });
                                            },
                                          ), // for date,
                                        )),
                                  ),
                                ),
                                // input date for the destination month
                                SizedBox(
                                  width: screenWidth * 0.067 * 1000 / 275,
                                  height: screenHeight * 0.007 * 43 / 5,
                                  child: DecoratedBox(
                                    decoration: const ShapeDecoration(
                                      shape: RoundedRectangleBorder(
                                        side: BorderSide(
                                            width: 1.0,
                                            style: BorderStyle.solid,
                                            color: Colors.black),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(5.0)),
                                      ),
                                    ),
                                    child: Padding(
                                        padding:
                                            const EdgeInsets.only(left: 5.0),
                                        child: DropdownButtonHideUnderline(
                                          child: DropdownButton<int>(
                                            items: months0,
                                            hint: const Text('Month'),
                                            value: _rideArrivalMonth,
                                            onChanged: (int? value) => {
                                              if (value != null)
                                                {
                                                  setState(() => {
                                                        _rideArrivalMonth =
                                                            value
                                                      })
                                                }
                                            },
                                          ), // for month,
                                        )),
                                  ),
                                ),
                                // input date for the destination years
                                SizedBox(
                                  width: screenWidth * 0.067 * 1000 / 275,
                                  height: screenHeight * 0.007 * 43 / 5,
                                  child: DecoratedBox(
                                    decoration: const ShapeDecoration(
                                      shape: RoundedRectangleBorder(
                                        side: BorderSide(
                                            width: 1.0,
                                            style: BorderStyle.solid,
                                            color: Colors.black),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(5.0)),
                                      ),
                                    ),
                                    child: Padding(
                                        padding:
                                            const EdgeInsets.only(left: 5.0),
                                        child: DropdownButtonHideUnderline(
                                          child: DropdownButton(
                                            items: years,
                                            hint: const Text('Years'),
                                            value: _rideArrivalYears,
                                            onChanged: (int? value) => {
                                              if (value != null)
                                                {
                                                  setState(() => {
                                                        _rideArrivalYears =
                                                            value
                                                      })
                                                }
                                            },
                                          ), // for year,
                                        )),
                                  ),
                                ),
                              ]),
                          // error message if one of arrival date, month, years is invalid
                          if (!initialState &&
                              (!rideArrivalDateDone ||
                                  !rideArrivalMonthDone ||
                                  !rideArrivalYearsDone))
                            const Padding(
                              padding: EdgeInsets.only(top: 3.0),
                              child: Text(
                                'Date, Month, and Years cannot be empty',
                                style:
                                    TextStyle(fontSize: 10, color: Colors.red),
                              ),
                            ),
                        ],
                      ),
                    ),
                    // arrival time for ride's time and date
                    const Text(
                      'Arrival Time',
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    Padding(
                        padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                // time picker for arrival time
                                SizedBox(
                                  width: screenWidth * 0.067 * 1000 / 275,
                                  height: screenHeight * 0.007 * 43 / 5,
                                  child: TimePickerSpinnerPopUp(
                                    barrierColor: Colors.black26,
                                    initTime: DateTime.now(),
                                    onChange: (dateTime) {
                                      // Implement your logic with select dateTime
                                      setState(() {
                                        _rideArrivalTime = TimeOfDay(
                                            hour: dateTime.hour,
                                            minute: dateTime.minute);
                                        _rideArrivalTimeValue =
                                            dateTime.hour * 60 +
                                                dateTime.minute;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                            // check if the time picker is already populated
                            if (!initialState && !ridePickUpArrivalTimeDone)
                              const Padding(
                                padding: EdgeInsets.only(top: 3.0),
                                child: Text(
                                  'Cannot be empty earlier than Pick-up Time',
                                  style: TextStyle(
                                      fontSize: 10, color: Colors.red),
                                ),
                              ),
                          ],
                        )),
                    const Divider(
                      color: Colors.black,
                      thickness: 0.6,
                    ),
                    // pick up information
                    const Text(
                      'Pick Up Information',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                    ),
                    // address for pick up information
                    const Text(
                      'Address',
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // the text field for pick up address
                          SizedBox(
                            height: screenHeight * 0.007 * 43 / 5,
                            child: TextField(
                              controller: _pickUpAddrController,
                              onTap: () async {
                                // show search screen for google auto complete
                                var place = await PlacesAutocomplete.show(
                                  context: context,
                                  apiKey: dotenv.env['GOOGLE_MAP_API_KEY'],
                                  mode: Mode.overlay,
                                  types: [],
                                  strictbounds: false,
                                  components: [
                                    Component(Component.country, 'us'),
                                  ],
                                  onError: (err) {
                                    print(err);
                                  },
                                );

                                FocusManager.instance.primaryFocus?.unfocus();
                                final plist = GoogleMapsPlaces(
                                  apiKey: dotenv.env['GOOGLE_MAP_API_KEY'],
                                  apiHeaders: await const GoogleApiHeaders()
                                      .getHeaders(),
                                  //from google_api_headers package
                                );
                                String placeid = place!.placeId ?? "0";
                                final detail =
                                    await plist.getDetailsByPlaceId(placeid);
                                final geometry = detail.result.geometry!;
                                final lat = geometry.location.lat;
                                final lang = geometry.location.lng;
                                fillPickUpAddr(place.description.toString());
                                setState(() {
                                  _pickUpAddress = _pickUpAddrController.text;
                                  _pickUpLat = lat;
                                  _pickUpLang = lang;
                                });
                              },
                              style: const TextStyle(fontSize: 17),
                              decoration: const InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                  color: Colors.black,
                                  width: 1.0,
                                  style: BorderStyle.solid,
                                )),
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                  color: Colors.black54,
                                  width: 1.0,
                                  style: BorderStyle.solid,
                                )),
                                labelText: 'Enter Address',
                                contentPadding: EdgeInsets.only(
                                    top: 12.0, bottom: 8.0, left: 12.0),
                              ),
                            ),
                          ),
                          // the error message if pick up address is invalid or empty
                          if (!initialState && !pickUpAddressDone)
                            const Padding(
                              padding: EdgeInsets.only(top: 3.0),
                              child: Text(
                                'Address cannot be empty',
                                style:
                                    TextStyle(fontSize: 10, color: Colors.red),
                              ),
                            ),
                        ],
                      ),
                    ),

                    // pick up time for pick up information
                    const Text(
                      'Pick-up Time',
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                // the time picker for pick up
                                SizedBox(
                                  width: screenWidth * 0.067 * 1000 / 275,
                                  height: screenHeight * 0.007 * 43 / 5,
                                  child: TimePickerSpinnerPopUp(
                                    barrierColor: Colors.black26,
                                    initTime: DateTime.now(),
                                    onChange: (pickTime) {
                                      // Implement your logic with select dateTime
                                      setState(() {
                                        _ridePickUpTime = TimeOfDay(
                                            hour: pickTime.hour,
                                            minute: pickTime.minute);
                                        _ridePickUpTimeValue =
                                            pickTime.hour * 60 +
                                                pickTime.minute;
                                        // print(_ridePickUpTime.toString());
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                            // the error message shown if pick up time is invalid or empty
                            if (!initialState && !ridePickUpArrivalTimeDone)
                              const Padding(
                                padding: EdgeInsets.only(top: 3.0),
                                child: Text(
                                  'Cannot be emtpy or later than Arrival Time',
                                  style: TextStyle(
                                      fontSize: 10, color: Colors.red),
                                ),
                              ),
                          ]),
                    ),
                    // details for pick up information
                    const Text(
                      'Details',
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // the details on pick up location
                            SizedBox(
                              height: screenHeight * 0.007 * 60 / 5,
                              child: TextField(
                                style: const TextStyle(fontSize: 17),
                                decoration: const InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                    color: Colors.black,
                                    width: 1.0,
                                    style: BorderStyle.solid,
                                  )),
                                  focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                    color: Colors.black54,
                                    width: 1.0,
                                    style: BorderStyle.solid,
                                  )),
                                  labelText: 'Enter Details',
                                  contentPadding: EdgeInsets.only(
                                      top: 12.0, bottom: 8.0, left: 12.0),
                                ),
                                onChanged: (text) {
                                  // try to set the model temp
                                  setState(() {
                                    _pickUpDetails = text;
                                  });
                                },
                              ),
                            ),
                          ]),
                    ),
                    const Divider(
                      color: Colors.black,
                      thickness: 0.6,
                    ),
                    // destination address
                    const Text(
                      'Destination Address',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // the text field for destination address
                            SizedBox(
                              height: screenHeight * 0.007 * 43 / 5,
                              child: TextField(
                                controller: _destAddrController,
                                maxLengthEnforcement: MaxLengthEnforcement.none,
                                onTap: () async {
                                  // show search screen
                                  var place = await PlacesAutocomplete.show(
                                    context: context,
                                    apiKey: dotenv.env['GOOGLE_MAP_API_KEY'],
                                    mode: Mode.overlay,
                                    types: [],
                                    strictbounds: false,
                                    components: [
                                      Component(Component.country, 'us'),
                                    ],
                                    onError: (err) {
                                      print(err);
                                    },
                                  );
                                  final plist = GoogleMapsPlaces(
                                    apiKey: dotenv.env['GOOGLE_MAP_API_KEY'],
                                    apiHeaders: await const GoogleApiHeaders()
                                        .getHeaders(),
                                    //from google_api_headers package
                                  );
                                  String placeid = place!.placeId ?? "0";
                                  final detail =
                                      await plist.getDetailsByPlaceId(placeid);
                                  final geometry = detail.result.geometry!;
                                  final lat = geometry.location.lat;
                                  final lang = geometry.location.lng;
                                  fillDestAddr(place.description.toString());
                                  setState(() {
                                    _destLat = lat;
                                    _destLang = lang;
                                    _destinationAddress =
                                        _destAddrController.text;
                                  });
                                },
                                style: const TextStyle(fontSize: 17),
                                decoration: const InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                    color: Colors.black,
                                    width: 1.0,
                                    style: BorderStyle.solid,
                                  )),
                                  focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                    color: Colors.black54,
                                    width: 1.0,
                                    style: BorderStyle.solid,
                                  )),
                                  labelText: 'Enter Address',
                                  contentPadding: EdgeInsets.only(
                                      top: 12.0, bottom: 8.0, left: 12.0),
                                ),
                              ),
                            ),
                            // the error message shown if destination address is invalid or empty
                            if (!initialState && !destinationAddressDone)
                              const Padding(
                                padding: EdgeInsets.only(top: 3.0),
                                child: Text(
                                  'Destination Address cannot be left blank',
                                  style: TextStyle(
                                      fontSize: 10, color: Colors.red),
                                ),
                              ),
                          ]),
                    ),
                    const Divider(
                      color: Colors.black,
                      thickness: 0.6,
                    ),
                    // vehicle details
                    const Text(
                      'Vehicle Details',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                    ),
                    const Text(
                      'Car Make and Model',
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // the text input for car make and model
                            SizedBox(
                              height: screenHeight * 0.007 * 43 / 5,
                              child: TextField(
                                style: const TextStyle(fontSize: 17),
                                decoration: const InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                    color: Colors.black,
                                    width: 1.0,
                                    style: BorderStyle.solid,
                                  )),
                                  focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                    color: Colors.black54,
                                    width: 1.0,
                                    style: BorderStyle.solid,
                                  )),
                                  labelText: 'i.e. Toyota Camry',
                                  contentPadding: EdgeInsets.only(
                                      top: 12.0, bottom: 8.0, left: 12.0),
                                ),
                                onChanged: (text) {
                                  // try to set the model temp
                                  setState(() {
                                    _carMakeAndModel = text;
                                  });
                                },
                              ),
                            ),
                            // the error message if car make and model is invalid or empty
                            if (!initialState && !carMakeAndModelDone)
                              const Padding(
                                padding: EdgeInsets.only(top: 3.0),
                                child: Text(
                                  'Car Make and Model cannot be left empty',
                                  style: TextStyle(
                                      fontSize: 10, color: Colors.red),
                                ),
                              ),
                          ]),
                    ),
                    const Text(
                      'Color',
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    Padding(
                        padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // the vehicle color text field
                              SizedBox(
                                height: screenHeight * 0.007 * 43 / 5,
                                child: TextField(
                                  style: const TextStyle(fontSize: 17),
                                  decoration: const InputDecoration(
                                    enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                      color: Colors.black,
                                      width: 1.0,
                                      style: BorderStyle.solid,
                                    )),
                                    focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                      color: Colors.black54,
                                      width: 1.0,
                                      style: BorderStyle.solid,
                                    )),
                                    labelText: 'i.e. Yellow',
                                    contentPadding: EdgeInsets.only(
                                        top: 12.0, bottom: 8.0, left: 12.0),
                                  ),
                                  onChanged: (text) {
                                    // try to set the model temp
                                    setState(() {
                                      _carColor = text;
                                    });
                                  },
                                ),
                              ),
                              // the error message shown if the car color is invalid or empty
                              if (!initialState && !carColorDone)
                                const Padding(
                                  padding: EdgeInsets.only(top: 3.0),
                                  child: Text(
                                    'Car Color cannot be left blank',
                                    style: TextStyle(
                                        fontSize: 10, color: Colors.red),
                                  ),
                                ),
                            ])),
                    const Text(
                      'License Plate',
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    Padding(
                        padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // the text input for the vehicle's license plate
                              SizedBox(
                                height: screenHeight * 0.007 * 43 / 5,
                                child: TextField(
                                  style: const TextStyle(fontSize: 17),
                                  decoration: const InputDecoration(
                                    enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                      color: Colors.black,
                                      width: 1.0,
                                      style: BorderStyle.solid,
                                    )),
                                    focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                      color: Colors.black54,
                                      width: 1.0,
                                      style: BorderStyle.solid,
                                    )),
                                    labelText: 'Enter License Plate Number',
                                    contentPadding: EdgeInsets.only(
                                        top: 12.0, bottom: 8.0, left: 12.0),
                                  ),
                                  onChanged: (text) {
                                    // try to set the model temp
                                    setState(() {
                                      _carLicensePlate = text;
                                    });
                                  },
                                ),
                              ),
                              // the error message if the license plate is invalid or empty
                              if (!initialState && !carLicensePlateDone)
                                const Padding(
                                  padding: EdgeInsets.only(top: 3.0),
                                  child: Text(
                                    'License Plate cannot be left blank',
                                    style: TextStyle(
                                        fontSize: 10, color: Colors.red),
                                  ),
                                ),
                            ])),
                    // available seats
                    const Text(
                      'Available Seats',
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // the drop down for available seats
                                SizedBox(
                                  width: screenWidth * 0.067 * 1500 / 275,
                                  height: screenHeight * 0.007 * 43 / 5,
                                  child: DecoratedBox(
                                    decoration: const ShapeDecoration(
                                      shape: RoundedRectangleBorder(
                                        side: BorderSide(
                                            width: 1.0,
                                            style: BorderStyle.solid,
                                            color: Colors.black),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(5.0)),
                                      ),
                                    ),
                                    child: Padding(
                                        padding:
                                            const EdgeInsets.only(left: 5.0),
                                        child: DropdownButtonHideUnderline(
                                          child: DropdownButton(
                                            items: <int>[1, 2, 3, 4, 5, 6, 7]
                                                .map((int val) {
                                              return DropdownMenuItem<int>(
                                                value: val,
                                                child: Text(val.toString()),
                                              );
                                            }).toList(),
                                            hint: const Text('Select a Number'),
                                            value: _numberOfRiders,
                                            onChanged: (int? value) => {
                                              if (value != null)
                                                {
                                                  setState(() =>
                                                      {_numberOfRiders = value})
                                                }
                                            },
                                          ), // for month,
                                        )),
                                  ),
                                ),
                                // the button to submit a ride post
                                SizedBox(
                                  width: screenWidth * 0.067 * 1000 / 275,
                                  height: screenHeight * 0.007 * 46 / 5,
                                  child: ElevatedButton(
                                      key: const Key("Submit Post"),
                                      style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all<Color>(
                                                  Colors.red), // background
                                          foregroundColor:
                                              MaterialStateProperty.all<Color>(
                                                  Colors.white), // foreground
                                          shape: MaterialStateProperty.all(
                                            RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                                side: const BorderSide(
                                                  color: Colors.white,
                                                  width: 2.0,
                                                )),
                                          )),
                                      onPressed: () async {
                                        // get the data that wanted to be created
                                        if (_createCondition()) {
                                          _create();
                                          // navigate to other page
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      const MainPage()));
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
                                                            'The ride post is created!'),
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
                                        } else {
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
                                                            'Please complete all the questions asked.'),
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
                                          sc.animateTo(0,
                                              duration: const Duration(
                                                  milliseconds: 700),
                                              curve: Curves.easeIn);
                                        }
                                      },
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: const <Widget>[
                                          Text('Next'),
                                          Icon(Icons.arrow_forward_ios_rounded),
                                        ],
                                      )),
                                ),
                              ],
                            ),
                            // the error message if available seats is invalid or empty
                            if (!initialState && !numberOfRidersDone)
                              const Padding(
                                padding: EdgeInsets.only(top: 3.0),
                                child: Text(
                                  'Available Seats cannot be left blank',
                                  style: TextStyle(
                                      fontSize: 10, color: Colors.red),
                                ),
                              ),
                          ]),
                    ),
                  ],
                ),
              )
            ],
          ),
        ));
  }
}
