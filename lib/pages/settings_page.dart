import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:soul_talk/components/my_settings_tile.dart';
import 'package:soul_talk/helper/navigate_pages.dart';
import 'package:soul_talk/themes/theme_provider.dart';

/*
SETTINGS PAGE

-Dark mode
-Blocked Users
-Account settings

 */

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,

      //App bar
      appBar: AppBar(
        title: const Text("S E T T I N G S"),
        foregroundColor: Theme.of(context).colorScheme.primary,
        centerTitle: true,
      ),

      //body
      body: Column(
        children: [
          //dark mode tile
          MySettingsTile(
            title: "Dark Mode",
            action: CupertinoSwitch(
              onChanged: (value) =>
                  Provider.of<ThemeProvider>(context, listen: false)
                      .toggleTheme(),
              value:
                  Provider.of<ThemeProvider>(context, listen: false).isDarkMode,
            ),
          ),

          //Blockk user tile
          GestureDetector(
            onTap: () => goToBlockedUserPage(context),
            child: MySettingsTile(
              title: "Blocked Users",
              action: Padding(
                padding: const EdgeInsets.all(3),
                child: Icon(
                  Icons.arrow_forward,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
          

          //Account settings tile
           GestureDetector(
            onTap: () => goAccountSettingsPage(context),
            child: MySettingsTile(
              title: "Account Settings",
              action: Padding(
                padding: const EdgeInsets.all(3),
                child: Icon(
                  Icons.arrow_forward,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
