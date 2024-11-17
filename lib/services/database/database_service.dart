/*
  DATABASE SERVICES

  This class handles all the data from and to firestore
  ----------------------------------------------------------------------------

  -User profile
  -Post message
  -Comments
  -Account stuff
  -follow/unfollow
  -Search usr

 */

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:soul_talk/models/comment.dart';
import 'package:soul_talk/models/user.dart';
import 'package:soul_talk/services/auth/auth_service.dart';

import '../../models/post.dart';

class DatabaseService {
  //get instance of firestore db &auth

  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  /*
  User Profile

  when a new user register,  we create new account for them, 
  also store their details in databse to display their profile page 
  */

  //Save user Profile
  Future<void> saveUserInfoInFirebase(
      {required String name, required String email}) async {
    //get current uid
    String uid = _auth.currentUser!.uid;

    //extract username form email
    String username = email.split('@')[0];

    //create a user profile
    UserProfile user = UserProfile(
      uid: uid,
      name: name,
      email: email,
      username: username,
      bio: '',
    );

    //convert user into a map so that we can store in firebase
    final userMap = user.toMap();

    //save the user in the firebase
    await _db.collection("Users").doc(uid).set(userMap);
  }

  //Get user info
  Future<UserProfile?> getUserFromFirebase(String uid) async {
    try {
      //retrive user doc from firebase
      DocumentSnapshot userDoc = await _db.collection("Users").doc(uid).get();

      //convert doc to usr profile
      return UserProfile.fromDocument(userDoc);
    } catch (e) {
      print(e);
      return null;
    }
  }

  //Update the user bio
  Future<void> updateUserBioInFirebase(String bio) async {
    String uid = AuthService().getCurrentUid();
    try {
      await _db.collection("Users").doc(uid).update({'bio': bio});
    } catch (e) {
      print(e);
    }
  }

  //Delete user from firestore
  Future<void> deleteUserInfoFromFirebase(String uid) async {
    WriteBatch batch = _db.batch();
    DocumentReference userDoc = _db.collection("Users").doc(uid);
    batch.delete(userDoc);
    QuerySnapshot userPosts =
        await _db.collection("Posts").where("uid", isEqualTo: uid).get();

    for (var post in userPosts.docs) {
      batch.delete(post.reference);
    }

    QuerySnapshot userComments =
        await _db.collection("Comments").where("uid", isEqualTo: uid).get();

    for (var comment in userComments.docs) {
      batch.delete(comment.reference);
    }

    QuerySnapshot allPosts = await _db.collection("Posts").get();
    for (QueryDocumentSnapshot post in allPosts.docs) {
      Map<String, dynamic> postData = post.data() as Map<String, dynamic>;
      var likedBy = postData['likedBy'] as List<dynamic>? ?? [];

      if (likedBy.contains(uid)) {
        batch.update(post.reference, {
          'likedBy': FieldValue.arrayRemove([uid]),
          'likes': FieldValue.increment(-1),
        });
      }
    }

    await batch.commit();
  }
/*
    Post Message
*/

//post a message
  Future<void> postMessageInFirebase(String message) async {
    try {
      String uid = _auth.currentUser!.uid;

      UserProfile? user = await getUserFromFirebase(uid);

      Post newPost = Post(
        id: '',
        uid: uid,
        name: user!.name,
        username: user.username,
        message: message,
        timestamp: Timestamp.now(),
        likeCount: 0,
        likedBy: [],
      );

      Map<String, dynamic> newPostMap = newPost.toMap();

      await _db.collection("Posts").add(newPostMap);
    } catch (e) {
      print(e);
    }
  }

//delete a post
  Future<void> deletePostFromFirebase(String postId) async {
    try {
      await _db.collection("Posts").doc(postId).delete();
    } catch (e) {
      print(e);
    }
  }

//Get all posts from  Firebase
  Future<List<Post>> getAllPostsFromFirebase() async {
    try {
      QuerySnapshot snapshot = await _db
          .collection("Posts")
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs.map((doc) => Post.fromDocument(doc)).toList();
    } catch (e) {
      return [];
    }
  }

//Get individual post

//Likes
  Future<void> toggleLikeInFirebase(String postId) async {
    try {
      String uid = _auth.currentUser!.uid;

      DocumentReference postDoc = _db.collection("Posts").doc(postId);

      await _db.runTransaction(
        (transaction) async {
          DocumentSnapshot postSnapshot = await transaction.get(postDoc);

          List<String> likedBy =
              List<String>.from(postSnapshot['likedBy'] ?? []);

          int currentLikeCount = postSnapshot['likes'];

          if (!likedBy.contains(uid)) {
            likedBy.add(uid);

            currentLikeCount++;
          } else {
            likedBy.remove(uid);
            currentLikeCount--;
          }

          transaction.update(postDoc, {
            'likes': currentLikeCount,
            'likedBy': likedBy,
          });
        },
      );
    } catch (e) {
      print(e);
    }
  }

//Comments

//Add a comment to the post
  Future<void> addCommentInFirebase(String postId, message) async {
    try {
      String uid = _auth.currentUser!.uid;
      UserProfile? user = await getUserFromFirebase(uid);

      Comment newComment = Comment(
        id: '',
        postId: postId,
        uid: uid,
        name: user!.name,
        username: user.username,
        message: message,
        timestamp: Timestamp.now(),
      );

      Map<String, dynamic> newCommentMap = newComment.toMap();
      await _db.collection("Comments").add(newCommentMap);
    } catch (e) {
      print(e);
    }
  }

//delte the commetn
  Future<void> deleteCommentInFirebase(String commentId) async {
    try {
      await _db.collection("Comments").doc(commentId).delete();
    } catch (e) {
      print(e);
    }
  }

//fetch comment for the post
  Future<List<Comment>> getCommentsFromFirebase(String postId) async {
    try {
      QuerySnapshot snapshot = await _db
          .collection("Comments")
          .where("postId", isEqualTo: postId)
          .get();
      return snapshot.docs.map((doc) => Comment.fromDocument(doc)).toList();
    } catch (e) {
      print(e);
      return [];
    }
  }

//Account stuff (requirements to publish the app, block user and report a user)

//Report a user
  Future<void> reportUserInFirebase(String postId, userId) async {
    final currentUserId = _auth.currentUser!.uid;

    final report = {
      'reportedBy': currentUserId,
      'messageId': postId,
      'messageOwnerId': userId,
      'timeStamp': FieldValue.serverTimestamp(),
    };

    await _db.collection("Reports").add(report);
  }

  //block a user
  Future<void> blockUserInFirebase(String userId) async {
    final currentUserId = _auth.currentUser!.uid;

    await _db
        .collection("Users")
        .doc(currentUserId)
        .collection("BlockedUsers")
        .doc(userId)
        .set({});
  }

  //unblock user
  Future<void> unblockUserInFirebase(String blockedUserId) async {
    final currentUserId = _auth.currentUser!.uid;

    await _db
        .collection("Users")
        .doc(currentUserId)
        .collection("BlockedUsers")
        .doc(blockedUserId)
        .delete();
  }

  //get list of blocked users
  Future<List<String>> getBlockedUidsFromFirebase() async {
    final currentUserId = _auth.currentUser!.uid;

    final snapshot = await _db
        .collection("Users")
        .doc(currentUserId)
        .collection("BlockedUsers")
        .get();

    return snapshot.docs.map((doc) => doc.id).toList();
  }

//Follow

  //follow user
  Future<void> followUserInFirebase(String uid) async {
    final currentUser = _auth.currentUser!.uid;
    await _db
        .collection("Users")
        .doc(currentUser)
        .collection("Following")
        .doc(uid)
        .set({});

    await _db
        .collection("Users")
        .doc(uid)
        .collection("Followers")
        .doc(currentUser)
        .set({});
  }

  //unfollow user
  Future<void> unFollowUserInFirebase(String uid) async {
    final currentUser = _auth.currentUser!.uid;

    await _db
        .collection("Users")
        .doc(currentUser)
        .collection("Following")
        .doc(uid)
        .delete();

    await _db
        .collection("Users")
        .doc(uid)
        .collection("Followers")
        .doc(currentUser)
        .delete();
  }

  //get user's followers
  Future<List<String>> getFollowerUidsFromFirebase(String uid) async {
    final snapshot =
        await _db.collection("Users").doc(uid).collection("Followers").get();

    return snapshot.docs.map((doc) => doc.id).toList();
  }

  Future<List<String>> getFollowingUidsFromFirebase(String uid) async {
    final snapshot =
        await _db.collection("Users").doc(uid).collection("Following").get();

    return snapshot.docs.map((doc) => doc.id).toList();
  }

//Search
  Future<List<UserProfile>> searchUsersInFirebase(String searchTerm) async {
    try {
      QuerySnapshot snapshot = await _db
          .collection("Users")
          .where('username', isGreaterThanOrEqualTo: searchTerm)
          .where('username', isLessThanOrEqualTo: '$searchTerm\uf8ff')
          .get();

      return snapshot.docs.map((doc) => UserProfile.fromDocument(doc)).toList();
    } catch (e) {
      return [];
    }
  }
}
