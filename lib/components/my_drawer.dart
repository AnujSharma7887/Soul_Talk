import 'package:flutter/material.dart';
import 'package:soul_talk/components/my_drawer_tile.dart';
import 'package:soul_talk/pages/profile_page.dart';
import 'package:soul_talk/pages/search_page.dart';
import 'package:soul_talk/pages/settings_page.dart';
import 'package:soul_talk/services/auth/auth_service.dart';

class MyDrawer extends StatelessWidget {
  MyDrawer({super.key});
  //access auth services
  final _auth = AuthService();

  //logout
  void logout() {
    _auth.logout();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      child: SafeArea(
        child: Column(
          children: [
            // App Logo
            Padding(
                padding: const EdgeInsets.symmetric(vertical: 50.0),
                child: Image.asset('assets/owl.png')),
            Divider(
              indent: 25,
              endIndent: 25,
              color: Theme.of(context).colorScheme.secondary,
            ),

            const SizedBox(height: 20),

            //home list tile
            MyDrawerTile(
              icon: Icons.home,
              title: "H O M E",
              onTap: () {
                Navigator.pop(context);
              },
            ),

            //Profile list tile
            MyDrawerTile(
              icon: Icons.person,
              title: "P R O F I L E",
              onTap: () {
                Navigator.pop(context);

                //go to profle page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfilePage(
                      uid: _auth.getCurrentUid(),
                    ),
                  ),
                );
              },
            ),

            //search
            MyDrawerTile(
              icon: Icons.search_rounded,
              title: "S E A R C H",
              onTap: () {
                //pop drawer
                Navigator.pop(context);

                //go to settings page
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SearchPage(),
                    ));
              },
            ),

            //settings
            MyDrawerTile(
              icon: Icons.settings,
              title: "S E T T I N G S",
              onTap: () {
                //pop drawer
                Navigator.pop(context);

                //go to settings page
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsPage(),
                    ));
              },
            ),
            const Spacer(),

            //loguot
            MyDrawerTile(
              icon: Icons.logout,
              title: "L O G O U T",
              onTap: logout,
            ),

            const SizedBox(
              height: 20,
            )
          ],
        ),
      ),
    );
  }
}
