import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:Fluttaxi/src/entity/entities.dart';
import 'package:Fluttaxi/src/infra/help/help.dart';
import 'package:Fluttaxi/src/provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../biz.dart';

class StepDriverSearchTravelBiz {
  ViagemService _viagemService = ViagemService();
  HomeDriverBloc _homeMotoristaBloc =
      BlocProvider.getBloc<HomeDriverBloc>();
  AuthDriverBloc _authBloc = BlocProvider.getBloc<AuthDriverBloc>();
  BaseDriverBloc _baseMotoristaBloc =
      BlocProvider.getBloc<BaseDriverBloc>();
  GoogleService _googleService = GoogleService();
  Geolocator _geolocator = Geolocator();
  StreamSubscription<QuerySnapshot> _streamAllAbertaViagem;
  StreamSubscription<QuerySnapshot> _streamSpecificAbertaViagem;
  StreamSubscription<Position> _streamPosition;
  StepDriverStartBiz _stepMotoristaInicioBiz = StepDriverStartBiz();
  bool indicaStatusProcesso = true;
  StreamSubscription<Position> _streamPositionInicial;


  static StepDriverSearchTravelBiz _instance;

  factory StepDriverSearchTravelBiz() {
    _instance ??= StepDriverSearchTravelBiz._internalConstructor();
    return _instance;
  }

  StepDriverSearchTravelBiz._internalConstructor();

  /*start monitoramento firebase*/
  Future<void> Start() async {

    /*ativa o monitoramento da localizacao atual do motorista*/
    await startMonitoramentoLocalAtual();

    /*motorista*/
    Motorista motorista = await _authBloc.userInfoFlux.first;

    /*stream relaciona a viagem especifica*/
    var stream = await _viagemService.startProcuraViagemEmAberta();

    _streamAllAbertaViagem = stream.listen((data) {
      data.documentChanges.forEach((change) async {

        /*cancela busca por corrida pois ja tem uma corrida em  setada */
        _streamAllAbertaViagem?.cancel();

        print(
            'Stream de buscar viagem Abertas está ativas com base em serie de parametro radio ....');
        Viagem viagem = Viagem.fromSnapshotJson(change.document);
        indicaStatusProcesso = true;
        await streamMonitoramentoViagemEspecifica(viagem, motorista);
      });
    });
  }


  Future<void> streamMonitoramentoViagemEspecifica(
      Viagem viagem, Motorista motorista) async {

    /*encerra monitoramento da localizacao atual motorista*/
    encerrarFluxosPosicaoLocalMotorista();

      /*adiciona a viagem no fluxo para ser utilizada posteriormente*/
      _baseMotoristaBloc.viagemEvent.add(viagem);

      /*adiciona localização do motorista com base no usuario*/
      adicionaLocalizacaoInicialPassageiroMotorista(viagem);

      /*obtem fluxo para monitorar viagem especifica*/
      var streamViagemEspecifica =
      await _viagemService.getViagemById(viagem.Id);

      _streamSpecificAbertaViagem = streamViagemEspecifica.listen((data) {
        data.documentChanges.forEach((changeResult) async {
          var viagemEspefica = Viagem.fromSnapshotJson(changeResult.document);
          print('Stream de buscar viagem Especifica está ativo');

          if (viagemEspefica.Status == TravelStatus.DriverPath) {
            /*mata  o stream evitar encalar os processos*/
            //streamSpecificAbertaViagem?.cancel();

            /*inicia  o processo de viagem atualizando a variavel viagem */
            if (motorista.Id == viagemEspefica.MotoristaEntity.Id) {
              if (!indicaStatusProcesso) return;

              /*atualiza firebase  com a localização do motorista e sua respectiva localizacao*/
              await visualizaLocalizacaoPassageiroMotorista(
                  viagemEspefica, TravelStatus.DriverPath);
              /*atualiza a tela*/
              _homeMotoristaBloc.stepMotoristaEvent
                  .add(StepDriverHome.TravelAccept);

              /*atualiza o fluxo da viagem com informacoes novas*/
              _baseMotoristaBloc.viagemEvent.add(viagemEspefica);

              indicaStatusProcesso = false;
            } else {
              /*manda notificacao que a viagem foi aceita por outro motorista e inicia o processo de busca de viagens novamente */
              encerraFluxo();
              _homeMotoristaBloc.stepMotoristaEvent
                  .add(StepDriverHome.LookingTravel);
              Start();
            }
            /*fecha o modal pois a viagem foi iniciada */
          } else if (viagemEspefica.Status == TravelStatus.Canceled) {
            /*mata  o stream evitar encalar os processos*/
            encerraFluxo();
            _homeMotoristaBloc.stepMotoristaEvent
                .add(StepDriverHome.LookingTravel);
            Start();
          }
        });
      });
  }

  /* fix resolver problema de quando  estava procurando a viagem o monitoramento parava*/
  Future<void> startMonitoramentoLocalAtual() async {
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    /*obtem o nome do endereco com base lat e log*/
    var endereco = await _googleService.getAddresByCoordinates(
        position.latitude.toString(), position.longitude.toString());

    final ProviderMapa providerMapa = ProviderMapa(
        EnderecoAtualMotorista: endereco,
        LatLngPosicaoMotoristaPoint:
        LatLng(position.latitude, position.longitude));

    await _adicionarCarrinhoMapa(providerMapa, 120);
    Future.delayed(const Duration(milliseconds: 500), () {
      startMonitoramentoMotoristaMapa();
    });
  }


  void encerrarFluxosStream() {
    if (_streamPosition != null) _streamPosition?.cancel();
    if (_streamAllAbertaViagem != null) _streamAllAbertaViagem?.cancel();
    if (_streamSpecificAbertaViagem != null)
      _streamSpecificAbertaViagem?.cancel();

    encerrarFluxosPosicaoLocalMotorista();
  }

  void encerraFluxo() {
    encerrarFluxosStream();
    _stepMotoristaInicioBiz.encerrarFluxosStream();
    /*chama metodo do processo anterior para que seja adicionado no mapa a localizacao atual e o deslocamento em real time*/
    _stepMotoristaInicioBiz.start();
  }

  /*adiciona ponto inicial posicao motorista piloto*/
  Future<void> adicionaLocalizacaoInicialPassageiroMotorista(
      Viagem viagem) async {
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    /*obtem o nome do endereco com base lat e log*/
    var endereco = await _googleService.getAddresByCoordinates(
        position.latitude.toString(), position.longitude.toString());

    final ProviderMapa providerMapa = ProviderMapa(
        EnderecoAtualMotorista: endereco,
        EnderecoOrigem: viagem.OrigemEndereco,
        LatLngOrigemPoint:
            LatLng(viagem.OrigemLatitude, viagem.OrigemLongitude),
        Zoom: 15,
        LatLngPosicaoMotoristaPoint:
            LatLng(position.latitude, position.longitude));

    await rotaMotoristaAteUsuario(providerMapa);
    /*inicia fluxo pedindo que  mostre o modal de aceita*/
    _homeMotoristaBloc.stepMotoristaEvent
        .add(StepDriverHome.TripFound);
    /*adiciona monitoramento */
    Future.delayed(const Duration(milliseconds: 500), () async {
      await visualizaLocalizacaoPassageiroMotorista(
          viagem, TravelStatus.AwaitingDriver);
    });
  }

  Future<void> visualizaLocalizacaoPassageiroMotorista(
      Viagem viagem, TravelStatus statusViagem) async {
    var locationOptions =
        LocationOptions(accuracy: LocationAccuracy.high, distanceFilter: 10);

    bool semaforo = true;

    if (_streamPosition != null) _streamPosition.cancel();

    _streamPosition = _geolocator
        .getPositionStream(locationOptions)
        .listen((Position position) async {
      if (position != null && semaforo) {
        semaforo = false;
        Future.delayed(const Duration(milliseconds: 1800), () async {
          var endereco = await _googleService.getAddresByCoordinates(
              position.latitude.toString(), position.longitude.toString());

          if (statusViagem == TravelStatus.DriverPath) {
            /*obtem a viagem vigente do fluxo*/
            viagem.MotoristaPosicaoLatitude = position.latitude;
            viagem.MotoristaPosicaoLongitude = position.longitude;
            viagem.EnderecoAtualMotorista = endereco;
            /*salva a atual localizacao do motorista para o passageiro poder ter atualizacao em real time*/
            await _viagemService.save(viagem);
          }

          /*seta com atual posicao do motorista no destino*/
          ProviderMapa providerMapa = ProviderMapa(
              EnderecoOrigem: viagem.OrigemEndereco,
              EnderecoAtualMotorista: endereco,
              LatLngPosicaoMotoristaPoint:
                  LatLng(position.latitude, position.longitude),
              LatLngOrigemPoint:
                  LatLng(viagem.OrigemLatitude, viagem.OrigemLongitude),
              Zoom: 15);

          await rotaMotoristaAteUsuario(providerMapa);

          semaforo = true;
        });
      }
    });
  }

  /*inicia o processo de gerar linha no mapa*/
  Future rotaMotoristaAteUsuario(ProviderMapa provider) async {
    /*criar pontos de origem e destino, se foi iciada gera o ponto em real time*/
    await _addMarkerRealTimeViagemMotoristaToPassageir(provider, 120);

    String route = await _googleService.getRouteCoordinates(
        provider.LatLngPosicaoMotoristaPoint, provider.LatLngOrigemPoint);
    /*obtem lista de rotas origem destino*/
    await createRoute(route, provider);
    _baseMotoristaBloc.providermapEvent.add(provider);
  }

/*fim linha mapa*/

  /*desenha pontos motorista ao encontro do passageiro*/
  Future _addMarkerRealTimeViagemMotoristaToPassageir(
      ProviderMapa provider, int iconSize) async {
    provider.Markers = Set<Marker>();

    final Uint8List markerIcon =
        await getBytesFromAsset('assets/images/car/taximarker.png', iconSize);

    /*pontos do local motorista*/
    provider.Markers.add(Marker(
        markerId: MarkerId(provider.EnderecoAtualMotorista.toString()),
        position: provider.LatLngPosicaoMotoristaPoint,
        infoWindow: InfoWindow(
            title: provider.EnderecoAtualMotorista,
            snippet: "Motorista está Aqui!"),
        icon: BitmapDescriptor.fromBytes(markerIcon)));

    /*ponto do local passageiro*/
    provider.Markers.add(Marker(
        markerId: MarkerId(provider.EnderecoOrigem.toString()),
        position: provider.LatLngOrigemPoint,
        infoWindow: InfoWindow(
            title: provider.EnderecoOrigem, snippet: "Passageiro está Aqui!"),
        icon:
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen)));
  }

  /*auxilia no ajuste do tamanho da imagem*/
  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    try {
      ByteData data = await rootBundle.load(path);
      ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
          targetWidth: width);
      ui.FrameInfo fi = await codec.getNextFrame();
      return (await fi.image.toByteData(format: ui.ImageByteFormat.png))
          .buffer
          .asUint8List();
    } on Exception catch (ex) {
      print(
          'Erro metodo getBytesFromAsset, classe StepMotoristaInicioBiz -  $ex');
    }
  }

/*fim metodo*/

  /*cria linha com rota origem e destino*/
  Future createRoute(String encondedPoly, ProviderMapa provider) async {
    provider.Polylines = Set<Polyline>();
    provider.Polylines.add(Polyline(
        polylineId: PolylineId(provider.EnderecoOrigem.toString()),
        width: 6,
        points:
            HelpService.convertToLatLng(HelpService.decodePoly(encondedPoly)),
        color: Colors.blueAccent));
  }

/*fim criacao linha*/

/*definie  carrinho no mapa*/
  Future _adicionarCarrinhoMapa(ProviderMapa provider, int iconSize) async {
    try {
      provider.Markers = Set<Marker>();

      final Uint8List markerIcon =
      await getBytesFromAsset('assets/images/car/taximarker.png', iconSize);

      //_geolocator.bearingBetween(startLatitude, startLongitude, endLatitude, endLongitude)

      /*adiciona carrinho*/
      provider.Markers.add(Marker(
          markerId: MarkerId(provider.EnderecoAtualMotorista.toString()),
          position: provider.LatLngPosicaoMotoristaPoint,
          flat: true,
          infoWindow: InfoWindow(
              title: provider.EnderecoAtualMotorista, snippet: "Está Aqui!"),
          icon: BitmapDescriptor.fromBytes(markerIcon)));

      _baseMotoristaBloc.providermapEvent.add(provider);
    } on Exception catch (ex) {
      print(
          'Erro metodo _adicionarCarrinhoMapa, classe StepMotoristaInicioBiz -  $ex');
    }
  }

  /*- responsavel por obter qualquer  alteração na localização do motorista e atualiza o mapa*/
  Future<void> startMonitoramentoMotoristaMapa() async {
    try {
      Geolocator _geolocator = Geolocator();

      if (_streamPositionInicial != null) _streamPositionInicial?.cancel();

      var locationOptions =
      LocationOptions(accuracy: LocationAccuracy.high, distanceFilter: 10);

      ProviderMapa providerMapa =
      await _baseMotoristaBloc.providermapFlux.first;
      bool semaforo = true;

      _streamPositionInicial = _geolocator
          .getPositionStream(locationOptions)
          .listen((Position position) {
        if (position != null && semaforo) {
          semaforo = false;
          Future.delayed(const Duration(milliseconds: 100), () async {

            /*obtem o nome do endereco com base lat e log*/
            var endereco = await _googleService.getAddresByCoordinates(
                position.latitude.toString(), position.longitude.toString());

            providerMapa.LatLngPosicaoMotoristaPoint =
                LatLng(position.latitude, position.longitude);
            providerMapa.EnderecoAtualMotorista = endereco;
            print(
                'Monitoramento do local atual do motorista da localização do motorista.');

            _adicionarCarrinhoMapa(providerMapa, 120).then((r) {
              /*aguarda finalizar para setar o carrinho no mapa*/
              semaforo = true;
            });
          });
        }
      });
    } on Exception catch (ex) {
      print(
          'Erro metodo startMonitoramentoMotoristaMapa, classe StepMotoristaInicioBiz -  $ex');
    }
  }

  void encerrarFluxosPosicaoLocalMotorista() {
    if (_streamPositionInicial != null) _streamPositionInicial?.cancel();
  }


}
