import 'package:firebase_auth/firebase_auth.dart';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';



class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<User?> signUpUser({
    required String email,
    required String password,
     required String name,
  }) async {
    try {
      UserCredential result =
          await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
    
      );
     User? user=result.user;
         if (user != null) {
       
        await _firestore.collection("users").doc(user.uid).set({
          "uid": user.uid,
          "name": name,
          "email": email,
          "role": "user",
          "createdAt": FieldValue.serverTimestamp(),
        });
      }


      return result.user;
    
    } on FirebaseAuthException catch (e) {
      throw e.message ?? "Signup failed";
    }
  }

 Future<User?> signUpWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser =
          await _googleSignIn.signIn();

      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      User? user=userCredential.user;
          if (user != null &&
          userCredential.additionalUserInfo!.isNewUser) {
        await _firestore.collection("users").doc(user.uid).set({
          "uid": user.uid,
          "name": user.displayName,
          "email": user.email,
          "role": "user",
          "createdAt": FieldValue.serverTimestamp(),
        });
      }


      return userCredential.user;
    } catch (e) {
      print("Google SignUp Error: $e");
      return null;
    }
  }
  Future<User?> login({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential result =
          await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      User? user=result.user;
      if (user != null) {
    await saveUserSession(user.uid);}
      return result.user;
    } on FirebaseAuthException catch (e) {
      throw e.message ?? "Login failed";
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }


Future<Map<String, dynamic>?> getUserData(String uid) async {
  try {
    DocumentSnapshot doc =
        await _firestore.collection("users").doc(uid).get();

    if (doc.exists) {
      return doc.data() as Map<String, dynamic>;
    }
    return null;
  } catch (e) {
    print("Error fetching user data: $e");
    return null;
  }
}
Future<void> saveUserSession(String uid) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('uid', uid);
}
Future<String?> getSavedUser() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('uid');
}

Future<void> clearUserSession() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('uid');
}
  Future<void> updateUserProfileImage(String uid, String imageUrl) async {
    await _firestore.collection('users').doc(uid).set({
      'profileImage': imageUrl,
    }, SetOptions(merge: true));
  }



  

}