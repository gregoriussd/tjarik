import 'package:ppb_midterm_project/screens/dashboard.dart';
import 'package:ppb_midterm_project/screens/profile.dart';
import 'package:ppb_midterm_project/screens/login.dart';
import 'package:ppb_midterm_project/screens/register.dart';
import 'package:ppb_midterm_project/screens/camera_preview.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:camera/camera.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final cameras = await availableCameras();
  final firstCamera = cameras.first;

  runApp(MyApp(camera: firstCamera));
}

class MyApp extends StatelessWidget {
  final CameraDescription camera;

  const MyApp({super.key, required this.camera});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(initialRoute: 'login', routes: {
      'home': (context) => const DashboardScreen(),
      'login': (context) => const LoginScreen(),
      'register': (context) => const RegisterScreen(),
      'camera': (context) => CameraPreviewScreen(camera: camera),
      'profile': (context) => const ProfileScreen(),
    });
  }
}