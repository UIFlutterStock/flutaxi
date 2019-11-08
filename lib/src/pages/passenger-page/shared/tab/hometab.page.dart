import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/feather.dart';
import 'package:Fluttaxi/src/entity/entities.dart';
import 'package:Fluttaxi/src/infra/admin/admin.dart';
import 'package:Fluttaxi/src/provider/provider.dart';

import '../../pages.dart';

class HomeTabPage extends StatefulWidget {
  @override
  _HomeTabPageState createState() => _HomeTabPageState();
}

class _HomeTabPageState extends State<HomeTabPage> {
  HomeTabBloc _homeBloc;
  AuthPassengerBloc _authBloc;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    _homeBloc = BlocProvider.getBloc<HomeTabBloc>();
    _authBloc = BlocProvider.getBloc<AuthPassengerBloc>();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: Drawer(
        child: Container(
          color: Colors.white,
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              StreamBuilder(
                  stream: _authBloc.userInfoFlux,
                  builder: (BuildContext context,
                      AsyncSnapshot<Passageiro> snapshot) {
                    if (!snapshot.hasData)
                      return Container(
                        height: 1,
                        width: 1,
                      );

                    Passageiro passageiro = snapshot.data;

                    return DrawerHeader(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            height: 100,
                            width: 100,
                            decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.white, width: 2),
                                borderRadius: BorderRadius.circular(70),
                                image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: passageiro.Foto.IndicaOnLine
                                        ? NetworkImage(passageiro.Foto.Url)
                                        : AssetImage(passageiro.Foto.Url))),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            passageiro.Nome,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          /* Text(
                            passageiro.Email,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 12),
                          )*/
                        ],
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                      ),
                    );
                  }),
              _tileGet(0, "home", "Home"),
              _tileGet(1, "user", "ProFile"),
              _tileGet(2, "archive", "Historic"),
              _tileGet(3, "settings", "Configuration"),
              ListTile(
                leading: Icon(
                  Feather.getIconData('log-out'),
                  color: Colors.black,
                  size: 25,
                ),
                title: Text(
                  'Logout',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                onTap: () {
                  _authBloc.signOut().then((r) {
                    NavigationPagesPassageiro.goToAccount(context);
                  });
                },
              )
            ],
          ),
        ),
      ),
      body: _getPage(),
    );
  }

  void changeDrawer(BuildContext contextValue) {
    _authBloc.refreshAuth();
    Scaffold.of(contextValue).openDrawer();
  }

  Widget _tileGet(int index, String icon, String title) {
    return ListTile(
      leading: Icon(
        Feather.getIconData(icon),
        color: Colors.black,
        size: 25,
      ),
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
      onTap: () {
        _homeBloc.tabPageControllerEvent.add(index);
        _scaffoldKey.currentState.openEndDrawer();
      },
    );
  }

  Widget _getPage() => StreamBuilder(
      stream: _homeBloc.tabPageControllerFlux,
      initialData: 0,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        var position = snapshot.hasData ? snapshot.data : 0;

        switch (position) {
          case 0:
            return HomePage(changeDrawer);
            break;
          case 1:
            return ProfilePage(changeDrawer);
            break;
          case 2:
            return HistoricPage(changeDrawer);
          case 3:
            return ConfigurationPage(changeDrawer);
            break;
          default:
            return HomePage(changeDrawer);
        }
      });
}
