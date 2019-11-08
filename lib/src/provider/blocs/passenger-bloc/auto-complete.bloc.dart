import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:Fluttaxi/src/entity/entities.dart';
import 'package:rxdart/rxdart.dart';

import '../../provider.dart';

class AutoCompleteBloc extends BlocBase {
  GoogleService _googleService;

  /*listagem relacionada a auto-complete*/
  final BehaviorSubject<List<Local>> _listaLocalController =
      new BehaviorSubject<List<Local>>();

  Observable<List<Local>> get listaLocalFlux => _listaLocalController.stream;

  Sink<List<Local>> get listaLocalEvent => _listaLocalController.sink;

/*fim listagem*/

/*variaveis controle de busca*/
  final BehaviorSubject<Filtro> _searchController =
      new BehaviorSubject<Filtro>();

  Observable<Filtro> get searchFlux => _searchController.stream;

  Sink<Filtro> get searchEvent => _searchController.sink;

/*fim controlle de busca*/

  AutoCompleteBloc() {
    /*instanciamento sevice*/
    _googleService = new GoogleService();
    /*end service*/
    /*qualquer alteração na variavel de busca chama o metodo para start filtro*/
    searchFlux.listen(searchByKeyWord());
  }

  /*chamado quando a variavel observada muda estado*/
  searchByKeyWord() {
    _searchController
        .distinct() //evita valores repetidos
        .debounceTime(Duration(microseconds: 500)) // aguarda um tempo
        .asyncMap(filterBy) // converte o valor
        .switchMap((value) => Observable.just(value))
        .listen((r) => listaLocalEvent.add(r));
  }

  /*filtro que busca locais com base na palavra*/
  Future<List<Local>> filterBy(Filtro filtro) async {
    var list = (await _googleService.searchPlace(filtro));

    if (filtro.PalavraChave == '') return list;

    return list;
  }
/*end auto-complete*/


  @override
  void dispose() {
    _listaLocalController?.close();
    super.dispose();
  }
}
