import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final List<Map<String, String>> batikList = [
    {'name': 'Batik Betawi', 'image': 'assets/batik/batik_betawi.jpg'},
    {'name': 'Batik Kawung', 'image': 'assets/batik/batik_kawung.jpg'},
    {'name': 'Batik Lereng', 'image': 'assets/batik/batik_lereng.jpg'},
    {'name': 'Batik Mega Mendung', 'image': 'assets/batik/batik_megamendung.jpg'},
    {'name': 'Batik Parang', 'image': 'assets/batik/batik_parang.jpg'},
    {'name': 'Batik Sekar Jagad', 'image': 'assets/batik/batik_sekarjagad.jpg'},
    {'name': 'Batik Sidomukti', 'image': 'assets/batik/batik_sidomukti.jpg'},
    {'name': 'Batik Simbut', 'image': 'assets/batik/batik_simbut.jpg'},
    {'name': 'Batik Sogan', 'image': 'assets/batik/batik_sogan.jpg'},
    {'name': 'Batik Tujuh Rupa', 'image': 'assets/batik/batik_tujuhrupa.jpg'},
  ];

  void navigateCameraPreview () {
    if (!context.mounted) return;
    Navigator.pushReplacementNamed(context, 'camera');
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
                  child: Image.asset(
                    item['image']!,
                    width: 120,
                    height: 110,
                    fit: BoxFit.cover,
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
      floatingActionButton: FloatingActionButton(
      onPressed: () {
        navigateCameraPreview();
      },
      child: Icon(Icons.add),
    ),
    );
  }
}

