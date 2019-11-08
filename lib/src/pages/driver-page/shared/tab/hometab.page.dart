import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/feather.dart';
import 'package:Fluttaxi/src/entity/entities.dart';
import 'package:Fluttaxi/src/infra/admin/admin.dart';
import 'package:Fluttaxi/src/pages/driver-page/home/home.page.dart';
import 'package:Fluttaxi/src/pages/driver-page/report/report-list/relatoria-listagem.page.dart';
import 'package:Fluttaxi/src/provider/provider.dart';

import '../../pages.dart';

class HomeTabPage extends StatefulWidget {
  @override
  _HomeTabPageState createState() => _HomeTabPageState();
}

class _HomeTabPageState extends State<HomeTabPage> {
  HomeTabBloc _homeBloc;
  AuthDriverBloc _authBloc;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    _homeBloc = BlocProvider.getBloc<HomeTabBloc>();
    _authBloc = BlocProvider.getBloc<AuthDriverBloc>();
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
                      AsyncSnapshot<Motorista> snapshot) {
                    if (!snapshot.hasData)
                      return Container(
                        height: 1,
                        width: 1,
                      );

                    Motorista motorista = snapshot.data;

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
                                    image: motorista.Foto.IndicaOnLine
                                        ? NetworkImage(motorista.Foto.Url)
                                        : AssetImage(motorista.Foto.Url))),
                          ),
                          SizedBox(
                            height: 2,
                          ),
                          Text(
                            motorista.Nome,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                        ],
                      ),
                    );
                  }),
              _tileGet(0, "home", "Home"),
              _tileGet(1, "settings", "My Car"),
              _tileGet(2, "archive", "Historic"),
              _tileGet(3, "dollar-sign", "Spending"),
              _tileGet(4, "trending-up", "Report"),
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
                    NavigationPagesRace.goToAccount(context);
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
            return MyCarPage(changeDrawer);
            break;
          case 2:
            return HistoricPage(changeDrawer);
            break;
          case 3:
            return ReportListPage(changeDrawer);
            break;
          case 4:
            return ChartPage(changeDrawer);
            break;
          default:
            return HomePage(changeDrawer);
            break;
        }
      });
}
