import 'package:carpool_app/main/auth_pages/signup_widgets/shared_widgets.dart';
import 'package:carpool_app/main/utils/field_validator.dart';
import 'package:checkbox_formfield/checkbox_formfield.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';

class ProvideInfo extends StatefulWidget {
  /// FormState Key used to validate inputs are provided and phone is formatted
  final GlobalKey<FormState> formKey;

  /// Class to house User Information as it is obtained during signup process
  UserData user;

  ProvideInfo({super.key, required this.formKey, required this.user});

  @override
  State<ProvideInfo> createState() => _ProvideInfoState();
}

class _ProvideInfoState extends State<ProvideInfo> {
  /// Controller to hold first name provided
  final TextEditingController _firstNameController = TextEditingController();

  /// Controller to hold last name provided
  final TextEditingController _lastNameController = TextEditingController();

  /// Controller to hold phone # provided and format recognized via [RegExp]
  final TextEditingController _phoneNoController = TextEditingController();

  /// Controller to hold first name provided
  final TextEditingController _addressController = TextEditingController();

  /// Picker for Profile Image Upload from Gallery
  final ImagePicker _picker = ImagePicker();

  /// Placeholder for uploaded profile photo
  File? image;

  /// Placeholder for profile photo download url, used in displaying
  String imageUrl = "";

  @override
  Widget build(BuildContext context) {
    /// Height double obtained via MediaQuery, used in dyanmic sizing
    double height = MediaQuery.of(context).size.height;

    /// Width double obtained via MediaQuery, used in dyanmic sizing
    double width = MediaQuery.of(context).size.width;
    return Container(
      width: width * 0.8,
      padding: EdgeInsets.all(width * 0.02),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Formatted title/subtitle widget, defined in shared widgets file
              const SignupTitle('Welcome to HuskyExpress',
                  'Let\'s finish creating your Profile with some basic Information'),
              SizedBox(height: height * 0.01),
              // Form to validate info is provided for profile db population
              // Utilized FormState key in parent SignUp widget
              Form(
                key: widget.formKey,
                child: Column(children: [
                  // Gesture detector used to init upload profile image & display process
                  GestureDetector(
                    onTap: () {
                      getGalleryImage();
                      uploadProfileImage();
                    },
                    child: Container(
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
                      // If imageUrl populated, use to display the profile photo
                      child: imageUrl != ""
                          ? CircleAvatar(
                              radius: width * 0.16,
                              backgroundImage:
                                  NetworkImage(imageUrl.toString()),
                            )
                          : Center(
                              child: Icon(Icons.file_upload_rounded,
                                  size: height * 0.12, color: Colors.grey)),
                    ),
                  ),
                  SizedBox(height: height * 0.016),
                  TextFormField(
                    controller: _firstNameController,
                    textInputAction: TextInputAction.done,
                    autovalidateMode: AutovalidateMode.always,
                    decoration: const InputDecoration(
                      labelText: 'First Name',
                      icon: Icon(Icons.badge),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      widget.user.firstName = value;
                    },
                    // Must provide first name
                    validator: (value) {
                      if (value!.isEmpty) {
                        return '* Required Field';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: height * 0.01),
                  TextFormField(
                    controller: _lastNameController,
                    textInputAction: TextInputAction.done,
                    autovalidateMode: AutovalidateMode.always,
                    decoration: const InputDecoration(
                      labelText: 'Last Name',
                      icon: Icon(Icons.badge),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      widget.user.lastName = value;
                    },
                    // Must provide last name
                    validator: (value) {
                      if (value!.isEmpty) {
                        return '* Required Field';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: height * 0.01),
                  TextFormField(
                    controller: _phoneNoController,
                    textInputAction: TextInputAction.done,
                    autovalidateMode: AutovalidateMode.always,
                    decoration: const InputDecoration(
                      labelText: 'Phone #',
                      icon: Icon(Icons.phone),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      widget.user.phoneNo = value;
                    },
                    // Validates phone # provided in format is recognized
                    validator: (value) {
                      if (value!.isEmpty) {
                        return '* Required Field';
                      } else if (!FieldValidator.validatePhoneNo(value)) {
                        return 'Input does not appear to be a valid Phone No.';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: height * 0.01),
                  TextFormField(
                    controller: _addressController,
                    textInputAction: TextInputAction.done,
                    autovalidateMode: AutovalidateMode.always,
                    decoration: const InputDecoration(
                      labelText: 'Home Address',
                      icon: Icon(Icons.home),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      widget.user.savedLocations['home'] = value;
                    },
                    // Must provided home address
                    validator: (value) {
                      if (value!.isEmpty) {
                        return '* Required Field';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: height * 0.005),
                  // Checkbox to communicate is User intends to Host rides
                  CheckboxListTileFormField(
                    title: const Text(
                      '\t\tI intend to be a Ride Host',
                      style: TextStyle(fontSize: 16),
                    ),
                    initialValue: false,
                    // autovalidateMode: AutovalidateMode.always,
                    checkColor: Colors.white,
                    onChanged: (value) {
                      widget.user.isHostAccount = value;
                    },
                    dense: true,
                  )
                ]),
              )
            ],
          ),
        ),
      ),
    );
  }

  /// Uses the [ImagePicker] to get a profile image from the Phone Gallery
  Future<void> getGalleryImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;
      // Converts image to file and updates the placeholder value
      final imageTemp = File(image.path);
      setState(() {
        this.image = imageTemp;
      });
    } on Exception catch (e) {
      print(e);
    }
  }

  /// Uploaded the chosen gallery photo to [FirebaseFirestore], indexed by usedId
  Future<void> uploadProfileImage() async {
    if (image == null) return;
    final _storage = FirebaseStorage.instance;

    try {
      // Name the firestore reference with the user's ID for easy access
      Reference ref = _storage.ref().child('${widget.user.userDocId}.jpg');
      await ref.putFile(image!).whenComplete(() async {
        final url = await ref.getDownloadURL();
        setState(() {
          imageUrl = url;
          widget.user.pfpId = '${widget.user.userDocId}.jpg';
          widget.user.photoInd = url;
        });
      });
    } on FirebaseException catch (e) {
      print('Error Uploading Image: ${e}');
    }
  }
}
