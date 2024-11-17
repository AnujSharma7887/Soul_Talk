import 'package:flutter/material.dart';
import 'package:soul_talk/components/my_button.dart';
import 'package:soul_talk/components/my_loading_circle.dart';
import 'package:soul_talk/components/my_text_field.dart';
import 'package:soul_talk/services/auth/auth_service.dart';
import 'package:soul_talk/services/database/database_service.dart';

/*
  Register page

  usr can create  a new account from here

  field contains :
  -name 
  -email
  -password
  -confirm password

  once successfully registered user will be redirected to home page.

  if already has an accoun? redirect to login page
 */

class RegisterPage extends StatefulWidget {
  final void Function()? onTap;
  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  //access the auth service
  final _auth = AuthService();
  final _db = DatabaseService();

  //text controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController pwController = TextEditingController();
  final TextEditingController confirmPwController = TextEditingController();

  //register button
  void register() async {
    if (pwController.text == confirmPwController.text) {
      showLoadingCircle(context);

      try {
        await _auth.registerEmailPassword(
          emailController.text,
          pwController.text,
        );

        if (mounted) hideLoadingCircle(context);

        //once registered, create and save profile in databse

        await _db.saveUserInfoInFirebase(
          name: nameController.text,
          email: emailController.text,
        );
      }
      //catch any errors
      catch (e) {
        if (mounted) hideLoadingCircle(context);

        //let usr know that what went wrong
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(e.toString()),
            ),
          );
        }
      }
    } else {
      showDialog(
        context: context,
        builder: (context) => const AlertDialog(
          title: Text("Password Do not match"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 100),
                  //logo
                  Icon(
                    Icons.lock_open_rounded,
                    size: 72,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 25),

                  //Create an account  message
                  Text(
                    "Let's create an account for you!..",
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 25),

                  //name text field
                  MyTextField(
                    controller: nameController,
                    hintText: "Enter your Name...",
                    obscureText: false,
                  ),
                  const SizedBox(height: 10),

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

                  MyTextField(
                    controller: confirmPwController,
                    hintText: "Confirm Password...",
                    obscureText: true,
                  ),
                  const SizedBox(height: 10),

                  //sign up button
                  MyButton(
                    onTap: register,
                    text: "Register",
                  ),
                  const SizedBox(height: 50),

                  //Already a member? go to login page
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already a member?",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 5),

                      //user can tap here and go to login page
                      GestureDetector(
                        onTap: widget.onTap,
                        child: Text(
                          "Login here",
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
      ),
    );
  }
}
