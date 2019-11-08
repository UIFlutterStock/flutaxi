import 'dart:convert';

import 'package:Fluttaxi/src/entity/entities.dart';
import 'package:Fluttaxi/src/infra/admin/admin.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;


class GoogleService {


  Future<String> getRouteCoordinates(LatLng l1, LatLng l2) async {
    String url = "https://maps.googleapis.com/maps/api/directions/json?origin=${l1
        .latitude},${l1.longitude}&destination=${l2.latitude},${l2
        .longitude}&key=${keyGoogle}";
    http.Response response = await http.get(url);
    Map values = jsonDecode(response.body);
    return values["routes"][0]["overview_polyline"]["points"];
  }


  Future<String> getAddresByCoordinates(String latitude,
      String longitude) async {
    String url = "https://maps.googleapis.com/maps/api/geocode/json?latlng=${latitude},${longitude}&key=${keyGoogle}";
    http.Response response = await http.get(url);
    Map values = jsonDecode(response.body);

    return values["results"][0]["formatted_address"];
  }


  Future<List<Local>> searchPlace(Filtro filtro) async {
    String url =
        "https://maps.googleapis.com/maps/api/place/textsearch/json?key=${keyGoogle}&language=pt&query=" +
            Uri.encodeQueryComponent(filtro.PalavraChave);

    var res = await http.get(url);
    if (res.statusCode == 200) {
      return Local.fromJson(json.decode(res.body), filtro.Referencia);
    } else {
      return List();
    }
  }

  Future<DistanciaTempo> getdistancia(LatLng l1, LatLng l2) async {
    String url = "https://maps.googleapis.com/maps/api/distancematrix/json?origins=${l1
        .latitude},${l1.longitude}&destinations=${l2.latitude},${l2
        .longitude}&mode=driving&key=${keyGoogle}";

    http.Response response = await http.get(url);
    Map values = jsonDecode(response.body);
    String distancia = values["rows"][0]["elements"][0]["distance"]["text"];
    String distanciaKm = (values["rows"][0]["elements"][0]["distance"]["value"])
        .toString();
    String tempo = values["rows"][0]["elements"][0]["duration"]["text"];
    double valor = (((double.parse(distanciaKm)) * valorKm) / 1000)
        .roundToDouble();
    return DistanciaTempo(Distancia: distancia, Tempo: tempo, Valor: valor);
  }
}
