import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:Fluttaxi/src/entity/entities.dart';
import 'package:rxdart/rxdart.dart';

class HomePassageiroBloc extends BlocBase {
  final BehaviorSubject<StepPassengerHome> _stepProcessoController =
  new BehaviorSubject<StepPassengerHome>();

  Stream<StepPassengerHome> get stepProcessoFlux =>
      _stepProcessoController.stream;

  Sink<StepPassengerHome> get stepProcessoEvent =>
      _stepProcessoController.sink;

  final BehaviorSubject<String> _timeController = new BehaviorSubject<String>();

  Stream<String> get timeFlux => _timeController.stream;

  Sink<String> get timeEvent => _timeController.sink;

  /*gerenciamento preco/distancia */
  final BehaviorSubject<TipoCarro> _tipoCarroController =
      new BehaviorSubject<TipoCarro>();

  Stream<TipoCarro> get tipocarroFlux => _tipoCarroController.stream;

  Sink<TipoCarro> get tipocarroEvent => _tipoCarroController.sink;

  /*fim viagem*/

  HomePassageiroBloc() {
    _stepProcessoController.add(StepPassengerHome.Start);
  }

  @override
  void dispose() {
    _tipoCarroController?.close();
    _stepProcessoController?.close();
    _timeController?.close();
    super.dispose();
  }
}
