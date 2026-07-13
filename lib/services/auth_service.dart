import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:temple/routes/route_helper.dart';

class AuthService extends GetxController {
  static AuthService instance = Get.find();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  late Rx<User?> _user;

  @override
  void onReady() {
    super.onReady();
    _user = Rx<User?>(_auth.currentUser);
    _user.bindStream(_auth.userChanges());
    ever(_user, _initialScreen);
  }

  // void _initialScreen(User? user) {
  //   if (user == null) {
  //     Get.offAllNamed(RouteHelper.getLoginPage()); // Send to login screen if logged out
  //   } else {
  //     Get.offAllNamed(RouteHelper.getInitial()); // Send to homepage if logged in
  //   }
  // }
    void _initialScreen(User? user) async {
    // 🧠 This ensures the 3-second splash screen finishes drawing before authentication redirects take over!
    await Future.delayed(const Duration(seconds: 3)); 

    if (user == null) {
      Get.offAllNamed(RouteHelper.getLoginPage()); // Single clean route push
    } else {
      Get.offAllNamed(RouteHelper.getInitial());  // Single clean route push
    }
  }

  // 🟢 EMAIL LOGIN METHOD
  Future<void> loginWithEmail(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      String errorMessage = "An error occurred";
      if (e.code == 'user-not-found') {
        errorMessage = "No user found with this email address.";
      } else if (e.code == 'wrong-password') {
        errorMessage = "Incorrect password. Please try again.";
      } else if (e.code == 'invalid-email') {
        errorMessage = "The email address format is invalid.";
      }
      
      Get.snackbar(
        "Login Failed",
        errorMessage,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  // 🟢 EMAIL REGISTRATION (SIGN UP) METHOD
  Future<void> signUpWithEmail(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      String errorMessage = "Registration failed";
      if (e.code == 'weak-password') {
        errorMessage = "The password provided is too weak.";
      } else if (e.code == 'email-already-in-use') {
        errorMessage = "An account already exists for this email address.";
      }
      
      Get.snackbar(
        "Sign Up Failed",
        errorMessage,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  // 🟢 CLEAN SIGN OUT METHOD
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
