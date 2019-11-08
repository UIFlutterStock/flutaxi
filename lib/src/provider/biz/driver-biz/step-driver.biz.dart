import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:Fluttaxi/src/entity/entities.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../provider.dart';

class StepDriverStartBiz {
  static StepDriverStartBiz _instance;

  factory StepDriverStartBiz() {
    _instance ??= StepDriverStartBiz._internalConstructor();
    return _instance;
  }

  StepDriverStartBiz._internalConstructor();

  GoogleService _googleService = GoogleService();
  BaseDriverBloc _baseMotoristaBloc =
      BlocProvider.getBloc<BaseDriverBloc>();
  StreamSubscription<Position> _streamPositionInicial;

  /*inicio motorista*/
  Future start() async {
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
    if (_streamPositionInicial != null) _streamPositionInicial?.cancel();
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
            print('Monitoramento inicial da localização do motorista.');

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

/*fim metodo*/

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

}
