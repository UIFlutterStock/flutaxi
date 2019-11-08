import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Fluttaxi/src/infra/infra.dart';

import 'entities.dart';


class Veiculo {
  String Id;
  String Codigo;
  String Marca;
  String Modelo;
  String Ano;
  String Placa;
  String Cor;
  Imagem Foto;
  DateTime CriadoEm;
  DateTime ModificadoEm;
  bool Status;
  TipoCarro Tipo;


  Veiculo({this.Id,
    this.Codigo = '',
    this.Marca,
    this.Modelo,
    this.Ano,
    this.Placa,
    this.Cor,
    this.Foto,
    this.Tipo,
    this.ModificadoEm,
    this.CriadoEm,
    this.Status});

  Veiculo.fromSnapshotJson(DocumentSnapshot snapshot)
      : this.Id = snapshot.documentID,
        this.Codigo = snapshot.data["Codigo"],
        this.Marca = snapshot.data["Marca"],
        this.Modelo = snapshot.data["Modelo"],
        this.Ano = snapshot.data["Ano"],
        this.Cor = snapshot.data["Cor"],
        this.Placa = snapshot.data["Placa"],
        this.Tipo = snapshot.data['Tipo'] == null
            ? snapshot.data['Tipo']
            : TipoCarro.values[snapshot.data['Tipo']],
        this.Foto = Imagem.fromSnapshotJson(snapshot),
        this.ModificadoEm =DateTime.parse(
            snapshot.data['ModificadoEm'].toString()),
        this.CriadoEm =DateTime.parse(snapshot.data['CriadoEm']),
        this.Status = snapshot.data["Status"] as bool;

  Veiculo.fromJson(Map<dynamic, dynamic> map)
      : Codigo = map["Codigo"],
        this.Id = map["Id"],
        this.Marca =map["Marca"],
        this.Modelo = map["Modelo"],
        this.Placa = map["Placa"],
        this.Ano =map["Ano"],
        this.Cor =map["Cor"],
        this.Tipo = TipoCarro.values[map['Tipo']],
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
      "Marca": this.Marca,
      "Modelo": this.Modelo,
      "Ano": this.Ano == null ? '' : this.Ano,
      "Cor": this.Cor == null ? '' : this.Cor,
      "Placa": this.Placa,
      "Foto":this.Foto == null ? Imagem().toJson()  : this.Foto.toJson(),
      "ModificadoEm":
      this.ModificadoEm == null ? DateTime.now().toString() : this.ModificadoEm
          .toString(),
      "CriadoEm": this.CriadoEm == null ? DateTime.now().toString() : this
          .CriadoEm.toString(),
      "Status": this.Status == null ? true : this.Status,
      "Tipo": this.Tipo == null ? 0 : this.Tipo.index,
    };
  }
}
