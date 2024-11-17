import 'package:flutter/material.dart';
import 'package:soul_talk/components/my_button.dart';
import 'package:soul_talk/components/my_loading_circle.dart';
import 'package:soul_talk/components/my_text_field.dart';
import 'package:soul_talk/services/auth/auth_service.dart';

class LoginPage extends StatefulWidget {
  final void Function()? onTap;
  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  //access the auth service
  final _auth = AuthService();

  //text controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController pwController = TextEditingController();

  //login method
  void login() async {
    //show loading circle
    showLoadingCircle(context);

    //attempt login
    try {
      await _auth.loginEmailPassword(emailController.text, pwController.text);

      //finish loading circle
      if (mounted) hideLoadingCircle(context);
    }

    //catch any errors
    catch (e) {
      //finished loading
      if (mounted) hideLoadingCircle(context);

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(e.toString()),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 50),
                //logo
                Icon(
                  Icons.lock_open_rounded,
                  size: 72,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 25),

                //Welcome back message
                Text(
                  "Welcome Back, you've been missed!",
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 25),

                //emial textfield
                MyTextField(
                  controller: emailController,
                  hintText: "Enter your Email...",
                  obscureText: false,
                ),
                const SizedBox(height: 10),

                //password
                MyTextField(
                  controller: pwController,
                  hintText: "Enter Password...",
                  obscureText: true,
                ),
                const SizedBox(height: 10),

                //forgot password
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    "Forgot Password..?",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                //signin button
                MyButton(
                  onTap: login,
                  text: "Login",
                ),
                const SizedBox(height: 50),

                //not a member , register now text to go to register page
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Not a member?",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 5),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: Text(
                        "Register Now",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
