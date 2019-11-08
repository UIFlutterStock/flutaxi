import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/feather.dart';
import 'package:Fluttaxi/src/entity/entities.dart';
import 'package:Fluttaxi/src/infra/infra.dart';
import 'package:Fluttaxi/src/provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../pages.dart';

class DriverFoundWidget extends StatelessWidget {
  GlobalKey<ScaffoldState> scaffoldKey;

  DriverFoundWidget(this.scaffoldKey);

  BasePassageiroBloc _baseBloc = BlocProvider.getBloc<BasePassageiroBloc>();
  HomePassageiroBloc _homeBloc = BlocProvider.getBloc<HomePassageiroBloc>();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: _baseBloc.viagemFlux,
        builder: (BuildContext context, AsyncSnapshot<Viagem> snapshot) {
          if (!snapshot.hasData)
            return Container(
              height: 1,
              width: 1,
            );

          var height = MediaQuery
              .of(context)
              .size
              .height * 0.43;
          var width = MediaQuery.of(context).size.width;

          var viagem = snapshot.data;

          if (viagem?.Id == null || viagem.Status == TravelStatus.Canceled)
            return Container(
              height: 1,
              width: 1,
            );

          var timelimite = (viagem.ViagemAceitaEm).add(Duration(minutes: 5));
          var cancelarAte = DateFormat('hh:mm').format(timelimite);

          return Positioned(
              height: height,
              width: width,
              bottom: 0,
              child: new Container(
                color: Colors.transparent,
                child: new Container(
                    decoration: new BoxDecoration(
                        color: Colors.white,
                        borderRadius: new BorderRadius.only(
                            topLeft: const Radius.circular(40.0),
                            topRight: const Radius.circular(40.0))),
                    child: Column(
                      children: <Widget>[
                        SizedBox(
                          height: 2,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "Your driver is on his way !",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8, right: 8),
                          child: Text(
                              'The driver is on his way, please wait. If you wish to change your trip, you can cancel free of charge before ${cancelarAte}.',
                              style: TextStyle(fontSize: 14)),
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
                                                  size: 24,
                                                  color: Colors.black,
                                                ),
                                              ],
                                            )
                                          ],
                                        )),
                                    Text(
                                      "R\$${(TipoCarro.Pop == viagem.TipoCorrida ? viagem.ValorPop : viagem.ValorTop).toStringAsFixed(2)}  ",
                                      style: TextStyle(
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
                                                              .MotoristaEntity
                                                                  .Foto
                                                                  .IndicaOnLine
                                                              ? NetworkImage(viagem
                                                              .MotoristaEntity
                                                                  .Foto
                                                                  .Url)
                                                              : AssetImage(viagem
                                                              .MotoristaEntity
                                                                  .Foto
                                                                  .Url))),
                                                )
                                              ],
                                            )
                                          ],
                                        )),
                                    Text(
                                      '${HelpService.fixString(
                                          viagem.MotoristaEntity.Nome, 15)}',
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                        '${HelpService.fixString(
                                            viagem.MotoristaEntity.Email, 13)}',
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
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Center(
                          child: Column(
                            children: <Widget>[
                              Text(
                                '${HelpService.fixString(viagem.MotoristaEntity.Automovel.Placa, 10)}',
                                style: TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                  '${HelpService.fixString(viagem.MotoristaEntity.Automovel.Cor, 10)} - ${HelpService.fixString(viagem.MotoristaEntity.Automovel.Modelo, 10)}',
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold)),
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
                                    "Cancelar",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16.0),
                                  ),
                                ),
                                onPressed: () async {
                                  if (DateTime.now().isAfter(timelimite)) {
                                    ShowSnackBar.build(
                                        scaffoldKey,
                                        'Sorry the trip cannot be canceled by the app, the time for cancellation is over, wait for the driver and cancel in person!',
                                        context);
                                    return;
                                  }

                                  await _baseBloc.cancelarCorrida();
                                  _homeBloc.stepProcessoEvent
                                      .add(StepPassengerHome.Start);
                                  _baseBloc.viagemEvent.add(Viagem());
                                  await _baseBloc.orchestration();
                                }))
                      ],
                    )),
              )
              /* */
              );
        });
  }
}
