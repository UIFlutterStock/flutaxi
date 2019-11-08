import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Fluttaxi/src/entity/entities.dart';
import 'package:Fluttaxi/src/infra/infra.dart';

class VeiculoService {
  static final String _baseUrl = dabaBaseTables["veiculo"];
  final CollectionReference _db;

  VeiculoService() : _db = Firestore.instance.collection(_baseUrl);

  Future<Veiculo> save(Veiculo entity) async {
    if (entity.Id == null) entity.Id = _db.document().documentID;

    await _db.document(entity.Id).setData(entity.toJson());
    return entity;
  }

  Future<List<Veiculo>> getAll() async {
    final CollectionReference _dbs = Firestore.instance.collection(_baseUrl);

    var query = await _dbs.getDocuments();

    return query.documents.isEmpty
        ? null
        : query.documents
        .map((result) => Veiculo.fromSnapshotJson(result))
        .toList();
  }
}
