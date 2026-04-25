import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tjarik/models/batik_model.dart';
import 'package:tjarik/services/database_service.dart';

class CollectionScreen extends StatefulWidget {
  final FirebaseStorage storage;

  const CollectionScreen({super.key, required this.storage});

  @override
  State<CollectionScreen> createState() => _CollectionScreenState();
}

class _CollectionScreenState extends State<CollectionScreen> {
  final DatabaseService _databaseService = DatabaseService();

  Future<String> getImageUrl(String imagePath) async {
    try {
      if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
        return imagePath;
      }

      final ref = widget.storage.ref().child(imagePath);
      final url = await ref.getDownloadURL();
      return url;
    } catch (e) {
      print('Error getting image URL: $e');
      return '';
    }
  }

  void navigateCameraPreview() {
    if (!context.mounted) return;
    Navigator.pushReplacementNamed(context, 'camera');
  }

  void navigateDashboard() {
    if (!context.mounted) return;
    Navigator.pushReplacementNamed(context, 'home');
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text("Collection"), centerTitle: true),
      body: user == null
          ? const Center(child: Text('Please sign in to see your collection.'))
          : StreamBuilder<List<BatikScan>>(
              stream: _databaseService.getCollection(user.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Failed to load collection: ${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                final scans = snapshot.data ?? [];

                if (scans.isEmpty) {
                  return const Center(child: Text('No batik scans yet.'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: scans.length,
                  itemBuilder: (context, index) {
                    final scan = scans[index];

                    return Container(
                      height: 110,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(20),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(14),
                              bottomLeft: Radius.circular(14),
                            ),
                            child: FutureBuilder<String>(
                              future: getImageUrl(scan.imagePath),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.done) {
                                  if (snapshot.hasData &&
                                      snapshot.data!.isNotEmpty) {
                                    return Image.network(
                                      snapshot.data!,
                                      width: 120,
                                      height: 110,
                                      fit: BoxFit.cover,
                                    );
                                  } else {
                                    return Container(
                                      width: 120,
                                      height: 110,
                                      color: Colors.grey[300],
                                      child: const Icon(Icons.error),
                                    );
                                  }
                                } else {
                                  return Container(
                                    width: 120,
                                    height: 110,
                                    color: Colors.grey[300],
                                    child: const Center(
                                      child: SizedBox(
                                        width: 30,
                                        height: 30,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              scan.motifName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'collectionCameraBtn',
            onPressed: () {
              navigateCameraPreview();
            },
            child: Icon(Icons.add),
          ),
          const SizedBox(width: 16),
          FloatingActionButton(
            heroTag: 'collectionDashboardBtn',
            onPressed: () {
              navigateDashboard();
            },
            child: Icon(Icons.home),
          ),
        ],
      ),
    );
  }
}
