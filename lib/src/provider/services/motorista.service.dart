import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Fluttaxi/src/entity/entities.dart';
import 'package:Fluttaxi/src/infra/infra.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MotoristaService {
  static final String _baseUrl = dabaBaseTables["motorista"];
  final CollectionReference _db;

  MotoristaService() : _db = Firestore.instance.collection(_baseUrl);

  Future<Motorista> save(Motorista entity) async {
    if (entity.Id == null) entity.Id = _db.document().documentID;

    await _db.document(entity.Id).setData(entity.toJson());
    return entity;
  }

  Future<void> verificyExistsByEmailAndSave(Motorista entity) async {
    var result = await getByEmail(entity.Email);

    /*se ja existir o usuario reaproveita o id  e a idade que já foi cadastrada*/
    if (result != null) {
      entity.Id = result.Id;
      entity.Automovel = result.Automovel;
    }
    await save(entity);
  }

  Future<Motorista> getByEmail(String email) async {
    final CollectionReference _dbs = Firestore.instance.collection(_baseUrl);
    var query = await _dbs.where("Email", isEqualTo: email).getDocuments();

    return query.documents.isEmpty
        ? null
        : Motorista.fromSnapshot(query.documents[0]);
  }

  Future<Motorista> getCustomerStorage() async {
    SharedPreferences storageData = await SharedPreferences.getInstance();

    var motorista = storageData.getString('motorista');
    var customerResult = motorista == null
        ? null
        : Motorista.fromJson(Motorista.stringToMap(motorista.toString()));
    return (customerResult);
  }

  Future setStorage(Motorista motorista) async {
    try {
      SharedPreferences storageData = await SharedPreferences.getInstance();
      var r = motorista.toJson();
      await storageData.setString('motorista', json.encode(motorista.toJson()));
    } catch (ex) {
      throw ('Erro in SetCardStorage' + ex);
    }
  }

  Future<void> remove() async {
    SharedPreferences storageData = await SharedPreferences.getInstance();
    await storageData.remove('motorista');
  }
}
