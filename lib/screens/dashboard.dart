import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';

class DashboardScreen extends StatefulWidget {
  final FirebaseStorage storage;

  const DashboardScreen({super.key, required this.storage});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // list map nama bating dengan path file di firebase storage, akan digantikan dengan relational DB
  final List<Map<String, String>> batikList = [
    {'name': 'Batik Betawi', 'file': 'batik_betawi.jpg'},
    {'name': 'Batik Kawung', 'file': 'batik_kawung.jpg'},
    {'name': 'Batik Lereng', 'file': 'batik_lereng.jpg'},
    {'name': 'Batik Mega Mendung', 'file': 'batik_megamendung.jpg'},
    {'name': 'Batik Parang', 'file': 'batik_parang.jpg'},
    {'name': 'Batik Sekar Jagad', 'file': 'batik_sekarjagad.jpg'},
    {'name': 'Batik Sidomukti', 'file': 'batik_sidomukti.jpg'},
    {'name': 'Batik Simbut', 'file': 'batik_simbut.jpg'},
    {'name': 'Batik Sogan', 'file': 'batik_sogan.jpg'},
    {'name': 'Batik Tujuh Rupa', 'file': 'batik_tujuhrupa.jpg'},
  ];

  Future<String> getImageUrl(String fileName) async {
    try {
      final ref = widget.storage.ref().child('default/$fileName');
      final url = await ref.getDownloadURL();
      return url;
    } catch (e) {
      print('Error getting image URL: $e');
      return '';
    }
  }

  void navigateCameraPreview () {
    if (!context.mounted) return;
    Navigator.pushReplacementNamed(context, 'camera');
  }

  void navigateCollection () {
    if (!context.mounted) return;
    Navigator.pushReplacementNamed(context, 'collection');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: batikList.length,
        itemBuilder: (context, index) {
          final item = batikList[index];

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
                    future: getImageUrl(item['file']!),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
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
                              child: CircularProgressIndicator(strokeWidth: 2),
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
                    item['name']!,
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
      ),
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'dashboardCameraBtn',
            onPressed: () {
              navigateCameraPreview();
            },
            child: Icon(Icons.add),
          ),
          const SizedBox(width: 16),
          FloatingActionButton(
            heroTag: 'dashboardCollectionBtn',
            onPressed: () {
              navigateCollection();
            },
            child: const Icon(Icons.collections),
          ),
        ],
      ),
    );
  }
}

