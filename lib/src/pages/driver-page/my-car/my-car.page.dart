import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:Fluttaxi/src/entity/entities.dart';
import 'package:Fluttaxi/src/infra/infra.dart';
import 'package:Fluttaxi/src/provider/blocs/blocs.dart';
import 'package:Fluttaxi/src/provider/provider.dart';

import '../../pages.dart';

class MyCarPage extends StatefulWidget {
  const MyCarPage(this.changeDrawer);

  final ValueChanged<BuildContext> changeDrawer;

  @override
  _MyCarPageState createState() => _MyCarPageState();
}

class _MyCarPageState extends State<MyCarPage> {
  VehicleDriverBloc _veiculoMotoristaBloc;
  AuthDriverBloc _auth;
  MotoristaService _motoristaService;
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  GlobalKey<ScaffoldState> _scaffoldKey;
  TextEditingController _textPlacaName = new TextEditingController();

  @override
  void initState() {
    _scaffoldKey = new GlobalKey<ScaffoldState>();
    _veiculoMotoristaBloc = VehicleDriverBloc();
    _auth = BlocProvider.getBloc<AuthDriverBloc>();
    _motoristaService = MotoristaService();

    _veiculoMotoristaBloc.load(true);
    _loadPlaca();
    super.initState();
  }

  @override
  void dispose() {
    _veiculoMotoristaBloc?.dispose();
    _textPlacaName?.dispose();
    super.dispose();
  }

  _loadPlaca() async {
    var motorista = await _auth.userInfoFlux.first;
    _textPlacaName.text =
    motorista.Automovel.Placa != null ? motorista.Automovel.Placa : '';
  }


  Future<void> _salvarInfo() async {
    Motorista motorista = await _auth.userInfoFlux.first;
    String tipoSelecionado =
    (await _veiculoMotoristaBloc.selecionarCategoriaFlux.first);
    String marcaSelecionada =
    (await _veiculoMotoristaBloc.selecionarMarcaFlux.first);
    String anoSelecionada =
    (await _veiculoMotoristaBloc.selecionarAnoFlux.first);
    String corSelecionada =
    (await _veiculoMotoristaBloc.selecionarCorFlux.first);
    String modeloSelecionada =
    (await _veiculoMotoristaBloc.selecionarModeloFlux.first);

    if (tipoSelecionado == null || tipoSelecionado == '') {
      ShowSnackBar.build(
          _scaffoldKey, 'Need to select car type.', context);
      return;
    }

    if (marcaSelecionada == null || marcaSelecionada == '') {
      ShowSnackBar.build(
          _scaffoldKey, 'Need to select a car brand.', context);
      return;
    }

    if (modeloSelecionada == null || modeloSelecionada == '') {
      ShowSnackBar.build(
          _scaffoldKey, 'Need to select a car model.', context);
      return;
    }


    if (anoSelecionada == null || anoSelecionada == '') {
      ShowSnackBar.build(
          _scaffoldKey, 'Must select car year.', context);
      return;
    }

    if (corSelecionada == null || corSelecionada == '') {
      ShowSnackBar.build(
          _scaffoldKey, 'Need to select car color.', context);
      return;
    }

    final alphanumeric = RegExp(r'[a-zA-Z]{3}[0-9]{4}');
    if (_textPlacaName == null ||
        _textPlacaName.value == null ||
        _textPlacaName.value.text == '' ||
        (_textPlacaName.value.text
            .replaceAll('-', '')
            .length != 7) ||
        !alphanumeric.hasMatch(_textPlacaName.value.text.replaceAll('-', ''))) {
      ShowSnackBar.build(
          _scaffoldKey, 'Must add valid card ex : ABC1234.' , context);
      return;
    }

    var veiculo = Veiculo(
        Placa: _textPlacaName.text,
        Marca: marcaSelecionada,
        Ano: anoSelecionada,
        Cor: corSelecionada,
        Modelo: modeloSelecionada,
        Status: true,
        Tipo: tipoSelecionado == 'Pop' ? TipoCarro.Pop : TipoCarro.Top);

    motorista.Automovel = veiculo;

    await _motoristaService.save(motorista);
    _motoristaService.setStorage(motorista);
    _auth.userInfoEvent.add(motorista);
    ShowSnackBar.build(
        _scaffoldKey, 'Successfully saved car data.', context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        body: Stack(children: <Widget>[
          SingleChildScrollView(
            child: Container(
              height: MediaQuery
                  .of(context)
                  .size
                  .height +
                  (MediaQuery
                      .of(context)
                      .size
                      .height * 0.1),
              width: MediaQuery
                  .of(context)
                  .size
                  .width,
              child: Column(
                children: <Widget>[
                  new Center(
                      child: Container(
                        padding: EdgeInsets.only(top: 100.0),
                        child: Column(
                          children: <Widget>[
                            Card(
                              elevation: 30.0,
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Container(
                                width: MediaQuery
                                    .of(context)
                                    .size
                                    .width * 0.85,
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    children: <Widget>[
                                      Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment: MainAxisAlignment
                                            .center,
                                        children: <Widget>[
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 16.0,
                                                top: 10,
                                                bottom: 25),
                                            child: Text(
                                              'Car Data ! ',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(fontSize: 22),
                                            ),
                                          ),
                                        ],
                                      ),
                                      StreamBuilder(
                                          initialData: List<String>(),
                                          stream: _veiculoMotoristaBloc
                                              .listCategoriaFlux,
                                          builder: (BuildContext context,
                                              AsyncSnapshot<List<String>>
                                              snapshot) {
                                            if (!snapshot.hasData)
                                              return Container(
                                                  height: 1, width: 1);

                                            List<String> list = snapshot.data;

                                            if (list.length == 0)
                                              return Padding(
                                                padding: const EdgeInsets.all(
                                                    8.0),
                                                child: Container(
                                                  height: 1,
                                                  width: 1,
                                                ),
                                              );

                                            return Padding(
                                              padding: const EdgeInsets.all(
                                                  8.0),
                                              child: InputDecorator(
                                                decoration: InputDecoration(
                                                  border: OutlineInputBorder(),
                                                  contentPadding:
                                                  EdgeInsets.all(8.0),
                                                ),
                                                child: DropdownButtonHideUnderline(
                                                    child: StreamBuilder(
                                                        initialData: null,
                                                        stream: _veiculoMotoristaBloc
                                                            .selecionarCategoriaFlux,
                                                        builder: (BuildContext
                                                        context,
                                                            AsyncSnapshot<
                                                                String>
                                                            snapshots) {

                                                          return DropdownButton<
                                                              String>(
                                                            elevation: 8,
                                                            hint: Text(
                                                                'Select a Category'),
                                                            iconSize: 24.0,
                                                            isExpanded: true,
                                                            isDense: true,
                                                            value: snapshots
                                                                .data,
                                                            onChanged:
                                                                (
                                                                String categoria) {
                                                              _veiculoMotoristaBloc
                                                                  .selecionarMarcaEvent
                                                                  .add(null);
                                                              _veiculoMotoristaBloc
                                                                  .selecionarModeloEvent
                                                                  .add(null);
                                                              _veiculoMotoristaBloc
                                                                  .selecionarCategoriaEvent
                                                                  .add(
                                                                  categoria);
                                                              _veiculoMotoristaBloc
                                                                  .load(false);
                                                            },
                                                            items: (list.map((
                                                                result) =>
                                                                DropdownMenuItem(
                                                                    value:
                                                                    result,
                                                                    child: Text(
                                                                        result))))
                                                                .toList(),
                                                          );
                                                        })),
                                              ),
                                            );
                                          }),
                                      StreamBuilder(
                                          initialData: List<Veiculo>(),
                                          stream: _veiculoMotoristaBloc
                                              .listMarcaVeiculoFlux,
                                          builder: (BuildContext context,
                                              AsyncSnapshot<List<Veiculo>>
                                              snapshot) {
                                            if (!snapshot.hasData ||
                                                snapshot.connectionState ==
                                                    ConnectionState.waiting)
                                              return Center(
                                                  child: CircularProgressIndicator(
                                                    valueColor: new AlwaysStoppedAnimation<
                                                        Color>(Colors.amber),
                                                  ));


                                            List<Veiculo> list = snapshot.data;

                                            if (list.length == 0)
                                              return Container(
                                                height: 1,
                                                width: 1,
                                              );

                                            return Padding(
                                              padding: const EdgeInsets.all(
                                                  8.0),
                                              child: InputDecorator(
                                                decoration: InputDecoration(
                                                  border: OutlineInputBorder(),
                                                  contentPadding:
                                                  EdgeInsets.all(8.0),
                                                ),
                                                child: DropdownButtonHideUnderline(
                                                    child: StreamBuilder(
                                                        initialData: null,
                                                        stream: _veiculoMotoristaBloc
                                                            .selecionarMarcaFlux,
                                                        builder: (BuildContext
                                                        context,
                                                            AsyncSnapshot<
                                                                String>
                                                            snapshots) {
                                                          return DropdownButton<
                                                              String>(
                                                            elevation: 8,
                                                            hint: Text(
                                                                'Select a brand'),
                                                            iconSize: 24.0,
                                                            isExpanded: true,
                                                            isDense: true,
                                                            value: snapshots
                                                                .data,
                                                            onChanged:
                                                                (String marca) {
                                                              _veiculoMotoristaBloc
                                                                  .selecionarMarcaEvent
                                                                  .add(marca);
                                                              _veiculoMotoristaBloc
                                                                  .selecionarModeloEvent
                                                                  .add(null);
                                                              _veiculoMotoristaBloc
                                                                  .load(false);
                                                            },
                                                            items: (list.map((
                                                                result) =>
                                                                DropdownMenuItem(
                                                                    value: result
                                                                        .Marca,
                                                                    child: Text(
                                                                        result
                                                                            .Marca))))
                                                                .toList(),
                                                          );
                                                        })),
                                              ),
                                            );
                                          }),
                                      StreamBuilder(
                                          initialData: List<Veiculo>(),
                                          stream: _veiculoMotoristaBloc
                                              .listModeloVeiculoFlux,
                                          builder: (BuildContext context,
                                              AsyncSnapshot<List<Veiculo>>
                                              snapshot) {
                                            if (!snapshot.hasData)
                                              return Container(
                                                  height: 1, width: 1);

                                            List<Veiculo> list = snapshot.data;

                                            if (list.length == 0)
                                              return Padding(
                                                padding: const EdgeInsets.all(
                                                    0.0),
                                                child: Container(
                                                  height: 1,
                                                  width: 1,
                                                ),
                                              );

                                            return Padding(
                                              padding: const EdgeInsets.all(
                                                  8.0),
                                              child: InputDecorator(
                                                decoration: InputDecoration(
                                                  border: OutlineInputBorder(),
                                                  contentPadding:
                                                  EdgeInsets.all(8.0),
                                                ),
                                                child: DropdownButtonHideUnderline(
                                                    child: StreamBuilder(
                                                        initialData: null,
                                                        stream: _veiculoMotoristaBloc
                                                            .selecionarModeloFlux,
                                                        builder: (BuildContext
                                                        context,
                                                            AsyncSnapshot<
                                                                String>
                                                            snapshots) {
                                                          return DropdownButton<
                                                              String>(
                                                            elevation: 8,
                                                            hint: Text(
                                                                'Select a model'),
                                                            iconSize: 24.0,
                                                            isExpanded: true,
                                                            isDense: true,
                                                            value: snapshots
                                                                .data,
                                                            onChanged:
                                                                (String marca) {
                                                              _veiculoMotoristaBloc
                                                                  .selecionarModeloEvent
                                                                  .add(marca);
                                                              _veiculoMotoristaBloc
                                                                  .load(false);
                                                            },
                                                            items: (list.map((
                                                                result) =>
                                                                DropdownMenuItem(
                                                                    value: result
                                                                        .Modelo,
                                                                    child: Text(
                                                                        result
                                                                            .Modelo))))
                                                                .toList(),
                                                          );
                                                        })),
                                              ),
                                            );
                                          }),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: StreamBuilder(
                                            initialData: List<String>(),
                                            stream: _veiculoMotoristaBloc
                                                .listAnoVeiculoFlux,
                                            builder: (BuildContext context,
                                                AsyncSnapshot<List<String>>
                                                snapshot) {
                                              if (!snapshot.hasData)
                                                return Container(
                                                    height: 1, width: 1);

                                              List<String> list = snapshot.data;

                                              if (list.length == 0)
                                                return Container(
                                                  height: 1,
                                                  width: 1,
                                                );

                                              return InputDecorator(
                                                decoration: InputDecoration(
                                                  border: OutlineInputBorder(),
                                                  contentPadding:
                                                  EdgeInsets.all(8.0),
                                                ),
                                                child: DropdownButtonHideUnderline(
                                                    child: StreamBuilder(
                                                        initialData: null,
                                                        stream:
                                                        _veiculoMotoristaBloc
                                                            .selecionarAnoFlux,
                                                        builder: (BuildContext
                                                        context,
                                                            AsyncSnapshot<
                                                                String>
                                                            snapshots) {
                                                          return DropdownButton<
                                                              String>(
                                                            elevation: 8,
                                                            hint: Text(
                                                                'Select the year of the vehicle.'),
                                                            iconSize: 24.0,
                                                            isExpanded: true,
                                                            isDense: true,
                                                            value: snapshots
                                                                .data,
                                                            onChanged:
                                                                (String ano) {
                                                              _veiculoMotoristaBloc
                                                                  .selecionarAnoEvent
                                                                  .add(ano);
                                                              _veiculoMotoristaBloc
                                                                  .buildAno(
                                                                  ano);
                                                            },
                                                            items: (list.map((
                                                                result) =>
                                                                DropdownMenuItem(
                                                                    value:
                                                                    result,
                                                                    child: Text(
                                                                        result))))
                                                                .toList(),
                                                          );
                                                        })),
                                              );
                                            }),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: StreamBuilder(
                                            initialData: List<String>(),
                                            stream: _veiculoMotoristaBloc
                                                .listCorVeiculoFlux,
                                            builder: (BuildContext context,
                                                AsyncSnapshot<List<String>>
                                                snapshot) {
                                              if (!snapshot.hasData)
                                                return Container(
                                                    height: 1, width: 1);

                                              List<String> list = snapshot.data;

                                              if (list.length == 0)
                                                return Container(
                                                  height: 1,
                                                  width: 1,
                                                );

                                              return InputDecorator(
                                                decoration: InputDecoration(
                                                  border: OutlineInputBorder(),
                                                  contentPadding:
                                                  EdgeInsets.all(8.0),
                                                ),
                                                child: DropdownButtonHideUnderline(
                                                    child: StreamBuilder(
                                                        initialData: null,
                                                        stream:
                                                        _veiculoMotoristaBloc
                                                            .selecionarCorFlux,
                                                        builder: (BuildContext
                                                        context,
                                                            AsyncSnapshot<
                                                                String>
                                                            snapshots) {
                                                          return DropdownButton<
                                                              String>(
                                                            elevation: 8,
                                                            hint: Text(
                                                                'Select vehicle color.'),
                                                            iconSize: 24.0,
                                                            isExpanded: true,
                                                            isDense: true,
                                                            value: snapshots
                                                                .data,
                                                            onChanged:
                                                                (String cor) {
                                                              _veiculoMotoristaBloc
                                                                  .selecionarCorEvent
                                                                  .add(cor);
                                                              _veiculoMotoristaBloc
                                                                  .buildCor(
                                                                  cor);
                                                            },
                                                            items: (list.map((
                                                                result) =>
                                                                DropdownMenuItem(
                                                                    value:
                                                                    result,
                                                                    child: Text(
                                                                        result))))
                                                                .toList(),
                                                          );
                                                        })),
                                              );
                                            }),
                                      ),
                                      Padding(
                                          padding: const EdgeInsets.only(
                                              top: 8,
                                              bottom: 28,
                                              left: 8,
                                              right: 8),
                                          child: InputDecorator(
                                            decoration: InputDecoration(
                                              border: OutlineInputBorder(),
                                              contentPadding: EdgeInsets.only(
                                                  left: 5),
                                            ),
                                            child: TextFormField(

                                              controller: _textPlacaName,
                                              onFieldSubmitted: (term) {
                                                _salvarInfo();
                                              },
                                              keyboardType: TextInputType.text,
                                              style: TextStyle(
                                                  fontSize: 16.0,
                                                  color: Colors.black
                                                      .withOpacity(0.7),
                                                  fontFamily:
                                                  FontStyleApp.fontFamily()),
                                              decoration: InputDecoration(
                                                hintText: 'Add a Plate . ',
                                                errorStyle: TextStyle(
                                                    fontFamily:
                                                    FontStyleApp.fontFamily()),
                                                border: InputBorder.none,
                                                hintStyle: TextStyle(
                                                    fontFamily:
                                                    FontStyleApp.fontFamily(),
                                                    fontSize: 17.0,
                                                    color: Colors.black
                                                        .withOpacity(0.4)),
                                              ),
                                            ),
                                          )),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Container(
                                margin: EdgeInsets.only(top: 20.0),
                                decoration: new BoxDecoration(
                                    borderRadius:
                                    BorderRadius.all(Radius.circular(25.0)),
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
                                        "SAVE",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16.0),
                                      ),
                                    ),
                                    onPressed: () {
                                      _salvarInfo();
                                    }))
                          ],
                        ),
                      ))
                ],
              ),
            ),
          ),
          buttonBar(widget.changeDrawer, context)
        ]));
  }
}
