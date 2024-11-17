import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:soul_talk/components/my_bio_box.dart';
import 'package:soul_talk/components/my_follow_button.dart';
import 'package:soul_talk/components/my_input_alert_box.dart';
import 'package:soul_talk/components/my_post_tile.dart';
import 'package:soul_talk/components/my_profile_stats.dart';
import 'package:soul_talk/helper/navigate_pages.dart';
import 'package:soul_talk/models/user.dart';
import 'package:soul_talk/pages/follow_list_page.dart';
import 'package:soul_talk/services/auth/auth_service.dart';
import 'package:soul_talk/services/database/database_provider.dart';

class ProfilePage extends StatefulWidget {
  final String uid;
  const ProfilePage({
    super.key,
    required this.uid,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final listeningProvider = Provider.of<DatabaseProvider>(context);

  late final databaseProvider =
      Provider.of<DatabaseProvider>(context, listen: false);

  UserProfile? user;
  String currentUserId = AuthService().getCurrentUid();

  final bioTextController = TextEditingController();

  bool _isLoading = true;
  bool _isFollowing = false;

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  Future<void> loadUser() async {
    user = await databaseProvider.userProfile(widget.uid);

    await databaseProvider.loadUserFollowers(widget.uid);
    await databaseProvider.loadUserFollowing(widget.uid);

    _isFollowing = databaseProvider.isFollowing(widget.uid);
    setState(() {
      _isLoading = false;
    });
  }

  void _showEditBioBox() {
    showDialog(
        context: context,
        builder: (context) => MyInputAlertBox(
            textController: bioTextController,
            hintText: "Edit Bio",
            onPressed: saveBio,
            onPressedText: "Save"));
  }

  Future<void> saveBio() async {
    setState(() {
      _isLoading = true;
    });

    await databaseProvider.updateBio(bioTextController.text);

    await loadUser();

    setState(() {
      _isLoading = false;
    });

    print("Saving..");
  }

  Future<void> toggleFollow() async {
    if (_isFollowing) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Unfollow"),
          content: Text("Are you sure you want to unfollow"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await databaseProvider.unfollowUser(widget.uid);
              },
              child: Text("Yes"),
            ),
          ],
        ),
      );
    } else {
      await databaseProvider.followUser(widget.uid);
    }

    setState(() {
      _isFollowing = !_isFollowing;
    });
  }

  @override
  Widget build(BuildContext context) {
    final allUsersPosts = listeningProvider.filterUserPosts(widget.uid);

    final followerCount = listeningProvider.getFollowerCount(widget.uid);
    final followingCount = listeningProvider.getFollowingCount(widget.uid);

    _isFollowing = listeningProvider.isFollowing(widget.uid);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(_isLoading ? '' : user!.name),
        centerTitle: true,
        foregroundColor: Theme.of(context).colorScheme.primary,
        leading: IconButton(onPressed: ()=> goHomePage(context), icon: const Icon(Icons.arrow_back)),
      ),
      body: ListView(
        children: [
          Center(
            child: Text(
              _isLoading ? '' : '@${user!.username}',
              style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
            ),
          ),
          const SizedBox(height: 25),
          Center(
              child: Container(
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                borderRadius: BorderRadius.circular(25)),
            padding: EdgeInsets.all(25),
            child: Icon(
              Icons.person,
              size: 72,
              color: Theme.of(context).colorScheme.primary,
            ),
          )),
          const SizedBox(height: 25),

          //Stats
          MyProfileStats(
            postCount: allUsersPosts.length,
            followerCount: followerCount,
            followingCount: followingCount,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FollowListPage(
                  uid: widget.uid,
                ),
              ),
            ),
          ),

          //Follow Button
          if (user != null && user!.uid != currentUserId)
            MyFollowButton(
              onPressed: toggleFollow,
              isFollowing: _isFollowing,
            ),
          if (user != null && user!.uid == currentUserId)
            const SizedBox(height: 25),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Bio",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                if (user != null && user!.uid == currentUserId)
                  GestureDetector(
                    onTap: _showEditBioBox,
                    child: Icon(
                      Icons.edit,
                      size: 18,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
              ],
            ),
          ),
          MyBioBox(
            text: _isLoading ? 'Loading...' : user!.bio,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 30.0, top: 25),
            child: Text(
              "Posts",
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          allUsersPosts.isEmpty
              ? Center(
                  child: Text(
                    "No Posts Here!",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: allUsersPosts.length,
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    final post = allUsersPosts[index];

                    return MyPostTile(
                      post: post,
                      onUserTap: () {},
                      onPostTap: () => goPostPage(context, post),
                    );
                  },
                )
        ],
      ),
    );
  }
}
