import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:Fluttaxi/src/entity/entities.dart';
import 'package:Fluttaxi/src/provider/blocs/blocs.dart';

import '../../../pages.dart';

class FinishRaceWidget extends StatelessWidget {
  GlobalKey<ScaffoldState> scaffoldKey;

  FinishRaceWidget(this.scaffoldKey);

  HomePassageiroBloc _homeBloc = BlocProvider.getBloc<HomePassageiroBloc>();
  BasePassageiroBloc _baseBloc = BlocProvider.getBloc<BasePassageiroBloc>();

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(milliseconds: 2000), () async {
      ShowSnackBar.build(
          scaffoldKey, 'Trip successful !', context);

      _homeBloc.stepProcessoEvent.add(StepPassengerHome.Start);
      await _baseBloc.orchestration();
    });

    return Container(height: 1, width: 1);
  }
}
