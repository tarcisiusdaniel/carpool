import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'
    hide EmailAuthProvider, PhoneAuthProvider;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';

class ApplicationState extends ChangeNotifier {
  ApplicationState() {
    init();
  }

  /// The login status of the Application User as a [bool]
  bool _loggedIn = false;
  bool get loggedIn => _loggedIn;
  set loggedIn(bool value) {
    _loggedIn = value;
  }

  /// The email verification status of the Application User as a [bool]
  bool _emailVerified = false;
  bool get emailVerified => _emailVerified;
  set emailVerified(bool value) {
    _emailVerified = value;
  }

  /// The user profile db populated status of the Application User as a [bool]
  bool _userPopulated = false;
  bool get userPopulated => _userPopulated;
  set userPopulated(bool value) {
    _userPopulated = value;
  }

  Future<void> init() async {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);

    FirebaseUIAuth.configureProviders([
      EmailAuthProvider(),
    ]);

    FirebaseAuth.instance.userChanges().listen((user) {
      if (user != null && !user.isAnonymous) {
        _loggedIn = true;
        if (user.emailVerified) {
          _emailVerified = true;
        }
        // Check that the User has stored information in the db
        FirebaseFirestore.instance
            .collection('User')
            .doc(user.uid)
            .get()
            .then((snapshot) => {_userPopulated = snapshot.exists});
      } else {
        _loggedIn = false;
      }
      notifyListeners();
    });
  }
}
