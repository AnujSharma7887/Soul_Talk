import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:soul_talk/pages/home_page.dart';
import 'package:soul_talk/services/auth/login_or_register.dart';

/*
  AUTH DATE

  this file checks if the user is logged in or not
  --------------------------------------------------------------------------

  if the user is logged in -> go to homepage

  if the user is not logged in -> go to register page

*/

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return const HomePage();
          } else {
            return const LoginOrRegister();
          }
        },
      ),
    );
  }
}
