import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:Fluttaxi/src/entity/entities.dart';
import 'package:Fluttaxi/src/provider/provider.dart';

import '../../../pages.dart';
import '../../pages.dart';

class FinishRunWidget extends StatelessWidget {
  GlobalKey<ScaffoldState> scaffoldKey;

  FinishRunWidget(this.scaffoldKey);

  BaseDriverBloc _authBase = BlocProvider.getBloc<BaseDriverBloc>();
  ViagemService _viagemService = new ViagemService();
  BaseDriverBloc _baseBloc = BlocProvider.getBloc<BaseDriverBloc>();
  HomeDriverBloc _homeBloc = BlocProvider.getBloc<HomeDriverBloc>();

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
                'Finish Race !',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
            ),
            onChanged: (result) {
              if (result == SwipePosition.SwipeRight) {
                _finalizarViagem().then((r) {
                  ShowSnackBar.build(
                      scaffoldKey, 'Race completed successfully', context);
                });
              } else {}
            },
          ),
        ),
      ),
    );
  }

  Future<void> _finalizarViagem() async {
    Viagem viagem = await _authBase.viagemFlux.first;
    viagem.Status = TravelStatus.Finished;
    await _viagemService.save(viagem);
    Future.delayed(const Duration(milliseconds: 1000), () {
      _homeBloc.stepMotoristaEvent.add(StepDriverHome.Start);
      _baseBloc.orchestration();
    });
  }
}
