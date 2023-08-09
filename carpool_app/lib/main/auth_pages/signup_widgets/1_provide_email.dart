import 'package:carpool_app/main/auth_pages/signup_widgets/shared_widgets.dart';
import '../../utils/field_validator.dart';
import 'package:flutter/material.dart';

class ProvideEmail extends StatefulWidget {
  /// FormState Key used to validate the provided email and nuid formats
  GlobalKey<FormState> formKey;

  /// Class to house User Information as it is obtained during signup process
  UserData user;

  ProvideEmail({super.key, required this.user, required this.formKey});

  @override
  State<ProvideEmail> createState() => _ProvideEmailState();
}

class _ProvideEmailState extends State<ProvideEmail> {
  /// Controller to hold provided email value
  static TextEditingController _emailController = TextEditingController();

  /// Controller to hold provided confirm email value
  static TextEditingController _confirmController = TextEditingController();

  /// Controller to hold provided nuid is 9-digits and parseable as int
  static TextEditingController _nuidController = TextEditingController();

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
          child: Column(
            children: [
              // Formatted title/subtitle widget, defined in shared widgets file
              const SignupTitle('Welcome to HuskyExpress',
                  'Let\'s start Signing-Up by providing your NEU Email (or Gmail) & NUID'),
              SizedBox(height: height * 0.03),
              // Form with text form fields to validate email, confirm email, and nuid
              Form(
                key: widget.formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _emailController,
                      textInputAction: TextInputAction.next,
                      autovalidateMode: AutovalidateMode.always,
                      decoration: const InputDecoration(
                        labelText: 'Enter your Gmail or NEU Email Address',
                        icon: Icon(Icons.email),
                        border: OutlineInputBorder(),
                      ),
                      // Validator for use with key in parent SignUp Page to control
                      // sign-up navigation iteratively
                      validator: (value) {
                        if (value!.isEmpty) {
                          return '* Required Field';
                        } else if (!FieldValidator.validateEmail(
                            value.trim())) {
                          return 'Enter valid email (e.g. example@northeastern.edu)';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: height * 0.024),
                    TextFormField(
                      controller: _confirmController,
                      textInputAction: TextInputAction.next,
                      autovalidateMode: AutovalidateMode.always,
                      decoration: const InputDecoration(
                        labelText: 'Confirm your Email Address',
                        icon: Icon(Icons.mark_email_read),
                        border: OutlineInputBorder(),
                      ),
                      // Updates housed user email value
                      onChanged: (value) {
                        widget.user.email = value;
                      },
                      // Validator for use with key in parent SignUp Page to control
                      // sign-up navigation iteratively
                      validator: (value) {
                        if (value!.isEmpty) {
                          return '* Required Field';
                        } else if (!FieldValidator.validateEmail(
                            value.trim())) {
                          return 'Enter valid email (e.g. example@northeastern.edu)';
                        } else if (!FieldValidator.inputsMatch(
                            _emailController.text.trim(), value.trim())) {
                          return 'Email inputs must Match';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: height * 0.024),
                    TextFormField(
                      controller: _nuidController,
                      textInputAction: TextInputAction.done,
                      autovalidateMode: AutovalidateMode.always,
                      decoration: const InputDecoration(
                        labelText: 'Enter your 9-digit NUID',
                        icon: Icon(Icons.pin),
                        border: OutlineInputBorder(),
                      ),
                      // Updates housed user nuid value
                      onChanged: (value) {
                        widget.user.nuid = value;
                      },
                      // Validator for use with key in parent SignUp Page to control
                      // sign-up navigation iteratively
                      validator: (value) {
                        if (value!.isEmpty) {
                          return '* Required Field';
                        } else if (!FieldValidator.validateNUID(value.trim())) {
                          return 'Enter valid 9-digit NUID';
                        }
                        return null;
                      },
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
