import 'package:carpool_app/main/auth_pages/signup_widgets/shared_widgets.dart';
import 'package:flutter/material.dart';

class ReviewProfile extends StatefulWidget {
  /// Key not utilized, review fields verified in previous signup steps
  GlobalKey<FormState> formKey;

  /// Class to house User Information as it is obtained during signup process
  UserData user;

  ReviewProfile({
    Key? key,
    required this.user,
    required this.formKey,
  }) : super(key: key);

  @override
  _ReviewProfileState createState() => _ReviewProfileState();
}

class _ReviewProfileState extends State<ReviewProfile> {
  @override
  Widget build(BuildContext context) {
    /// height double obtained via MediaQuery, used in dyanmic sizing
    double height = MediaQuery.of(context).size.height;

    /// Width double obtained via MediaQuery, used in dyanmic sizing
    double width = MediaQuery.of(context).size.width;
    return Container(
      width: width * 0.8,
      padding: EdgeInsets.all(width * 0.04),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Formatted title/subtitle widget, defined in shared widgets file
            const SignupTitle('Welcome to HuskyExpress',
                'Review your information & create your Account'),
            SizedBox(height: height * 0.015),
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
              // If profile photo exists, display in review
              child: widget.user.photoInd != ""
                  ? CircleAvatar(
                      radius: width * 0.16,
                      backgroundImage:
                          NetworkImage(widget.user.photoInd.toString()),
                    )
                  : Center(
                      child: Icon(Icons.person,
                          size: height * 0.12, color: Colors.grey)),
            ),
            SizedBox(height: height * 0.015),
            RichText(
                text: TextSpan(
                    text: 'Name: ',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black),
                    children: [
                  TextSpan(
                      text:
                          '${widget.user.firstName} ${widget.user.lastName[0].toUpperCase()}.',
                      style: const TextStyle(
                          color: Colors.black, fontWeight: FontWeight.normal)),
                ])),
            SizedBox(height: height * 0.015),
            RichText(
                text: TextSpan(
                    text: 'Email: ',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black),
                    children: [
                  TextSpan(
                      text: widget.user.email,
                      style: const TextStyle(
                          color: Colors.black, fontWeight: FontWeight.normal)),
                ])),
            SizedBox(height: height * 0.015),
            RichText(
                text: TextSpan(
                    text: 'Phone: ',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black),
                    children: [
                  TextSpan(
                      text: widget.user.phoneNo,
                      style: const TextStyle(
                          color: Colors.black, fontWeight: FontWeight.normal)),
                ])),
            SizedBox(height: height * 0.015),
            RichText(
                text: TextSpan(
                    text: 'Address: ',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black),
                    children: [
                  TextSpan(
                      text: widget.user.savedLocations['home'],
                      style: const TextStyle(
                          color: Colors.black, fontWeight: FontWeight.normal)),
                ])),
          ],
        ),
      ),
    );
  }
}
