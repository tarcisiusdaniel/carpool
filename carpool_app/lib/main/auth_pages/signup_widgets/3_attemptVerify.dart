import 'dart:async';

import 'package:carpool_app/app_state.dart';
import 'package:carpool_app/main/auth_pages/signup_widgets/shared_widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class VerifyEmail extends StatefulWidget {
  /// Key not utilized, email verification check handled using Auth in SignUp file
  GlobalKey<FormState> formKey;

  /// Class to house User Information as it is obtained during signup process
  UserData user;

  VerifyEmail({super.key, required this.user, required this.formKey});

  @override
  State<VerifyEmail> createState() => _VerifyEmailState();
}

class _VerifyEmailState extends State<VerifyEmail> {
  /// [Timer] utilized to periodically check email verification status
  Timer? timer;

  /// Value to store whether email is verified, updated by [checkEmailVerified]
  bool isEmailVerified = false;

  /// Establishes a timer to check email verification status every 5sec
  /// [Timer] canceled on email verfied in [checkEmailVerified] method
  @override
  void initState() {
    super.initState();

    if (!isEmailVerified) {
      timer = Timer.periodic(
        const Duration(seconds: 5),
        (_) => checkEmailVerified(),
      );
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /// Height double obtained via MediaQuery, used in dyanmic sizing
    double height = MediaQuery.of(context).size.height;

    /// Width double obtained via MediaQuery, used in dyanmic sizing
    double width = MediaQuery.of(context).size.width;

    return Container(
        padding: EdgeInsets.all(width * 0.04),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Formatted title/subtitle widget, defined in shared widgets file
                const SignupTitle('Welcome to HuskyExpress',
                    'Send a Verification Email and verify your identity to continue Account Creation'),
                // Consumer to listen to AppState in order to display verificiation status
                // - Red Locked icon and not verified message displayed if false
                // - Green Unlocked icon and verified message displayed if true
                Consumer<ApplicationState>(
                  builder: (context, appState, _) {
                    return Container(
                      padding: EdgeInsets.all(width * 0.04),
                      child: Column(children: [
                        Center(
                            child: appState.loggedIn && appState.emailVerified
                                ? Icon(
                                    Icons.lock_open,
                                    color: Colors.green,
                                    size: height * 0.28,
                                  )
                                : Icon(Icons.lock,
                                    color: Colors.red, size: height * 0.28)),
                        SizedBox(height: height * 0.032),
                        appState.loggedIn && appState.emailVerified
                            ? const Text(
                                'Congratulations, you have verified your email!')
                            : const Text(
                                'Send and check your email to verify your Account'),
                      ]),
                    );
                  },
                ),
                SizedBox(height: height * 0.032),
                // Button to call sendEmailVerification method
                ElevatedButton(
                    onPressed: () {
                      sendEmailVerification();
                    },
                    child: const Text('Send Verification Email')),
              ],
            ),
          ),
        ));
  }

  /// Checks the boolean value of [emailVerified] via [FirebaseAuth]
  Future checkEmailVerified() async {
    print('Attempting Check Verification Status');
    var user = FirebaseAuth.instance.currentUser!;
    // Reload user to check for updated email verification status
    FirebaseAuth.instance.currentUser!.reload();
    setState(() {
      isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    });
    // Cancels timer upon isEmailVerified == true
    if (isEmailVerified) timer?.cancel();
  }

  /// Sends a verification email to the email provided by User in a prev step
  Future<void> sendEmailVerification() async {
    FirebaseAuth _auth = FirebaseAuth.instance;
    if (_auth.currentUser != null) {
      try {
        await _auth.currentUser!.sendEmailVerification();
      } on FirebaseAuthException catch (e) {
        print(e.code);
        print('Error on send Email Verification:\n ${e}');
      }
    } else {
      print('No Current User signed in');
    }
  }
}
