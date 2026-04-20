import 'dart:convert';
import 'dart:io';

import 'package:firebase_ai/firebase_ai.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';

class CameraPreviewScreen extends StatefulWidget {
  final CameraDescription camera;
  final FirebaseStorage storage;
  final GenerativeModel model;

  const CameraPreviewScreen({super.key, required this.camera, required this.storage, required this.model});

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
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.high,
    );
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<Map<String, String>> _analyzeImage(XFile image) async {
    const prompt =
      """
      Analisis gambar ini!
      Berikan nama dari motif batik yang ditemukan
      dan berikan filosofi dari batiknya.
      Balas HANYA JSON valid dengan format:
      {"name":"...", "filosofi":"..."}
      Jika bukan motif batik:
      {"name":"Tidak ditemukan", "filosofi":""}
      """;

    final bytes = await image.readAsBytes();
    final mimeType = image.mimeType ?? 'image/jpeg';

    final response = await widget.model.generateContent([
      Content.text(prompt),
      Content.inlineData(mimeType, bytes),
    ]);

    final raw = (response.text ?? '{}').trim();

    try {
      final data = jsonDecode(raw) as Map<String, dynamic>;
      return {
        'name': (data['name'] ?? 'Tidak ditemukan').toString(),
        'filosofi': (data['filosofi'] ?? '').toString(),
      };
    } catch (_) {
      return {
        'name': 'Tidak ditemukan',
        'filosofi': '',
      };
    }
  }

  Future<String> _uploadImage(XFile image) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final imageName = '${timestamp}_${image.name}';
    final ref = widget.storage.ref().child('user/$imageName');

    await ref.putFile(File(image.path));
    return ref.getDownloadURL();
  }

  Future<void> _showAnalysisAndAskSave({
    required XFile image,
    required Map<String, String> analysis }) async {
    if (!mounted) return;

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
                      child: Image.file(
                        File(image.path),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text('Nama motif: ${(analysis['name']?.isNotEmpty ?? false) ? analysis['name'] : '-'}'),
                  const SizedBox(height: 8),
                  Text('Filosofi: ${(analysis['filosofi']?.isNotEmpty ?? false) ? analysis['filosofi'] : '-'}'),
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
      final url = await _uploadImage(image);

      // [FUTURE] Simpan image path di database relasional

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tersimpan ke Firebase: $url')),
      );
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal proses foto: $e')),
        );
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gallery upload failed: $e')),
        );
      }
      return;
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
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
            heroTag: 'galleryBtn',
            onPressed: _isUploading ? null : pickFromGallery,
            child: const Icon(Icons.photo_library),
          ),
          const SizedBox(width: 16),
          FloatingActionButton(
            heroTag: 'cameraBtn',
            onPressed: _isUploading ? null : takePicture,
            child: const Icon(Icons.camera_alt),
          ),
        ],
      ),
    );
  }
}