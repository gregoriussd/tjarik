import 'package:firebase_ai/firebase_ai.dart';
import 'package:tjarik/screens/dashboard.dart';
import 'package:tjarik/screens/profile.dart';
import 'package:tjarik/screens/login.dart';
import 'package:tjarik/screens/register.dart';
import 'package:tjarik/screens/camera_preview.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'firebase_options.dart';
import 'package:camera/camera.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final cameras = await availableCameras();
  final firstCamera = cameras.first;
  final storage = FirebaseStorage.instance;
  final model = FirebaseAI.googleAI().generativeModel(
    model: 'gemini-2.5-flash',
    generationConfig: GenerationConfig(
      responseMimeType: 'application/json',
      responseSchema: Schema.object(
        properties: {
          'name': Schema.string(),
          'filosofi': Schema.string(),
        },
        optionalProperties: const [],
        propertyOrdering: const ['name', 'filosofi'],
      ),
      temperature: 0.2,
    ),
  );

  runApp(MyApp(camera: firstCamera, storage: storage, model: model));
}

class MyApp extends StatelessWidget {
  final CameraDescription camera;
  final FirebaseStorage storage;
  final GenerativeModel model;

  const MyApp({super.key, required this.camera, required this.storage, required this.model});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(initialRoute: 'login', routes: {
      'home': (context) => DashboardScreen(storage: storage),
      'login': (context) => const LoginScreen(),
      'register': (context) => const RegisterScreen(),
      'camera': (context) => CameraPreviewScreen(camera: camera, storage: storage, model: model),
      'profile': (context) => const ProfileScreen(),
    });
  }
}