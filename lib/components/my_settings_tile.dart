import 'package:flutter/material.dart';

/*

SETTINGS LIST TILE

Tis is a simple tile for each item in the settings page.

-------------------------------------------------------------

to use this widget, you need:

-title
-action

 */

class MySettingsTile extends StatelessWidget {
  final String title;
  final Widget action;
  const MySettingsTile({
    super.key,
    required this.title,
    required this.action,
  });

  @override
  Widget build(BuildContext context) {
    //list tile
    return Container(
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          borderRadius: BorderRadius.circular(18)),
      margin: const EdgeInsets.only(left: 25, top: 25, right: 25),
      padding: const EdgeInsets.all(15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          action,
        ],
      ),
    );
  }
}
