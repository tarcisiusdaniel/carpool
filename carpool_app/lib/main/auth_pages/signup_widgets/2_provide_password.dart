import 'package:carpool_app/main/auth_pages/signup_widgets/shared_widgets.dart';
import '../../utils/field_validator.dart';
import 'package:flutter/material.dart';

class ProvidePassword extends StatefulWidget {
  /// FormState Key used to validate the provided password meets criteria
  GlobalKey<FormState> formKey;

  /// Class to house User Information as it is obtained during signup process
  UserData user;

  ProvidePassword({super.key, required this.user, required this.formKey});

  @override
  State<ProvidePassword> createState() => _ProvidePasswordState();
}

class _ProvidePasswordState extends State<ProvidePassword> {
  /// Controller to hold provided password value
  static TextEditingController _passwordController = TextEditingController();

  /// Controller to hold confirm password value
  static TextEditingController _confirmController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    /// Height double obtained via MediaQuery, used in dyanmic sizing
    double height = MediaQuery.of(context).size.height;

    /// Width double obtained via MediaQuery, used in dyanmic sizing
    double width = MediaQuery.of(context).size.width;
    return Container(
        width: width * 0.8,
        padding: EdgeInsets.all(width * 0.04),
        child: Center(
            child: SingleChildScrollView(
          child: Column(children: [
            // Formatted title/subtitle widget, defined in shared widgets file
            const SignupTitle('Welcome to HuskyExpress',
                'Next, create a password with the following criteria:'),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('* At least 1 letter',
                    style: TextStyle(
                        fontSize: height * 0.014,
                        fontWeight: FontWeight.bold,
                        color: Colors.red)),
                Text('* At least 1 number',
                    style: TextStyle(
                        fontSize: height * 0.014,
                        fontWeight: FontWeight.bold,
                        color: Colors.red)),
                Text('* At least 1 special character',
                    style: TextStyle(
                        fontSize: height * 0.014,
                        fontWeight: FontWeight.bold,
                        color: Colors.red)),
              ],
            ),
            SizedBox(height: height * 0.032),
            // Form to verify that the provided password meets criteria
            Form(
              key: widget.formKey,
              child: Column(children: [
                TextFormField(
                  controller: _passwordController,
                  textInputAction: TextInputAction.next,
                  autovalidateMode: AutovalidateMode.always,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Enter your new Password',
                    icon: Icon(Icons.password),
                    border: OutlineInputBorder(),
                  ),
                  // Validator for use with key in parent SignUp Page to control
                  // sign-up navigation iteratively
                  validator: (value) {
                    if (value!.isEmpty) {
                      return '* Required Field';
                    } else if (!FieldValidator.validatePassword(value)) {
                      return 'Password must have at least 1 number, 1 letter, and 1 special character';
                    }
                    return null;
                  },
                ),
                SizedBox(height: height * 0.032),
                TextFormField(
                  controller: _confirmController,
                  textInputAction: TextInputAction.done,
                  autovalidateMode: AutovalidateMode.always,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Confirm your new Password',
                    icon: Icon(Icons.password),
                    border: OutlineInputBorder(),
                  ),
                  // Updates user password value, used later to sign in
                  // Password is not written to database as part of profile info
                  onChanged: (value) {
                    widget.user.password = value;
                  },
                  // Validator for use with key in parent SignUp Page to control
                  // sign-up navigation iteratively
                  validator: (value) {
                    if (value!.isEmpty) {
                      return '* Required Field';
                    } else if (!FieldValidator.inputsMatch(
                        value.trim(), _passwordController.text.trim())) {
                      return 'Password inputs must Match';
                    }
                    return null;
                  },
                ),
              ]),
            ),
          ]),
        )));
  }
}
