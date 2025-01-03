import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VendorAuthController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // Register Function
  Future<String> registerNewUser(
      String fullName,
      String email,
      String password,
      String storeName,
      int phoneNumber,
      String locality,
      String city,
      String state) async {
    String res = 'something went wrong';

    try {
      // we want to create the use in the authentication tab and then leter in firestore
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      await _firestore.collection("vendors").doc(userCredential.user!.uid).set({
        'fullname': fullName,
        'email': email,
        'password': password,
        'storeImage': '',
        'uid': userCredential.user!.uid,
        'pinCode': '',
        'locality': locality,
        'city': city,
        'state': state,
        'phone': phoneNumber,
        'storeName': storeName
      });

      res = 'success';
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        res = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        res = 'The account already exists for that email.';
      }
    } catch (e) {
      res = e.toString();
    }
    return res;
  }

  //Login USER functin

  Future<String> loginUser(String email, String password) async {
    String res = "something went wrong";

    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      res = 'success';
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        res = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        res = 'Wrong password provided for that user.';
      }
    } catch (e) {
      res = e.toString();
    }

    return res;
  }

  // Reset Password function
  Future<String> resetPassword(String email) async {
    String res = "something went wrong";

    try {
      await _auth.sendPasswordResetEmail(email: email);
      res = 'Password reset email sent successfully';
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        res = 'No user found for that email.';
      } else {
        res = e.message ?? 'An error occurred';
      }
    } catch (e) {
      res = e.toString();
    }
    return res;
  }
}
