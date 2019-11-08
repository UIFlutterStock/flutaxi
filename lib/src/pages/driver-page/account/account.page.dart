import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:Fluttaxi/src/infra/infra.dart';
import 'package:Fluttaxi/src/provider/provider.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import 'widgets/loginAccount.widget.dart';
import 'widgets/registerAccount.widget.dart';

class AccountPage extends StatefulWidget {
  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldLoginKey =
      new GlobalKey<ScaffoldState>();
  PageController _pageController;
  LoadingBloc _loadingBloc;
  Color left = Colors.black;
  Color right = Colors.white;

  @override
  void dispose() {
    _pageController?.dispose();

    //_baseBloc?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    _loadingBloc = BlocProvider.getBloc<LoadingBloc>();
    _pageController = PageController();
    super.initState();
  }

  Widget _buildMenuBar(BuildContext context) => Container(
        width: 300.0,
        height: 50.0,
        decoration: BoxDecoration(
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black,
                offset: Offset(0.0, 0.3),
                blurRadius: 1.0,
              ),
            ],
            borderRadius: BorderRadius.all(Radius.circular(25.0)),
            gradient: ColorsStyle.getColorBotton()),
        child: CustomPaint(
          painter: TabIndicationPainterHelp(pageController: _pageController),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Expanded(
                child: FlatButton(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onPressed: _onSignInButtonPress,
                  child: Text(
                    "LOGIN",
                    style: TextStyle(
                        color: left,
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              //Container(height: 33.0, width: 1.0, color: Colors.white),
              Expanded(
                child: FlatButton(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onPressed: _onSignUpButtonPress,
                  child: Text(
                    "NOVO",
                    style: TextStyle(
                        color: right,
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      );

  void _onSignInButtonPress() => _pageController.animateToPage(0,
      duration: Duration(milliseconds: 500), curve: Curves.decelerate);

  void _onSignUpButtonPress() => _pageController?.animateToPage(1,
      duration: Duration(milliseconds: 500), curve: Curves.decelerate);

  Widget _buildContent(bool statusLoading) => ModalProgressHUD(
        inAsyncCall: statusLoading,
        progressIndicator: CircularProgressIndicator(
          valueColor: new AlwaysStoppedAnimation<Color>(Colors.amber),
        ),
        child: SingleChildScrollView(
          child: Stack(children: <Widget>[
            Container(
              margin: EdgeInsets.only(top: 50),
              height: 870.0,
              width: MediaQuery.of(context).size.width,
              decoration: new BoxDecoration(
                gradient: ColorsStyle.getColorBackGround(),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Stack(children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(top: 10.0),
                      child: new Image(
                          width: 320.0,
                          height: 220.0,
                          fit: BoxFit.fill,
                          image:
                          new AssetImage('assets/images/intro/race.png')),
                    ),
                  ]),
                  Padding(
                    padding: EdgeInsets.only(top: 10.0),
                    child: _buildMenuBar(context),
                  ),
                  Expanded(
                    flex: 2,
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: (i) {
                        if (i == 0) {
                          setState(() {
                            right = Colors.white;
                            left = Colors.black;
                          });
                        } else if (i == 1) {
                          setState(() {
                            right = Colors.black;
                            left = Colors.white;
                          });
                        }
                      },
                      children: <Widget>[
                        new ConstrainedBox(
                          constraints: const BoxConstraints.expand(),
                          child: LoginAccount(_loadingBloc, _scaffoldLoginKey),
                        ),
                        new ConstrainedBox(
                            constraints: const BoxConstraints.expand(),
                            child: RegisterAccount(
                                _loadingBloc, _scaffoldLoginKey)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ]),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: _scaffoldLoginKey,
      body: NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (overscroll) {
            overscroll.disallowGlow();
            return false;
          },
          child: StreamBuilder<bool>(
            initialData: false,
            stream: _loadingBloc.loadingStatusFlux,
            builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
              return _buildContent(snapshot.data);
            },
          )),
    );
  }
}
