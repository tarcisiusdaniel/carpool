import 'package:flutter/material.dart';

// Widget to display Signup Step information (Title + Instructions)
class SignupTitle extends StatelessWidget {
  const SignupTitle(this.title, this.subtitle, {super.key});

  /// Title field of the Step
  final String title;

  /// Subtitle field of the step, to help user understanding
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    /// Height double obtained via MediaQuery, used in dyanmic sizing
    double height = MediaQuery.of(context).size.width;

    /// Width double obtained via MediaQuery, used in dyanmic sizing
    double width = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.fromLTRB(
          width * 0.08, height * 0.02, width * 0.08, height * 0.02),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: height * 0.04,
                  fontWeight: FontWeight.bold,
                )),
            SizedBox(height: height * 0.02),
            Text(subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: height * 0.03, fontWeight: FontWeight.normal)),
          ]),
    );
  }
}

/// Houses all information needed to complete the signup process
/// Acts as a store for information before:
///   - creating Auth credential
///   - signing the user in
///   - verifying the users identity via email
///   - populating the users profile information
class UserData {
  String userDocId = '';
  String email = '';
  String nuid = '';
  String password = '';
  bool agreedToTerms = true;
  bool emailVerified = false;
  String photoInd = '';
  String firstName = '';
  String lastName = '';
  String phoneNo = '';
  bool isHostAccount = false;
  String pfpId = '';
  Map<String, String> savedLocations = {};
  List<String> rideIds = [];
}
