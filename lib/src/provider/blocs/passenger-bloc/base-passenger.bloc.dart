import 'dart:async';

import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:Fluttaxi/src/entity/entities.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rxdart/rxdart.dart';

import '../../provider.dart';
import 'blocs.dart';

class BasePassageiroBloc extends BlocBase {

  /*variaveis observable*/

  /*gerenciamento da viagem*/
  final BehaviorSubject<Viagem> _viagemController =
      new BehaviorSubject<Viagem>();

  Stream<Viagem> get viagemFlux => _viagemController.stream;

  Sink<Viagem> get viagemEvent => _viagemController.sink;

/*fim viagem*/

/*variavel relacionado ao mapaprovider*/
  final BehaviorSubject<ProviderMapa> _providerMapController =
      new BehaviorSubject<ProviderMapa>();

  Observable<ProviderMapa> get providermapFlux => _providerMapController.stream;

  Sink<ProviderMapa> get providermapEvent => _providerMapController.sink;

/*fim provider mapa*/

  BasePassageiroBloc() {}

  /*classe central , responsavel por concentrar inteligencia das ações tomadas*/
  Future<void> orchestration() async {
    HomePassageiroBloc _homePassageiroBloc =
    BlocProvider.getBloc<HomePassageiroBloc>();
    StepPassengerHome _stepHome =
    await _homePassageiroBloc.stepProcessoFlux.first;
    StepPassengerStartBiz _stepPassageiroInicioBiz =
    StepPassengerStartBiz();
    StepConfirmRunBiz _stepConfirmaCorridaBiz = StepConfirmRunBiz();
    StepPassageiroProcurarMotorista _stepPassageiroProcurarMotorista =
    StepPassageiroProcurarMotorista();

    /*garante que não irá existir fluxo ativo enquando for inicial processo*/
    encerrarFluxosStream();


    switch (_stepHome) {
      case StepPassengerHome.Start:
        _stepPassageiroInicioBiz.start();
        break;
      case StepPassengerHome.ConfirmPrice:
        _stepConfirmaCorridaBiz.start();
        break;
      case StepPassengerHome.SearchDriver:
        _stepPassageiroProcurarMotorista.start();
        break;
      default:
        throw new Exception('Chamada de ação que não deveria existir.');
        break;
    }
  }

  void encerrarFluxosStream() {
    StepPassengerStartBiz _stepPassageiroInicioBiz =
    StepPassengerStartBiz();
    StepPassageiroProcurarMotorista _stepPassageiroProcurarMotorista =
    StepPassageiroProcurarMotorista();

    /*garante que não irá existir fluxo ativo enquando for inicial processo*/
    _stepPassageiroInicioBiz.encerrarFluxosStream();
    _stepPassageiroProcurarMotorista.encerrarFluxosStream();
    //stepMotoristaProcurarViagem.encerrarFluxosStream();
    //stepMotoristaViagemIniciada.encerrarFluxosStream();
  }

  /*cancelamento corrida segundo nivel*/
  Future cancelarCorrida() async {
    ViagemService _viagemService = ViagemService();
    Viagem viagem = await viagemFlux.first;
    viagem.Status = TravelStatus.Canceled;
    /*mata o stream do firebase se tiver aberta e outros*/
    encerrarFluxosStream();
    await _viagemService.save(viagem);
  }

  /*fim cancelamento corrida*/

  /*adiciona ponto ao provider map  */
  refreshProvider(LatLng localizacao, String Endereco,
      LocalLocation referenciaLocal) async {
    ProviderMapa provider = await providermapFlux.first;
    provider.Markers = Set<Marker>();
    if (referenciaLocal != LocalLocation.Destiny) {
      provider.LatLngOrigemPoint = localizacao;
      provider.EnderecoOrigem = Endereco;
    } else {
      provider.EnderecoDestino = Endereco;
      provider.LatLngDestinoPoint = localizacao;
    }
    providermapEvent.add(provider);
  }

  /* end provider  */

  @override
  void dispose() {
    _viagemController?.close();
    _providerMapController?.close();
    super.dispose();
  }
}
