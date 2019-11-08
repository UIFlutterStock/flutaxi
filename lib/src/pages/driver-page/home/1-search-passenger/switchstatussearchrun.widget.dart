import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:Fluttaxi/src/entity/entities.dart';
import 'package:Fluttaxi/src/provider/provider.dart';

import '../../../pages.dart';

class SwitchStatusSearchRunWidget extends StatefulWidget {
  bool _value;
  GlobalKey<ScaffoldState> scaffoldKey;

  SwitchStatusSearchRunWidget(this._value, this.scaffoldKey);

  @override
  _SwitchStatusSearchRunWidgetState createState() =>
      _SwitchStatusSearchRunWidgetState();
}

class _SwitchStatusSearchRunWidgetState extends State<SwitchStatusSearchRunWidget> {
  bool _value = false;
  BaseDriverBloc _baseBloc;
  HomeDriverBloc _homeBloc;
  AuthDriverBloc _authMotoristaBlocBloc;
  HomeTabBloc _homeTabBloc;
  @override
  void initState() {
    _baseBloc = BlocProvider.getBloc<BaseDriverBloc>();
    _homeBloc = BlocProvider.getBloc<HomeDriverBloc>();
    _homeTabBloc = BlocProvider.getBloc<HomeTabBloc>();
    _authMotoristaBlocBloc = BlocProvider.getBloc<AuthDriverBloc>();
    _value = widget._value;
    super.initState();
  }


  validaInicioCorrida(bool value) async {
    Motorista motorista = await _authMotoristaBlocBloc.userInfoFlux.first;

    if (motorista == null) {
      await _authMotoristaBlocBloc.refreshAuth();
      motorista = await _authMotoristaBlocBloc.userInfoFlux.first;
    }

    if (motorista.Automovel == null || motorista.Automovel.Placa == null ||
        motorista.Automovel.Placa == '') {
      ShowSnackBar.build(
          widget.scaffoldKey,
          'Necessário completar o cadastrado para iniciar uma corrida. Por favor preencha informações relacionada ao veiculo!',
          context);

      Future.delayed(const Duration(milliseconds: 4000), () {
        _homeTabBloc.tabPageControllerEvent.add(1);
      });
      return;
    }

    _onChanged1(value);
  }

  void _onChanged1(bool value) =>
      setState(() {
    if (value) {
      _homeBloc.stepMotoristaEvent.add(StepDriverHome.LookingTravel);

        } else {
      _homeBloc.stepMotoristaEvent.add(StepDriverHome.Start);
        }

    Future.delayed(const Duration(milliseconds: 2000), () {
      _baseBloc.orchestration();
    });
        _value = value;
      });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Align(
        alignment: Alignment.topRight,
        child: new Container(
          margin: EdgeInsets.only(top: 30, right: 25),
          child: Switch(
              activeColor: Colors.blueAccent,
              value: _value,
              onChanged: validaInicioCorrida),
        ),
      ),
    );
  }
}
