import 'package:firebase_auth/firebase_auth.dart';
import 'package:soul_talk/services/database/database_service.dart';

/*
  AUTHENTICATON SERVICE

  this file handles everything  to do with authentication in firebase
  -----------------------------------------------------------------------------

  -Login
  -Register
  -Logout
  -Delete account

 */

class AuthService {
  //get instance of auth
  final _auth = FirebaseAuth.instance;

  //get current user and current uid
  User? getCurrentUser() => _auth.currentUser;
  String getCurrentUid() => _auth.currentUser!.uid;

  //login -> email &pw
  Future<UserCredential> loginEmailPassword(String email, password) async {
    //attempt login
    try {
      final UserCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return UserCredential;
    }
    //catch any errors
    on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  //register ->email& pw
  Future<UserCredential> registerEmailPassword(String email, password) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  //logout
  Future<void> logout() async {
    await _auth.signOut();
  }

  //delete account
  Future<void> deleteAccount() async {
    User? user = getCurrentUser();

    if (user != null) {
      await DatabaseService().deleteUserInfoFromFirebase(user.uid);
      await user.delete();
    }
  }
}
