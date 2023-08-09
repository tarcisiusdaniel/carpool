import 'package:carpool_app/main/utils/field_validator.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatelessWidget {
  /// Key for Login Field [FormState] used for format validation
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  /// Controller to house email value
  final _emailController = TextEditingController();

  /// Controller to hold password value
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    /// Height double obtained via MediaQuery, used in dyanmic sizing
    double height = MediaQuery.of(context).size.height;

    /// Width double obtained via MediaQuery, used in dyanmic sizing
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(title: const Text('HuskyExpress Login')),
        body: Center(
            child: Container(
          width: width * 0.9,
          padding: EdgeInsets.all(width * 0.02),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Welcome to HuskyExpress!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: height * 0.032,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor)),
              SizedBox(height: width * 0.036),
              Text(
                'NEU Seattle\'s premiere Student Carpooling App',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Color.fromARGB(255, 115, 115, 115),
                    fontSize: width * 0.032),
              ),
              SizedBox(height: height * 0.032),
              // Login fields as form in order to hold state and validate format
              // FieldValidator helper class used for validation
              Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _emailController,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                            icon: Icon(Icons.email),
                            labelText: 'Northeastern Email or Gmail',
                            border: OutlineInputBorder()),
                        // Validates that email is formatted as northeastern or gmail
                        validator: (String? email) {
                          if (email!.isEmpty) {
                            return "* Required Field";
                          } else if (!FieldValidator.validateEmail(
                              email.trim())) {
                            return "Enter a valid NEU Email or Gmail Address";
                          } else {
                            return null;
                          }
                        },
                      ),
                      SizedBox(height: height * 0.005),
                      TextFormField(
                        controller: _passwordController,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        textInputAction: TextInputAction.done,
                        obscureText: true,
                        decoration: const InputDecoration(
                            icon: Icon(Icons.lock),
                            labelText: 'Password',
                            border: OutlineInputBorder()),
                        // Validates that pwd is formatted with proper security guidelines
                        validator: (String? password) {
                          if (password!.isEmpty) {
                            return "* Required Field";
                          } else if (!FieldValidator.validatePassword(
                              password.trim())) {
                            return "* At least 1 letter, 1 number, and 1 special character";
                          } else {
                            return null;
                          }
                        },
                      ),
                    ],
                  )),
              SizedBox(height: height * 0.005),
              // Button to log the user into the application
              OutlinedButton.icon(
                onPressed: () => {
                  // showDialog(
                  //     context: context,
                  //     barrierDismissible: false,
                  //     builder: (context) => const Center(
                  //           child: CircularProgressIndicator(),
                  //         )),
                  signIn(_emailController.text.trim(),
                          _passwordController.text.trim())
                      .whenComplete(() => context.pushReplacement('/home'))
                      .onError((error, stackTrace) => print(error)),
                },
                icon: const Icon(Icons.login),
                label: const Text('Login'),
              ),
              SizedBox(height: height * 0.01),
              // Button to navigate user to the Forgot Password page
              OutlinedButton.icon(
                onPressed: () => context.push('/sign-in/forgot-password'),
                icon: const Icon(Icons.help_outline),
                label: const Text('Forgot Password?'),
              ),
              SizedBox(height: height * 0.0036),
              // Button to navigate new users to the Sign Up process
              OutlinedButton.icon(
                onPressed: () => context.go('/sign-up'),
                icon: const Icon(Icons.edit_square),
                label: const Text('Sign Up'),
              ),
            ],
          ),
        )));
  }

  /// Signs the User in with valid email and password via [FirebaseAuth]
  Future<void> signIn(String email, String password) async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password);
      } on FirebaseAuthException catch (e) {
        print(e);
      }
    }
  }
}
