import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream to listen to auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current user
  User? get currentUser => _auth.currentUser;

  Future<UserCredential> signUp({
    required String email,
    required String password,
    required String phoneNumber,
    required String username,
  }) async {
    try {
      // Create user in Firebase Auth
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Add user details to Firestore
      if (userCredential.user != null) {
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'email': email,
          'phoneNumber': phoneNumber,
          'username': username,
          'uid': userCredential.user!.uid,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw Exception('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        throw Exception('The account already exists for that email.');
      }
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  // Sign In with Email/Phone and Password
  Future<UserCredential> signIn({
    required String identifier,
    required String password,
  }) async {
    // Check if identifier is email or phone number
    final bool isEmail = identifier.contains('@');

    if (isEmail) {
      // Sign in with email
      try {
        return await _auth.signInWithEmailAndPassword(
          email: identifier,
          password: password,
        );
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          throw Exception('No user found for that email.');
        } else if (e.code == 'wrong-password') {
          throw Exception('Wrong password provided for that user.');
        }
        rethrow;
      }
    } else {
      // Identifier is treated as phone number
      // We need to look up the email associated with this phone number
      try {
        final QuerySnapshot result = await _firestore
            .collection('users')
            .where('phoneNumber', isEqualTo: identifier)
            .limit(1)
            .get();

        if (result.docs.isEmpty) {
          throw Exception('No account found with this phone number.');
        }

        final String email = result.docs.first['email'];

        // Sign in using the retrieved email
        return await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } catch (e) {
        // Rethrow original exceptions or wrap generic ones
        if (e is FirebaseAuthException) {
          rethrow;
        }
        throw Exception('Login failed: ${e.toString()}');
      }
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Send Password Reset Email
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }
}
