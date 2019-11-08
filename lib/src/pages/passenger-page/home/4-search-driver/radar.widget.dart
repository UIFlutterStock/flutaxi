import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';

class RadarWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      bottom: -175,
      child: Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            alignment: Alignment.center,
            width: 350,
            height: 350,
            child: FlareActor('assets/images/car/pulsar.flr',
                alignment: Alignment.center,
                fit: BoxFit.contain,
                animation: "calling"),
          )),
    );
  }
}
