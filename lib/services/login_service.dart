import 'package:firebase_auth/firebase_auth.dart';


class LoginService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // login with email and password
  Future<User?> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    
      final user = credential.user;

      // Check if email is verified
      if (user != null && !user.emailVerified) {
        await _auth.signOut();
        throw Exception('Email not verified. Please check your inbox.');
      }

      return user;

    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Login failed');
    } 
  }

  // Register with email and password
  Future<User?> registerWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;

      // Send email verification
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      }

      return user;

    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Registration failed');
    } catch (e) {
      print(e.toString());
      throw Exception(e.toString());

    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    if (email.isEmpty) {
      throw Exception('Please enter your email address.');
    }

    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Password reset failed');
    } catch (e) {
      throw Exception('An unknown error occurred');
    }
  }


  //Check if user is logged in
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  //Logout
  Future<void> logout() async {
    await _auth.signOut();
  }
}
