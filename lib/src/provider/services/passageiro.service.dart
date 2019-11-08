import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Fluttaxi/src/entity/entities.dart';
import 'package:Fluttaxi/src/infra/infra.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PassageiroService {
  static final String _baseUrl = dabaBaseTables["passageiro"];
  final CollectionReference _db;

  PassageiroService() : _db = Firestore.instance.collection(_baseUrl);

  Future<Passageiro> save(Passageiro entity) async {
    if (entity.Id == null) entity.Id = _db.document().documentID;

    await _db.document(entity.Id).setData(entity.toJson());
    return entity;
  }

  Future<void> verificyExistsByEmailAndSave(Passageiro entity) async {
    var result = await getByEmail(entity.Email);

    /*se ja existir o usuario reaproveita o id  e a idade que já foi cadastrada*/
    if (result != null) {
      entity.Id = result.Id;
      entity.Idade = result.Idade;
    }
    await save(entity);
  }

  Future<Passageiro> getByEmail(String email) async {
    final CollectionReference _dbs = Firestore.instance.collection(_baseUrl);
    var query = await _dbs.where("Email", isEqualTo: email).getDocuments();

    return query.documents.isEmpty
        ? null
        : Passageiro.fromSnapshot(query.documents[0]);
  }

  Future<Passageiro> getCustomerStorage() async {
    SharedPreferences storageData = await SharedPreferences.getInstance();

    var passageiro = storageData.getString('passageiro');
    var customerResult = passageiro == null
        ? null
        : Passageiro.fromJson(Passageiro.stringToMap(passageiro.toString()));
    return (customerResult);
  }

  Future setStorage(Passageiro customer) async {
    try {
      SharedPreferences storageData = await SharedPreferences.getInstance();
      await storageData.setString('passageiro', json.encode(customer.toJson()));
    } catch (ex) {
      throw ('Erro in SetCardStorage' + ex);
    }
  }

  Future<void> remove() async {
    SharedPreferences storageData = await SharedPreferences.getInstance();
    await storageData.remove('passageiro');
  }
}
