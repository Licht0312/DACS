import 'package:app_doan_nhandien/ui/home/homeScreen.dart';
import 'package:flutter/material.dart';
import 'flower_classifier.dart'; // import file AI
import 'dart:io';
import 'package:image_picker/image_picker.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await FlowerClassifier.loadModel(); // Tải mô hình AI
  } catch (e) {
    print("Lỗi khi tải mô hình: $e");
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NHẬN DIỆN HOA',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
        ),
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}