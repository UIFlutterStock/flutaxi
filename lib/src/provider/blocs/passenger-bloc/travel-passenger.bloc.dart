import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:Fluttaxi/src/entity/entities.dart';
import 'package:rxdart/rxdart.dart';

import '../../provider.dart';

class TravelPassengerBloc extends BlocBase {

  final BehaviorSubject<List<Viagem>> _listViagensController =
  BehaviorSubject<List<Viagem>>.seeded(List<Viagem>());

  Stream<List<Viagem>> get listViagensFlux => _listViagensController.stream;

  Sink<List<Viagem>> get listViagensEvent => _listViagensController.sink;

  ViagemService _viagemService;
  PassageiroService _passageiroService;

  TravelPassengerBloc() {
    _viagemService = new ViagemService();
    _passageiroService = new PassageiroService();
  }


  loadViagem()async {
    Passageiro passageiro = await _passageiroService.getCustomerStorage();
    List<Viagem> listViagem = await _viagemService.getViagensByPassageiro(
        passageiro.Id);
    if (listViagem == null)
      listViagem = List<Viagem>();

    listViagensEvent.add(listViagem);
  }



  @override
  void dispose() {
    _listViagensController?.close();
    super.dispose();
  }
}
