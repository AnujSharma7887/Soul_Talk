//go to user page
import 'package:flutter/material.dart';
import 'package:soul_talk/models/post.dart';
import 'package:soul_talk/pages/account_settings_page.dart';
import 'package:soul_talk/pages/blocked_users_page.dart';
import 'package:soul_talk/pages/home_page.dart';
import 'package:soul_talk/pages/post_page.dart';
import 'package:soul_talk/pages/profile_page.dart';

void goUserPage(BuildContext context, String uid) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ProfilePage(uid: uid),
    ),
  );
}

//go to post page
void goPostPage(BuildContext context, Post post) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => PostPage(post: post),
    ),
  );
}

//go to blocked user page
void goToBlockedUserPage(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => BlockedUsersPage(),
    ),
  );
}

// go to account settings page
void goAccountSettingsPage(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => AccountSettingsPage(),
    ),
  );
}

// go to home page, remove all previous routs
void goHomePage(BuildContext context) {
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (context) => HomePage()),
    (route) => route.isFirst,
  );
}
