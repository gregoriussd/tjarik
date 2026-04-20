import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';

class CameraPreviewScreen extends StatefulWidget {
  final CameraDescription camera;
  final FirebaseStorage storage;

  const CameraPreviewScreen({super.key, required this.camera, required this.storage});

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

  Future<String> _uploadImage(XFile image) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final imageName = '${timestamp}_${image.name}';
    final ref = widget.storage.ref().child('user/$imageName');

    await ref.putFile(File(image.path));
    return ref.getDownloadURL();
  }

  Future<String> takePicture() async {
    if (_isUploading) return '';

    setState(() {
      _isUploading = true;
    });

    try {
      await _initializeControllerFuture;
      final image = await _controller.takePicture();
      final url = await _uploadImage(image);

      // [FUTURE] Simpan image path di database relasional

      // await Gal.putImage(image.path, album: 'flutter_access_device_app');

      if (!mounted) {
        return '';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Picture saved to Firebase Storage')),
      );

      return url; // For future use
    } catch (e) {
      if (mounted) {
        print('Error taking picture: $e');
      }
      return '';
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  Future<String> pickFromGallery() async {
    if (_isUploading) return '';

    setState(() => _isUploading = true);
    try {
      final image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
      );
      if (image == null) return '';

      final url = await _uploadImage(image);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image uploaded from gallery')),
        );
      }
      return url;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gallery upload failed: $e')),
        );
      }
      return '';
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
            onPressed: _isUploading ? null : () async => await pickFromGallery(),
            child: const Icon(Icons.photo_library),
          ),
          const SizedBox(width: 16),
          FloatingActionButton(
            heroTag: 'cameraBtn',
            onPressed: _isUploading ? null : () async => await takePicture(),
            child: const Icon(Icons.camera_alt),
          ),
        ],
      ),
    );
  }
}