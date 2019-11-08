import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:Fluttaxi/src/entity/entities.dart';
import 'package:Fluttaxi/src/infra/infra.dart';
import 'package:Fluttaxi/src/provider/provider.dart';

class ConfirmRaceWidget extends StatelessWidget {
  HomePassageiroBloc _homeBloc = BlocProvider.getBloc<HomePassageiroBloc>();
  BasePassageiroBloc _baseBloc = BlocProvider.getBloc<BasePassageiroBloc>();

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height * 0.35;
    var width = MediaQuery.of(context).size.width;
    return Positioned(
        height: height,
        width: width,
        bottom: 0,
        child: StreamBuilder(
            stream: _baseBloc.viagemFlux,
            builder: (BuildContext context, AsyncSnapshot<Viagem> snapshot) {
              if (!snapshot.hasData) {
                return Container(height: 1, width: 1);
              }

              Viagem viagem = snapshot.data;

              return StreamBuilder(
                  stream: _homeBloc.tipocarroFlux,
                  builder:
                      (BuildContext context, AsyncSnapshot snapshotViagem) {
                    if (!snapshotViagem.hasData) {
                      return Container(height: 1, width: 1);
                    }

                    TipoCarro tipoCarro = snapshotViagem.data ?? TipoCarro.Pop;

                    return Container(
                      color: Colors.white,
                      child: Column(
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              _buildStep(
                                  tipoCarro.index == 0
                                      ? 'assets/images/car/normal.png'
                                      : 'assets/images/car/normalinativo.png',
                                  viagem,
                                  'POP',
                                  tipoCarro.index == 0,
                                  TipoCarro.Pop),
                              _buildStep(
                                  tipoCarro.index == 0
                                      ? 'assets/images/car/taxiinativo.png'
                                      : 'assets/images/car/taxi.png',
                                  viagem,
                                  'TOP',
                                  tipoCarro.index == 1,
                                  TipoCarro.Top),
                            ],
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
                                        vertical: 10.0, horizontal: 42.0),
                                    child: Text(
                                      "Confirm",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16.0),
                                    ),
                                  ),
                                  onPressed: () async {
                                    viagem.TipoCorrida = tipoCarro;
                                    _homeBloc.stepProcessoEvent.add(
                                        StepPassengerHome.SearchDriver);
                                    await _baseBloc.orchestration();
                                  }))
                        ],
                      ),
                    );
                  });
            })
        /* */
        );
  }

  Widget _buildStep(String url, Viagem viagem, String title, bool status,
          TipoCarro tipo) =>
      InkWell(
        onTap: () {
          _homeBloc.tipocarroEvent.add(tipo);
        },
        child: Container(
          margin: EdgeInsets.only(top: 25),
          child: Column(
            children: <Widget>[
              CircleAvatar(
                radius: 30.0,
                backgroundColor: Color(0xFFEBF5FB).withOpacity(0.5),
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        Image.asset(url),
                      ],
                    )
                  ],
                ),
              ),
              Container(
                  alignment: Alignment.center,
                  child: Text(
                    title,
                    style: TextStyle(color: Colors.white),
                  ),
                  height: 20,
                  width: 40,
                  decoration: new BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(25.0)),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: Colors.black,
                          offset: Offset(0.0, 0.3),
                          blurRadius: 1.0,
                        ),
                      ],
                      gradient: LinearGradient(
                          colors: status
                              ? [Colors.orange, Colors.orange]
                              : [Colors.white70, Colors.white70],
                          tileMode: TileMode.repeated))),
              Padding(
                padding: EdgeInsets.only(top: 5),
                child: Text(
                    "\$${(TipoCarro.Pop == tipo ? viagem.ValorPop : viagem.ValorTop).toStringAsFixed(2)}  ",
                    /*"\$\8.05  "*/
                    style: TextStyle(
                        fontFamily: 'roboto',
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.none,
                        color: status
                            ? Colors.black
                            : Colors.black.withOpacity(0.2))),
              ),
              Padding(
                padding: EdgeInsets.only(top: 0),
                child: Text(viagem.Tempo,
                    /*"\$\8.05  "*/
                    style: TextStyle(
                        fontSize: 14.0,
                        fontFamily: 'roboto',
                        fontWeight: FontWeight.normal,
                        decoration: TextDecoration.none,
                        color: status
                            ? Colors.black
                            : Colors.black.withOpacity(0.2))),
              ),
            ],
          ),
        ),
      );
}
