import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Fluttaxi/src/entity/motorista.entity.dart';
import 'package:Fluttaxi/src/entity/passageiro.entity.dart';
import 'package:Fluttaxi/src/infra/infra.dart';

import 'entities.dart';

class Viagem {
  String Id;
  String Codigo;
  String Distancia;
  String Tempo;
  DateTime CriadoEm;
  DateTime ModificadoEm;
  DateTime ViagemAceitaEm;
  Passageiro PassageiroEntity;
  Motorista MotoristaEntity;
  TipoCarro TipoCorrida;
  String OrigemEnderecoPrincipal;
  String OrigemEndereco;
  String EnderecoAtualMotorista;
  double ValorPop;
  double ValorTop;
  double MotoristaPosicaoLongitude;
  double MotoristaPosicaoLatitude;
  double OrigemLatitude;
  double OrigemLongitude;
  String DestinoEnderecoPrincipal;
  String DestinoEndereco;
  double DestinoLatitude;
  double DestinoLongitude;
  TravelStatus Status;

  Viagem(
      {this.Id,
      this.Codigo = '',
      this.Distancia,
      this.Tempo,
      this.ValorPop,
        this.ValorTop,
      this.OrigemEnderecoPrincipal,
      this.OrigemEndereco,
      this.OrigemLatitude,
      this.OrigemLongitude,
        this.MotoristaPosicaoLongitude,
        this.MotoristaPosicaoLatitude,
      this.TipoCorrida,
      this.DestinoEnderecoPrincipal,
      this.DestinoEndereco,
        this.EnderecoAtualMotorista,
      this.DestinoLatitude,
        this.DestinoLongitude,
      this.PassageiroEntity,
      this.MotoristaEntity,
      this.ModificadoEm,
      this.CriadoEm,
        this.ViagemAceitaEm,
      this.Status});

  Viagem.fromSnapshotJson(DocumentSnapshot snapshot)
      : this.Id = snapshot.documentID,
        this.Codigo = snapshot.data["Codigo"],
        this.OrigemEnderecoPrincipal = snapshot.data["OrigemEnderecoPrincipal"],
        this.OrigemEndereco = snapshot.data["OrigemEndereco"],
        this.OrigemLatitude = snapshot.data["OrigemLatitude"],
        this.OrigemLongitude = snapshot.data["OrigemLongitude"],
        this.EnderecoAtualMotorista = snapshot.data["EnderecoAtualMotorista"],
        this.ValorPop = snapshot.data["ValorPop"].toDouble(),
        this.ValorTop = snapshot.data["ValorTop"].toDouble(),
        this.DestinoEnderecoPrincipal =
            snapshot.data["DestinoEnderecoPrincipal"],
        this.DestinoEndereco = snapshot.data["DestinoEndereco"],
        this.DestinoLatitude = snapshot.data["DestinoLatitude"],
        this.DestinoLongitude = snapshot.data["DestinoLongitude"],
        this.MotoristaPosicaoLongitude = snapshot.data["MotoristaPosicaoLongitude"],
        this.MotoristaPosicaoLatitude = snapshot.data["MotoristaPosicaoLatitude"],
        this.Distancia = snapshot.data["Distancia"],
        this.Tempo = snapshot.data["Tempo"],
        this.PassageiroEntity = Passageiro.fromJson(snapshot.data["PassageiroEntity"]),
        this.MotoristaEntity = Motorista.fromJson(snapshot.data["MotoristaEntity"]),
        this.ModificadoEm = snapshot.data['ModificadoEm'].toDate(),
        this.CriadoEm = snapshot.data['CriadoEm'].toDate(),
        this.ViagemAceitaEm = snapshot.data['ViagemAceitaEm'].toDate(),
        this.TipoCorrida = TipoCarro.values[snapshot.data['TipoCorrida']],
        this.Status = TravelStatus.values[(snapshot.data["Status"])];

  static Map<String, dynamic> stringToMap(String s) {
    Map<String, dynamic> map = json.decode(s);
    return map;
  }

  toJson() {
    return {
      "Id": this.Id,
      "Codigo": this.Codigo == '' ? HelpService.generateCode(12) : this.Codigo,
      "OrigemEnderecoPrincipal": this.OrigemEnderecoPrincipal,
      "OrigemEndereco": this.OrigemEndereco,
      "OrigemLatitude": this.OrigemLatitude,
      "OrigemLongitude": this.OrigemLongitude,
      "EnderecoAtualMotorista": this.EnderecoAtualMotorista,
      "DestinoEnderecoPrincipal": this.DestinoEnderecoPrincipal,
      "DestinoEndereco": this.DestinoEndereco,
      "DestinoLatitude": this.DestinoLatitude,
      "DestinoLongitude": this.DestinoLongitude,
      "MotoristaPosicaoLongitude": this.MotoristaPosicaoLongitude,
      "MotoristaPosicaoLatitude": this.MotoristaPosicaoLatitude,
      "ValorPop": this.ValorPop,
      "ValorTop": this.ValorTop,
      "Tempo": this.Tempo,
      "Distancia": this.Distancia,
      "PassageiroEntity": this.PassageiroEntity.toJson(),
      "MotoristaEntity": this.MotoristaEntity == null
          ? Motorista().toJson()
          : this.MotoristaEntity.toJson(),
      "ModificadoEm":
          this.ModificadoEm == null ? DateTime.now() : this.ModificadoEm,
      "CriadoEm": this.CriadoEm == null ? DateTime.now() : this.CriadoEm,
      "ViagemAceitaEm": this.ViagemAceitaEm == null ? DateTime.now() : this.ViagemAceitaEm,
      "Status": this.Status == null ? 0 : this.Status.index,
      "TipoCorrida": this.TipoCorrida == null ? 0 : this.TipoCorrida.index,
    };
  }
}
