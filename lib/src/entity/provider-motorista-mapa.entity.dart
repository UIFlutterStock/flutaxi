import 'package:google_maps_flutter/google_maps_flutter.dart';

class ProviderPassageiroMapa {
  String EnderecoOrigem;
  String EnderecoDestino;
  String EnderecoAtualMotorista;
  double Zoom;
  LatLng LatLngOrigemPoint;
  LatLng LatLngDestinoPoint;
  LatLng LatLngPosicaoMotoristaPoint;
  Set<Marker> Markers;
  Set<Circle> CircleMapa;
  Set<Polyline> Polylines;

  ProviderPassageiroMapa(
      {this.EnderecoOrigem,
      this.EnderecoDestino,
      this.Zoom = 15.0,
      this.LatLngOrigemPoint,
      this.LatLngDestinoPoint,
      this.EnderecoAtualMotorista,
      this.LatLngPosicaoMotoristaPoint,
      this.Markers,
      this.CircleMapa,
      this.Polylines});
}
