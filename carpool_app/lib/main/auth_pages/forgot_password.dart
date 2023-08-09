import 'package:carpool_app/main/auth_pages/signup_widgets/shared_widgets.dart';
import 'package:carpool_app/main/utils/field_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ForgotPasswordPage extends StatelessWidget {
  /// Key used to validate provided email is valid format (neu or gmail)
  GlobalKey<FormState> _formKey = GlobalKey();

  /// Controller to hold provided email string
  final TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    /// Width double obtained via MediaQuery, used in dyanmic sizing
    double height = MediaQuery.of(context).size.height;

    /// Width double obtained via MediaQuery, used in dyanmic sizing
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
        appBar: AppBar(
          title: const Text('Forgot Password Page'),
        ),
        body: Container(
            padding: EdgeInsets.all(height * 0.025),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: height * 0.025),
                  const SignupTitle(
                      'Oh No!\n Looks like your forgot your Password!',
                      'Let\'s reset it by sending an password reset email.'),
                  SizedBox(height: height * 0.032),
                  Form(
                    key: _formKey,
                    child: TextFormField(
                      controller: _emailController,
                      textInputAction: TextInputAction.done,
                      autovalidateMode: AutovalidateMode.always,
                      decoration: const InputDecoration(
                          icon: Icon(Icons.email),
                          border: OutlineInputBorder(),
                          labelText: 'Email Address'),
                      // Validates email is valid format then attempts reset
                      validator: (value) {
                        if (value!.isEmpty) {
                          return '* Must provide your email to reset your password';
                        } else if (!FieldValidator.validateEmail(
                            value.trim())) {
                          return 'Provided Email format is invalid';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(height: height * 0.02),
                  // Button to send password reset email
                  OutlinedButton.icon(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        sendPasswordResetEmail(
                            email: _emailController.text.trim());
                      }
                    },
                    icon: const Icon(Icons.send),
                    label: const Text('Send Password Reset Email'),
                  ),
                  SizedBox(height: height * 0.04),
                  // Button to navigate user back to login page
                  OutlinedButton.icon(
                      onPressed: () => context.go('/sign-in'),
                      icon: const Icon(Icons.login),
                      label: const Text('Back to Sign-In')),
                ],
              ),
            )));
  }

  /// Sends a password reset email via [FirebaseAuth]
  Future<void> sendPasswordResetEmail(
      {required String email, ActionCodeSettings? acs}) async {
    try {
      print('Attempt Reset Send; ${FirebaseAuth.instance}');
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      print(e.code);
      print('Error sending pwd reset:\n${e}');
      rethrow;
    }
  }
}
