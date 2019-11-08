import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:rxdart/rxdart.dart';

class HomeTabBloc extends BlocBase {
  final BehaviorSubject<bool> _tabStatusController =
      BehaviorSubject<bool>.seeded(true);

  Stream<bool> get tabStatusControllerFlux => _tabStatusController.stream;

  Sink<bool> get tabStatusControllerEvent => _tabStatusController.sink;

  final BehaviorSubject<int> _statusTabPageController =
      BehaviorSubject<int>.seeded(0);

  Stream<int> get tabPageControllerFlux => _statusTabPageController.stream;

  Sink<int> get tabPageControllerEvent => _statusTabPageController.sink;

  @override
  void dispose() {
    _tabStatusController?.close();
    _statusTabPageController?.close();
    super.dispose();
  }
}
