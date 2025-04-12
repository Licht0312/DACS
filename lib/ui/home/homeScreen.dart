import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:app_doan_nhandien/flower_classifier.dart';
import 'package:app_doan_nhandien/ui/lookup/lookupScreen.dart'; // Đảm bảo đã import đúng
import 'package:app_doan_nhandien/ui/setting/settingScreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  File? _image;
  String _result = '';

  final List<Widget> _screens = [
    const Center(child: Text("Trang chủ")), // Placeholder cho tab 0
    const LookupScreen(), // Thêm trang Tra cứu vào đây
    const SettingScreen(), // Trang Cài đặt
  ];

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _image = File(picked.path);
        _result = '';
      });
      _classifyImage(File(picked.path));
    }
  }

  Future<void> _classifyImage(File image) async {
    final result = await FlowerClassifier.classifyImage(image.path);
    if (result != null && result.isNotEmpty) {
      setState(() {
        _result = result[0]['label'];
      });
    } else {
      setState(() {
        _result = 'Dữ liệu chưa có trên hệ thống';
      });
    }
  }

  // Hàm chụp ảnh từ camera
  Future<void> _takePicture() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.camera);
    if (picked != null) {
      setState(() {
        _image = File(picked.path);
        _result = '';
      });
      _classifyImage(File(picked.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trang chủ')),
      body: _currentIndex == 0
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_image != null)
              Image.file(_image!, height: 200, fit: BoxFit.cover)
            else
              const Icon(Icons.image, size: 100, color: Colors.grey),
            const SizedBox(height: 16),
            if (_result.isNotEmpty)
              Text("Kết quả: $_result", style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.upload),
              label: const Text('Chọn ảnh từ thư viện'),
              onPressed: _pickImage,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.camera_alt),
              label: const Text('Chụp ảnh'),
              onPressed: _takePicture,
            ),
          ],
        ),
      )
          : _screens[_currentIndex], // Hiển thị các trang khác theo index
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Tra cứu'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Cài đặt'),
        ],
      ),
    );
  }
}
