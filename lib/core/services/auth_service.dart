import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../models/user_model.dart';
import '../../repositories/auth_repository.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final AuthRepository _authRepository = AuthRepository();

  // ── Auth State Stream ─────────────────────────────────────────
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;
  String? get currentUid => _auth.currentUser?.uid;

  // ─────────────────────────────────────────────────────────────
  // REGISTER
  // ─────────────────────────────────────────────────────────────
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      await result.user!.updateDisplayName(name.trim());

      final userModel = UserModel(
        uid: result.user!.uid,
        name: name.trim(),
        email: email.trim(),
        phone: phone.trim(),
        role: UserRole.customer,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _authRepository.createUser(userModel);

      return userModel;
    } catch (e) {
      throw _parseError(e);
    }
  }

  // ─────────────────────────────────────────────────────────────
  // LOGIN
  // ─────────────────────────────────────────────────────────────
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return await getUserProfile(result.user!.uid);
    } catch (e) {
      throw _parseError(e);
    }
  }

  // ─────────────────────────────────────────────────────────────
  // GOOGLE SIGN IN
  // ─────────────────────────────────────────────────────────────
  Future<UserModel> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) throw Exception('Google sign-in cancelled.');
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final result = await _auth.signInWithCredential(credential);
      
      var userProfile = await _authRepository.getUser(result.user!.uid);
      if (userProfile == null) {
         userProfile = UserModel(
          uid: result.user!.uid,
          name: result.user!.displayName ?? 'User',
          email: result.user!.email ?? '',
          phone: '',
          photoUrl: result.user!.photoURL ?? '',
          role: UserRole.customer,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await _authRepository.createUser(userProfile);
      }
      return userProfile;
    } catch (e) {
      throw _parseError(e);
    }
  }

  // ─────────────────────────────────────────────────────────────
  // FORGOT PASSWORD
  // ─────────────────────────────────────────────────────────────
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } catch (e) {
      throw _parseError(e);
    }
  }

  // ─────────────────────────────────────────────────────────────
  // LOGOUT
  // ─────────────────────────────────────────────────────────────
  Future<void> logout() async {
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  // ─────────────────────────────────────────────────────────────
  // GET USER PROFILE
  // ─────────────────────────────────────────────────────────────
  Future<UserModel> getUserProfile(String uid) async {
    final userProfile = await _authRepository.getUser(uid);
    if (userProfile != null) {
      return userProfile;
    }
    
    // Fallback if not found in Firestore
    final firebaseUser = _auth.currentUser;
    return UserModel(
      uid: uid,
      name: firebaseUser?.displayName ?? 'User',
      email: firebaseUser?.email ?? '',
      phone: '',
      photoUrl: firebaseUser?.photoURL ?? '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // UPDATE PROFILE
  // ─────────────────────────────────────────────────────────────
  Future<UserModel> updateProfile({
    required String uid,
    String? name,
    String? phone,
    String? address,
    String? photoUrl,
  }) async {
    try {
      if (name != null && currentUser != null) {
        await currentUser!.updateDisplayName(name.trim());
      }
      
      final updateFields = <String, dynamic>{};
      if (name != null) updateFields['name'] = name.trim();
      if (phone != null) updateFields['phone'] = phone.trim();
      if (address != null) updateFields['address'] = address.trim();
      if (photoUrl != null) updateFields['photoUrl'] = photoUrl.trim();

      await _authRepository.updateUser(uid, updateFields);
      
      return await getUserProfile(uid);
    } catch (e) {
      throw _parseError(e);
    }
  }

  // ─────────────────────────────────────────────────────────────
  // PRIVATE: Parse errors safely for both Android and Web
  // ─────────────────────────────────────────────────────────────
  String _parseError(Object e) {
    if (e is FirebaseAuthException) {
      return _codeToMessage(e.code);
    }
    final str = e.toString();
    if (str.contains('user-not-found')) {
      return 'No account found with this email.';
    }
    if (str.contains('wrong-password')) {
      return 'Incorrect password. Please try again.';
    }
    if (str.contains('email-already-in-use')) {
      return 'An account with this email already exists.';
    }
    if (str.contains('weak-password')) {
      return 'Password must be at least 6 characters.';
    }
    if (str.contains('invalid-email')) {
      return 'Please enter a valid email address.';
    }
    if (str.contains('too-many-requests')) {
      return 'Too many attempts. Please try again later.';
    }
    if (str.contains('network-request-failed')) {
      return 'Network error. Check your connection.';
    }
    if (str.contains('invalid-credential')) {
      return 'Invalid credentials. Please try again.';
    }
    if (str.contains('cancelled')) return 'Sign-in was cancelled.';
    return e.toString();
  }

  String _codeToMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account with this email already exists.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Check your connection.';
      case 'invalid-credential':
        return 'Invalid credentials. Please try again.';
      default:
        return 'An unexpected error occurred.';
    }
  }
}