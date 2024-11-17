/*
  DATABASE PROVIDER

  This provider is to seperate the firestore  data handeling and the ui of the app.
  data  bsae srvice class handles data to and from firebse

  -make easy to switch in backend providers
*/

import 'package:flutter/material.dart';
import 'package:soul_talk/models/comment.dart';
import 'package:soul_talk/models/user.dart';
import 'package:soul_talk/services/auth/auth_service.dart';
import 'package:soul_talk/services/database/database_service.dart';

import '../../models/post.dart';

class DatabaseProvider extends ChangeNotifier {
  final _auth = AuthService();
  final _db = DatabaseService();

  //get usr profile given uid
  Future<UserProfile?> userProfile(String uid) => _db.getUserFromFirebase(uid);

  //update usr bio
  Future<void> updateBio(String bio) => _db.updateUserBioInFirebase(bio);

  //Post
  List<Post> _allPosts = [];
  List<Post> _followingPosts = [];

  //get posts
  List<Post> get allPosts => _allPosts;
  List<Post> get followingPosts => _followingPosts;

  //post a message
  Future<void> postMessage(String message) async {
    await _db.postMessageInFirebase(message);

    await loadAllPost();
  }

  //fetch all posts
  Future<void> loadAllPost() async {
    final allPosts = await _db.getAllPostsFromFirebase();
    final blockedUserIds = await _db.getBlockedUidsFromFirebase();

    initializeLikeMap();
    _allPosts =
        allPosts.where((post) => !blockedUserIds.contains(post.uid)).toList();

    loadFollowingPosts();

    notifyListeners();
  }

  //filter and return posts given uid
  List<Post> filterUserPosts(String uid) {
    return _allPosts.where((post) => post.uid == uid).toList();
  }

  //load following posts
  Future<void> loadFollowingPosts() async {
    String currentUid = _auth.getCurrentUid();

    final followingUserIds = await _db.getFollowingUidsFromFirebase(currentUid);

    _followingPosts =
        _allPosts.where((post) => followingUserIds.contains(post.uid)).toList();

    notifyListeners();
  }

  //delete post
  Future<void> deletePost(String postId) async {
    await _db.deletePostFromFirebase(postId);
    await loadAllPost();
  }

  //likes
  Map<String, int> _likeCounts = {};

  List<String> _likedPosts = [];

  bool isPostLikedByCurrentUser(String postId) => _likedPosts.contains(postId);

  int getLikeCount(String postId) => _likeCounts[postId] ?? 0;

  void initializeLikeMap() {
    final currentUserID = _auth.getCurrentUid();

    _likedPosts.clear();
    for (var post in _allPosts) {
      _likeCounts[post.id] = post.likeCount;

      if (post.likedBy.contains(currentUserID)) {
        _likedPosts.add(post.id);
      }
    }
  }

  //toggle like
  Future<void> toggleLike(String postId) async {
    final likedPostOriginal = _likedPosts;
    final likedCountsOriginal = _likeCounts;

    if (_likedPosts.contains(postId)) {
      _likedPosts.remove(postId);
      _likeCounts[postId] = (_likeCounts[postId] ?? 0) - 1;
    } else {
      _likedPosts.add(postId);
      _likeCounts[postId] = (_likeCounts[postId] ?? 0) + 1;
    }

    notifyListeners();

    //update likes in database in firebase

    try {
      await _db.toggleLikeInFirebase(postId);
    } catch (e) {
      _likedPosts = likedPostOriginal;
      _likeCounts = likedCountsOriginal;

      notifyListeners();
    }
  }

  //comments
  //list of comments
  final Map<String, List<Comment>> _comment = {};

  //get comments locally
  List<Comment> getComment(String postId) => _comment[postId] ?? [];

  //fetch comment from detabase
  Future<void> loadComments(String postId) async {
    final allComments = await _db.getCommentsFromFirebase(postId);
    _comment[postId] = allComments;
    notifyListeners();
  }

  //add comments
  Future<void> addComment(String postId, message) async {
    await _db.addCommentInFirebase(postId, message);
    await loadComments(postId);
  }

  //delete the comments
  Future<void> deleteComment(String commentId, postId) async {
    await _db.deleteCommentInFirebase(commentId);
    await loadComments(postId);
  }

  //Account Stuff
  List<UserProfile> _blockedUsers = [];

  List<UserProfile> get blockedUsers => _blockedUsers;

  //fetch blocked users from database
  Future<void> loadBlockedUsers() async {
    final blockedUserIds = await _db.getBlockedUidsFromFirebase();

    final blockedUserData = await Future.wait(
        blockedUserIds.map((id) => _db.getUserFromFirebase(id)));

    _blockedUsers = blockedUserData.whereType<UserProfile>().toList();

    notifyListeners();
  }

  //block a user
  Future<void> blockUser(String userId) async {
    await _db.blockUserInFirebase(userId);
    await loadBlockedUsers();
    await loadAllPost();

    notifyListeners();
  }

  //Unblock a user
  Future<void> unblockUser(String blockedUserId) async {
    await _db.unblockUserInFirebase(blockedUserId);
    await loadBlockedUsers();
    await loadAllPost();

    notifyListeners();
  }

  //report a user
  Future<void> reportUser(String postId, userId) async {
    await _db.reportUserInFirebase(postId, userId);
  }

  //Follow
  final Map<String, List<String>> _followers = {};
  final Map<String, List<String>> _following = {};
  final Map<String, int> _followerCount = {};
  final Map<String, int> _followingCount = {};

  int getFollowerCount(String uid) => _followerCount[uid] ?? 0;
  int getFollowingCount(String uid) => _followingCount[uid] ?? 0;

  Future<void> loadUserFollowers(String uid) async {
    final listOfFollowerUids = await _db.getFollowerUidsFromFirebase(uid);

    _followers[uid] = listOfFollowerUids;
    _followerCount[uid] = listOfFollowerUids.length;

    notifyListeners();
  }

  Future<void> loadUserFollowing(String uid) async {
    final listOfFollowingUids = await _db.getFollowingUidsFromFirebase(uid);

    _following[uid] = listOfFollowingUids;
    _followingCount[uid] = listOfFollowingUids.length;

    notifyListeners();
  }

  Future<void> followUser(String targetUserId) async {
    final currentUserId = _auth.getCurrentUid();

    _following.putIfAbsent(currentUserId, () => []);
    _following.putIfAbsent(targetUserId, () => []);

    if (!_followers[targetUserId]!.contains(currentUserId)) {
      _followers[targetUserId]?.add(currentUserId);
      _followerCount[targetUserId] = (_followerCount[targetUserId] ?? 0) + 1;
      _following[currentUserId]?.add(targetUserId);
      _followingCount[currentUserId] =
          (_followingCount[currentUserId] ?? 0) + 1;
    }

    notifyListeners();

    try {
      await _db.followUserInFirebase(targetUserId);
      await loadUserFollowers(currentUserId);
      await loadUserFollowing(currentUserId);
    } catch (e) {
      _followers[targetUserId]?.remove(currentUserId);
      _followerCount[targetUserId] = (_followerCount[targetUserId] ?? 0) - 1;
      _following[currentUserId]?.remove(targetUserId);
      _followingCount[currentUserId] =
          (_followingCount[currentUserId] ?? 0) - 1;

      notifyListeners();
    }
  }

  Future<void> unfollowUser(String targetUserId) async {
    final currentUserId = _auth.getCurrentUid();

    _following.putIfAbsent(currentUserId, () => []);
    _following.putIfAbsent(targetUserId, () => []);

    if (_followers[targetUserId]!.contains(currentUserId)) {
      _followers[targetUserId]?.remove(currentUserId);
      _followerCount[targetUserId] = (_followerCount[targetUserId] ?? 1) - 1;
      _following[currentUserId]?.remove(targetUserId);
      _followingCount[currentUserId] =
          (_followingCount[currentUserId] ?? 1) - 1;
    }

    notifyListeners();

    try {
      await _db.unFollowUserInFirebase(targetUserId);
      await loadUserFollowers(currentUserId);
      await loadUserFollowing(currentUserId);
    } catch (e) {
      _followers[targetUserId]?.add(currentUserId);
      _followerCount[targetUserId] = (_followerCount[targetUserId] ?? 0) + 1;
      _following[currentUserId]?.add(targetUserId);
      _followingCount[currentUserId] =
          (_followingCount[currentUserId] ?? 0) + 1;

      notifyListeners();
    }
  }

  bool isFollowing(String uid) {
    final currentUserId = _auth.getCurrentUid();
    return _followers[uid]?.contains(currentUserId) ?? false;
  }

  final Map<String, List<UserProfile>> _followersProfile = {};
  final Map<String, List<UserProfile>> _followingProfile = {};

  List<UserProfile> getListOfFollowersProfile(String uid) =>
      _followersProfile[uid] ?? [];

  List<UserProfile> getListOfFollowingProfile(String uid) =>
      _followingProfile[uid] ?? [];

  Future<void> loadUserFollowerProfiles(String uid) async {
    try {
      final followerIds = await _db.getFollowerUidsFromFirebase(uid);

      List<UserProfile> followerProfiles = [];

      for (String followerId in followerIds) {
        UserProfile? followerProfile =
            await _db.getUserFromFirebase(followerId);

        if (followerProfile != null) {
          followerProfiles.add(followerProfile);
        }
      }

      _followersProfile[uid] = followerProfiles;

      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  Future<void> loadUserFollowingProfiles(String uid) async {
    try {
      final followingIds = await _db.getFollowingUidsFromFirebase(uid);

      List<UserProfile> followingProfiles = [];

      for (String followingId in followingIds) {
        UserProfile? followingProfile =
            await _db.getUserFromFirebase(followingId);

        if (followingProfile != null) {
          followingProfiles.add(followingProfile);
        }
      }

      _followingProfile[uid] = followingProfiles;

      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  //Search
  List<UserProfile> _searchResults = [];
  List<UserProfile> get searchResult => _searchResults;

  Future<void> searchUsers(String searchTerm) async {
    try {
      final results = await _db.searchUsersInFirebase(searchTerm);

      _searchResults = results;

      notifyListeners();
    } catch (e) {
      print(e);
    }
  }
}
