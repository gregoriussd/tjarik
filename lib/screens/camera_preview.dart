import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_ai/firebase_ai.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tjarik/models/batik_model.dart';
import 'package:tjarik/services/database_service.dart';

class CameraPreviewScreen extends StatefulWidget {
  final CameraDescription camera;
  final FirebaseStorage storage;
  final GenerativeModel model;

  const CameraPreviewScreen({
    super.key,
    required this.camera,
    required this.storage,
    required this.model,
  });

  @override
  State<CameraPreviewScreen> createState() => _CameraPreviewScreenState();
}

class _CameraPreviewScreenState extends State<CameraPreviewScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(widget.camera, ResolutionPreset.high);
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>> _analyzeImage(XFile image) async {
    const prompt = """
      Analisis gambar ini dan identifikasi apakah ini motif batik.
      Balas HANYA JSON valid, tanpa teks tambahan, dengan format:
      {"name":"...", "origin":"...", "philosophy":"...", "confidence":0.0}

      Aturan:
      - "name": nama motif batik, atau "Tidak ditemukan" jika bukan batik.
      - "origin": daerah asal motif (contoh: "Yogyakarta"). Jika tidak ditemukan, isi "-".
      - "philosophy": filosofi singkat motif. Jika tidak ditemukan, isi "-".
      - "confidence": angka desimal 0.0 sampai 1.0.

      Jika bukan motif batik, balas:
      {"name":"Tidak ditemukan", "origin":"-", "philosophy":"-", "confidence":0.0}
      """;

    final bytes = await image.readAsBytes();
    final mimeType = image.mimeType ?? 'image/jpeg';

    final response = await widget.model.generateContent([
      Content.text(prompt),
      Content.inlineData(mimeType, bytes),
    ]);

    final raw = (response.text ?? '{}').trim();
    final cleanedRaw = raw
        .replaceAll('```json', '')
        .replaceAll('```', '')
        .trim();

    try {
      final data = jsonDecode(cleanedRaw) as Map<String, dynamic>;
      final parsedConfidence =
          double.tryParse((data['confidence'] ?? '0').toString()) ?? 0.0;

      return {
        'name': (data['name'] ?? 'Tidak ditemukan').toString(),
        'origin': (data['origin'] ?? '-').toString(),
        'philosophy': (data['philosophy'] ?? '-').toString(),
        'confidence': parsedConfidence.clamp(0.0, 1.0),
      };
    } catch (_) {
      return {
        'name': 'Tidak ditemukan',
        'origin': '-',
        'philosophy': '-',
        'confidence': 0.0,
      };
    }
  }

  Future<File> _compressTo500Square(XFile image) async {
    final bytes = await image.readAsBytes();
    final decoded = img.decodeImage(bytes);

    if (decoded == null) {
      return File(image.path);
    }

    final square = img.copyResizeCropSquare(decoded, size: 500);
    final squareBytes = Uint8List.fromList(img.encodeJpg(square, quality: 85));

    final compressedBytes = await FlutterImageCompress.compressWithList(
      squareBytes,
      quality: 80,
      format: CompressFormat.jpeg,
      minWidth: 500,
      minHeight: 500,
      keepExif: false,
    );

    final tempDir = await getTemporaryDirectory();
    final outFile = File(
      '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}_500.jpg',
    );
    await outFile.writeAsBytes(compressedBytes, flush: true);
    return outFile;
  }

  Future<String> _uploadImage(File imageFile) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final imageName = '${timestamp}_compressed.jpg';
    final imagePath = 'user/$imageName';
    final ref = widget.storage.ref().child(imagePath);

    await ref.putFile(imageFile);
    return imagePath;
  }

  Future<void> _showAnalysisAndAskSave({
    required XFile image,
    required Map<String, dynamic> analysis,
  }) async {
    if (!mounted) return;

    final motifName = (analysis['name'] ?? 'Tidak ditemukan').toString();
    final origin = (analysis['origin'] ?? '-').toString();
    final philosophy = (analysis['philosophy'] ?? '-').toString();
    final confidence =
        double.tryParse((analysis['confidence'] ?? '0').toString()) ?? 0.0;

    String personalNote = '';

    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (context) {
        final screenWidth = MediaQuery.of(context).size.width;
        final dialogWidth = screenWidth > 480 ? 420.0 : screenWidth * 0.9;

        return AlertDialog(
          title: const Text('Hasil Analisis'),
          content: SizedBox(
            width: dialogWidth,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: AspectRatio(
                      aspectRatio: 4 / 3,
                      child: Image.file(File(image.path), fit: BoxFit.cover),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text('Nama motif: ${motifName.isNotEmpty ? motifName : '-'}'),
                  const SizedBox(height: 8),
                  Text('Asal: ${origin.isNotEmpty ? origin : '-'}'),
                  const SizedBox(height: 8),
                  Text('Filosofi: ${philosophy.isNotEmpty ? philosophy : '-'}'),
                  const SizedBox(height: 8),
                  Text('Confidence: ${(confidence * 100).toStringAsFixed(1)}%'),
                  const SizedBox(height: 12),
                  TextField(
                    onChanged: (value) {
                      personalNote = value;
                    },
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Catatan pribadi',
                      hintText: 'Tulis catatan kamu di sini...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );

    if (shouldSave == true) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final compressedFile = await _compressTo500Square(image);

        BatikScan newScan = BatikScan(
          userId: user.uid,
          motifName: motifName,
          origin: origin,
          philosophy: philosophy,
          imagePath: await _uploadImage(compressedFile),
          confidence: confidence,
          personalNote: personalNote,
          createdAt: DateTime.now(),
        );
        await DatabaseService().saveBatikScan(newScan);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Tersimpan ke Firebase')));
    }
  }

  Future<void> takePicture() async {
    if (_isUploading) return;

    setState(() {
      _isUploading = true;
    });

    try {
      await _initializeControllerFuture;
      final image = await _controller.takePicture();

      final analysis = await _analyzeImage(image);
      await _showAnalysisAndAskSave(image: image, analysis: analysis);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal proses foto: $e')));
      }
      return;
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  Future<void> pickFromGallery() async {
    if (_isUploading) return;

    try {
      final image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
      );

      setState(() => _isUploading = true);
      if (image == null) return;

      final analysis = await _analyzeImage(image);
      await _showAnalysisAndAskSave(image: image, analysis: analysis);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gallery upload failed: $e')));
      }
      return;
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  void navigateDashboard() {
    if (!context.mounted) return;
    Navigator.pushReplacementNamed(context, 'home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Camera Access')),
      body: Stack(
        children: [
          FutureBuilder<void>(
            future: _initializeControllerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return CameraPreview(_controller);
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
          if (_isUploading)
            Positioned.fill(
              child: AbsorbPointer(
                absorbing: true,
                child: Container(
                  color: Colors.black45,
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 12),
                        Text(
                          'Uploading...',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'cameraGalleryBtn',
            onPressed: _isUploading ? null : pickFromGallery,
            child: const Icon(Icons.photo_library),
          ),
          const SizedBox(width: 16),
          FloatingActionButton(
            heroTag: 'cameraShutterBtn',
            onPressed: _isUploading ? null : takePicture,
            child: const Icon(Icons.camera_alt),
          ),
          const SizedBox(width: 16),
          FloatingActionButton(
            heroTag: 'cameraHomeBtn',
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
