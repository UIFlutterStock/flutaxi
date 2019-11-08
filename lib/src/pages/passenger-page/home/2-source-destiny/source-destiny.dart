import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/feather.dart';
import 'package:Fluttaxi/src/entity/entities.dart';
import 'package:Fluttaxi/src/infra/infra.dart';
import 'package:Fluttaxi/src/provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:line_icons/line_icons.dart';

class SelectSourceDestinyWidget extends StatefulWidget {
  @override
  _SelectSourceDestinyWidgetState createState() =>
      _SelectSourceDestinyWidgetState();
}

class _SelectSourceDestinyWidgetState
    extends State<SelectSourceDestinyWidget> {
  TextEditingController origemController = new TextEditingController();
  TextEditingController destinoController = new TextEditingController();
  final FocusNode origemFocus = FocusNode();
  final FocusNode destinoFocus = FocusNode();
  BasePassageiroBloc _baseBloc;
  AutoCompleteBloc _autoCompleteBloc;
  GoogleService _googleService;
  HomePassageiroBloc _homeBloc;
  AuthPassengerBloc _authBloc;

  @override
  void dispose() {
    origemController?.dispose();
    destinoController?.dispose();
    origemFocus?.dispose();
    destinoFocus?.dispose();
    _autoCompleteBloc?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _authBloc = BlocProvider.getBloc<AuthPassengerBloc>();
    _homeBloc = BlocProvider.getBloc<HomePassageiroBloc>();
    _baseBloc = BlocProvider.getBloc<BasePassageiroBloc>();
    _autoCompleteBloc = AutoCompleteBloc();
    _googleService = GoogleService();
    _authBloc.refreshAuth();
    _load();
    super.initState();
  }

  /*ao iniciar essa tela obtem os valores do destino e origem atual da tela e adiciona oo input */
  _load() async {
    ProviderMapa provide = await _baseBloc.providermapFlux.first;
    origemController.text = provide.EnderecoOrigem;
    _autoCompleteBloc.listaLocalEvent.add(List<Local>());
    destinoController.text = '';
  }

  /*verifica se a origem e destino está devidamente adiciona e se tiver inicia o processo */
  _validaProximaEtapa() async {
    ProviderMapa provider = await _baseBloc.providermapFlux.first;

    if (provider.EnderecoOrigem.isNotEmpty &&
        provider.EnderecoDestino.isNotEmpty &&
        origemController.value.text != '' &&
        destinoController.value.text != '') {
      /*obtem a distancia*/
      _googleService
          .getdistancia(provider.LatLngOrigemPoint, provider.LatLngDestinoPoint)
          .then((result) async {
        Viagem viagem = Viagem(
            Status: TravelStatus.Open,
            DestinoEndereco: destinoController.value.text,
            DestinoEnderecoPrincipal: destinoController.value.text,
            DestinoLatitude: provider.LatLngDestinoPoint.latitude,
            DestinoLongitude: provider.LatLngDestinoPoint.longitude,
            OrigemEndereco: origemController.value.text,
            OrigemEnderecoPrincipal: origemController.value.text,
            OrigemLatitude: provider.LatLngOrigemPoint.latitude,
            OrigemLongitude: provider.LatLngOrigemPoint.longitude,
            Distancia: result.Distancia,
            Tempo: result.Tempo,
            ValorTop: result.Valor + (result.Valor * 0.20),
            ValorPop: result.Valor);


        _baseBloc.viagemEvent.add(viagem);
        _homeBloc.tipocarroEvent.add(TipoCarro.Pop);
        _homeBloc.stepProcessoEvent.add(StepPassengerHome.ConfirmPrice);
        await _baseBloc.orchestration();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          bottom: new PreferredSize(
            preferredSize: const Size.fromHeight(125.0),
            child: Container(
              color: Colors.white,
              child: new Padding(
                padding: new EdgeInsets.only(
                  bottom: 10.0,
                  left: 10.0,
                  right: 10.0,
                ),
                child: Column(
                  children: <Widget>[
                    Container(
                      child: new IconButton(
                        icon: Icon(
                          LineIcons.arrow_left,
                          color: Colors.black,
                        ),
                        onPressed: () {
                          _homeBloc.stepProcessoEvent
                              .add(StepPassengerHome.Start);
                          _baseBloc.orchestration();
                        },
                      ),
                      width: double.infinity,
                      alignment: Alignment.topLeft,
                      height: 40,
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          top: 0.0, bottom: 0.0, left: 5.0, right: 0.0),
                      child: TextField(
                        focusNode: origemFocus,
                        controller: origemController,
                        onChanged: (value) {
                          if (value != null && value.isNotEmpty)
                            _autoCompleteBloc.searchEvent
                                .add(Filtro(value, LocalLocation.Source));
                        },
                        style: TextStyle(
                            fontSize: 16.0,
                            color: Colors.black,
                            fontFamily: FontStyleApp.fontFamily()),
                        decoration: InputDecoration(
                          suffixIcon: IconButton(
                              icon: Icon(
                                Icons.close,
                                color: Colors.black,
                              ),
                              onPressed: () {
                                WidgetsBinding.instance.addPostFrameCallback(
                                        (_) => origemController.clear());
                                _autoCompleteBloc.listaLocalEvent
                                    .add(List<Local>());
                              }),
                          border: InputBorder.none,
                          labelText: "Departure Location ?",
                          hintStyle: TextStyle(
                              fontFamily: FontStyleApp.fontFamily(),
                              fontSize: 18.0),
                        ),
                      ),
                    ),
                    SizedBox(height: 5),
                    Padding(
                      padding: EdgeInsets.only(
                          top: 0.0, bottom: 0.0, left: 5.0, right: 0.0),
                      child: TextField(
                        focusNode: destinoFocus,
                        controller: destinoController,
                        onChanged: (value) {
                          if (value != null && value.isNotEmpty)
                            _autoCompleteBloc.searchEvent
                                .add(Filtro(value, LocalLocation.Destiny));
                        },
                        style: TextStyle(
                            fontSize: 16.0,
                            color: Colors.black,
                            fontFamily: FontStyleApp.fontFamily()),
                        decoration: InputDecoration(
                          suffixIcon: IconButton(
                              icon: Icon(
                                Icons.close,
                                color: Colors.black,
                              ),
                              onPressed: () {
                                _autoCompleteBloc.listaLocalEvent
                                    .add(List<Local>());
                                WidgetsBinding.instance.addPostFrameCallback(
                                        (_) => destinoController.clear());
                                return false;
                              }),
                          border: InputBorder.none,
                          labelText: "Where are we going ?",
                          hintStyle: TextStyle(
                              fontFamily: FontStyleApp.fontFamily(),
                              fontSize: 18.0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              StreamBuilder(
                  stream: _authBloc.userInfoFlux,
                  builder: (BuildContext context,
                      AsyncSnapshot<Passageiro> snapshot) {
                    if (!snapshot.hasData)
                      return Container(height: 1, width: 1,);

                    Passageiro passageiro = snapshot.data;

                    if ((passageiro.Casa != null &&
                        passageiro.Casa.Nome != null) ||
                        (passageiro.Trabalho != null &&
                            passageiro.Trabalho.Nome != null)) {
                      return Container(
                        width: MediaQuery
                            .of(context)
                            .size
                            .width,
                        height: MediaQuery
                            .of(context)
                            .size
                            .height * 0.10,
                        child: Row(
                          children: <Widget>[
                            _buildLocal(TipoLocal.House),
                            _buildLocal(TipoLocal.Job),
                          ],
                        ),
                      );
                    } else {
                      return Container(height: 1, width: 1);
                    }
                  }),
              Container(
                height: 255,
                constraints: BoxConstraints(minWidth: 230.0, minHeight: 25.0),
                child: StreamBuilder(
                    stream: _autoCompleteBloc.listaLocalFlux,
                    builder: (BuildContext context,
                        AsyncSnapshot<List<Local>> snapshot) {
                      if (!snapshot.hasData || snapshot.data.length == 0) {
                        return Container(height: 1, width: 1);
                      }

                      return ListView(
                        scrollDirection: Axis.vertical,
                        padding: EdgeInsets.all(8.0),
                        children: snapshot.data
                            .map((data) => GestureDetector(
                                  onTap: () {
                                    LatLng latlng =
                                        LatLng(data.Latitude, data.Logitude);

                                    if (data.referencia ==
                                        LocalLocation.Source) {
                                      origemController.text = data.Nome;
                                      _baseBloc.refreshProvider(latlng,
                                          data.Nome, LocalLocation.Source);
                                    } else {
                                      _baseBloc.refreshProvider(latlng,
                                          data.Nome, LocalLocation.Destiny);
                                      destinoController.text = data.Nome;
                                    }
                                    _autoCompleteBloc.listaLocalEvent
                                        .add(List<Local>());
                                    _validaProximaEtapa();
                                  },
                                  child: ListTile(
                                    leading: Icon(Icons.location_on),
                                    title: Text(
                                      data.Nome,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Text(data.Endereco),
                                  ),
                                ))
                            .toList(),
                      );
                    }),
              )
            ],
          ),
        ));
  }

  _buildLocal(TipoLocal tipoLocal) => StreamBuilder(
      stream: _authBloc.userInfoFlux,
      builder: (BuildContext context, AsyncSnapshot<Passageiro> snapshot) {
        if (!snapshot.hasData)
          return Expanded(
              child: Container(
            height: 1,
            width: 1,
          ));

        Passageiro passageiro = snapshot.data;

        if (TipoLocal.House == tipoLocal &&
            (passageiro.Casa == null || passageiro.Casa.Nome == null))
          return Container(height: 1, width: 1);

        if (TipoLocal.Job == tipoLocal &&
            (passageiro.Trabalho == null || passageiro.Trabalho.Nome == null))
          return Container(height: 1, width: 1);

        return Expanded(
            child: GestureDetector(
          onTap: () {
            if (tipoLocal == TipoLocal.House) {
              LatLng latlng =
                  LatLng(passageiro.Casa.Latitude, passageiro.Casa.Logitude);

              if (origemFocus.hasFocus) {
                _baseBloc.refreshProvider(
                    latlng, passageiro.Casa.Nome, LocalLocation.Source);
                origemController.text = passageiro.Casa.Nome;
              } else {
                _baseBloc.refreshProvider(
                    latlng, passageiro.Casa.Nome, LocalLocation.Destiny);
                destinoController.text = passageiro.Casa.Nome;
              }

              _autoCompleteBloc.listaLocalEvent.add(List<Local>());
              _validaProximaEtapa();
            } else {
              LatLng latlng = LatLng(
                  passageiro.Trabalho.Latitude, passageiro.Trabalho.Logitude);

              if (origemFocus.hasFocus) {
                _baseBloc.refreshProvider(
                    latlng, passageiro.Trabalho.Nome, LocalLocation.Source);
                origemController.text = passageiro.Trabalho.Nome;
              } else {
                _baseBloc.refreshProvider(
                    latlng, passageiro.Trabalho.Nome, LocalLocation.Destiny);
                destinoController.text = passageiro.Trabalho.Nome;
              }
              _autoCompleteBloc.listaLocalEvent.add(List<Local>());
              _validaProximaEtapa();
            }
          },
          child: Container(
            margin: TipoLocal.House == tipoLocal
                ? EdgeInsets.only(left: 5)
                : EdgeInsets.only(right: 5),
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              border: Border.all(width: 0.1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                    margin: EdgeInsets.only(left: 10),
                    child: Icon(
                        Feather.getIconData(
                            tipoLocal == TipoLocal.House ? 'home' : 'briefcase'),
                        color: Colors.black54)),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: TipoLocal.House == tipoLocal
                          ? (passageiro.Casa != null &&
                                  passageiro.Casa.Nome != null
                              ? EdgeInsets.only(top: 5, left: 10)
                              : EdgeInsets.only(top: 15, left: 10))
                          : (passageiro.Trabalho != null &&
                                  passageiro.Trabalho.Nome != null
                              ? EdgeInsets.only(top: 5, left: 10)
                              : EdgeInsets.only(top: 15, left: 10)),
                      child: Text(
                        tipoLocal == TipoLocal.House ? 'Home' : 'Job',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    (TipoLocal.House == tipoLocal &&
                            passageiro.Casa != null &&
                            passageiro.Casa.Nome != null)
                        ? Padding(
                            padding: const EdgeInsets.only(top: 5, left: 10),
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.36,
                              child: Text(
                                passageiro.Casa.Nome,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          )
                        : Container(
                            height: 1,
                            width: 1,
                          ),
                    (TipoLocal.Job == tipoLocal &&
                            passageiro.Trabalho != null &&
                            passageiro.Casa.Nome != null)
                        ? Padding(
                            padding: const EdgeInsets.only(top: 5, left: 10),
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.36,
                              child: Text(
                                passageiro.Trabalho.Nome,
                                maxLines: 1,
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          )
                        : Container(
                            height: 1,
                            width: 1,
                          ),
                  ],
                ),
              ],
            ),
          ),
        ));
      });
}
