import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Fluttaxi/src/infra/infra.dart';

import 'entities.dart';

class Motorista {
  String Id;
  String Codigo;
  String Nome;
  String Email;
  Imagem Foto;
  Veiculo Automovel;
  DateTime CriadoEm;
  DateTime ModificadoEm;
  bool Status;

  Motorista({this.Id,
    this.Codigo = '',
    this.Nome,
    this.Foto,
    this.Email,
    this.Automovel,
    this.ModificadoEm,
    this.CriadoEm,
    this.Status});

  Motorista.fromSnapshot(DocumentSnapshot snapshot)
      : this.Id = snapshot.documentID,
        this.Codigo = snapshot.data["Codigo"],
        this.Nome = snapshot.data["Nome"] == null ? '': snapshot.data["Nome"],
        this.Email = snapshot.data["Email"] == null ? '': snapshot.data["Email"],
        this.Foto = Imagem.fromSnapshotJson(snapshot),
        this.Automovel = Veiculo.fromJson(snapshot.data["Automovel"]),
        this.ModificadoEm =DateTime.parse(
            snapshot.data['ModificadoEm'].toString()),
        this.CriadoEm =DateTime.parse(snapshot.data['CriadoEm']),
        this.Status = snapshot.data["Status"] as bool;

  Motorista.fromJson(Map<dynamic, dynamic> map)
      : Codigo = map["Codigo"],
        this.Id = map["Id"],
        this.Nome = map["Nome"]== null ? '': map["Nome"],
        this.Email = map["Email"]== null ? '': map["Email"],
        this.Automovel = Veiculo.fromJson(map["Automovel"]),
        this.Foto = Imagem.fromMap(map["Foto"]),
        this.ModificadoEm = DateTime.parse(map['ModificadoEm']),
        this.CriadoEm = DateTime.parse(map['CriadoEm']),
        this.Status = map["Status"] as bool;

  static Map<String, dynamic> stringToMap(String s) {
    Map<String, dynamic> map = json.decode(s);
    return map;
  }


  toJson() {
    return {
      "Id": this.Id,
      "Codigo": this.Codigo == '' ? HelpService.generateCode(12) : this.Codigo,
      "Nome": this.Nome == null ? '': this.Nome  ,
      "Email": this.Email== null ? '': this.Email,
      "Foto": this.Foto == null ? Imagem().toJson() : this.Foto.toJson(),
      "Automovel":
      this.Automovel == null ? Veiculo().toJson() : this.Automovel.toJson(),
      "ModificadoEm":
      this.ModificadoEm == null ? DateTime.now().toString() : this.ModificadoEm
          .toString(),
      "CriadoEm": this.CriadoEm == null ? DateTime.now().toString() : this
          .CriadoEm.toString(),
      "Status": this.Status == null ? true : this.Status,
    };
  }
}
