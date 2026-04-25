import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:tjarik/models/batik_model.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: 'tjarik-db',
  );

  Future<void> saveBatikScan(BatikScan scan) async {
    await _db.collection('batik_scans').add(scan.toMap());
  }

  Stream<List<BatikScan>> getCollection(String uid) {
    return _db
        .collection('batik_scans')
        .where('user_id', isEqualTo: uid)
        .snapshots()
        .map((snapshot) {
          final scans = snapshot.docs
              .map((doc) => BatikScan.fromFirestore(doc))
              .toList();
          scans.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return scans;
        });
  }

  Future<void> updateNote(String docId, String newNote) async {
    await _db.collection('batik_scans').doc(docId).update({
      'personal_note': newNote,
    });
  }

  Future<void> deleteScan(String docId) async {
    await _db.collection('batik_scans').doc(docId).delete();
  }
}