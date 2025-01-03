import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> loginUser(String email, String password) async {
    try {
      // First, try to sign in with Firebase Auth
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);

      // Check both collections to determine the role
      DocumentSnapshot vendorDoc = await _firestore
          .collection('vendors')
          .doc(userCredential.user!.uid)
          .get();

      DocumentSnapshot buyerDoc = await _firestore
          .collection('buyers')
          .doc(userCredential.user!.uid)
          .get();

      String role = '';
      if (vendorDoc.exists) {
        role = 'vendor';
      } else if (buyerDoc.exists) {
        role = 'buyer';
      } else {
        // If user doesn't exist in either collection, sign out
        await _auth.signOut();
        return {'status': 'error', 'message': 'Account not found in any role'};
      }

      return {'status': 'success', 'role': role};
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return {'status': 'error', 'message': 'No user found for that email.'};
      } else if (e.code == 'wrong-password') {
        return {
          'status': 'error',
          'message': 'Wrong password provided for that user.'
        };
      }
      return {
        'status': 'error',
        'message': e.message ?? 'Authentication error'
      };
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }

  // Register Function for Buyers
  Future<String> registerNewUser(
      String fullName, String email, String password) async {
    String res = 'something went wrong';

    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      await _firestore.collection("buyers").doc(userCredential.user!.uid).set({
        'fullname': fullName,
        'email': email,
        'password': password,
        'profilImage': '',
        'uid': userCredential.user!.uid,
        'pinCode': '',
        'locality': '',
        'city': '',
        'state': ''
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

  // Register Function for Vendors
  Future<String> registerNewVendor(
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
