/*
  POST TILE

  All posts will be displayed using this post tile widget
  -----------------------------------------------------------------------------



*/
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:soul_talk/components/my_input_alert_box.dart';
import 'package:soul_talk/helper/time_formatter.dart';
import 'package:soul_talk/models/post.dart';
import 'package:soul_talk/services/auth/auth_service.dart';
import 'package:soul_talk/services/database/database_provider.dart';

class MyPostTile extends StatefulWidget {
  final void Function()? onUserTap;
  final void Function()? onPostTap;

  final Post post;
  const MyPostTile({
    super.key,
    required this.post,
    required this.onUserTap,
    required this.onPostTap,
  });

  @override
  State<MyPostTile> createState() => _MyPostTileState();
}

class _MyPostTileState extends State<MyPostTile> {
  late final databaseProvider =
      Provider.of<DatabaseProvider>(context, listen: false);
  late final listeningProvider = Provider.of<DatabaseProvider>(context);

  //on startup
  @override
  void initState() {
    super.initState();

    //load comments for this post
    _loadComments();
  }

  //Likes, user tapped liked or unliked
  void _toggleLikePost() async {
    try {
      await databaseProvider.toggleLike(widget.post.id);
    } catch (e) {
      print(e);
    }
  }

  //Comments
  //Open comment box -> user want to type in
  final _commentController = TextEditingController();

  void _openNewCommentBox() {
    showDialog(
      context: context,
      builder: (context) => MyInputAlertBox(
        textController: _commentController,
        hintText: "Type you Comment",
        onPressed: () async {
          await _addComment();
        },
        onPressedText: "Comment",
      ),
    );
  }

  //add comment
  Future<void> _addComment() async {
    if (_commentController.text.trim().isEmpty) return;
    try {
      await databaseProvider.addComment(
        widget.post.id,
        _commentController.text.trim(),
      );
    } catch (e) {
      print(e);
    }
  }

  //Load the comments
  Future<void> _loadComments() async {
    await databaseProvider.loadComments(widget.post.id);
  }

//show options for post
  void _showOptions() {
    String currentUid = AuthService().getCurrentUid();
    final bool isOwnPost = widget.post.uid == currentUid;

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              //belongs to current user
              if (isOwnPost)
                ListTile(
                  leading: const Icon(Icons.delete),
                  title: Text("Delete"),
                  onTap: () async {
                    Navigator.pop(context);
                    await databaseProvider.deletePost(widget.post.id);
                  },
                )
              //belongs to other users
              else ...[
                ListTile(
                  leading: const Icon(Icons.flag),
                  title: Text("Report"),
                  onTap: () {
                    Navigator.pop(context);
                    _reportPostConfirmationBox();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.block),
                  title: Text("Block"),
                  onTap: () {
                    Navigator.pop(context);

                    _blockUserConfirmationBox();
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

  //report post confirmation box
  void _reportPostConfirmationBox() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Report User"),
        content: Text("Are you sure you want to report this message?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              await databaseProvider.reportUser(
                  widget.post.id, widget.post.uid);

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Message Reported"),
                ),
              );
            },
            child: const Text("Report"),
          ),
        ],
      ),
    );
  }

  //block user confirmation box
  void _blockUserConfirmationBox() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Block User"),
        content: Text("Are you sure you want to block this user?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              await databaseProvider.blockUser(widget.post.uid);

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("User Blocked"),
                ),
              );
            },
            child: const Text("Block"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    //does current user like this post
    bool likedByCurrentUser =
        listeningProvider.isPostLikedByCurrentUser(widget.post.id);

    //listen to like count
    int likeCount = listeningProvider.getLikeCount(widget.post.id);

    //listen to comments count
    int commentCount = listeningProvider.getComment(widget.post.id).length;

    return GestureDetector(
      onTap: widget.onPostTap,
      child: Container(
        //decoration part
        margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary,
            borderRadius: BorderRadius.circular(8)),

        //Column
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //Top section
            GestureDetector(
              onTap: widget.onUserTap,
              child: Row(
                children: [
                  //profile pic
                  Icon(
                    Icons.person,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 10),

                  //name
                  Text(
                    widget.post.name,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 5),

                  //usernaem handle
                  Text(
                    '@${widget.post.username}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const Spacer(),

                  //button handle
                  GestureDetector(
                    onTap: _showOptions,
                    child: Icon(
                      Icons.more_horiz,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            //Message
            Text(
              widget.post.message,
              style: TextStyle(
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
            ),
            const SizedBox(
              height: 10,
            ),

            //buttons -> like &  comment
            Row(
              children: [
                //Likes section
                SizedBox(
                  width: 60,
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: _toggleLikePost,
                        child: likedByCurrentUser
                            ? const Icon(Icons.favorite, color: Colors.red)
                            : Icon(
                                Icons.favorite_border,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        likeCount != 0 ? likeCount.toString() : '',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),

                //Comments section
                Row(
                  children: [
                    GestureDetector(
                      onTap: _openNewCommentBox,
                      child: Icon(
                        Icons.chat,
                        color: Theme.of(context).colorScheme.primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      commentCount != 0 ? commentCount.toString() : '',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    )
                  ],
                ),
                const Spacer(),

                //timestamp
                Text(
                  formatTimeStamp(widget.post.timestamp),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
