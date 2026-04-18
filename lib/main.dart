import 'package:ppb_midterm_project/screens/dashboard.dart';
import 'package:ppb_midterm_project/screens/profile.dart';
import 'package:ppb_midterm_project/screens/login.dart';
import 'package:ppb_midterm_project/screens/register.dart';
import 'package:ppb_midterm_project/screens/camera_preview.dart';
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

  runApp(MyApp(camera: firstCamera, storage: storage));
}

class MyApp extends StatelessWidget {
  final CameraDescription camera;
  final FirebaseStorage storage;

  const MyApp({super.key, required this.camera, required this.storage});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(initialRoute: 'login', routes: {
      'home': (context) => DashboardScreen(storage: storage),
      'login': (context) => const LoginScreen(),
      'register': (context) => const RegisterScreen(),
      'camera': (context) => CameraPreviewScreen(camera: camera, storage: storage),
      'profile': (context) => const ProfileScreen(),
    });
  }
}