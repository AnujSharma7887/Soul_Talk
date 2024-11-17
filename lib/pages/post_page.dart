import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:soul_talk/components/my_comment_tile.dart';
import 'package:soul_talk/components/my_post_tile.dart';
import 'package:soul_talk/helper/navigate_pages.dart';
import 'package:soul_talk/models/post.dart';
import 'package:soul_talk/services/database/database_provider.dart';

class PostPage extends StatefulWidget {
  final Post post;
  const PostPage({super.key, required this.post});

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  //providers
  late final listeningProvider = Provider.of<DatabaseProvider>(context);
  late final databaseProvider =
      Provider.of<DatabaseProvider>(context, listen: false);

  //Build UI
  @override
  Widget build(BuildContext context) {
    //listen to all comments for this post
    final allComments = listeningProvider.getComment(widget.post.id);

    //SCAFFOLD
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text("P O S T"),
        centerTitle: true,
        foregroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 5.0),
            child: MyPostTile(
                post: widget.post,
                onUserTap: () => goUserPage(context, widget.post.uid),
                onPostTap: () {}),
          ),

          //Comments on this post
           allComments.isEmpty
              ? Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Center(
                    child: Text(
                      "No Comments Here....",
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 15),
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: allComments.length,
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    final comment = allComments[index];
                    return MyCommentTile(
                      comment: comment,
                      onUserTap: () => goUserPage(context, comment.uid),
                    );
                  },
                )
        ],
      ),
    );
  }
}
