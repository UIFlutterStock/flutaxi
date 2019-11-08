import 'package:flutter/material.dart';
import 'package:flutter_icons/font_awesome.dart';
import 'package:Fluttaxi/src/infra/infra.dart';
import 'package:Fluttaxi/src/provider/blocs/blocs.dart';

import '../../../pages.dart';


class LoginAccount extends StatefulWidget {
  LoadingBloc _baseBloc;
  GlobalKey<ScaffoldState> _scaffoldLoginKey;

  LoginAccount(this._baseBloc, this._scaffoldLoginKey);

  @override
  _LoginAccountState createState() => _LoginAccountState();
}

class _LoginAccountState extends State<LoginAccount> {
  final FocusNode focusEmailLogin = FocusNode();
  final FocusNode focusPasswordLogin = FocusNode();
  TextEditingController loginEmailController = new TextEditingController();
  TextEditingController loginPasswordController = new TextEditingController();
  bool _obscureTextLogin = true;
  AuthDriverBloc _auth;
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    focusEmailLogin?.dispose();
    focusPasswordLogin?.dispose();

    super.dispose();
  }

  @override
  void initState() {
    _auth = AuthDriverBloc();
    super.initState();
  }


  void _functionLoginWithEmailPass(BuildContext context) {
    if (_formKey.currentState.validate()) {
      widget._baseBloc.loadingStatusEvent.add(true);
      _auth
          .signWithEmailPassword(
              email: loginEmailController.value.text.trim(),
              password: loginPasswordController.value.text.trim())
          .then((r) {
        new Future.delayed(new Duration(seconds: 1), () {
          widget._baseBloc.loadingStatusEvent.add(false);
        });
        _functionResetFields();
        NavigationPagesRace.goToHome(context);
      }, onError: (ex) {
        new Future.delayed(new Duration(seconds: 1), () {
          widget._baseBloc.loadingStatusEvent.add(false);
        });

        switch (ex.code) {
          case "ERROR_WRONG_PASSWORD":
            ShowSnackBar.build(widget._scaffoldLoginKey,
                'Invalid Username or Password!', context);
            break;
          case "ERROR_INVALID_EMAIL":
            ShowSnackBar.build(
                widget._scaffoldLoginKey, 'E-mail invalido!', context);
            break;
          default:
            ShowSnackBar.build(widget._scaffoldLoginKey,
                'Sorry, there was a problem!', context);
            break;
        }
      });
    }
  }

  void _functionLoginWithGoogle(BuildContext context) {
    widget._baseBloc.loadingStatusEvent.add(true);
    _auth.signWithGoogle().then((r) {
      new Future.delayed(new Duration(seconds: 1), () {
        widget._baseBloc.loadingStatusEvent.add(false);
      });
      NavigationPagesRace.goToHome(context);
    }, onError: (ex) {
      new Future.delayed(new Duration(seconds: 1), () {
        widget._baseBloc.loadingStatusEvent.add(false);
      });

      switch (ex.code) {
        case "ERROR_WRONG_PASSWORD":
          ShowSnackBar.build(
              widget._scaffoldLoginKey, 'Username or password incorrect!', context);
          break;
        case "ERROR_INVALID_EMAIL":
          ShowSnackBar.build(
              widget._scaffoldLoginKey, 'Invalid email!', context);
          break;
        default:
          ShowSnackBar.build(
              widget._scaffoldLoginKey, 'An unknown error has occurred!',
              context);
          break;
      }
    });
  }

  void _functionResetFields() {
    loginEmailController.text = "";
    loginPasswordController.text = "";
    setState(() {
      _formKey = GlobalKey<FormState>();
    });
  }

  void _functionToggleLogin() {
    setState(() {
      _obscureTextLogin = !_obscureTextLogin;
    });
  }

  Widget _buildForgot() => Padding(
        padding: EdgeInsets.only(top: 10),
        child: FlatButton(
            onPressed: () =>
                NavigationPagesRace.goToRecoveryPass(context),
            child: Text(
              "Forgot password?",
              style: TextStyle(
                  decoration: TextDecoration.underline, fontSize: 18.0),
            )),
      );



  Widget _buildOr() => Padding(
        padding: EdgeInsets.only(top: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              decoration: BoxDecoration(gradient: ColorsStyle.getColorBotton()),
              width: 100.0,
              height: 1.0,
            ),
            Padding(
              padding: EdgeInsets.only(left: 15.0, right: 15.0),
              child: Text(
                "OR",
                style: TextStyle(
                    fontSize: 16.0,
                    fontFamily: FontStyleApp.fontFamily(),
                    fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: ColorsStyle.getColorBotton(),
              ),
              width: 100.0,
              height: 1.0,
            ),
          ],
        ),
      );

  Widget _buildFacebookGoogleButton(Icon icon, Function function, Color color,
          EdgeInsetsGeometry edgGeometry) =>
      Padding(
        padding: edgGeometry,
        child: GestureDetector(
          onTap: () {
            function();
          },
          child: Container(
            padding: const EdgeInsets.all(15.0),
            decoration: new BoxDecoration(
              shape: BoxShape.circle,
              color: color,
            ),
            child: icon,
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Container(
        padding: EdgeInsets.only(top: 15.0),
        child: Column(
          children: <Widget>[
            Stack(
              alignment: Alignment.topCenter,
              overflow: Overflow.visible,
              children: <Widget>[
                Card(
                  elevation: 2.0,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Container(
                    width: 300.0,
                    height: 200.0,
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(
                              top: 5.0, bottom: 0.0, left: 25.0, right: 25.0),
                          child: TextFormField(
                            validator: (value) =>
                                HelpService.validateEmail(value),
                            focusNode: focusEmailLogin,
                            controller: loginEmailController,
                            keyboardType: TextInputType.emailAddress,
                            style: TextStyle(
                                fontSize: 16.0,
                                color: Colors.black,
                                fontFamily: FontStyleApp.fontFamily()),
                            decoration: InputDecoration(
                              errorStyle: TextStyle(
                                  fontFamily: FontStyleApp.fontFamily()),
                              border: InputBorder.none,
                              icon: Icon(
                                FontAwesome.getIconData("envelope"),
                                color: Colors.black,
                                size: 22.0,
                              ),
                              labelText: "Email",
                              hintStyle: TextStyle(
                                  fontFamily: FontStyleApp.fontFamily(),
                                  fontSize: 17.0),
                            ),
                          ),
                        ),
                        Container(
                          width: 250.0,
                          height: 1.0,
                          color: Colors.grey[400],
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              top: 0.0, bottom: 0.0, left: 25.0, right: 25.0),
                          child: TextFormField(
                            validator: (value) {
                              if (value.isEmpty) {
                                return "Password email address!";
                              }
                              return null;
                            },
                            focusNode: focusPasswordLogin,
                            controller: loginPasswordController,
                            obscureText: _obscureTextLogin,
                            style: TextStyle(
                                fontSize: 16.0,
                                color: Colors.black,
                                fontFamily: FontStyleApp.fontFamily()),
                            decoration: InputDecoration(
                              errorStyle: TextStyle(
                                  fontFamily: FontStyleApp.fontFamily()),
                              border: InputBorder.none,
                              icon: Icon(
                                FontAwesome.getIconData("lock"),
                                color: Colors.black,
                                size: 22.0,
                              ),
                              labelText: "Password",
                              hintStyle: TextStyle(
                                  fontFamily: FontStyleApp.fontFamily(),
                                  fontSize: 18.0),
                              suffixIcon: GestureDetector(
                                onTap: _functionToggleLogin,
                                child: Icon(
                                  FontAwesome.getIconData("eye"),
                                  size: 15.0,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: 250.0,
                          height: 1.0,
                          color: Colors.grey[400],
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                    margin: EdgeInsets.only(top: 180.0),
                    decoration: new BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(25.0)),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: Colors.black,
                            offset: Offset(0.0, 0.3),
                            blurRadius: 1.0,
                          ),
                        ],
                        gradient: ColorsStyle.getColorBotton()),
                    child: MaterialButton(
                        highlightColor: Colors.transparent,
                        splashColor: Color(0xFFFFFFFF),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 42.0),
                          child: Text(
                            "LOGIN",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16.0),
                          ),
                        ),
                        onPressed: () {
                          _functionLoginWithEmailPass(context);
                        }))
              ],
            ),
            _buildForgot(),
            _buildOr(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _buildFacebookGoogleButton(
                    Icon(
                      FontAwesome.getIconData("facebook-f"),
                      color: Colors.blueAccent,
                    ),
                    ()  {
                      ShowSnackBar.build(widget._scaffoldLoginKey, 'Currently it is only possible to login with Google Account or Email!', context);
                      return false;
                    },
                    Colors.blueAccent.withOpacity(0.1),
                    EdgeInsets.only(top: 10.0, right: 40.0)),
                _buildFacebookGoogleButton(
                    Icon(
                      FontAwesome.getIconData("google"),
                      color: Colors.deepOrange,
                    ), () {
                  _functionLoginWithGoogle(context);
                }, Colors.red.withOpacity(0.1), EdgeInsets.only(top: 10.0)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
