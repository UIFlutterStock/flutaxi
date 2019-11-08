import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:Fluttaxi/src/entity/entities.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

import '../../provider.dart';

class AuthDriverBloc extends BlocBase {
  GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final MotoristaService _customerService = MotoristaService();

  final _userInfoController = BehaviorSubject<Motorista>();

  Observable<Motorista> get userInfoFlux => _userInfoController.stream;

  Sink<Motorista> get userInfoEvent => _userInfoController.sink;

  Motorista get userValue => _userInfoController.value;

  final BehaviorSubject<bool> _startController = new BehaviorSubject<bool>();

  Observable<bool> get startFlux => _startController.stream;

  Sink<bool> get startEvent => _startController.sink;
  MotoristaService _motoristaService;

  AuthDriverBloc() {
    _motoristaService = MotoristaService();
    /*utilizado para  verificar se é a primeira vez que usuario está logando , se sim se apresentado as tela de introducão, se nao vai tela de login*/
    _verificaPaginaInicial();
  }

  _verificaPaginaInicial() async {
    Motorista motorista = await _motoristaService.getCustomerStorage();

    userInfoEvent.add(motorista);
    startEvent.add(motorista == null);
  }

  Future<void> refreshAuth() async {
    Motorista motorista = await _motoristaService.getCustomerStorage();
    userInfoEvent.add(motorista);
  }

  Future<void> addMotoristaAuth(Motorista motorista) async {
    _motoristaService.setStorage(motorista);
    await _motoristaService.save(motorista);
    await refreshAuth();
  }

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


      final motorista = Motorista(
          Email: user.email,
          Foto: Imagem(Url: user.photoUrl, IndicaOnLine: true),
          Nome: user.displayName,
          Id: user.uid);

      await _customerService.verificyExistsByEmailAndSave(motorista);
      userInfoEvent.add(motorista);
      await _customerService.setStorage(motorista);
    } on PlatformException catch (ex) {
      throw ex;
    } catch (ex) {
      throw ex;
    }
  }

  Future<bool> signWithEmailPassword({
    @required String email,
    @required String password,
  }) async {
    try {
      final FirebaseUser user = (await _auth.signInWithEmailAndPassword(
              email: email, password: password))
          .user;

      if (user == null) return false;

      final motorista = Motorista(
          Email: user.email,
          Foto: Imagem(
              Url: 'assets/images/usuario/avatar_user.png',
              IndicaOnLine: false),
          Nome: user.displayName,
          Id: user.uid);

      userInfoEvent.add(motorista);
      await _customerService.setStorage(motorista);

      return true;
    } on PlatformException catch (ex) {
      throw ex;
    } catch (ex) {
      throw ex;
    }
  }

  Future<void> recoveryPassword({
    @required String email,
  }) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on PlatformException catch (ex) {
      throw ex;
    } catch (ex) {
      throw ex;
    }
  }

  Future<void> registerWithEmailPassword({
    @required String email,
    @required String password,
    @required String name,
  }) async {
    try {
      FirebaseUser user = (await _auth.createUserWithEmailAndPassword(
              email: email, password: password))
          .user;

      final motorista = Motorista(
          Email: user.email,
          Foto: Imagem(
              Url: 'assets/images/usuario/avatar_user.png',
              IndicaOnLine: false),
          Nome: name,
          Id: user.uid);

      await _customerService.verificyExistsByEmailAndSave(motorista);

      userInfoEvent.add(motorista);
      _customerService.setStorage(motorista);
    } on PlatformException catch (ex) {
      throw ex;
    } catch (ex) {
      throw ex;
    }
  }

  Stream<FirebaseUser> get onAuthStateChanged => _auth.onAuthStateChanged;

  Future<void> signOut() async {
    await _motoristaService.remove();
    userInfoEvent.add(null);
    return Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  Future<bool> isSignedIn() async {
    final currentUser = await _auth.currentUser();
    return currentUser != null;
  }

  @override
  void dispose() {
    _userInfoController?.close();
    _startController?.close();
    super.dispose();
  }
}
