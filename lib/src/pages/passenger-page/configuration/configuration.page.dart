import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/feather.dart';
import 'package:Fluttaxi/src/entity/entities.dart';
import 'package:Fluttaxi/src/provider/blocs/blocs.dart';

import '../../pages.dart';
import '../pages.dart';

class ConfigurationPage extends StatefulWidget {
  const ConfigurationPage(this.changeDrawer);

  final ValueChanged<BuildContext> changeDrawer;

  @override
  _ConfigurationPageState createState() => _ConfigurationPageState();
}

class _ConfigurationPageState extends State<ConfigurationPage> {

  AuthPassengerBloc _authBloc;

  @override
  void initState() {
    _authBloc = BlocProvider.getBloc<AuthPassengerBloc>();
    _authBloc.refreshAuth();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _updatePassageiro(Passageiro passageiro) async {
    await _authBloc.addPassageiroAuth(passageiro);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
          child: Stack(
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
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
                        return Container(
                          height: 200,
                          alignment: Alignment.center,
                          margin: EdgeInsets.only(top: 50),
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
                                        image: NetworkImage(passageiro.Foto.Url))),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Text(
                                passageiro.Nome,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                            ],
                          ),
                        );
                      }),
                  Padding(
                    padding: const EdgeInsets.only(left: 18),
                    child: Container(
                      child: Text(
                        'Favorite Places',
                        textAlign: TextAlign.left,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ),
                  ),
                  _getLocal('home', 'Add House', TipoLocal.House),
                  _getContentEndereco(TipoLocal.House),
                  _getLocal('briefcase', 'Add Job', TipoLocal.Job),
                  _getContentEndereco(TipoLocal.Job),
                ],
              ),
              buttonBar(widget.changeDrawer, context),
            ],
          ),
        ));
  }

  Widget _getLocal(String icon, String label, TipoLocal tipoLocal) =>
      GestureDetector(
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => AddLocationPage(tipoLocal))),
        child: Padding(
          padding: const EdgeInsets.only(left: 18, top: 10),
          child: Container(
            margin: EdgeInsets.only(left: 10, top: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(Feather.getIconData(icon)),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(label, style: TextStyle(color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0),),
                  ),
                ),
                StreamBuilder(
                    stream: _authBloc.userInfoFlux,
                    builder: (BuildContext context,
                        AsyncSnapshot<Passageiro> snapshot) {
                      if (!snapshot.hasData)
                        return Center(child: CircularProgressIndicator(
                          valueColor: new AlwaysStoppedAnimation<Color>(
                              Colors.amber),
                        ));

                      Passageiro passageiro = snapshot.data;

                      if (tipoLocal == TipoLocal.House) {
                        if (passageiro.Casa == null ||
                            passageiro.Casa?.Endereco == null)
                          return Container(width: 10, height: 10);
                      } else {
                        if (passageiro.Trabalho == null ||
                            passageiro.Trabalho?.Endereco == null)
                          return Container(width: 10, height: 10);
                      }

                      return Expanded(
                          child: GestureDetector(
                            onTap: () {
                              if (tipoLocal == TipoLocal.House) {
                                passageiro.Casa = null;
                              } else {
                                passageiro.Trabalho = null;
                              }
                              _updatePassageiro(passageiro);
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(right: 20),
                              child: Text(
                                'Excluir',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 14),
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ));
                    })
              ],
            ),
          ),
        ),
      );

  Widget _getContentEndereco(TipoLocal tipoLocal) => StreamBuilder(
      stream: _authBloc.userInfoFlux,
      builder: (BuildContext context, AsyncSnapshot<Passageiro> snapshot) {
        if (!snapshot.hasData)
          return Center(child: CircularProgressIndicator(
            valueColor: new AlwaysStoppedAnimation<Color>(Colors.amber),
          ));

        Passageiro passageiro = snapshot.data;

        if (tipoLocal == TipoLocal.House) {
          if (passageiro.Casa == null || passageiro?.Casa?.Nome == null)
            return Container(width: 10, height: 10);
        } else {
          if (passageiro.Trabalho == null || passageiro?.Trabalho?.Nome == null)
            return Container(width: 10, height: 10);
        }
        return Padding(
          padding: const EdgeInsets.only(left: 30),
          child: Text(tipoLocal == TipoLocal.House
              ? passageiro.Casa.Nome
              : passageiro.Trabalho.Nome,style: TextStyle(fontSize: 12),),
        );
      });
}
