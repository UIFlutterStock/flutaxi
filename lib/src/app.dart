import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';

import 'entity/entities.dart';
import 'infra/admin/admin.dart';
import 'pages/driver-page/pages.dart';
import 'pages/passenger-page/start-passageiro.page.dart';
import 'provider/blocs/blocs.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    List<Bloc<BlocBase>> blocsPassageiro = _blocPassageiro();

    List<Bloc<BlocBase>> blocsMotorista = _blocMotorista();

    return BlocProvider(
      blocs: configAmbiente == Ambiente.Passenger
          ? blocsPassageiro
          : blocsMotorista,
      child: MaterialApp(
          locale: Locale('pt', 'PT'),
          title: "Fluttaxi App ",
          debugShowCheckedModeBanner: false,
          home: configAmbiente == Ambiente.Passenger
              ? StartPassageiroPage()
              : StartRacePage(),
          routes: configAmbiente == Ambiente.Passenger
              ? routesPassageiroConfig
              : routesRaceConfig,
          theme: ThemeData(
              fontFamily: "Raleway",
              scaffoldBackgroundColor: Colors.white,
              textTheme: TextTheme(body1: TextStyle(fontSize: 16)))),
    );
  }

  /*provider passageiro*/
  List<Bloc<BlocBase>> _blocPassageiro() {
    final List<Bloc> blocsPassageiro = [
      Bloc((i) => LoadingBloc()),
      Bloc((i) => HomeTabBloc()),
      Bloc((i) => HomePassageiroBloc()),
      Bloc((i) => AuthPassengerBloc()),
      Bloc((i) => TravelPassengerBloc()),
      Bloc((i) => BasePassageiroBloc()),
    ];
    return blocsPassageiro;
  }

/*provider motorista*/
  List<Bloc<BlocBase>> _blocMotorista() {
    final List<Bloc> blocsPassageiro = [
      Bloc((i) => LoadingBloc()),
      Bloc((i) => HomeTabBloc()),
      Bloc((i) => HomeDriverBloc()),
      Bloc((i) => AuthDriverBloc()),
      Bloc((i) => BaseDriverBloc()),
    ];
    return blocsPassageiro;
  }
}
