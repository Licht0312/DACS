import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:app_doan_nhandien/flower_classifier.dart';
import 'package:app_doan_nhandien/ui/lookup/lookupScreen.dart';
import 'package:app_doan_nhandien/ui/setting/settingScreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  int _currentIndex = 0;
  File? _image;
  String _result = '';
  CameraController? _cameraController;
  FlashMode _flashMode = FlashMode.off;
  bool _showPreview = false;

  final List<Widget> _screens = [
    const SizedBox(), // Placeholder, sẽ thay bằng camera view
    const LookupScreen(),
    const SettingScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    if (cameras.isNotEmpty) {
      _cameraController = CameraController(
        cameras.first,
        ResolutionPreset.high,
      );
      await _cameraController!.initialize();
      if (mounted) setState(() {});
    }
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      _processImage(File(picked.path));
    }
  }

  Future<void> _takePicture() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      final image = await _cameraController!.takePicture();
      _processImage(File(image.path));
    } catch (e) {
      debugPrint('Error taking picture: $e');
    }
  }

  Future<void> _processImage(File image) async {
    setState(() {
      _image = image;
      _showPreview = true;
      _result = '';
    });

    // Gọi AI nhận diện
    final result = await FlowerClassifier.classifyImage(image.path);
    if (mounted) {
      setState(() {
        _result = result != null && result.isNotEmpty
            ? result[0]['label']
            : 'Dữ liệu chưa có trên hệ thống';
      });
    }
  }

  void _toggleFlash() {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    setState(() {
      // Chuyển đổi giữa 3 chế độ flash
      switch (_flashMode) {
        case FlashMode.off:
          _flashMode = FlashMode.auto;
          break;
        case FlashMode.auto:
          _flashMode = FlashMode.torch;
          break;
        case FlashMode.torch:
          _flashMode = FlashMode.off;
          break;
        default:
          _flashMode = FlashMode.off;
      }

      _cameraController!.setFlashMode(_flashMode);
    });
  }

  void _backToCamera() {
    setState(() {
      _showPreview = false;
      _image = null;
      _result = '';
    });
  }

  IconData _getFlashIcon() {
    switch (_flashMode) {
      case FlashMode.off:
        return Icons.flash_off;
      case FlashMode.auto:
        return Icons.flash_auto;
      case FlashMode.torch:
        return Icons.flash_on;
      default:
        return Icons.flash_off;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nhận diện hoa')),
      body: _currentIndex == 0
          ? Stack(
        children: [
          // Hiển thị camera hoặc ảnh preview
          if (!_showPreview && _cameraController != null && _cameraController!.value.isInitialized)
            CameraPreview(_cameraController!)
          else if (_image != null)
            Center(
              child: Image.file(
                _image!,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            )
          else
            const Center(child: CircularProgressIndicator()),

          // Kết quả nhận diện
          if (_result.isNotEmpty)
            Positioned(
              top: 20,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(10),
                color: Colors.black54,
                child: Text(
                  "Kết quả: $_result",
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

          // Nút quay lại camera (khi đang xem preview)
          if (_showPreview)
            Positioned(
              top: 20,
              left: 20,
              child: FloatingActionButton(
                heroTag: 'back',
                mini: true,
                onPressed: _backToCamera,
                child: const Icon(Icons.arrow_back),
              ),
            ),

          // Các nút điều khiển
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Nút chọn ảnh từ thư viện
                if (!_showPreview)
                  FloatingActionButton(
                    heroTag: 'gallery',
                    onPressed: _pickImage,
                    child: const Icon(Icons.photo_library),
                  ),

                // Nút chụp ảnh hoặc chụp lại
                FloatingActionButton(
                  heroTag: 'capture',
                  onPressed: _showPreview ? _backToCamera : _takePicture,
                  child: Icon(_showPreview ? Icons.camera_alt : Icons.camera),
                ),

                // Nút bật/tắt đèn flash (chỉ hiện khi không ở chế độ preview)
                if (!_showPreview)
                  FloatingActionButton(
                    heroTag: 'flash',
                    onPressed: _toggleFlash,
                    child: Icon(_getFlashIcon()),
                  ),
              ],
            ),
          ),
        ],
      )
          : _screens[_currentIndex],
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