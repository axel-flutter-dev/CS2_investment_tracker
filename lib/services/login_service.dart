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
      return credential.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Login failed');
    } catch (e) {
      throw Exception('An unknown error occurred');
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
      return credential.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Registration failed');
    } catch (e) {
      print(e.toString());
      throw Exception(e.toString());

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
