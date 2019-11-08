import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:Fluttaxi/src/entity/entities.dart';
import 'package:Fluttaxi/src/infra/help/help.dart';
import 'package:Fluttaxi/src/provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class StepConfirmRunBiz {
  static StepConfirmRunBiz _instance;

  factory StepConfirmRunBiz() {
    _instance ??= StepConfirmRunBiz._internalConstructor();
    return _instance;
  }

  StepConfirmRunBiz._internalConstructor();

  BasePassageiroBloc _basePassageiroBloc =
  BlocProvider.getBloc<BasePassageiroBloc>();
  GoogleService _googleService = GoogleService();

  Future start() async {
    BasePassageiroBloc _baseBloc = BlocProvider.getBloc<BasePassageiroBloc>();
    var provider = await _baseBloc.providermapFlux.first;

    /*criar pontos de origem e destino, se foi iciada gera o ponto em real time*/
    /*if (statusViagem == StatusViagem.Iniciada) {
      await _addMarkerRealTimeViagem(provider, 50);
    } else {*/
    await _addMarkerProcurarMotorista(provider);
    /*}*/

    String route = await _googleService.getRouteCoordinates(
        provider.LatLngOrigemPoint, provider.LatLngDestinoPoint);
    /*obtem lista de rotas origem destino*/
    await createRoute(route, provider);
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

  Future _addMarkerProcurarMotorista(ProviderMapa provider) async {
    provider.Markers = Set<Marker>();

    /*ponto inicial*/
    provider.Markers.add(Marker(
        markerId: MarkerId(provider.EnderecoOrigem.toString()),
        position: provider.LatLngOrigemPoint,
        infoWindow: InfoWindow(
            title: provider.EnderecoOrigem, snippet: "Estamos Aqui!"),
        icon:
        BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen)));

    /*ponto destino*/
    provider.Markers.add(Marker(
        markerId: MarkerId(provider.EnderecoDestino.toString()),
        position: provider.LatLngDestinoPoint,
        infoWindow:
        InfoWindow(title: provider.EnderecoDestino, snippet: "Vamos Aqui!"),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue)));
  }

  /*cria linha com rota origem e destino*/
  Future createRoute(String encondedPoly, ProviderMapa provider) async {
    provider.Polylines = Set<Polyline>();
    provider.Polylines.add(Polyline(
        polylineId: PolylineId(provider.EnderecoOrigem.toString()),
        width: 6,
        points:
            HelpService.convertToLatLng(HelpService.decodePoly(encondedPoly)),
        color: Colors.blueAccent));


    _basePassageiroBloc.providermapEvent.add(provider);
  }

/*fim criacao linha*/
}
