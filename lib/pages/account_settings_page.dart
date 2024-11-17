import 'package:flutter/material.dart';
import 'package:soul_talk/services/auth/auth_service.dart';

class AccountSettingsPage extends StatefulWidget {
  const AccountSettingsPage({super.key});

  @override
  State<AccountSettingsPage> createState() => _AccountSettingsPageState();
}

class _AccountSettingsPageState extends State<AccountSettingsPage> {
  void confirmDeletion(BuildContext content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete Account"),
        content: Text("Are you sure you want to delete your Account?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              await AuthService().deleteAccount();

              Navigator.pushNamedAndRemoveUntil(
                context,
                '/',
                (route) => false,
              );
            },
            child: const Text(
              "Delete",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text("A C C O U N T"),
        centerTitle: true,
        foregroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              top: 30,
            ),
            child: Align(
              alignment: Alignment.center,
              child: Text(
                "Permanently Delete Your Account!",
                style: TextStyle(
                    fontSize: 20, color: Theme.of(context).colorScheme.primary),
              ),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.only(top: 30, left: 15, right: 15, bottom: 10),
            child: Align(
              alignment: Alignment.center,
              child: Text(
                "This will Permanently Delete Your SoulTalk Account. Deleting your account will completely remove all of you information from our database. This cannot be undone.",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 15, color: Theme.of(context).colorScheme.primary),
              ),
            ),
          ),
          GestureDetector(
            onTap: () => confirmDeletion(context),
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.all(25),
                  padding: EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                      child: Text(
                    "Delete Account",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white),
                  )),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
