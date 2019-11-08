import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:Fluttaxi/src/entity/entities.dart';
import 'package:Fluttaxi/src/infra/help/help.dart';
import 'package:Fluttaxi/src/provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class StepPassageiroProcurarMotorista {
  static StepPassageiroProcurarMotorista _instance;

  factory StepPassageiroProcurarMotorista() {
    _instance ??= StepPassageiroProcurarMotorista._internalConstructor();
    return _instance;
  }

  StepPassageiroProcurarMotorista._internalConstructor();

  AuthPassengerBloc _authPassageiroBloc =
  BlocProvider.getBloc<AuthPassengerBloc>();
  BasePassageiroBloc _basePassageiroBloc =
  BlocProvider.getBloc<BasePassageiroBloc>();
  ViagemService _viagemService = ViagemService();
  StreamSubscription<QuerySnapshot> _streamAllAbertaViagem;
  HomePassageiroBloc _homeBloc = BlocProvider.getBloc<HomePassageiroBloc>();
  GoogleService _googleService = GoogleService();

  Future start() async {
    Passageiro passageiro = await _authPassageiroBloc.userInfoFlux.first;
    Viagem viagem = await _basePassageiroBloc.viagemFlux.first;

    viagem.PassageiroEntity = passageiro;

    Viagem viagemResult = await _viagemService.getViagemAbertaByUsuario(
        passageiro.Id, TravelStatus.Open);

    /*obtemo id da viagem em aberto*/
    if (viagemResult != null) viagem.Id = viagemResult.Id;

    bool statusProcesso = false;
    bool statusSemaforo = false;
    bool statusProcessoCorridaIniciada = false;

    var stream = await _viagemService.startViagem(viagem);

    _streamAllAbertaViagem = stream.listen((data) {
      data.documentChanges.forEach((change) async {

        if (!statusSemaforo) {
          statusSemaforo = true;

          var resultViagem = Viagem.fromSnapshotJson(change.document);
          _basePassageiroBloc.viagemEvent.add(resultViagem);


          if (resultViagem.Status == TravelStatus.DriverPath) {
            if (!statusProcesso) {
              _basePassageiroBloc.viagemEvent.add(resultViagem);
              _homeBloc.stepProcessoEvent
                  .add(StepPassengerHome.DriverAccepted);
              statusProcesso = true;
            }

            if (resultViagem.EnderecoAtualMotorista != null)
              await rotaMotoristaAteUsuario(resultViagem);

            statusSemaforo = false;
          } else if (resultViagem.Status == TravelStatus.Started) {
            if (resultViagem.EnderecoAtualMotorista != null) {
              await rotaCorridaIniciada(resultViagem);

              if (!statusProcessoCorridaIniciada) {
                _homeBloc.stepProcessoEvent
                    .add(StepPassengerHome.RaceProgress);
                statusProcessoCorridaIniciada = true;
              }
            }
            statusSemaforo = false;
          } else if (resultViagem.Status == TravelStatus.Canceled) {
            _homeBloc.stepProcessoEvent.add(StepPassengerHome.Start);
            _basePassageiroBloc.viagemEvent.add(Viagem());
            encerrarFluxosStream();
            await _basePassageiroBloc.orchestration();
          } else if (resultViagem.Status == TravelStatus.Open) {
            statusSemaforo = false;
          }
          else if (resultViagem.Status == TravelStatus.Finished) {
            _homeBloc.stepProcessoEvent.add(StepPassengerHome.EndRace);
            _basePassageiroBloc.viagemEvent.add(Viagem());
            encerrarFluxosStream();
          }
        }
      });
    });
  }


  Future rotaCorridaIniciada(Viagem viagem) async {
    ProviderMapa providerMapa = ProviderMapa(
        EnderecoDestino: viagem.DestinoEndereco,
        EnderecoAtualMotorista: viagem.EnderecoAtualMotorista,
        LatLngOrigemPoint: LatLng(
            viagem.MotoristaPosicaoLatitude, viagem.MotoristaPosicaoLatitude),
        LatLngPosicaoMotoristaPoint: LatLng(
            viagem.MotoristaPosicaoLatitude,
            viagem.MotoristaPosicaoLongitude),
        LatLngDestinoPoint: LatLng(
            viagem.DestinoLatitude, viagem.DestinoLongitude),
        Zoom: 15);

    /*criar pontos de origem e destino, se foi iciada gera o ponto em real time*/
    await _addMarkerRealTimeCorridaIniciada(providerMapa, 120);

    String route = await _googleService.getRouteCoordinates(
        providerMapa.LatLngPosicaoMotoristaPoint,
        providerMapa.LatLngDestinoPoint);

    /*obtem lista de rotas origem destino*/
    await createRouteCorridaIniciada(route, providerMapa);
    _basePassageiroBloc.providermapEvent.add(providerMapa);
  }

  /*inicia o processo de gerar linha no mapa*/
  Future rotaMotoristaAteUsuario(Viagem viagem) async {
    ProviderMapa providerMapa = ProviderMapa(
        EnderecoOrigem: viagem.OrigemEndereco,
        EnderecoAtualMotorista: viagem.EnderecoAtualMotorista,
        LatLngPosicaoMotoristaPoint: LatLng(
            viagem.MotoristaPosicaoLatitude,
            viagem.MotoristaPosicaoLongitude),
        LatLngOrigemPoint: LatLng(
            viagem.OrigemLatitude, viagem.OrigemLongitude),
        Zoom: 15);

    /*criar pontos de origem e destino, se foi iciada gera o ponto em real time*/
    await _addMarkerRealTimeViagemMotoristaToPassageir(providerMapa, 120);

    String route = await _googleService.getRouteCoordinates(
        providerMapa.LatLngPosicaoMotoristaPoint,
        providerMapa.LatLngOrigemPoint);

    /*obtem lista de rotas origem destino*/
    await createRoute(route, providerMapa);
    _basePassageiroBloc.providermapEvent.add(providerMapa);
  }

  Future createRoute(String encondedPoly, ProviderMapa provider) async {
    provider.Polylines = Set<Polyline>();
    provider.Polylines.add(Polyline(
        polylineId: PolylineId(provider.EnderecoOrigem.toString()),
        width: 6,
        points:
        HelpService.convertToLatLng(HelpService.decodePoly(encondedPoly)),
        color: Colors.blueAccent));
  }

  Future createRouteCorridaIniciada(String encondedPoly,
      ProviderMapa provider) async {
    provider.Polylines = Set<Polyline>();
    provider.Polylines.add(Polyline(
        polylineId: PolylineId(provider.EnderecoAtualMotorista.toString()),
        width: 6,
        points:
        HelpService.convertToLatLng(HelpService.decodePoly(encondedPoly)),
        color: Colors.blueAccent));
  }

  /*desenha pontos motorista ao encontro do passageiro*/
  Future _addMarkerRealTimeViagemMotoristaToPassageir(ProviderMapa provider,
      int iconSize) async {
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
            title: provider.EnderecoOrigem, snippet: "Estamos Aqui!"),
        icon:
        BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen)));
  }

  /*desenha pontos motorista ao encontro do passageiro*/
  Future _addMarkerRealTimeCorridaIniciada(ProviderMapa provider,
      int iconSize) async {
    provider.Markers = Set<Marker>();

    final Uint8List markerIcon =
    await getBytesFromAsset('assets/images/car/taximarker.png', iconSize);

    /*pontos do local motorista*/
    provider.Markers.add(Marker(
        markerId: MarkerId(provider.EnderecoAtualMotorista.toString()),
        position: provider.LatLngPosicaoMotoristaPoint,
        infoWindow: InfoWindow(
            title: provider.EnderecoAtualMotorista,
            snippet: "Estamos Aqui!"),
        icon: BitmapDescriptor.fromBytes(markerIcon)));

    /*ponto do local passageiro*/
    provider.Markers.add(Marker(
        markerId: MarkerId(provider.EnderecoDestino.toString()),
        position: provider.LatLngDestinoPoint,
        infoWindow: InfoWindow(
            title: provider.EnderecoDestino, snippet: "Vamos Aqui!"),
        icon:
        BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen)));
  }


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
    if (_streamAllAbertaViagem != null) _streamAllAbertaViagem?.cancel();
  }
}
