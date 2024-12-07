import 'package:firebase_core/firebase_core.dart'; 
import 'package:firebase_database/firebase_database.dart';
import 'package:i_love_my_girlfriend/modelservices/model/app_user.dart'; 

class UserDataProvider {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref().child('users');

  Future<void> initializeFirebase() async {
    await Firebase.initializeApp();
  }

  Future<void> insertUser(AppUser user) async {
    await initializeFirebase(); 
    await _dbRef.push().set(user.toJson());
  }

  Future<void> removeUser(String userKey) async {
    await initializeFirebase();
    await _dbRef.child(userKey).remove();
  }

  Future<List<AppUser>> getUsers() async {
    await initializeFirebase();
    DataSnapshot snapshot = await _dbRef.get(); 
    List<AppUser> users = [];

    if (snapshot.exists) {
      for (var child in snapshot.children) {
        users.add(AppUser.fromJson(child.key!, child.value as Map<String, dynamic>));
      }
    }
    return users;
  }

  Future<void> updateUser(String userKey, AppUser updatedUser) async {
    await initializeFirebase();
    await _dbRef.child(userKey).update(updatedUser.toJson());
  }
}
