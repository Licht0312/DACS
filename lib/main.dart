import 'package:flutter/material.dart';
import 'package:app_doan_nhandien/ui/home/homeScreen.dart';
import 'package:app_doan_nhandien/ui/lookup/lookupScreen.dart';
import 'package:app_doan_nhandien/ui/setting/settingScreen.dart';
import 'flower_classifier.dart'; // import file AI

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
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/lookup': (context) => const LookupScreen(),
        '/settings': (context) => const SettingScreen(),
      },
    );
  }
}
