//folllow and unfollow button

import 'package:flutter/material.dart';

class MyFollowButton extends StatelessWidget {
  final void Function()? onPressed;
  final bool isFollowing;
  const MyFollowButton({
    super.key,
    required this.onPressed,
    required this.isFollowing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(25),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: MaterialButton(
          padding: EdgeInsets.all(25),
          onPressed: onPressed,
          color: isFollowing
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onPrimary,
          child: Text(
            isFollowing ? "Unfollow" : "Follow",
            style: TextStyle(
                color: Theme.of(context).colorScheme.inversePrimary,
                fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
