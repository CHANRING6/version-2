import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Converts raw exceptions (Firestore, FirebaseAuth, network, or plain
/// Dart exceptions) into short, user-friendly messages. Used anywhere the
/// app previously showed a raw `error.toString()` to the user.
class AppErrorHandler {
  static String friendlyMessage(Object error) {
    if (error is FirebaseAuthException) {
      return _fromAuthCode(error.code);
    }
    if (error is FirebaseException) {
      return _fromFirestoreCode(error.code);
    }

    final msg = error.toString();

    if (msg.contains('SocketException') ||
        msg.contains('Failed host lookup') ||
        msg.contains('Network is unreachable') ||
        msg.contains('ClientException')) {
      return 'No internet connection. Please check your network and try again.';
    }
    if (msg.contains('TimeoutException')) {
      return 'That took too long. Please try again.';
    }

    // Strip common Dart exception-wrapper noise, e.g. "Exception: ..."
    final cleaned = msg.replaceFirst(RegExp(r'^[A-Za-z]*Exception:\s*'), '');

    // Repository/service layers in this app already throw short, friendly
    // messages in most places — but guard against very long raw dumps.
    if (cleaned.length > 140 || cleaned.contains('at Object.')) {
      return 'Something went wrong. Please try again.';
    }
    return cleaned;
  }

  static String _fromAuthCode(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with that email.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'email-already-in-use':
        return 'An account with that email already exists.';
      case 'weak-password':
        return 'Please choose a stronger password (6+ characters).';
      case 'invalid-email':
        return 'That email address looks invalid.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a moment and try again.';
      case 'network-request-failed':
        return 'No internet connection. Please check your network.';
      case 'user-disabled':
        return 'This account has been disabled.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }

  static String _fromFirestoreCode(String code) {
    switch (code) {
      case 'permission-denied':
        return "You don't have permission to do that.";
      case 'unavailable':
        return 'Service is temporarily unavailable. Please try again.';
      case 'not-found':
        return 'The requested data could not be found.';
      case 'deadline-exceeded':
        return 'That took too long. Please try again.';
      default:
        return 'Something went wrong while syncing your data.';
    }
  }
}
