import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:Fluttaxi/src/pages/driver-page/pages.dart';
import 'package:Fluttaxi/src/provider/provider.dart';

import 'intro/intro.page.dart';

class StartRacePage extends StatefulWidget {
  @override
  _StartRacePageState createState() => _StartRacePageState();
}

class _StartRacePageState extends State<StartRacePage> {
  AuthDriverBloc _startPage;

  @override
  void initState() {
    _startPage = BlocProvider.getBloc<AuthDriverBloc>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: _startPage.startFlux,
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {

          if (!snapshot.hasData) {
            return Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
            color: Colors.white,
                child: Center(child: CircularProgressIndicator(
                  valueColor: new AlwaysStoppedAnimation<Color>(Colors.amber),
                )));
          }
          return snapshot.data ? IntroPage() : HomeTabPage();
        });
  }
}
