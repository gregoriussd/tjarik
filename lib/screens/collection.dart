import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tjarik/models/batik_model.dart';
import 'package:tjarik/services/database_service.dart';
import 'package:tjarik/screens/batik_detail.dart';
import 'package:tjarik/widgets/bottom_navbar.dart';

class CollectionScreen extends StatefulWidget {
  final FirebaseStorage storage;

  const CollectionScreen({super.key, required this.storage});

  @override
  State<CollectionScreen> createState() => _CollectionScreenState();
}

class _CollectionScreenState extends State<CollectionScreen> {
  final DatabaseService _databaseService = DatabaseService();
  int _currentNavIndex = 1;

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
      appBar: AppBar(
        title: const Text(
          "My Collection",
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
                  return const Center(
                    child: Text(
                      'No batik scans yet.',
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
                  itemCount: scans.length,
                  itemBuilder: (context, index) {
                    final scan = scans[index];

                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CollectionDetailScreen(
                              scan: scan,
                              storage: widget.storage,
                            ),
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
                              child: scan.imageUrl.isNotEmpty
                                  ? Image.network(
                                      scan.imageUrl,
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
                                      errorBuilder:
                                          (context, error, stackTrace) {
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
                                      scan.motifName,
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
      floatingActionButton: null,
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentNavIndex,
        onTap: (index) {
          setState(() => _currentNavIndex = index);
        },
      ),
    );
  }
}
