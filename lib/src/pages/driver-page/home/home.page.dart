import 'dart:async';

import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:Fluttaxi/src/entity/entities.dart';
import 'package:Fluttaxi/src/provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../pages.dart';
import 'widget.dart';

class HomePage extends StatefulWidget {
  const HomePage(this.changeDrawer);

  final ValueChanged<BuildContext> changeDrawer;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  HomeDriverBloc _homeBloc;
  BaseDriverBloc _baseBloc;
  GlobalKey<ScaffoldState> _scaffoldKey;
  Completer<GoogleMapController> _controller;


  @override
  void initState() {
    _scaffoldKey = new GlobalKey<ScaffoldState>();
    _controller = Completer();
    _baseBloc = BlocProvider.getBloc<BaseDriverBloc>();
    _homeBloc = BlocProvider.getBloc<HomeDriverBloc>();
    _homeBloc.stepMotoristaEvent.add(StepDriverHome.Start);
    _baseBloc.orchestration();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        body: StreamBuilder(
            stream: _homeBloc.stepMotoristaFlux,
            builder: (BuildContext context,
                AsyncSnapshot<StepDriverHome> snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator(
                  valueColor: new AlwaysStoppedAnimation<Color>(Colors.amber),
                ));
              }

              StepDriverHome step = snapshot.data;
              var widgetsHome = _configHome(step);
              return Stack(
                children: widgetsHome,
              );
            }));
  }

  /*constroi a tela de acordo com a etapa atual do processo*/
  List<Widget> _configHome(StepDriverHome stepHome) {
    var widgetsHome = <Widget>[];
    widgetsHome = <Widget>[_buildGoogleMap()];

    switch (stepHome) {
      case StepDriverHome.Start:
        widgetsHome.add(buttonBar(widget.changeDrawer, context));
        widgetsHome.add(SwitchStatusSearchRunWidget(false, _scaffoldKey));
        return widgetsHome;
        break;
      case StepDriverHome.LookingTravel:
        widgetsHome.add(buttonBar(widget.changeDrawer, context));
        widgetsHome.add(InputSearchRunWidget());
        widgetsHome.add(RadarWidget());
        widgetsHome.add(SwitchStatusSearchRunWidget(true, _scaffoldKey));
        return widgetsHome;
        break;
      case StepDriverHome.TripFound:
        widgetsHome.add(ConfirmRunWidget());
        return widgetsHome;
        break;
      case StepDriverHome.TravelAccept:
        widgetsHome.add(StartRunWidget(_scaffoldKey));
        return widgetsHome;
        break;
      case StepDriverHome.EndRace:
        widgetsHome.add(FinishRunWidget(_scaffoldKey));
        return widgetsHome;
        break;
      default:
        return widgetsHome;
        break;
    }
  }

  Future _resizeZoom(ProviderMapa provider) async {
    var next = await _homeBloc.stepMotoristaFlux.first;

    if (next == StepDriverHome.Start)
      await Future.delayed(const Duration(milliseconds: 1500), () {
        _gotoLocation(provider.LatLngPosicaoMotoristaPoint.latitude,
            provider.LatLngPosicaoMotoristaPoint.longitude, 18, 0, 0);
      });
    else if (next == StepDriverHome.LookingTravel) {
      await Future.delayed(const Duration(milliseconds: 1500), () {
        _gotoLocation(provider.LatLngPosicaoMotoristaPoint.latitude,
            provider.LatLngPosicaoMotoristaPoint.longitude, 14, 0, 0);
      });
    } else if (next == StepDriverHome.TripFound) {
      await Future.delayed(const Duration(milliseconds: 1500), () {
        _gotoLocation(provider.LatLngPosicaoMotoristaPoint.latitude,
            provider.LatLngPosicaoMotoristaPoint.longitude, 17, 0, 0);
      });
    } else if (next == StepDriverHome.TravelAccept) {
      await Future.delayed(const Duration(milliseconds: 1500), () {
        _gotoLocation(provider.LatLngPosicaoMotoristaPoint.latitude,
            provider.LatLngPosicaoMotoristaPoint.longitude, 18, 0, 0);
      });
    } else if (next == StepDriverHome.EndRace) {
      await Future.delayed(const Duration(milliseconds: 1500), () {
        _gotoLocation(provider.LatLngPosicaoMotoristaPoint.latitude,
            provider.LatLngPosicaoMotoristaPoint.longitude, 16, 0, 0);
      });
    }

    return false;
  }

  Widget _buildGoogleMap() {
    return StreamBuilder(
        stream: _baseBloc.providermapFlux,
        builder: (BuildContext context, AsyncSnapshot<ProviderMapa> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator(
              valueColor: new AlwaysStoppedAnimation<Color>(Colors.amber),
            ));
          }

          ProviderMapa provider = snapshot.data;

          /*reposiziona com zoom*/
          _resizeZoom(provider);

          return Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: GoogleMap(
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
              circles: provider.CircleMapa,
              initialCameraPosition: CameraPosition(
                  target: provider.LatLngPosicaoMotoristaPoint, zoom: 16),
              //onMapCreated: appState.onCreated,
              myLocationEnabled: false,
              mapType: MapType.normal,
              compassEnabled: true,
              markers: provider.Markers,
              // onCameraMove: appState.onCameraMove,
              polylines: provider.Polylines,
            ),
          );
        });
  }

  Future<void> _gotoLocation(
      double lat, double long, double zoom, double tilt, double bearing) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: LatLng(lat, long),
      zoom: zoom,
      tilt: tilt,
      bearing: bearing,
    )));
  }
}
