import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:rxdart/rxdart.dart';

class LoadingBloc extends BlocBase {
  final BehaviorSubject<bool> _loadingStatusController =
      new BehaviorSubject<bool>();

  Observable<bool> get loadingStatusFlux => _loadingStatusController.stream;

  Sink<bool> get loadingStatusEvent => _loadingStatusController.sink;

  @override
  void dispose() {
    _loadingStatusController?.close();
    super.dispose();
  }
}
