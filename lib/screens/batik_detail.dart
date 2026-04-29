import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:tjarik/models/batik_model.dart';

class CollectionDetailScreen extends StatelessWidget {
  final BatikScan scan;
  final FirebaseStorage storage;

  const CollectionDetailScreen({
    super.key,
    required this.scan,
    required this.storage,
  });

  String _formatDateTime(DateTime dt) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return '${dt.year}-${twoDigits(dt.month)}-${twoDigits(dt.day)} '
        '${twoDigits(dt.hour)}:${twoDigits(dt.minute)}';
  }

  Widget _infoTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value.isNotEmpty ? value : '-',
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Collection Detail'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Builder(
              builder: (context) {
                final url = scan.imageUrl;
                if (url.isEmpty) {
                  return Container(
                    height: 220,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Icon(Icons.broken_image, size: 40),
                    ),
                  );
                }

                return ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    url,
                    width: double.infinity,
                    height: 220,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        alignment: Alignment.center,
                        child: const Icon(Icons.broken_image, size: 40),
                      );
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            _infoTile('Motif Name', scan.motifName),
            _infoTile('Origin', scan.origin),
            _infoTile('Philosophy', scan.philosophy),
            _infoTile('Personal Note', scan.personalNote),
            _infoTile(
              'Confidence',
              '${(scan.confidence * 100).toStringAsFixed(1)}%',
            ),
            _infoTile('Created At', _formatDateTime(scan.createdAt)),
            _infoTile('Image Url', scan.imageUrl),
            _infoTile('User ID', scan.userId),
            _infoTile('Document ID', scan.id ?? '-'),
          ],
        ),
      ),
    );
  }
}

class BatikDetailScreen extends StatelessWidget {
  final BatikDefault batik;

  const BatikDetailScreen({super.key, required this.batik});

  Widget _infoTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value.isNotEmpty ? value : '-',
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Batik Detail'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Builder(
              builder: (context) {
                final url = batik.imageUrl;
                if (url.isEmpty) {
                  return Container(
                    height: 220,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Icon(Icons.broken_image, size: 40),
                    ),
                  );
                }

                return ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    url,
                    width: double.infinity,
                    height: 220,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        alignment: Alignment.center,
                        child: const Icon(Icons.broken_image, size: 40),
                      );
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            _infoTile('Motif Name', batik.motifName),
            _infoTile('Origin', batik.origin),
            _infoTile('Philosophy', batik.philosophy),
          ],
        ),
      ),
    );
  }
}
