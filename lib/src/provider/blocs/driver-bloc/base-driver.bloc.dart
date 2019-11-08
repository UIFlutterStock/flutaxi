import 'dart:async';

import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Fluttaxi/src/entity/entities.dart';
import 'package:Fluttaxi/src/entity/enums.dart';
import 'package:rxdart/rxdart.dart';

import '../../provider.dart';

class BaseDriverBloc extends BlocBase {
  /*servicos utilizadas */
  static StreamSubscription<QuerySnapshot> _streamFirebaseAllViagemAberta;
  static StreamSubscription<QuerySnapshot> _streamSpecificAbertaViagem;
  bool indicaMonitoramentoPassageiroMotorista;

  /*fim*/

/*variavel relacionado ao mapaprovider*/
  final BehaviorSubject<ProviderMapa> _providerMapController =
      new BehaviorSubject<ProviderMapa>();

  Observable<ProviderMapa> get providermapFlux => _providerMapController.stream;

  Sink<ProviderMapa> get providermapEvent => _providerMapController.sink;

  /*fim provider mapa*/

  /*gerenciamento da viagem*/
  final BehaviorSubject<Viagem> _viagemController =
  new BehaviorSubject<Viagem>();

  Stream<Viagem> get viagemFlux => _viagemController.stream;

  Sink<Viagem> get viagemEvent => _viagemController.sink;

/*fim viagem*/

  BaseDriverBloc() {}

  /*classe central , responsavel por concentrar inteligencia das ações tomadas*/
  Future<void> orchestration() async {
    HomeDriverBloc _homeMotorista =
    BlocProvider.getBloc<HomeDriverBloc>();
    StepDriverHome _stepHome = await _homeMotorista.stepMotoristaFlux.first;
    StepDriverStartBiz stepMotoristaInicioBiz = StepDriverStartBiz();
    StepDriverSearchTravelBiz stepMotoristaProcurarViagem =
    StepDriverSearchTravelBiz();
    StepDriverViagemIniciada stepMotoristaViagemIniciada =
    StepDriverViagemIniciada();

    /*garante que não irá existir fluxo ativo enquando for inicial processo*/
    encerrarFluxosStream();

    switch (_stepHome) {
      case StepDriverHome.Start:
        stepMotoristaInicioBiz.start();
        break;
      case StepDriverHome.LookingTravel:
        stepMotoristaProcurarViagem.Start();
        break;
      case StepDriverHome.StartTrip:
        stepMotoristaViagemIniciada.Start();
        break;
      default:
        throw new Exception('Chamada de ação que não deveria existir.');
        break;
    }
  }

  /*end*/

  void encerrarFluxosStream() {
    StepDriverStartBiz stepMotoristaInicioBiz = StepDriverStartBiz();
    StepDriverSearchTravelBiz stepMotoristaProcurarViagem =
    StepDriverSearchTravelBiz();
    StepDriverViagemIniciada stepMotoristaViagemIniciada =
    StepDriverViagemIniciada();

    /*garante que não irá existir fluxo ativo enquando for inicial processo*/
    stepMotoristaInicioBiz.encerrarFluxosStream();
    stepMotoristaProcurarViagem.encerrarFluxosStream();
    stepMotoristaViagemIniciada.encerrarFluxosStream();
  }

  @override
  void dispose() {
    encerrarFluxosStream();
    _providerMapController?.close();
    _streamSpecificAbertaViagem?.cancel();
    _streamFirebaseAllViagemAberta?.cancel();
    _viagemController?.close();
    super.dispose();
  }
}
