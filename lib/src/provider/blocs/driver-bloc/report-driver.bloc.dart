import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:Fluttaxi/src/entity/entities.dart';
import 'package:rxdart/rxdart.dart';

import '../../provider.dart';

class ReportDriverBloc extends BlocBase {
  final BehaviorSubject<List<Relatorio>> _listRelatorioController =
      BehaviorSubject<List<Relatorio>>.seeded(List<Relatorio>());

  Stream<List<Relatorio>> get listRelatorioFlux =>
      _listRelatorioController.stream;

  Sink<List<Relatorio>> get listRelatorioEvent => _listRelatorioController.sink;


  final BehaviorSubject<double> _totalRelatorioController =
  BehaviorSubject<double>();

  Stream<double> get totalRelatorioFlux => _totalRelatorioController.stream;

  Sink<double> get totalRelatorioEvent => _totalRelatorioController.sink;

  final BehaviorSubject<double> _totalRelatorioFiltroController =
  BehaviorSubject<double>();

  Stream<double> get totalRelatorioFiltroFlux =>
      _totalRelatorioFiltroController.stream;

  Sink<double> get totalRelatorioFiltroEvent =>
      _totalRelatorioFiltroController.sink;

  RelatorioService _relatorioService = RelatorioService();

  loadRelatoriosByMotorista() async {
    AuthDriverBloc _auth = BlocProvider.getBloc<AuthDriverBloc>();
    Motorista motorista = await _auth.userInfoFlux.first;
    ViagemService viagemService = ViagemService();

    List<Relatorio> listRelatorios =
    await _relatorioService.getbyMotorista(motorista.Id);

    listRelatorioEvent
        .add(listRelatorios == null ? List<Relatorio>() : listRelatorios);

    List<Viagem> viagens =
    await viagemService.getViagensByMotoristaConcluida(motorista.Id);

    await calcularTotal(listRelatorios, viagens);
  }

  loadRelatoriosByMotoristaWithData(DateTime dataInicial,
      DateTime dataFinal) async {
    AuthDriverBloc _auth = BlocProvider.getBloc<AuthDriverBloc>();
    Motorista motorista = await _auth.userInfoFlux.first;
    ViagemService viagemService = ViagemService();

    List<Relatorio> listRelatorios =
        await _relatorioService.getbyMotorista(motorista.Id);

    listRelatorioEvent
        .add(listRelatorios == null ? List<Relatorio>() : listRelatorios);

    List<Viagem> viagens =
    await viagemService.getViagensByMotoristaConcluida(motorista.Id);

    if (viagens != null)
      viagens = viagens
          .where((v) =>
      v.ModificadoEm.isAfter(dataInicial) &&
          v.ModificadoEm.isBefore(dataFinal))
          .toList();

    if (listRelatorios != null)
      listRelatorios = listRelatorios
          .where((v) =>
      v.ModificadoEm.isAfter(dataInicial) &&
          v.ModificadoEm.isBefore(dataFinal))
          .toList();
    /*nao deu certo filtrar na mao*/
    /* List<Viagem> viagens =
    await viagemService.getViagensByMotoristaConcluidaWithDataInicialFinal(motorista.Id,dataInicial,dataFinal);*/

    await calcularTotalFiltro(listRelatorios, viagens);
  }

  calcularTotal(List<Relatorio> relatorios, List<Viagem> viagens) async {
    double totalViagens = 0;
    double totalGastos = 0;

    if (viagens != null)
      viagens.forEach((Viagem e) {
        totalViagens +=
        (e.TipoCorrida == TipoCarro.Top ? e.ValorTop : e.ValorPop);
      });
    if (relatorios != null)
      relatorios.forEach((Relatorio e) {
        totalGastos += (e.Comida + e.Gasolina + e.ManutencaoCarro);
      });

    totalRelatorioEvent.add(totalViagens - totalGastos);
  }

  calcularTotalFiltro(List<Relatorio> relatorios, List<Viagem> viagens) async {
    double totalViagens = 0;
    double totalGastos = 0;

    if (viagens != null)
      viagens.forEach((Viagem e) {
        totalViagens +=
        (e.TipoCorrida == TipoCarro.Top ? e.ValorTop : e.ValorPop);
      });
    if (relatorios != null)
      relatorios.forEach((Relatorio e) {
        totalGastos += (e.Comida + e.Gasolina + e.ManutencaoCarro);
      });

    totalRelatorioFiltroEvent.add(totalViagens - totalGastos);
  }
  @override
  void dispose() {
    _listRelatorioController?.close();
    _totalRelatorioController?.close();
    _totalRelatorioFiltroController?.close();
    super.dispose();
  }
}
