import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:Fluttaxi/src/entity/entities.dart';
import 'package:rxdart/rxdart.dart';

import '../../provider.dart';

class VehicleDriverBloc extends BlocBase {
  final BehaviorSubject<List<Veiculo>> _listMarcaVeiculoController =
      BehaviorSubject<List<Veiculo>>.seeded(List<Veiculo>());

  Stream<List<Veiculo>> get listMarcaVeiculoFlux =>
      _listMarcaVeiculoController.stream;

  Sink<List<Veiculo>> get listMarcaVeiculoEvent =>
      _listMarcaVeiculoController.sink;

  final BehaviorSubject<List<Veiculo>> _listModeloVeiculoController =
  BehaviorSubject<List<Veiculo>>.seeded(List<Veiculo>());

  Stream<List<Veiculo>> get listModeloVeiculoFlux =>
      _listModeloVeiculoController.stream;

  Sink<List<Veiculo>> get listModeloVeiculoEvent =>
      _listModeloVeiculoController.sink;

  final BehaviorSubject<List<String>> _listCorVeiculoController =
  BehaviorSubject<List<String>>.seeded(List<String>());

  Stream<List<String>> get listCorVeiculoFlux =>
      _listCorVeiculoController.stream;

  Sink<List<String>> get listCorVeiculoEvent => _listCorVeiculoController.sink;

  final BehaviorSubject<List<String>> _listAnoVeiculoController =
  BehaviorSubject<List<String>>.seeded(List<String>());

  Stream<List<String>> get listAnoVeiculoFlux =>
      _listAnoVeiculoController.stream;

  Sink<List<String>> get listAnoVeiculoEvent => _listAnoVeiculoController.sink;

  final BehaviorSubject<List<String>> _listCategoriaController =
  BehaviorSubject<List<String>>.seeded(List<String>());

  Stream<List<String>> get listCategoriaFlux => _listCategoriaController.stream;

  Sink<List<String>> get listCategoriaEvent => _listCategoriaController.sink;

  final BehaviorSubject<String> _selecionarCategoriaController =
  new BehaviorSubject<String>.seeded(null);

  Stream<String> get selecionarCategoriaFlux =>
      _selecionarCategoriaController.stream;

  Sink<String> get selecionarCategoriaEvent =>
      _selecionarCategoriaController.sink;

  final BehaviorSubject<String> _selecionarMarcaController =
  new BehaviorSubject<String>.seeded(null);

  Stream<String> get selecionarMarcaFlux => _selecionarMarcaController.stream;

  Sink<String> get selecionarMarcaEvent => _selecionarMarcaController.sink;

  final BehaviorSubject<String> _selecionarModeloController =
  new BehaviorSubject<String>.seeded(null);

  Stream<String> get selecionarModeloFlux => _selecionarModeloController.stream;

  Sink<String> get selecionarModeloEvent => _selecionarModeloController.sink;

  final BehaviorSubject<String> _selecionarCorController =
  new BehaviorSubject<String>.seeded(null);

  Stream<String> get selecionarCorFlux => _selecionarCorController.stream;

  Sink<String> get selecionarCorEvent => _selecionarCorController.sink;

  final BehaviorSubject<String> _selecionarAnoController =
  new BehaviorSubject<String>.seeded(null);

  Stream<String> get selecionarAnoFlux => _selecionarAnoController.stream;

  Sink<String> get selecionarAnoEvent => _selecionarAnoController.sink;

  static List<Veiculo> listaVeiculos;

  VeiculoService _veiculoService;

  VehicleDriverBloc() {
    _veiculoService = new VeiculoService();
  }

  load(bool first) async {
    if (first) {
      AuthDriverBloc _auth = BlocProvider.getBloc<AuthDriverBloc>();
      Motorista motorista = await _auth.userInfoFlux.first;
      selecionarCategoriaEvent
          .add(motorista.Automovel.Tipo == TipoCarro.Top ? 'Top' : 'Pop');
      selecionarMarcaEvent.add(
          motorista.Automovel.Marca == '' ? null : motorista.Automovel.Marca);
      selecionarModeloEvent.add(
          motorista.Automovel.Modelo == '' ? null : motorista.Automovel.Modelo);
      selecionarAnoEvent
          .add(motorista.Automovel.Ano == '' ? null : motorista.Automovel.Ano);
      selecionarCorEvent
          .add(motorista.Automovel.Cor == '' ? null : motorista.Automovel.Cor);
    }

    String tipoSelecionado = (await selecionarCategoriaFlux.first);
    String marcaSelecionada = (await selecionarMarcaFlux.first);
    String modeloSelecionada = (await selecionarModeloFlux.first);
    String anoSelecionada = (await selecionarAnoFlux.first);
    String corSelecionada = (await selecionarCorFlux.first);

    /*monta categoria*/
    buildCategoria(tipoSelecionado);

    /*evitar está toda hora indo no banco */
    if (listaVeiculos == null || listaVeiculos.length == 0)
      listaVeiculos = await _veiculoService.getAll();

    /*monta marcas */
    buildMarca(tipoSelecionado, marcaSelecionada);
    /*fim marca*/

    /*monta ano */
    buildAno(anoSelecionada);
    /*fim ano*/

    /*monta cor */
    buildCor(corSelecionada);
    /*fim ano*/

    /*modelo cor */
    buildModelo(marcaSelecionada, modeloSelecionada);
    /*fim ano*/
  }

  void buildCategoria(String tipoSelecionado) async {
    List<String> listaCategoriaAtual = await listCategoriaFlux.first;
    List<String> _listCategoria = <String>['Pop', 'Top'];

    /*somente monta o drop na primeira vez*/
    if (listaCategoriaAtual.length == 0) listCategoriaEvent.add(_listCategoria);

    selecionarCategoriaEvent.add(tipoSelecionado);
  }

  void buildAno(String anoSelecionada) async {
    List<String> listaAno = await listAnoVeiculoFlux.first;

    if (listaAno.length == 0 || listaAno == null)
      listAnoVeiculoEvent
          .add(List<String>.generate(29, (i) => ((i + 1990) + 1).toString()));

    selecionarAnoEvent.add(anoSelecionada);
  }

  void buildCor(String corSelecionado) async {
    List<String> listaCor = await listCorVeiculoFlux.first;
    List<String> _listCor = <String>[
      'Vermelho',
      'Amarelo',
      'Azul',
      'Branco',
      'Preto',
      'Cinza',
      'Laranja'
    ];

    if (listaCor.length == 0 || listaCor == null)
      listCorVeiculoEvent.add(_listCor);

    selecionarCorEvent.add(corSelecionado);
  }

  void buildMarca(String tipo, String marcaSelecionada) {
    TipoCarro tipoSelecionado =
    tipo == null ? null : (tipo == 'Pop' ? TipoCarro.Pop : TipoCarro.Top);

    List<Veiculo> list = listaVeiculos;

    if (tipoSelecionado != null) {
      var result = list.where((o) => o.Tipo.index == tipoSelecionado.index);

      if (result != null) {
        list = result.toList();
        list = _uniqifyList(list);
      } else {
        list = List<Veiculo>();
      }
    } else {
      list = List<Veiculo>();
    }
    selecionarMarcaEvent.add(marcaSelecionada);
    print(list.length);
    listMarcaVeiculoEvent.add(list);
  }

  void buildModelo(String marca, String modeloSelecionada) {
    List<Veiculo> list = listaVeiculos;

    if (marca != null) {
      var result = list.where((o) => o.Marca == marca);

      if (result != null) {
        list = result.toList();
        list = _uniqifyListModelo(list);
      } else {
        list = List<Veiculo>();
      }
    } else {
      list = List<Veiculo>();
    }

    selecionarModeloEvent.add(modeloSelecionada);
    listModeloVeiculoEvent.add(list);
  }

  List<Veiculo> _uniqifyList(List<Veiculo> list) {
    List<Veiculo> listVeiculo = List<Veiculo>();

    for (int i = 0; i < list.length; i++) {
      var item = listVeiculo.firstWhere((o) => o.Marca == list[i].Marca,
          orElse: () => null);

      if (item == null) listVeiculo.add(list[i]);
    }
    return listVeiculo;
  }

  List<Veiculo> _uniqifyListModelo(List<Veiculo> list) {
    List<Veiculo> listVeiculo = List<Veiculo>();

    for (int i = 0; i < list.length; i++) {
      var item = listVeiculo.firstWhere((o) => o.Modelo == list[i].Modelo,
          orElse: () => null);

      if (item == null) listVeiculo.add(list[i]);
    }
    return listVeiculo;
  }

  @override
  void dispose() {
    _selecionarMarcaController?.close();
    _listMarcaVeiculoController?.close();
    _selecionarAnoController?.close();
    _selecionarCorController?.close();
    _listCategoriaController?.close();
    _listModeloVeiculoController?.close();
    _selecionarCategoriaController?.close();
    _selecionarModeloController?.close();
    _listAnoVeiculoController?.close();
    _listCorVeiculoController?.close();
    super.dispose();
  }
}
