import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:meta/meta.dart';

class AuthenticationAdmin {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> signWithGoogle() async {
    try {
      final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final FirebaseUser user =
          (await _auth.signInWithCredential(credential)).user;
      print("signed in " + user.displayName);
    } on PlatformException catch (ex) {
      print(ex);
      print('Erro communication platform');
      throw ex;
    } catch (ex) {
      throw ex;
    }
  }

  Future<void> signWithEmailPassword({
    @required String email,
    @required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on PlatformException catch (ex) {
      print('Erro communication platform');
      throw ex;
    } catch (ex) {
      throw ex;
    }
  }

  Stream<FirebaseUser> get onAuthStateChanged => _auth.onAuthStateChanged;

  Future<void> signOut() async {
    return Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  Future<bool> isSignedIn() async {
    final currentUser = await _auth.currentUser();
    return currentUser != null;
  }
}
