import 'package:carpool_app/main/auth_pages/signup_widgets/shared_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SavedLocationsPage extends StatefulWidget {
  DocumentSnapshot user;
  SavedLocationsPage(this.user, {Key? key}) : super(key: key);

  @override
  State<SavedLocationsPage> createState() => _SavedLocationsPage();
}

class _SavedLocationsPage extends State<SavedLocationsPage> {
  var db = FirebaseFirestore.instance.collection("User");
  final nameField = TextEditingController();
  final addressField = TextEditingController();

  @override
  initState() {
    super.initState();
  }

  Future<DocumentSnapshot?> getData() async {
    try {
      widget.user = await FirebaseFirestore.instance
          .collection("User")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();

      return widget.user;
    } catch (e) {
      print(e);
    }
  }

  Future<void> uploadSavedLocation(DocumentSnapshot user) async {
    final oldSavedLocation =
        widget.user.get('savedLocations') as Map<String, dynamic>;
    oldSavedLocation.putIfAbsent(nameField.text, () => addressField.text);

    await db.doc(user.id).update({'savedLocations': oldSavedLocation}).onError(
        (error, _) => print("Error writing document: $error"));
  }

  Future<void> deleteSavedLocation(DocumentSnapshot user, String name) async {
    final newSavedLocation =
        widget.user.get('savedLocations') as Map<String, dynamic>;
    newSavedLocation.remove(name);

    await db.doc(user.id).update({'savedLocations': newSavedLocation}).onError(
        (error, stackTrace) => print("Error writing document: $error"));
  }

  // This widget is the saved locations page.
  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    String title = "Saved Locations";
    final savedLocation =
        widget.user.get('savedLocations') as Map<String, dynamic>;
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
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        child: const Text(
                          'Save a custom location',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                    const Padding(padding: EdgeInsets.all(5)),
                    Container(
                      padding: const EdgeInsets.all(15),
                      color: Colors.grey[200],
                      child: Column(
                        children: [
                          SizedBox(
                            height: 40,
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: TextFormField(
                                decoration: const InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  hintText: 'Name of Location (e.g. Home)',
                                ),
                                controller: nameField,
                              ),
                            ),
                          ),
                          const Padding(padding: EdgeInsets.all(5)),
                          SizedBox(
                            height: 40,
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: TextFormField(
                                decoration: const InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  hintText: 'Address (e.g. 100 Main St.',
                                ),
                                controller: addressField,
                              ),
                            ),
                          ),
                          const Padding(padding: EdgeInsets.all(5)),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () {
                            nameField.clear();
                            addressField.clear();
                          },
                          child: const Text(
                            'Clear',
                            style: TextStyle(
                                decoration: TextDecoration.underline,
                                color: Colors.black),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            uploadSavedLocation(widget.user)
                                .then((value) => getData())
                                .then((user) => setState(() {
                                      if (user != null) {
                                        widget.user = user;
                                      }
                                    }));
                          },
                          icon: const Icon(Icons.add),
                        ),
                      ],
                    ),
                    const Padding(padding: EdgeInsets.all(10)),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Your Saved Locations',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const Divider(
                      color: Colors.black,
                      thickness: 2,
                    ),
                    // SAVED LOCATIONS BELOW
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        children: [
                          ListView.builder(
                              shrinkWrap: true,
                              itemCount: savedLocation.length,
                              itemBuilder: (BuildContext context, int index) {
                                var names = savedLocation.keys.toList();
                                return ListTile(
                                  title: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(5)),
                                        ),
                                        padding: EdgeInsets.all(width * .015),
                                        child: SizedBox(
                                            width: width * .6,
                                            child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    names[index].toUpperCase(),
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  Text(savedLocation[
                                                          names[index]]
                                                      .toString()),
                                                ])),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete),
                                        onPressed: () {
                                          deleteSavedLocation(
                                                  widget.user, names[index])
                                              .then((value) => getData())
                                              .then((user) => setState(() {
                                                    if (user != null) {
                                                      widget.user = user;
                                                    }
                                                  }));
                                        },
                                      )
                                    ],
                                  ),
                                );
                              }),
                        ],
                      ),
                    ),
                  ],
                ),
              ));
            }
            return const Text("no data");
          }),
    );
  }
}
