import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:tjarik/models/batik_model.dart';
import 'package:tjarik/screens/batik_detail.dart';
import 'package:tjarik/widgets/bottom_navbar.dart';

class DashboardScreen extends StatefulWidget {
  final FirebaseStorage storage;

  const DashboardScreen({super.key, required this.storage});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: 'tjarik-db',
  );
  int _currentNavIndex = 0;

  Stream<List<BatikDefault>> getDefaultBatiks() {
    return _db.collection('batik_defaults').snapshots().map((snapshot) {
      final batiks = snapshot.docs
          .map((doc) => BatikDefault.fromFirestore(doc))
          .toList();
      batiks.sort((a, b) => a.motifName.compareTo(b.motifName));
      return batiks;
    });
  }

  void navigateCameraPreview() {
    if (!context.mounted) return;
    Navigator.pushReplacementNamed(context, 'camera');
  }

  void navigateCollection() {
    if (!context.mounted) return;
    Navigator.pushReplacementNamed(context, 'collection');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Dashboard",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: false,
        elevation: 0,
        backgroundColor: const Color(0xFFF7F8FA),
      ),
      backgroundColor: const Color(0xFFF7F8FA),
      body: StreamBuilder<List<BatikDefault>>(
        stream: getDefaultBatiks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Failed to load dashboard: ${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            );
          }

          final batiks = snapshot.data ?? [];

          if (batiks.isEmpty) {
            return const Center(
              child: Text(
                'No batik defaults found.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.85,
              crossAxisSpacing: 16,
              mainAxisSpacing: 20,
            ),
            itemCount: batiks.length,
            itemBuilder: (context, index) {
              final batik = batiks[index];

              return InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BatikDetailScreen(batik: batik),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(12),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                        child: batik.imageUrl.isNotEmpty
                            ? Image.network(
                                batik.imageUrl,
                                height: 140,
                                fit: BoxFit.cover,
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                      if (loadingProgress == null) {
                                        return child;
                                      }
                                      return Container(
                                        height: 140,
                                        color: Colors.grey[200],
                                        child: const Center(
                                          child: SizedBox(
                                            width: 30,
                                            height: 30,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation(
                                                    Color(0xFF1E6FE8),
                                                  ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    height: 140,
                                    color: Colors.grey[200],
                                    child: const Icon(
                                      Icons.error_outline,
                                      color: Colors.grey,
                                    ),
                                  );
                                },
                              )
                            : Container(
                                height: 140,
                                color: Colors.grey[200],
                                child: const Icon(
                                  Icons.image_not_supported,
                                  color: Colors.grey,
                                ),
                              ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                batik.motifName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                                maxLines: 1,
                                softWrap: false,
                                overflow: TextOverflow.clip,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentNavIndex,
        onTap: (index) {
          setState(() => _currentNavIndex = index);
        },
      ),
    );
  }
}
