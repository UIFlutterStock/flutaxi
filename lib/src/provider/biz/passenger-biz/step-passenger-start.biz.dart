import 'dart:async';

import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:geolocator/geolocator.dart';
import 'package:Fluttaxi/src/entity/entities.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../provider.dart';

class StepPassengerStartBiz {
  static StepPassengerStartBiz _instance;

  factory StepPassengerStartBiz() {
    _instance ??= StepPassengerStartBiz._internalConstructor();
    return _instance;
  }

  StepPassengerStartBiz._internalConstructor();

  GoogleService _googleService = GoogleService();
  BasePassageiroBloc _basePassageiroBloc =
      BlocProvider.getBloc<BasePassageiroBloc>();
  StreamSubscription<Position> _streamPositionInicial;

  /*inicio passageiro*/
  Future start() async {
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    /*obtem o nome do endereco com base lat e log*/
    var endereco = await _googleService.getAddresByCoordinates(
        position.latitude.toString(), position.longitude.toString());

    final ProviderMapa providerMapa = ProviderMapa(
        EnderecoOrigem: endereco,
        LatLngOrigemPoint: LatLng(position.latitude, position.longitude));

    await _adicionarLocalAtualPassageiroMapa(providerMapa, 120);
    Future.delayed(const Duration(milliseconds: 500), () {
      startMonitoramentoPassageiroMapa();
    });
  }

  void encerrarFluxosStream() {
    if (_streamPositionInicial != null) _streamPositionInicial?.cancel();
  }

  /*- responsavel por obter qualquer  alteração na localização do passageiro e atualiza o mapa*/
  Future<void> startMonitoramentoPassageiroMapa() async {
    try {
      Geolocator _geolocator = Geolocator();

      if (_streamPositionInicial != null) _streamPositionInicial?.cancel();

      var locationOptions =
          LocationOptions(accuracy: LocationAccuracy.high, distanceFilter: 10);

      ProviderMapa providerMapa =
          await _basePassageiroBloc.providermapFlux.first;
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

            providerMapa.LatLngOrigemPoint =
                LatLng(position.latitude, position.longitude);
            providerMapa.EnderecoOrigem = endereco;
            print('Monitoramento inicial da localização do passageiro.');

            _adicionarLocalAtualPassageiroMapa(providerMapa, 120).then((r) {
              /*aguarda finalizar para setar o carrinho no mapa*/
              semaforo = true;
            });
          });
        }
      });
    } on Exception catch (ex) {
      print(
          'Erro metodo startMonitoramentoPassageiroMapa, classe StepPassagieroInicioBiz -  $ex');
    }
  }

  /*definie  carrinho no mapa*/
  Future _adicionarLocalAtualPassageiroMapa(
      ProviderMapa provider, int iconSize) async {
    try {
      provider.Markers = Set<Marker>();
      /*adiciona carrinho*/
      provider.Markers.add(Marker(
          markerId: MarkerId(provider.EnderecoOrigem.toString()),
          position: provider.LatLngOrigemPoint,
          flat: true,
          infoWindow:
              InfoWindow(title: provider.EnderecoOrigem, snippet: "Está Aqui!"),
          icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueGreen)));

      _basePassageiroBloc.providermapEvent.add(provider);
    } on Exception catch (ex) {
      print(
          'Erro metodo _adicionarCarrinhoMapa, classe StepPassagieroInicioBiz -  $ex');
    }
  }

/*fim metodo*/

}
