import 'package:flutter/material.dart';
import 'package:flutter_icons/feather.dart';
import 'package:Fluttaxi/src/entity/entities.dart';
import 'package:Fluttaxi/src/infra/help/help.dart';
import 'package:Fluttaxi/src/provider/provider.dart';
import 'package:intl/intl.dart';

import '../../pages.dart';

class HistoricPage extends StatefulWidget {
  const HistoricPage(this.changeDrawer);

  final ValueChanged<BuildContext> changeDrawer;

  @override
  _HistoricPageState createState() => _HistoricPageState();
}

class _HistoricPageState extends State<HistoricPage> {
  Future<List<Viagem>> listaViagens;
  ViagemService viagemService;
  Motorista motorista;
  TravelDriverBloc _viagemBloc;

  @override
  void initState() {
    _viagemBloc = new TravelDriverBloc();
    _viagemBloc.loadViagem();
    super.initState();
  }

  @override
  void dispose() {
    _viagemBloc?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: <Widget>[
        Container(
          child: StreamBuilder(
              stream: _viagemBloc.listViagensFlux,
              builder:
                  (BuildContext context, AsyncSnapshot<List<Viagem>> snapshot) {
                if (!snapshot.hasData ||
                    snapshot.connectionState == ConnectionState.waiting)
                  return Center(child: CircularProgressIndicator(
                    valueColor: new AlwaysStoppedAnimation<Color>(Colors.amber),
                  ));

                List<Viagem> listaViagens = snapshot.data;


                if (listaViagens.length == 0)
                  return Center(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Icon(
                            Feather.getIconData('search'),
                            size: 40,
                          ),
                        ),
                        Container(
                            child: Text('No registered trips !',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold))),
                      ]));

                return Padding(
                  padding: const EdgeInsets.only(top: 18),
                  child: ListView.builder(
                      itemCount: listaViagens.length,
                      itemBuilder: (BuildContext ctxt, int index) {

                        return Container(
                          child: _itemHistorico(listaViagens[index]),
                          margin: EdgeInsets.only(top: 25),
                        );
                      }),
                );
              }),
        ),
        buttonBar(widget.changeDrawer, context),
      ],
    ));
  }

  _verificaCustoViagem(Viagem viagem) {
    if (viagem.Status != TravelStatus.Finished) return "Canceled";

    print(viagem.Status);

    return viagem.TipoCorrida == TipoCarro.Pop
        ? '\$${(viagem.ValorPop).toStringAsFixed(2)} '
        : '\$${(viagem.ValorTop).toStringAsFixed(2)} ';
  }

  _itemHistorico(Viagem viagem) => new Container(
        child: new Container(
          margin: new EdgeInsets.only(top: 15, bottom: 15, left: 5, right: 5),
          constraints: new BoxConstraints.expand(),
          child: new Container(
            child: new Column(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(top: 10),
                  // width: MediaQuery.of(context).size.width,
                  child: Row(
                    children: <Widget>[
                      Image(
                        height: 130,
                        width: 110,
                        image: AssetImage('assets/images/historico/mapa.png'),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                SizedBox(width: 5),
                                Text(
                                  DateFormat('dd-MM-yyyy H:mm')
                                      .format(viagem.CriadoEm),
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                      fontFamily: 'roboto',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14),
                                ),
                                SizedBox(
                                    width:
                                    TravelStatus.Finished != viagem.Status
                                            ? 25
                                            : 30),
                                Container(
                                    alignment: Alignment.center,
                                    child: Text(
                                      _verificaCustoViagem(viagem),
                                      style: TextStyle(
                                          fontFamily: 'roboto',
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14),
                                    ),
                                    height: 20,
                                    width:
                                    TravelStatus.Finished != viagem.Status
                                            ? 80
                                            : 55,
                                    decoration: new BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10.0)),
                                        boxShadow: <BoxShadow>[
                                          BoxShadow(
                                            color: Colors.black,
                                            offset: Offset(0.0, 0.3),
                                            blurRadius: 3.0,
                                          ),
                                        ],
                                        gradient: LinearGradient(
                                            colors: TravelStatus.Finished !=
                                                    viagem.Status
                                                ? [Colors.red, Colors.redAccent]
                                                : [
                                                    Colors.yellowAccent,
                                                    Colors.yellow
                                                  ],
                                            tileMode: TileMode.repeated)))
                                /*Text("R 58,00")*/
                              ],
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Image(
                                  height: 100,
                                  image: AssetImage(
                                      'assets/images/historico/pick.png'),
                                ),
                                Container(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          "Source",
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.5,
                                        child: new Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            new Text(
                                                HelpService.fixString(
                                                    viagem.OrigemEndereco, 30),
                                                style: TextStyle(fontSize: 12),
                                                textAlign: TextAlign.left),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          "Destiny",
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.5,
                                        child: new Column(
                                          mainAxisSize: MainAxisSize.max,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            new Text(
                                                HelpService.fixString(
                                                    viagem.DestinoEndereco, 30),
                                                style: TextStyle(fontSize: 12),
                                                textAlign: TextAlign.left),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        height: 170.0,
        decoration: new BoxDecoration(
          color: new Color(0xFFFFFFFF),
          shape: BoxShape.rectangle,
          borderRadius: new BorderRadius.circular(8.0),
          boxShadow: <BoxShadow>[
            new BoxShadow(
              color: Colors.black12,
              blurRadius: 10.0,
              offset: new Offset(1.0, 10.0),
            ),
          ],
        ),
      );
}
