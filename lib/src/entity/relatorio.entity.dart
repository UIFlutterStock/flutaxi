import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Fluttaxi/src/infra/infra.dart';

class Relatorio {
  String Id;
  String Codigo;
  String MotoristaId;
  double Gasolina;
  double Comida;
  double ManutencaoCarro;
  DateTime CriadoEm;
  DateTime ModificadoEm;

  Relatorio({
    this.Id,
    this.Codigo = '',
    this.Gasolina,
    this.MotoristaId,
    this.Comida,
    this.ManutencaoCarro,
    this.CriadoEm,
    this.ModificadoEm,
  });

  Relatorio.fromSnapshotJson(DocumentSnapshot snapshot)
      : this.Id = snapshot.documentID,
        this.Codigo = snapshot.data["Codigo"],
        this.Gasolina = snapshot.data["Gasolina"].toDouble(),
        this.MotoristaId = snapshot.data["MotoristaId"],
        this.Comida = snapshot.data["Comida"].toDouble(),
        this.ManutencaoCarro = snapshot.data["ManutencaoCarro"].toDouble(),
        this.ModificadoEm = DateTime.parse(snapshot.data['ModificadoEm']),
        this.CriadoEm = DateTime.parse(snapshot.data['CriadoEm']);

  static Map<String, dynamic> stringToMap(String s) {
    Map<String, dynamic> map = json.decode(s);
    return map;
  }

  toJson() {
    return {
      "Id": this.Id,
      "Codigo": this.Codigo == '' ? HelpService.generateCode(12) : this.Codigo,
      "Gasolina": this.Gasolina,
      "Comida": this.Comida,
      "MotoristaId": this.MotoristaId,
      "ManutencaoCarro": this.ManutencaoCarro,
      "ModificadoEm": this.ModificadoEm == null
          ? DateTime.now().toString()
          : this.ModificadoEm.toString(),
      "CriadoEm": this.CriadoEm == null
          ? DateTime.now().toString()
          : this.CriadoEm.toString(),
    };
  }
}
