import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:soul_talk/components/my_drawer.dart';
import 'package:soul_talk/components/my_post_tile.dart';
import 'package:soul_talk/helper/navigate_pages.dart';
import 'package:soul_talk/models/post.dart';
import 'package:soul_talk/services/database/database_provider.dart';

import '../components/my_input_alert_box.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //text controllers
  final _messageController = TextEditingController();

  //providers
  late final databaseProvider =
      Provider.of<DatabaseProvider>(context, listen: false);
  late final listeningProvider = Provider.of<DatabaseProvider>(context);

  //show post message dialogue box
  void _openPostMessageBox() {
    showDialog(
        context: context,
        builder: (context) => MyInputAlertBox(
            textController: _messageController,
            hintText: "What's in your mind..",
            onPressed: () async {
              await postMessage(_messageController.text);
            },
            onPressedText: "Post"));
  }

  //method to post
  Future<void> postMessage(String message) async {
    await databaseProvider.postMessage(message);
  }

  //on startup,
  @override
  void initState() {
    super.initState();

    loadAllPost();
  }

  //load all posts
  Future<void> loadAllPost() async {
    await databaseProvider.loadAllPost();
  }

  @override
  Widget build(BuildContext context) {
    //tab controller 2 options -> for you, following

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        drawer: MyDrawer(),
        appBar: AppBar(
          title: const Text("H O M E"),
          centerTitle: true,
          foregroundColor: Theme.of(context).colorScheme.primary,
          bottom: TabBar(
            dividerColor: Colors.transparent,
            labelColor: Theme.of(context).colorScheme.onPrimary,
            unselectedLabelColor: Theme.of(context).colorScheme.primary,
            indicatorColor: Theme.of(context).colorScheme.onPrimary,
            tabs: [
              Tab(text: "For you"),
              Tab(text: "Following"),
            ],
          ),
        ),

        //floating action button to make new post
        floatingActionButton: FloatingActionButton(
          onPressed: _openPostMessageBox,
          child: const Icon(
            Icons.add,
          ),
        ),

        //Body: list of all post
        body: TabBarView(children: [
          _buildPostList(listeningProvider.allPosts),
          _buildPostList(listeningProvider.followingPosts),
        ])
      ),
    );
  }

  //build list ui given a list of posts
  Widget _buildPostList(List<Post> posts) {
    return posts.isEmpty
        ?
        //post list is empty
        const Center(
            child: Text("Nothing here....."),
          )
        :
        //post list is not empty
        ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              //get each individual post
              final post = posts[index];

              //return Post Tile UI
              return MyPostTile(
                post: post,
                onUserTap: () => goUserPage(context, post.uid),
                onPostTap: () => goPostPage(context, post),
              );
            },
          );
  }
}
