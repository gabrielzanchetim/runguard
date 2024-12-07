import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<void> signIn(String email, String password) async {
    print("Attempting to sign in...");
    await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
    print("Sign in successful");
  }

  Future<void> signOut() async {
    print("Signing out...");
    await _firebaseAuth.signOut();
    print("Sign out successful");
  }

  Future<void> signUp(String name, String birthDate, String email, String password) async {
    UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
    User? user = userCredential.user;

    if (user != null) {
      await _firestore.collection('users').doc(user.uid).set({
        'name': name,
        'birthDate': birthDate,
        'email': email,
      });
      print("User registered and data saved");
    }
  }

  Future<void> addRun(DateTime dateTime, double distance, Duration duration) async {
    User? user = _firebaseAuth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).collection('runs').add({
        'time': dateTime.toIso8601String(),
        'distance': distance,
        'duration': duration.toString(),
      });
      print("Run added successfully");
    }
  }

  Future<void> updateRun(String runId, DateTime dateTime, double distance, Duration duration) async {
    User? user = _firebaseAuth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).collection('runs').doc(runId).update({
        'time': dateTime.toIso8601String(),
        'distance': distance,
        'duration': duration.toString(),
      });
      print("Run updated successfully");
    }
  }

  Future<void> deleteRun(String runId) async {
    User? user = _firebaseAuth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).collection('runs').doc(runId).delete();
      print("Run deleted successfully");
    }
  }

   Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print('Error sending password reset email: $e');
      throw e;
    }
  }

  Stream<QuerySnapshot> getRuns() {
    User? user = _firebaseAuth.currentUser;
    if (user != null) {
      return _firestore.collection('users').doc(user.uid).collection('runs').snapshots();
    }
    throw FirebaseAuthException(
      code: 'NO_USER',
      message: 'No user is currently signed in.',
    );
  }
}
