import 'package:firebase_auth/firebase_auth.dart';
import 'firestore_service.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();

  Stream<User?> get userStream => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<UserCredential?> signUp(
    String email,
    String password,
    String name,
    String? studentId, {
    bool isDoctor = false,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;
      if (user != null) {
        String role = 'student';
        if (email == 'admin@smartattendance.com') {
          role = 'admin';
        } else if (isDoctor) {
          role = 'doctor';
        }

        UserModel userModel = UserModel(
          id: user.uid,
          name: name,
          email: email,
          role: role,
          studentId: studentId,
          isDoctor: isDoctor || role == 'doctor',
        );
        await _firestoreService.createUser(userModel);
      }
      return result;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<UserCredential?> signIn(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<UserModel?> getCurrentUserModel() async {
    User? user = _auth.currentUser;
    if (user != null) {
      return await _firestoreService.getUser(user.uid);
    }
    return null;
  }
}
