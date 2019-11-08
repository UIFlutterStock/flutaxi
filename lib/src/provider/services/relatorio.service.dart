import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Fluttaxi/src/entity/entities.dart';
import 'package:Fluttaxi/src/infra/infra.dart';

class RelatorioService {
  static final String _baseUrl = dabaBaseTables["relatorio"];
  final CollectionReference _db;

  RelatorioService() : _db = Firestore.instance.collection(_baseUrl);

  Future<Relatorio> save(Relatorio entity) async {
    if (entity.Id == null) entity.Id = _db.document().documentID;

    await _db.document(entity.Id).setData(entity.toJson());
    return entity;
  }

  Future<Relatorio> getById(String id) async {
    final CollectionReference _dbs = Firestore.instance.collection(_baseUrl);
    var query = await _dbs.where("Id", isEqualTo: id).getDocuments();

    return query.documents.isEmpty
        ? null
        : Relatorio.fromSnapshotJson(query.documents[0]);
  }

  Future<void> deleteById(String id) async {
    await _db.document(id).delete();
  }

  Future<List<Relatorio>> getbyMotorista(String motoristaId) async {
    final CollectionReference _dbs = Firestore.instance.collection(_baseUrl);
    var query =
        await _dbs.where("MotoristaId", isEqualTo: motoristaId).getDocuments();

    return query.documents.isEmpty
        ? null
        : query.documents
        .map((result) => Relatorio.fromSnapshotJson(result))
        .toList();
  }

  Future<List<Relatorio>> getbyMotoristaWithDate(String motoristaId,
      DateTime dataInicial, DateTime dataFinal) async {
    final CollectionReference _dbs = Firestore.instance.collection(_baseUrl);
    var query =
    await _dbs.where("MotoristaId", isEqualTo: motoristaId).getDocuments();

    return query.documents.isEmpty
        ? null
        : query.documents
        .map((result) => Relatorio.fromSnapshotJson(result))
        .toList();
  }
}
