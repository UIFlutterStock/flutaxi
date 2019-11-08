import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Fluttaxi/src/infra/infra.dart';

class Imagem {
  Imagem({this.Url = '', this.Codigo = '', this.IndicaOnLine = true});

  String Url;
  String Codigo;
  bool IndicaOnLine;

  /*se for true vai buscar da internet*/

  Imagem.fromSnapshotJson(DocumentSnapshot snapshot)
      : Url = snapshot.data["Foto"]["Url"],
        IndicaOnLine = snapshot.data["Foto"]["IndicaOnLine"],
        Codigo = snapshot.data["Foto"]["Codigo"];

  Imagem.fromMap(Map<dynamic, dynamic> data)
      : Url = data["Url"],
        IndicaOnLine = data["IndicaOnLine"],
        Codigo = data["Codigo"];

  toJson() {
    return {
      "Url": this.Url,
      "IndicaOnLine": this.IndicaOnLine,
      "Codigo": this.Codigo == '' ? HelpService.generateCode(12) : this.Codigo,
    };
  }
}
