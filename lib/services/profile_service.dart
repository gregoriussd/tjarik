import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:tjarik/models/user_model.dart';

class ProfileService {
  final FirebaseFirestore _db = FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: 'tjarik-db',
  );
  final _storage = FirebaseStorage.instance;
  final _auth = FirebaseAuth.instance;

  Future<void> createprofile(UserModel userData) async {
    await _db.collection('users').doc(userData.uid).set(userData.toMap());
  }

  Future<void> updateProfile({
    required String newName,
    File? newPhotoFile,
  }) async {
    try {
      final uid = _auth.currentUser!.uid;
      String? photoUrl;

      if (newPhotoFile != null) {
        final compressedFile = await _compressImage(newPhotoFile, uid);

        final ref = _storage.ref().child('user_profiles/$uid.jpg');
        await ref.putFile(compressedFile);

        photoUrl = await ref.getDownloadURL();
      }

      Map<String, dynamic> dataToUpdate = {'name': newName};
      if (photoUrl != null) {
        dataToUpdate['profile_url'] = photoUrl;
      }

      await _db.collection('users').doc(uid).update(dataToUpdate);

      print('Profil Berhasil Diupdate!');
    } catch (e) {
      print('Error update profile: $e');
      rethrow;
    }
  }

  Stream<UserModel> getCurrentUserProfile() {
    final uid = _auth.currentUser!.uid;
    return _db
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>));
  }

  Future<File> _compressImage(File file, String uid) async {
    final targetPath = '${file.parent.path}/${uid}_compressed.jpg';
    var result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      minWidth: 400,
      minHeight: 400,
      quality: 70,
    );
    return File(result!.path);
  }
}
