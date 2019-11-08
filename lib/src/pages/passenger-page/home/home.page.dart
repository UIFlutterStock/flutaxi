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
  HomePassageiroBloc _homeBloc;
  BasePassageiroBloc _baseBloc;
  GlobalKey<ScaffoldState> _scaffoldKey;
  Completer<GoogleMapController> _controller;

  @override
  void initState() {
    _baseBloc = BlocProvider.getBloc<BasePassageiroBloc>();
    _homeBloc = BlocProvider.getBloc<HomePassageiroBloc>();
    _homeBloc.stepProcessoEvent.add(StepPassengerHome.Start);
    _scaffoldKey = GlobalKey<ScaffoldState>();
    _baseBloc.orchestration();
    _controller = Completer();
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
            stream: _homeBloc.stepProcessoFlux,
            builder: (BuildContext context,
                AsyncSnapshot<StepPassengerHome> snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator(
                  valueColor: new AlwaysStoppedAnimation<Color>(Colors.amber),
                ));
              }

              StepPassengerHome step = snapshot.data;
              var widgetsHome = _configHome(step);
              return Stack(
                children: widgetsHome,
              );
            }));
  }

  /*constroi a tela de acordo com a etapa atual do processo*/
  List<Widget> _configHome(StepPassengerHome stepHome) {
    var widgetsHome = <Widget>[];
    widgetsHome = <Widget>[_buildGoogleMap()];

    switch (stepHome) {
      case StepPassengerHome.Start:
        widgetsHome.add(buttonBar(widget.changeDrawer, context));
        widgetsHome.add(SearchInputWidget(_scaffoldKey));
        return widgetsHome;
        break;
      case StepPassengerHome.SelectSourceDestination:
        widgetsHome.add(SelectSourceDestinyWidget());
        return widgetsHome;
        break;
      case StepPassengerHome.ConfirmPrice:
        widgetsHome.add(BackConfirmRunWidget());
        widgetsHome.add(ConfirmRaceWidget());
        return widgetsHome;
        break;
      case StepPassengerHome.SearchDriver:
        widgetsHome.add(VoltarProcurandoMotoristaWidget());
        widgetsHome.add(ProcurandoMotoristaWidget());
        widgetsHome.add(RadarWidget());
        return widgetsHome;
        break;
      case StepPassengerHome.DriverAccepted:
        widgetsHome.add(DriverFoundWidget(_scaffoldKey));
        return widgetsHome;
        break;
      case StepPassengerHome.RaceProgress:
        widgetsHome.add(StartRaceWidget());
        return widgetsHome;
        break;
      case StepPassengerHome.EndRace:
        widgetsHome.add(FinishRaceWidget(_scaffoldKey));
        return widgetsHome;
        break;
      default:
        return widgetsHome;
        break;
    }
  }

  Future _resizeZoom(ProviderMapa provider) async {
    var next = await _homeBloc.stepProcessoFlux.first;

    if (next == StepPassengerHome.ConfirmPrice)
      await Future.delayed(const Duration(milliseconds: 1500), () {
        _gotoLocation(provider.LatLngOrigemPoint.latitude,
            provider.LatLngOrigemPoint.longitude, 14, 0, 0);
      });
    else if (next == StepPassengerHome.Start)
      await Future.delayed(const Duration(milliseconds: 1500), () {
        _gotoLocation(provider.LatLngOrigemPoint.latitude,
            provider.LatLngOrigemPoint.longitude, 12, 0, 0);
      });
    else if (next == StepPassengerHome.DriverAccepted &&
        provider.LatLngPosicaoMotoristaPoint != null
        && provider.LatLngPosicaoMotoristaPoint.latitude != null)
      await Future.delayed(const Duration(milliseconds: 1500), () {
        _gotoLocation(provider.LatLngPosicaoMotoristaPoint.latitude,
            provider.LatLngPosicaoMotoristaPoint.longitude, 17, 0, 0);
      });
    else if (next == StepPassengerHome.RaceProgress &&
        provider.LatLngPosicaoMotoristaPoint != null)
      await Future.delayed(const Duration(milliseconds: 1500), () {
        _gotoLocation(provider.LatLngPosicaoMotoristaPoint.latitude,
            provider.LatLngPosicaoMotoristaPoint.longitude, 15, 0, 0);
      });
    else if (next == StepPassengerHome.SearchDriver)
      await Future.delayed(const Duration(milliseconds: 1500), () {
        _gotoLocation(provider.LatLngOrigemPoint.latitude,
            provider.LatLngOrigemPoint.longitude, 17, 0, 0);
      });
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
              initialCameraPosition:
                  CameraPosition(target: provider.LatLngOrigemPoint, zoom: 19),
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
