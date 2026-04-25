import 'package:cloud_firestore/cloud_firestore.dart';

class BatikScan {
  final String? id;
  final String userId;
  final String motifName;
  final double confidence;
  final String origin;
  final String philosophy;
  final String imagePath;
  final String personalNote;
  final DateTime createdAt;

  BatikScan({
    this.id,
    required this.userId,
    required this.motifName,
    required this.confidence,
    required this.origin,
    required this.philosophy,
    required this.imagePath,
    required this.personalNote,
    required this.createdAt
  });

  factory BatikScan.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return BatikScan(
      id: doc.id,
      userId: data['user_id'] ?? '',
      motifName: data['motif_name'] ?? '',
      origin: data['origin'] ?? '',
      philosophy: data['philosophy'] ?? '',
      imagePath: data['image_path'] ?? '',
      confidence: (data['confidence'] ?? 0.0).toDouble(),
      personalNote: data['personal_note'],
      createdAt: (data['created_at'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'motif_name': motifName,
      'origin': origin,
      'philosophy': philosophy,
      'image_path': imagePath,
      'confidence': confidence,
      'personal_note': personalNote,
      'created_at': Timestamp.fromDate(createdAt),
    };
  }
}