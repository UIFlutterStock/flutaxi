import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:Fluttaxi/src/entity/entities.dart';
import 'package:Fluttaxi/src/entity/enums.dart';
import 'package:Fluttaxi/src/provider/blocs/blocs.dart';
import 'package:Fluttaxi/src/provider/provider.dart';

import '../../pages.dart';

class ConfirmRunWidget extends StatelessWidget {

  BaseDriverBloc _authBase = BlocProvider.getBloc<BaseDriverBloc>();
  AuthDriverBloc _authMotoristaBloc = BlocProvider.getBloc<
      AuthDriverBloc>();
  ViagemService _viagemService = new ViagemService();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SwipeButton(
            thumb: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Align(
                    widthFactor: 0.90,
                    child: Icon(
                      Icons.chevron_right,
                      size: 30.0,
                      color: Colors.black,
                    )),
              ],
            ),
            content: Center(
              child: Text(
                'Accept race !',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
            ),
            onChanged: (result) {
              if (result == SwipePosition.SwipeRight) {
                _startViagem().then(((r) =>
                {
                }));
              } else {}
            },
          ),
        ),
      ),
    );
  }

  Future<void> _startViagem() async {
    Viagem viagem = await _authBase.viagemFlux.first;
    Motorista motorista = await _authMotoristaBloc.userInfoFlux.first;
    viagem.Status = TravelStatus.DriverPath;
    viagem.MotoristaEntity = motorista;
    await _viagemService.save(viagem);
  }
}
