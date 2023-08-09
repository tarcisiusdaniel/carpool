import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditProfilePage extends StatefulWidget {
  DocumentSnapshot user;
  EditProfilePage(this.user, {Key? key}) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePage();
}

class _EditProfilePage extends State<EditProfilePage> {
  // Fields for PFP upload and display
  File? image;
  late String imageUrl = widget.user.get('photoIndex');
  // Controllers for Form
  late var firstNameField = TextEditingController();
  late var lastNameField = TextEditingController();
  late var phoneNumberField = TextEditingController();
  late var homeAddressField = TextEditingController();

  @override
  initState() {
    super.initState();
    imageUrl;
    firstNameField = TextEditingController(text: widget.user.get('firstName'));
    lastNameField = TextEditingController(text: widget.user.get('lastName'));
    phoneNumberField = TextEditingController(text: widget.user.get('phoneNo'));
    homeAddressField =
        TextEditingController(text: widget.user.get('savedLocations')['home']);
  }

  // Upload photo from device gallery onto firestore
  Future<void> uploadProfileImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (image == null) return;
    final fireStore = FirebaseStorage.instance;

    try {
      // Name the firestore reference with the user's ID
      Reference ref = fireStore.ref().child('${widget.user.id}.jpg');
      await ref.putFile(File(image.path)).whenComplete(() async {
        final url = await ref.getDownloadURL();
        setState(() {
          imageUrl = url;
          FirebaseFirestore.instance
              .collection('User')
              .doc(widget.user.id)
              .update({'pfpId': '${widget.user.id}.jpg', 'photoIndex': url});
        });
      });
    } on FirebaseException catch (e) {
      print('Error Uploading Image: ${e}');
    }
  }

  Future<void> updateProfile(DocumentSnapshot user) async {
    var db = FirebaseFirestore.instance;
    final oldSavedLocations =
        widget.user.get('savedLocations') as Map<String, dynamic>;
    oldSavedLocations['home'] = homeAddressField.text;

    await db.collection("User").doc(user.id).update({
      'lastName': lastNameField.text,
      'firstName': firstNameField.text,
      'phoneNo': phoneNumberField.text,
      'savedLocations': oldSavedLocations
    }).onError((error, _) => print("Error writing document: $error"));
  }

  // This widget is the edit profile page.
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    String title = "Edit Profile";
    return Scaffold(
        appBar: AppBar(
          title: Text(title),
          backgroundColor: Colors.red,
        ),
        body: SingleChildScrollView(
            child: Column(children: [
          const Padding(padding: EdgeInsets.all(20)),
          Container(
            height: width * 0.32,
            width: width * 0.32,
            decoration: BoxDecoration(
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
                    backgroundImage: NetworkImage(imageUrl.toString()),
                  )
                : const Center(
                    child: Icon(Icons.person, size: 96, color: Colors.grey)),
          ),
          SizedBox(
              width: 190,
              child: ElevatedButton.icon(
                style:
                    ElevatedButton.styleFrom(backgroundColor: Colors.grey[300]),
                onPressed: () {
                  uploadProfileImage();
                },
                icon: const Icon(
                  Icons.edit,
                  color: Colors.black,
                  size: 14,
                ),
                label: const Text(
                  'Edit Profile Picture',
                  style: TextStyle(fontSize: 14, color: Colors.black),
                ),
              )),
          Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  ListTile(
                      title: TextFormField(
                        decoration: const InputDecoration(
                          icon: Icon(Icons.person),
                          hintText: 'John',
                          labelText: 'First Name',
                        ),
                        controller: firstNameField,
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          firstNameField.clear();
                        },
                      )),
                  ListTile(
                      title: TextFormField(
                        decoration: const InputDecoration(
                          icon: Icon(Icons.person),
                          hintText: 'John',
                          labelText: 'Last Name',
                        ),
                        controller: lastNameField,
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          lastNameField.clear();
                        },
                      )),
                  ListTile(
                      title: TextFormField(
                        decoration: const InputDecoration(
                          icon: Icon(Icons.home_work),
                          hintText: '5555 Jane Doe St.',
                          labelText: 'Home Address',
                        ),
                        controller: homeAddressField,
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          homeAddressField.clear();
                        },
                      )),
                  ListTile(
                      title: TextFormField(
                        decoration: const InputDecoration(
                          icon: Icon(Icons.phone),
                          hintText: '555-555-5555',
                          labelText: 'Phone Number',
                        ),
                        controller: phoneNumberField,
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          phoneNumberField.clear();
                        },
                      )),
                  const Padding(padding: EdgeInsets.all(10)),
                ],
              )),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[300]),
            onPressed: () {
              updateProfile(widget.user);
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.save, color: Colors.black, size: 14),
            label: const Text(
              'Save',
              style: TextStyle(fontSize: 14, color: Colors.black),
            ),
          )
        ])));
  }
}
