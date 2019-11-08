import 'package:flutter/material.dart';
import 'package:flutter_icons/font_awesome.dart';
import 'package:Fluttaxi/src/infra/infra.dart';
import 'package:Fluttaxi/src/provider/provider.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import '../../pages.dart';


class RecoveryPassPage extends StatefulWidget {
  RecoveryPassPage({Key key}) : super(key: key);

  @override
  _RecoveryPassPageState createState() => _RecoveryPassPageState();
}

class _RecoveryPassPageState extends State<RecoveryPassPage> {
  TextEditingController loginEmailController = new TextEditingController();
  AuthDriverBloc _auth;
  LoadingBloc _baseBloc;
  final GlobalKey<ScaffoldState> _scaffoldLoginKey =
  new GlobalKey<ScaffoldState>();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    loginEmailController?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _baseBloc = LoadingBloc();
    _auth = AuthDriverBloc();
    super.initState();
  }

  Future<void> _functionRecoveryEmail(String email) async {
    if (_formKey.currentState.validate()) {
      _baseBloc.loadingStatusEvent.add(true);
      _auth.recoveryPassword(email: email).then((r) {
        _baseBloc.loadingStatusEvent.add(false);
        ShowSnackBar.build(
            _scaffoldLoginKey, 'Success ! E-mail send with success.', context);
      }, onError: (ex) {
        _baseBloc.loadingStatusEvent.add(false);
        switch (ex.code) {
          case 'ERROR_USER_NOT_FOUND':
            ShowSnackBar.build(
                _scaffoldLoginKey, 'Sorry, user not found!', context);
            break;
          default:
            ShowSnackBar.build(
                _scaffoldLoginKey, 'Sorry, a problem happened!', context);
            break;
        }
      });
    }
  }

  Widget _buildContent(bool statusLoading) =>
      ModalProgressHUD(
        inAsyncCall: statusLoading,
        progressIndicator: CircularProgressIndicator(
          valueColor: new AlwaysStoppedAnimation<Color>(Colors.deepOrange),
        ),
        child: Stack(
          children: <Widget>[
            BodyBack(),
            CustomScrollView(slivers: <Widget>[
              SliverAppBar(
                leading: IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    color: Colors.black,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                floating: true,
                snap: true,
                /*show with moviment up*/
                backgroundColor: Colors.transparent,
                elevation: 0,
                //   flexibleSpace: FlexibleSpaceBar(title: const Text("", style: TextStyle(color: Colors.black45),),centerTitle: true),
              ),
              SliverToBoxAdapter(
                child: Container(
                  margin: EdgeInsets.only(top: 50),
                  decoration: new BoxDecoration(
                    gradient: ColorsStyle.getColorBackGround(),
                  ),
                  child: Column(
                    children: <Widget>[
                      Center(
                        child: new Image(
                            width: 275.0,
                            height: 150.0,
                            fit: BoxFit.fill,
                            image: new AssetImage(
                                'assets/images/intro/login.png')),
                      ),
                      Form(
                        key: _formKey,
                        child: new Center(
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
                                          borderRadius: BorderRadius.circular(
                                              8.0),
                                        ),
                                        child: Container(
                                          width: 300.0,
                                          height: 150.0,
                                          child: Column(
                                            children: <Widget>[
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    top: 10.0,
                                                    bottom: 10.0,
                                                    left: 25.0,
                                                    right: 25.0),
                                                child: TextFormField(
                                                  validator: (value) =>
                                                      HelpService.validateEmail(
                                                          value),
                                                  controller: loginEmailController,
                                                  keyboardType:
                                                  TextInputType.emailAddress,
                                                  style: TextStyle(
                                                      fontSize: 16.0,
                                                      color: Colors.black,
                                                      fontFamily: FontStyleApp
                                                          .fontFamily()),
                                                  decoration: InputDecoration(
                                                    errorStyle: TextStyle(
                                                        fontFamily: FontStyleApp
                                                            .fontFamily()),
                                                    border: InputBorder.none,
                                                    icon: Icon(
                                                      FontAwesome.getIconData(
                                                          "envelope"),
                                                      color: Colors.black,
                                                      size: 22.0,
                                                    ),
                                                    labelText: "Email",
                                                    hintStyle: TextStyle(
                                                        fontFamily: FontStyleApp
                                                            .fontFamily(),
                                                        fontSize: 17.0),
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
                                          margin: EdgeInsets.only(top: 125.0),
                                          decoration: new BoxDecoration(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(25.0)),
                                              boxShadow: <BoxShadow>[
                                                BoxShadow(
                                                  color: Colors.black,
                                                  offset: Offset(0.0, 0.3),
                                                  blurRadius: 1.0,
                                                ),
                                              ],
                                              gradient:
                                              ColorsStyle.getColorBotton()),
                                          child: MaterialButton(
                                              highlightColor: Colors
                                                  .transparent,
                                              splashColor: Color(0xFFFFFFFF),
                                              child: Padding(
                                                padding: const EdgeInsets
                                                    .symmetric(
                                                    vertical: 10.0,
                                                    horizontal: 42.0),
                                                child: Text(
                                                  "RECOVERY",
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 18.0),
                                                ),
                                              ),
                                              onPressed: () =>
                                                  _functionRecoveryEmail(
                                                      loginEmailController
                                                          .value.text)))
                                    ],
                                  ),
                                ],
                              ),
                            )),
                      )
                    ],
                  ),
                ),
              )
            ])
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: _scaffoldLoginKey,
      body: NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (overscroll) {
            overscroll.disallowGlow();
          },
          child: StreamBuilder<bool>(
            initialData: false,
            stream: _baseBloc.loadingStatusFlux,
            builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
              return _buildContent(snapshot.data);
            },
          )),
    );
  }
}
