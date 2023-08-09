import 'package:carpool_app/main/main_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'app_state.dart';
import 'main/auth_pages/forgot_password.dart';
import 'main/auth_pages/login_page.dart';
import 'main/auth_pages/signup_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "lib/.env");
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  await Firebase.initializeApp();
  // Utilize Change Notifier to assist with Listening to App State and navigation
  runApp(ChangeNotifierProvider(
    create: (context) => ApplicationState(),
    builder: ((context, child) => const MyApp()),
  ));
}

/// [GoRouter] router to control navigations through the Application sections
final _appRouter = GoRouter(routes: [
  GoRoute(
      name: 'App Base Level',
      path: '/',
      builder: (context, state) => MyHomePage(),
      routes: [
        GoRoute(
            name: 'Login Page',
            path: 'sign-in',
            builder: (context, state) => LoginPage(),
            routes: [
              GoRoute(
                  name: 'Forgot Password Page',
                  path: 'forgot-password',
                  builder: (context, state) {
                    return ForgotPasswordPage();
                  }),
            ]),
        GoRoute(
          name: 'Create Account Page(s)',
          path: 'sign-up',
          builder: (context, state) => SignUpPage(),
        ),
        GoRoute(
          name: 'User Home Page',
          path: 'home',
          builder: (context, state) => MainPage(),
        ),
      ]),
]);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  /// Defines App as StatelessWidget with a router for navigation
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'HuskyExpress Carpool App',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      debugShowCheckedModeBanner: false,
      routerConfig: _appRouter,
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  /// Uses an appState [Consumer] to check status of User
  /// - if logged-in and profile data populated in the db, routes to Main Page
  /// - if above criteria not met, routes to Login Page
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Consumer<ApplicationState>(
          builder: (context, appState, _) =>
              appState.loggedIn && appState.userPopulated
                  ? MainPage()
                  : LoginPage()),
    ));
  }
}
