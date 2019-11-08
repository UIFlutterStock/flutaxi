import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/feather.dart';
import 'package:geolocator/geolocator.dart';
import 'package:Fluttaxi/src/entity/entities.dart';
import 'package:Fluttaxi/src/infra/infra.dart';
import 'package:Fluttaxi/src/provider/blocs/blocs.dart';
import 'package:Fluttaxi/src/provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../pages.dart';

class StartRunWidget extends StatelessWidget {
  GlobalKey<ScaffoldState> scaffoldKey;

  StartRunWidget(this.scaffoldKey);

  BaseDriverBloc _authBase = BlocProvider.getBloc<BaseDriverBloc>();
  ViagemService _viagemService = new ViagemService();
  HomeDriverBloc _homeBloc = BlocProvider.getBloc<HomeDriverBloc>();
  GoogleService _googleService = GoogleService();
  BaseDriverBloc _baseBloc = BlocProvider.getBloc<BaseDriverBloc>();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: _authBase.viagemFlux,
        builder: (BuildContext context, AsyncSnapshot<Viagem> snapshot) {
          if (!snapshot.hasData)
            return Container(
              height: 1,
              width: 1,
            );

          var viagem = snapshot.data;

          if (viagem?.Id == null || viagem.Status == TravelStatus.Canceled)
            return Container(
              height: 1,
              width: 1,
            );

          var height = MediaQuery
              .of(context)
              .size
              .height * 0.37;
          var width = MediaQuery
              .of(context)
              .size
              .width;
          print(viagem.PassageiroEntity.Foto.Url);
          return Positioned.fill(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  color: Colors.transparent,
                  child: new Container(
                      height: height,
                      width: width,
                      decoration: new BoxDecoration(
                          color: Colors.white,
                          borderRadius: new BorderRadius.only(
                              topLeft: const Radius.circular(40.0),
                              topRight: const Radius.circular(40.0))),
                      child: Column(
                        children: <Widget>[
                          SizedBox(
                            height: 15,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "The passenger is waiting!",
                              style: TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.w600),
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Container(
                            height: 1,
                            color: Colors.grey.withOpacity(0.4),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: Column(
                                    children: <Widget>[
                                      CircleAvatar(
                                          radius: 25.0,
                                          backgroundColor:
                                          Colors.grey.withOpacity(0.1),
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: <Widget>[
                                              Stack(
                                                alignment: Alignment.center,
                                                children: <Widget>[
                                                  Icon(
                                                    Feather.getIconData(
                                                        'dollar-sign'),
                                                    size: 28,
                                                    color: Colors.black,
                                                  ),
                                                ],
                                              )
                                            ],
                                          )),
                                      Text(
                                        "\$${(TipoCarro.Pop ==
                                            viagem.TipoCorrida
                                            ? viagem.ValorPop
                                            : viagem.ValorTop).toStringAsFixed(
                                            2)}  ",
                                        style:
                                        TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'roboto'),
                                      )
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    children: <Widget>[
                                      CircleAvatar(
                                          radius: 25.0,
                                          backgroundColor:
                                          Colors.grey.withOpacity(0.1),
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: <Widget>[
                                              Stack(
                                                alignment: Alignment.center,
                                                children: <Widget>[
                                                  Container(
                                                    height: 60,
                                                    width: 50,
                                                    decoration: BoxDecoration(
                                                        border: Border.all(
                                                            color: Colors.white,
                                                            width: 2),
                                                        borderRadius:
                                                        BorderRadius.circular(
                                                            70),
                                                        image: DecorationImage(
                                                            fit: BoxFit.cover,
                                                            image: viagem
                                                                .PassageiroEntity
                                                                .Foto
                                                                .IndicaOnLine
                                                                ? NetworkImage(
                                                                viagem
                                                                    .PassageiroEntity
                                                                    .Foto
                                                                    .Url)
                                                                : AssetImage(
                                                                viagem
                                                                    .PassageiroEntity
                                                                    .Foto
                                                                    .Url))),
                                                  )
                                                ],
                                              )
                                            ],
                                          )),
                                      Text(
                                        viagem.PassageiroEntity.Nome,
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(viagem.PassageiroEntity.Email,
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    children: <Widget>[
                                      CircleAvatar(
                                          radius: 25.0,
                                          backgroundColor:
                                          Colors.grey.withOpacity(0.1),
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: <Widget>[
                                              Stack(
                                                alignment: Alignment.center,
                                                children: <Widget>[
                                                  Icon(
                                                    Feather.getIconData(
                                                        'map-pin'),
                                                    size: 24,
                                                    color: Colors.black,
                                                  ),
                                                ],
                                              )
                                            ],
                                          )),
                                      Text(
                                        viagem.Distancia,
                                        style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                              width: width * 0.9,
                              margin: EdgeInsets.only(top: 10.0),
                              decoration: new BoxDecoration(
                                  borderRadius:
                                  BorderRadius.all(Radius.circular(10.0)),
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
                                        vertical: 10.0, horizontal: 35.0),
                                    child: Text(
                                      "Start Race !",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16.0),
                                    ),
                                  ),
                                  onPressed: () {
                                    _iniciarViagem(context);
                                  }))
                        ],
                      )),
                ),
              )
            /* */
          );
        });
  }

  Future<void> _iniciarViagem(BuildContext context) async {
    Viagem viagem = await _authBase.viagemFlux.first;

    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    /*valida a aproximacao, evitar que a corrida seja iciada com distancia maior que 1km*/
    DistanciaTempo distanciaTempo = await _googleService.getdistancia(
        LatLng(viagem.OrigemLatitude, viagem.OrigemLongitude),
        LatLng(position.latitude, position.longitude));

    if (distanciaTempo.Distancia.contains('km')) {
      var distancia = double.tryParse(
          distanciaTempo.Distancia.replaceAll('km', '').replaceAll(',', '.'));

      if (distancia > 1) {
        ShowSnackBar.build(
            scaffoldKey,
            'Sorry the journey cannot be started yet you are $distancia from the boarding place.',
            context);
        return false;
      }
    }

    viagem.Status = TravelStatus.Started;
    await _viagemService.save(viagem);
    _homeBloc.stepMotoristaEvent.add(StepDriverHome.StartTrip);
    _baseBloc.orchestration();
  }
}
