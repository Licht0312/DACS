import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_doan_nhandien/ui/home/homeScreen.dart';
import 'package:app_doan_nhandien/ui/lookup/lookupScreen.dart';
import 'package:app_doan_nhandien/ui/setting/settingScreen.dart';
import 'flower_classifier.dart'; // import file AI
import 'package:tflite_flutter/tflite_flutter.dart';

// Theme Provider
class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  void toggleTheme(bool isDarkMode) {
    _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  print('Initializing model...');
  try {
    await FlowerClassifier.loadModel(); // Tải mô hình AI
  } catch (e) {
    print("Lỗi khi tải mô hình: $e");
  }

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

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
      darkTheme: ThemeData.dark(useMaterial3: true),
      themeMode: themeProvider.themeMode,
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
