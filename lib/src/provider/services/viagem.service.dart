import 'package:Fluttaxi/src/entity/entities.dart';
import 'package:Fluttaxi/src/infra/infra.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire/geoflutterfire.dart';


class ViagemService {
  static final String _baseUrl = dabaBaseTables["viagem"];
  final CollectionReference _db;

  ViagemService() : _db = Firestore.instance.collection(_baseUrl);

  Future<Viagem> save(Viagem entity) async {
    if (entity.Id == null) entity.Id = _db
        .document()
        .documentID;

    await _db.document(entity.Id).setData(entity.toJson());
    return entity;
  }

  /*se o app tiver sido fechadao e tiver  viagem em aberta*/
  Future<void> cancelAllViagensPassageiroAberta(String idPassageiro) async {
    final CollectionReference _dbs = Firestore.instance.collection(_baseUrl);

    var query = await _dbs
        .where("PassageiroEntity.Id", isEqualTo: idPassageiro)
        .where("Status", isEqualTo: TravelStatus.Open.index)
        .getDocuments();

    if (!query.documents.isEmpty) {
      List<Viagem> listaViagensAberta = query.documents
          .map((result) => Viagem.fromSnapshotJson(result))
          .toList();

      listaViagensAberta.forEach((r) async {
        r.Status = TravelStatus.Canceled;
        await save(r);
      });
    }
  }


  /*verifica se existe viagem em aberta para passageiro*/
  Future<Stream<QuerySnapshot>> startViagem(Viagem entity) async {
    await save(entity);

    final CollectionReference _dbs = Firestore.instance.collection(_baseUrl);
    Stream<QuerySnapshot> snapshots =
    _dbs.where("Id", isEqualTo: entity.Id).limit(1).snapshots();

    return snapshots;
  }


  /*verifica se existe viagem em aberta para passageiro*/
  Future<Stream<QuerySnapshot>> startProcuraViagemEmAberta() async {
    final CollectionReference _dbs = Firestore.instance.collection(_baseUrl);
    Stream<QuerySnapshot> snapshots =
    _dbs.where("Status", isEqualTo: TravelStatus.Open.index)
        .limit(1)
        .snapshots();

    return snapshots;
  }


  Future<Stream<QuerySnapshot>> getViagemById(String id) async {
    final CollectionReference _dbs = Firestore.instance.collection(_baseUrl);

    Stream<QuerySnapshot> snapshots = await _dbs.where("Id", isEqualTo: id)
        .limit(1)
        .snapshots();

    return snapshots;
  }

  Future<Viagem> getStreamViagemById(String id) async {
    final CollectionReference _dbs = Firestore.instance.collection(_baseUrl);

    var query = await _dbs.where("Id", isEqualTo: id).getDocuments();

    return query.documents.isEmpty
        ? null
        : Viagem.fromSnapshotJson(query.documents[0]);
  }


  Future<Stream<List<DocumentSnapshot>>> getViagemAbertaGeoPoint(double lat,
      double lng, TravelStatus status) async {
    final CollectionReference _dbs = Firestore.instance.collection(_baseUrl);

    Geoflutterfire geo = Geoflutterfire();
    GeoFirePoint center = geo.point(latitude: lat, longitude: lng);
    double radius = 50;
    String field = 'position';

    Stream<List<DocumentSnapshot>> stream = geo
        .collection(
        collectionRef: _dbs.where("Status", isEqualTo: status.index))
        .within(center: center, radius: radius, field: field);

    return stream;
  }


  Future<Viagem> getViagemAbertaByUsuario(String idPassageiro,
      TravelStatus status) async {
    final CollectionReference _dbs = Firestore.instance.collection(_baseUrl);

    var query = await _dbs
        .where("Status", isEqualTo: status.index)
        .where("PassageiroEntity.Id", isEqualTo: idPassageiro)
        .getDocuments();

    return query.documents.isEmpty
        ? null
        : Viagem.fromSnapshotJson(query.documents[0]);
  }

  Future<List<Viagem>> getViagensByPassageiro(String idPassageiro) async {
    final CollectionReference _dbs = Firestore.instance.collection(_baseUrl);

    var query = await _dbs.where("PassageiroEntity.Id", isEqualTo: idPassageiro)
        .getDocuments();

    return query.documents.isEmpty
        ? null
        : query.documents
        .map((result) => Viagem.fromSnapshotJson(result))
        .toList();
  }

  Future<List<Viagem>> getViagensByMotoristaConcluida(
      String idMotorista) async {
    final CollectionReference _dbs = Firestore.instance.collection(_baseUrl);

    var query = await _dbs.where("Status", isEqualTo: 5)
        .where("MotoristaEntity.Id", isEqualTo: idMotorista).getDocuments();

    return query.documents.isEmpty
        ? null
        : query.documents
        .map((result) => Viagem.fromSnapshotJson(result))
        .toList();
  }

  Future<List<Viagem>> getViagensByMotoristaConcluidaWithDataInicialFinal(
      String idMotorista, DateTime dataInicial, DateTime dataFinal) async {
    final CollectionReference _dbs = Firestore.instance.collection(_baseUrl);

    var query = await _dbs.where("Status", isEqualTo: 5)
        .where("MotoristaEntity.Id", isEqualTo: idMotorista)
        .where('ModificadoEm', isGreaterThanOrEqualTo: dataInicial)
        .getDocuments();

    return query.documents.isEmpty
        ? null
        : query.documents
        .map((result) => Viagem.fromSnapshotJson(result))
        .toList();
  }


  Future<List<Viagem>> getViagensByMotorista(String idMotorista) async {
    final CollectionReference _dbs = Firestore.instance.collection(_baseUrl);

    var query = await _dbs.where("MotoristaEntity.Id", isEqualTo: idMotorista)
        .getDocuments();

    return query.documents.isEmpty
        ? null
        : query.documents
        .map((result) => Viagem.fromSnapshotJson(result))
        .toList();
  }
}
