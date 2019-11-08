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
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../provider.dart';

class StepDriverViagemIniciada {
  BaseDriverBloc _baseMotoristaBloc =
      BlocProvider.getBloc<BaseDriverBloc>();
  ViagemService _viagemService = ViagemService();
  StreamSubscription<QuerySnapshot> _streamSpecificaViagem;
  StreamSubscription<Position> _streamPosition;
  Geolocator _geolocator = Geolocator();
  GoogleService _googleService = GoogleService();
  HomeDriverBloc _homeBloc = BlocProvider.getBloc<HomeDriverBloc>();

  static StepDriverViagemIniciada _instance;

  factory StepDriverViagemIniciada() {
    _instance ??= StepDriverViagemIniciada._internalConstructor();
    return _instance;
  }

  StepDriverViagemIniciada._internalConstructor();

  /*start monitoramento firebase*/
  Future<void> Start() async {
    Viagem viagem = await _baseMotoristaBloc.viagemFlux.first;

    await monitoramentoOrigemDestino(viagem);
    /*obtem fluxo para monitorar viagem especifica*/
    var streamViagemEspecifica = await _viagemService.getViagemById(viagem.Id);

    /*chama o metodo para montar o layout possibilitando que o usuario finalize a viagem*/
    _homeBloc.stepMotoristaEvent.add(StepDriverHome.EndRace);

    _streamSpecificaViagem = streamViagemEspecifica.listen((data) {
      data.documentChanges.forEach((changeResult) async {
        var viagemEspefica = Viagem.fromSnapshotJson(changeResult.document);
        print('Stream de viagem iniciada Especifica está ativo');

        if (viagemEspefica.Status == TravelStatus.Finished) {
          /*encerra fluxo */
          encerrarFluxosStream();
        }
      });
    });
  }

  /*monitoramento da origem ate destino*/
  Future<void> monitoramentoOrigemDestino(Viagem viagem) async {
    var locationOptions =
        LocationOptions(accuracy: LocationAccuracy.high, distanceFilter: 10);

    bool semaforo = true;

    if (_streamPosition != null) _streamPosition.cancel();

    _streamPosition = _geolocator
        .getPositionStream(locationOptions)
        .listen((Position position) async {
      if (position != null && semaforo) {
        semaforo = false;
        /*a casa dois segundos salva a localizacao ataul*/
        Future.delayed(const Duration(milliseconds: 2000), () async {
          var endereco = await _googleService.getAddresByCoordinates(
              position.latitude.toString(), position.longitude.toString());

          /*obtem a viagem vigente do fluxo*/
          viagem.MotoristaPosicaoLatitude = position.latitude;
          viagem.MotoristaPosicaoLongitude = position.longitude;
          viagem.OrigemLongitude = position.longitude;
          viagem.OrigemLatitude = position.latitude;
          viagem.OrigemEndereco = endereco;
          viagem.OrigemEnderecoPrincipal = endereco;
          viagem.EnderecoAtualMotorista = endereco;

          /*salva a atual localizacao do motorista para o passageiro poder ter atualizacao em real time*/
          await _viagemService.save(viagem);

          /*seta com atual posicao do motorista no destino*/
          ProviderMapa providerMapa = ProviderMapa(
              EnderecoOrigem: endereco,
              EnderecoAtualMotorista: endereco,
              EnderecoDestino: viagem.DestinoEndereco,
              LatLngDestinoPoint: LatLng(
                  viagem.DestinoLatitude, viagem.DestinoLongitude),
              LatLngPosicaoMotoristaPoint:
                  LatLng(position.latitude, position.longitude),
              LatLngOrigemPoint: LatLng(position.latitude, position.longitude),
              Zoom: 15);

          await rotaOrigemDestiono(providerMapa);

          semaforo = true;
        });
      }
    });
  }

  /*inicia o processo de gerar linha no mapa*/
  Future rotaOrigemDestiono(ProviderMapa provider) async {
    /*criar pontos de origem e destino, se foi iciada gera o ponto em real time*/
    await _addMarkerRealTimeOrigemDestino(provider, 100);

    String route = await _googleService.getRouteCoordinates(
        provider.LatLngOrigemPoint, provider.LatLngDestinoPoint);
    /*obtem lista de rotas origem destino*/
    await createRoute(route, provider);
    _baseMotoristaBloc.providermapEvent.add(provider);
  }

  /*cria linha com rota origem e destino*/
  Future createRoute(String encondedPoly, ProviderMapa provider) async {
    provider.Polylines = Set<Polyline>();
    provider.Polylines.add(Polyline(
        polylineId: PolylineId(provider.EnderecoOrigem.toString()),
        width: 6,
        points:
            HelpService.convertToLatLng(HelpService.decodePoly(encondedPoly)),
        color: Colors.black));
  }

  /*desenha pontos motorista ao encontro do passageiro*/
  Future _addMarkerRealTimeOrigemDestino(
      ProviderMapa provider, int iconSize) async {
    provider.Markers = Set<Marker>();

    final Uint8List markerIcon =
    await getBytesFromAsset('assets/images/car/taximarker.png', iconSize);

    /*rotacao no carro no mapa*/
    var rotacao = await _geolocator.bearingBetween(
        provider.LatLngOrigemPoint.latitude,
        provider.LatLngOrigemPoint.longitude,
        provider.LatLngDestinoPoint.latitude,
        provider.LatLngDestinoPoint.longitude);

    /*pontos do local motorista*/
    provider.Markers.add(Marker(
        markerId: MarkerId(provider.EnderecoOrigem.toString()),
        position: provider.LatLngOrigemPoint,
        // rotation: rotacao ,
        flat: true,
        infoWindow: InfoWindow(
            title: provider.EnderecoOrigem, snippet: "Estamos Aqui!"),
        icon: BitmapDescriptor.fromBytes(markerIcon)));

    /*ponto do local passageiro*/
    provider.Markers.add(Marker(
        markerId: MarkerId(provider.EnderecoDestino.toString()),
        position: provider.LatLngDestinoPoint,
        infoWindow: InfoWindow(
            title: provider.EnderecoDestino, snippet: "Destino é aqui!"),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue)));
  }

  /*auxilia no ajuste do tamanho da imagem*/
  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))
        .buffer
        .asUint8List();
  }

  void encerrarFluxosStream() {
    if (_streamSpecificaViagem != null) _streamSpecificaViagem?.cancel();

    if (_streamPosition != null) _streamPosition?.cancel();
  }
}
