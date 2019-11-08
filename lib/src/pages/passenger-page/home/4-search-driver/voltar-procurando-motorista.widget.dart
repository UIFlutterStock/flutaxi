import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:Fluttaxi/src/entity/entities.dart';
import 'package:Fluttaxi/src/provider/blocs/blocs.dart';

class VoltarProcurandoMotoristaWidget extends StatelessWidget {
  BasePassageiroBloc _baseBloc = BlocProvider.getBloc<BasePassageiroBloc>();
  HomePassageiroBloc _homeBloc = BlocProvider.getBloc<HomePassageiroBloc>();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
          padding: const EdgeInsets.only(top: 30),
          child: RawMaterialButton(
            onPressed: () async {
              await _baseBloc.cancelarCorrida();
              _homeBloc.stepProcessoEvent.add(StepPassengerHome.Start);
              _baseBloc.viagemEvent.add(Viagem());
              await _baseBloc.orchestration();
            },
            child: new Icon(
              Icons.arrow_back,
              color: Colors.black,
              size: 25.0,
            ),
            shape: new CircleBorder(),
            elevation: 10.0,
            fillColor: Colors.white,
            padding: const EdgeInsets.all(1.0),
          )),
    );
  }
}
