import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:Fluttaxi/src/entity/entities.dart';
import 'package:Fluttaxi/src/provider/blocs/blocs.dart';

import '../../../pages.dart';

class SearchInputWidget extends StatelessWidget {
  GlobalKey<ScaffoldState> scaffoldKey;

  SearchInputWidget(this.scaffoldKey);

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      top: 100,
      child: Align(
        alignment: Alignment.topCenter,
        child: InkWell(
          onTap: () {
            _functionValidadeSearchSourceDestiny(context);
          },
          child: new Container(
            margin: EdgeInsets.only(right: 5, left: 5),
            width: MediaQuery.of(context).size.width * 0.98,
            child: Text(
              "Where are we going?",
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
            ),
            decoration: new BoxDecoration(
                borderRadius: new BorderRadius.all(new Radius.circular(50.0)),
                color: Colors.white),
            padding: new EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0),
          ),
        ),
      ),
    );
  }

  _functionValidadeSearchSourceDestiny(BuildContext context) async {
    AuthPassengerBloc authBloc = BlocProvider.getBloc<AuthPassengerBloc>();
    HomePassageiroBloc homeBloc = BlocProvider.getBloc<HomePassageiroBloc>();
    HomeTabBloc homeTabBloc = BlocProvider.getBloc<HomeTabBloc>();

    Passageiro passageiro = await authBloc.userInfoFlux.first;

    if (passageiro == null) {
      await authBloc.refreshAuth();
      passageiro = await authBloc.userInfoFlux.first;
    }

    if (passageiro.Idade < 10) {
      ShowSnackBar.build(
          scaffoldKey,
          'Must complete registration to start a race. Please fill in the age!',
          context);

      Future.delayed(const Duration(milliseconds: 4000), () {
        homeTabBloc.tabPageControllerEvent.add(1);
      });
    } else {
      homeBloc.stepProcessoEvent
          .add(StepPassengerHome.SelectSourceDestination);
    }
  }
}
