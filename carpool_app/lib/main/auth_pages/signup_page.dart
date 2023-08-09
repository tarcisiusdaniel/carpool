import 'package:carpool_app/main/auth_pages/signup_widgets/0_term_agreement.dart';
import 'package:carpool_app/main/auth_pages/signup_widgets/1_provide_email.dart';
import 'package:carpool_app/main/auth_pages/signup_widgets/2_provide_password.dart';
import 'package:carpool_app/main/auth_pages/signup_widgets/3_attemptVerify.dart';
import 'package:carpool_app/main/auth_pages/signup_widgets/4_provide_info.dart';
import 'package:carpool_app/main/auth_pages/signup_widgets/5_review_profile.dart';

import 'package:carpool_app/main/auth_pages/signup_widgets/shared_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// List of [FormState] keys used to perform step-by-step validation in signup
/// Keys used to prevent navigation to next step if invalid in current step
List<GlobalKey<FormState>> formKeys = [
  GlobalKey<FormState>(),
  GlobalKey<FormState>(),
  GlobalKey<FormState>(),
  GlobalKey<FormState>(),
  GlobalKey<FormState>(),
  GlobalKey<FormState>(),
];

class SignUpPage extends StatefulWidget {
  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  /// Class to house User Information as it is obtained during signup process
  UserData newUser = UserData();

  /// Current page used as index during signup process
  int currentPage = 0;

  /// Controller to control navigation to each page of signup procedure
  final PageController _signupPageController =
      PageController(initialPage: 0, keepPage: true);

  /// Defines the steps of the signup procedure
  /// Instance of [UserData] updated iteratively each step
  /// A [GlobalKey] is provided to each step to perform validation
  List<Widget> getSteps(UserData user, List<GlobalKey<FormState>> formKeys) {
    return [
      TermAgreement(user: user, formKey: formKeys[0]),
      ProvideEmail(user: user, formKey: formKeys[1]),
      ProvidePassword(user: user, formKey: formKeys[2]),
      VerifyEmail(user: user, formKey: formKeys[3]),
      ProvideInfo(user: user, formKey: formKeys[4]),
      ReviewProfile(user: user, formKey: formKeys[5])
    ];
  }

  /// List of Titles as [String] values to pass as AppBar Titles
  /// Indexed along with Steps during navigation of singup process
  List<String> stepTitles = [
    'Agree to Terms of Service',
    'Provide Email & NUID',
    'Create Password',
    'Verify Email',
    'Provide Profile Info',
    'Review & Create Account'
  ];

  @override
  void dispose() {
    _signupPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /// Width double obtained via MediaQuery, used in dyanmic sizing
    double height = MediaQuery.of(context).size.height;

    /// Width double obtained via MediaQuery, used in dyanmic sizing
    double width = MediaQuery.of(context).size.width;

    /// Steps of signup process as [List] for indexing iteratively
    List steps = getSteps(newUser, formKeys);

    /// Int used to identify number of steps for [PageView.builder]
    int numSteps = steps.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${stepTitles[currentPage]} - Step ${currentPage + 1} / ${numSteps.toString()}',
          style: const TextStyle(fontSize: 16),
        ),
        backgroundColor: Colors.red,
      ),
      body: Container(
          padding: EdgeInsets.all(width * 0.04),
          // PageView builder used to build each page of the signup process
          child: PageView.builder(
            itemCount: numSteps,
            physics: const NeverScrollableScrollPhysics(),
            controller: _signupPageController,
            onPageChanged: (page) {
              setState(() {
                currentPage = page;
              });
            },
            itemBuilder: (context, position) {
              return steps[position];
            },
          )),
      resizeToAvoidBottomInset: false,
      floatingActionButton: Container(
          padding: EdgeInsets.all(width * 0.04),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Button to navigate to previous step in signup if one exists
              // Navigates back to LoginPage if on first step
              FloatingActionButton(
                key: const Key('backwardNav'),
                heroTag: 'backwardNav',
                onPressed: () {
                  if (currentPage > 0) {
                    _signupPageController.jumpToPage(currentPage - 1);
                  } else {
                    context.pushReplacement('/sign-in');
                  }
                },
                backgroundColor: (currentPage == 0)
                    ? Color.fromARGB(255, 111, 111, 111)
                    : Colors.red,
                child: (currentPage == 0)
                    ? const Text('Cancel')
                    : const Icon(Icons.navigate_before),
              ),
              // Button to navigate to next step in signup if one exists
              // - Does not allow forward navigation if formKey returns invalid
              // - Step 3: creates user with email/password & signs them in
              // - Step 4: checks for email verification before allowing forward nav
              // - Final Step: Populates db with UserData, navigates to Landing
              FloatingActionButton(
                key: const Key('forwardNav'),
                heroTag: 'forwardNav',
                onPressed: () {
                  if (currentPage == 2) {
                    if (formKeys[currentPage].currentState!.validate()) {
                      createUser(newUser);
                      _signupPageController.jumpToPage(currentPage + 1);
                    }
                  } else if (currentPage == 3) {
                    if (FirebaseAuth.instance.currentUser!.emailVerified) {
                      _signupPageController.jumpToPage(currentPage + 1);
                    }
                  } else if (currentPage == numSteps - 1) {
                    populateUserData(newUser);
                    context.pushReplacement('/home');
                  } else {
                    if (formKeys[currentPage].currentState!.validate()) {
                      _signupPageController.jumpToPage(currentPage + 1);
                    }
                  }
                },
                backgroundColor:
                    (currentPage == numSteps - 1) ? Colors.green : Colors.red,
                child: (currentPage == numSteps - 1)
                    ? const Icon(Icons.person_add)
                    : const Icon(Icons.navigate_next),
              ),
            ],
          )),
    );
  }

  /// Creates the User with email and password via [FirebaseAuth]
  /// Stores the Auth uid for defining User profile db index
  Future<void> createUser(UserData data) async {
    try {
      UserCredential cred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: data.email, password: data.password);
      data.userDocId = cred.user!.uid;
    } on FirebaseAuthException catch (e) {
      print('Error creating user: ${e.code}');
      print(e);
    }
  }

  /// Using the iteratively populated [UserData] field, writes the Users info to db
  /// Uses the User's auth uid as the doc id for profile info for easy access
  Future<void> populateUserData(UserData user) async {
    try {
      await FirebaseFirestore.instance
          .collection('User')
          .doc(newUser.userDocId)
          .set({
        'firstName': newUser.firstName,
        'lastName': newUser.lastName,
        'nuid': newUser.nuid,
        'email': newUser.email,
        'phoneNo': newUser.phoneNo,
        'pfpId': newUser.pfpId,
        'savedLocations': newUser.savedLocations,
        'isHostAccount': newUser.isHostAccount,
        'photoIndex': newUser.photoInd,
        'rideIds': newUser.rideIds,
      });
    } on FirebaseException catch (e) {
      print('Error on writing UserData to Firestore: ${e.code}');
    }
  }
}
