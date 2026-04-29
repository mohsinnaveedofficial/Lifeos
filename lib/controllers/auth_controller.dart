import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lifeos/services/auth_service.dart';

class AuthController extends GetxController {
  AuthController(this._authService);

  static const googleCancelledMessage = 'Google sign-in was cancelled.';

  final AuthService _authService;
  final RxBool isLoading = false.obs;

  User? get currentUser => _authService.currentUser;

  Future<String?> login({required String email, required String password}) {
    return _runAuthAction(() {
      return _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    });
  }

  Future<String?> register({required String email, required String password}) {
    return _runAuthAction(() {
      return _authService.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    });
  }

  Future<String?> resetPassword({required String email}) {
    return _runAuthAction(() {
      return _authService.sendPasswordResetEmail(email: email);
    });
  }

  Future<String?> changePassword({
    required String currentPassword,
    required String newPassword,
  }) {
    return _runAuthAction(() {
      return _authService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
    });
  }

  Future<String?> continueWithGoogle() {
    return _runAuthAction(() {
      return _authService.signInWithGoogle();
    });
  }

  Future<String?> logout() {
    return _runAuthAction(() {
      return _authService.signOut();
    });
  }

  Future<String?> _runAuthAction(Future<dynamic> Function() action) async {
    if (isLoading.value) {
      return 'Please wait...';
    }

    try {
      isLoading.value = true;
      await action();
      return null;
    } on AuthCancelledException {
      return googleCancelledMessage;
    } on FirebaseAuthException catch (e) {
      return _mapFirebaseAuthError(e);
    } on GoogleSignInException catch (e) {
      return _mapGoogleSignInError(e);
    } catch (_) {
      return 'Something went wrong. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  String _mapFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account is disabled. Contact support.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password must be at least 6 characters long.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Check your internet connection.';
      case 'requires-recent-login':
        return 'Please login again before changing your password.';
      case 'operation-not-allowed':
        return 'Password change is not available for this account.';
      default:
        return e.message ?? 'Authentication failed. Please try again.';
    }
  }

  String _mapGoogleSignInError(GoogleSignInException e) {
    switch (e.code) {
      case GoogleSignInExceptionCode.clientConfigurationError:
        return 'Google Sign-In is not configured correctly for this app.';
      case GoogleSignInExceptionCode.canceled:
      case GoogleSignInExceptionCode.interrupted:
        return googleCancelledMessage;
      case GoogleSignInExceptionCode.providerConfigurationError:
        return 'Google provider setup is invalid. Check Firebase Auth providers.';
      case GoogleSignInExceptionCode.uiUnavailable:
        return 'Google Sign-In UI is unavailable on this device.';
      case GoogleSignInExceptionCode.userMismatch:
        return 'Please retry with the same Google account you started with.';
      default:
        return e.description ?? 'Google Sign-In failed. Please try again.';
    }
  }
}
