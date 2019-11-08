import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Fluttaxi/src/infra/infra.dart';

import 'entities.dart';

class Passageiro {
  String Id;
  String Codigo;
  String Nome;
  String Email;
  int Idade;
  Imagem Foto;
  DateTime CriadoEm;
  DateTime ModificadoEm;
  bool Status;
  Local Casa;
  Local Trabalho;

  Passageiro(
      {this.Id,
        this.Codigo = '',
        this.Nome,
        this.Idade,
        this.Email,
        this.Foto,
        this.ModificadoEm,
        this.Casa,
        this.Trabalho,
        this.CriadoEm,
        this.Status = true});

  Passageiro.fromSnapshot(DocumentSnapshot snapshot)
      : this.Id = snapshot.documentID,
        this.Codigo = snapshot.data["Codigo"],
        this.Nome = snapshot.data["Nome"] == null ? '---' : snapshot.data["Nome"],
        this.Idade = snapshot.data["Idade"],
        this.Email = snapshot.data["Email"],
        this.Foto = Imagem.fromMap(snapshot.data["Foto"]),
        this.Casa = Local.fromMap(snapshot.data["Casa"]),
        this.Trabalho = Local.fromMap(snapshot.data["Trabalho"]),
        this.ModificadoEm =DateTime.parse(snapshot.data['ModificadoEm'].toString()),
        this.CriadoEm =DateTime.parse( snapshot.data['CriadoEm']),
        this.Status = snapshot.data["Status"] as bool;

  Passageiro.fromJson(Map<dynamic, dynamic> map)
      : Codigo = map["Codigo"],
        this.Id = map["Id"],
        this.Email = map["Email"],
        this.Nome = map["Nome"] == null ? '---' : map["Nome"] ,
        this.Idade = map["Idade"],
        this.Foto = Imagem.fromMap(map["Foto"]),
        this.Casa = map["Casa"] == null ? null :   Local.fromMap(map["Casa"]),
        this.Trabalho =map["Trabalho"] == null ? null :   Local.fromMap(map["Trabalho"]),
        this.ModificadoEm = DateTime.parse(map['ModificadoEm']),
        this.CriadoEm = DateTime.parse(map['CriadoEm']),
        this.Status = map["Status"] as bool;

  static Map<dynamic, dynamic> stringToMap(String s) {
    Map<dynamic, dynamic> map = jsonDecode(s) as Map<dynamic, dynamic>;
    return map;
  }

  toJson() {
    return {
      "Id": this.Id,
      "Codigo": this.Codigo == '' ? HelpService.generateCode(12) : this.Codigo,
      "Nome":this.Nome == null ? '---' : this.Nome,
      "Idade": this.Idade,
      "Email": this.Email,
      "Foto": this.Foto == null ? Imagem().toJson() : this.Foto.toJson(),
      "Casa": this.Casa == null ? Local().toJson() : this.Casa.toJson(),
      "Trabalho": this.Trabalho == null ? Local().toJson() : this.Trabalho.toJson(),
      "ModificadoEm":
      this.ModificadoEm == null ? DateTime.now().toString() : this.ModificadoEm.toString(),
      "CriadoEm": this.CriadoEm == null ? DateTime.now().toString() : this.CriadoEm.toString(),
      "Status": this.Status == null ? true : this.Status
    };
  }
}
