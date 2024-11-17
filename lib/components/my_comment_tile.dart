//Commetn tile which is gonna show comments in post page
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:soul_talk/models/comment.dart';
import 'package:soul_talk/services/auth/auth_service.dart';
import 'package:soul_talk/services/database/database_provider.dart';

class MyCommentTile extends StatelessWidget {
  final Comment comment;
  final void Function()? onUserTap;

  const MyCommentTile({
    super.key,
    required this.comment,
    required this.onUserTap,
  });

  void _showOptions(BuildContext context) {
    String currentUid = AuthService().getCurrentUid();
    final bool isOwnComment = comment.uid == currentUid;

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              if (isOwnComment)
                ListTile(
                  leading: const Icon(Icons.delete),
                  title: Text("Delete"),
                  onTap: () async {
                    Navigator.pop(context);
                    await Provider.of<DatabaseProvider>(context, listen: false)
                        .deleteComment(comment.id, comment.postId);
                  },
                )
              else ...[
                ListTile(
                  leading: const Icon(Icons.flag),
                  title: Text("Report"),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.block),
                  title: Text("Block"),
                  onTap: () {
                    Navigator.pop(context);
                  },
                )
              ],
              ListTile(
                leading: const Icon(Icons.cancel),
                title: Text("Cancel"),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.tertiary,
          borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onUserTap,
            child: Row(
              children: [
                Icon(
                  Icons.person,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 10),
                Text(
                  comment.name,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 5),
                Text(
                  '@${comment.username}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => _showOptions(context),
                  child: Icon(
                    Icons.more_horiz,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          Text(
            comment.message,
            style: TextStyle(
              color: Theme.of(context).colorScheme.inversePrimary,
            ),
          ),
        ],
      ),
    );
  }
}