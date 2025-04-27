import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';

class AuthService {
  Future<UserCredential?> signInWithGoogle(BuildContext context) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF7C4DFF)));
        },
      );

      // Start the Google Sign-In process
      final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();

      // Check if the user canceled the sign-in process
      if (gUser == null) {
        Navigator.of(context, rootNavigator: true).pop(); // Close the dialog
        return null; // User canceled the sign-in
      }

      // Get details
      final GoogleSignInAuthentication gAuth = await gUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: gAuth.accessToken,
        idToken: gAuth.idToken,
      );

      // Sign in to Firebase with the Google credentials
      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

      // Dismiss the loading indicator
      Navigator.of(context, rootNavigator: true).pop(); // Close the dialog

      return userCredential;
    } catch (e) {
      // Handle error (optional)
      print("Error: $e");

      // Dismiss the loading indicator in case of error
      Navigator.of(context, rootNavigator: true).pop(); // Close the dialog

      return null;
    }
  }
}


