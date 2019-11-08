import 'package:flutter/material.dart';

class ShowSnackBar {
  static build(GlobalKey<ScaffoldState> _scaffoldLoginKey, String _text,
      BuildContext context) {
    FocusScope.of(context).requestFocus(new FocusNode());
    _scaffoldLoginKey.currentState?.removeCurrentSnackBar();
    _scaffoldLoginKey.currentState?.showSnackBar(new SnackBar(
      content: new Text(
        _text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: 16.0,
        ),
      ),
      backgroundColor: Colors.blue,
      duration: Duration(seconds: 3),
    ));
  }
}
