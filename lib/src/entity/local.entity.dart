import 'package:cloud_firestore/cloud_firestore.dart';

import 'entities.dart';

class Local {
  String Nome;
  String Endereco;
  double Latitude;
  double Logitude;
  LocalLocation referencia;

  Local(
      {this.Nome,
      this.Endereco,
      this.Latitude,
      this.Logitude,
      this.referencia});

  static List<Local> fromJson(
      Map<String, dynamic> json, LocalLocation referencia) {
    List<Local> resultList = List();

    var results = json['results'] as List;
    for (var item in results) {
      var itemList = Local(
          Nome: item['name'],
          Endereco: item['formatted_address'],
          Latitude: item['geometry']['location']['lat'],
          Logitude: item['geometry']['location']['lng'],
          referencia: referencia);
      resultList.add(itemList);
    }
    return resultList;
  }

  toJson() {
    return {
      "Nome": this.Nome,
      "Endereco": this.Endereco,
      "Latitude": this.Latitude,
      "Logitude": this.Logitude,
    };
  }

  Local.fromMap(Map<dynamic, dynamic> data)
      : Nome = data["Nome"],
        Endereco = data["Endereco"],
        Latitude = data["Latitude"],
        Logitude = data["Logitude"];
}

class DistanciaTempo {
  String Distancia;
  String Tempo;
  double Valor;

  DistanciaTempo({this.Distancia, this.Tempo, this.Valor});
}
