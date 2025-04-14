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
  bool _isCameraInitialized = false;
  bool _isProcessing = false;

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
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      _cameraController?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      if (_cameraController != null) {
        _initializeCamera();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        debugPrint('No cameras found');
        return;
      }

      _cameraController = CameraController(
        cameras.firstWhere(
              (camera) => camera.lensDirection == CameraLensDirection.back,
          orElse: () => cameras.first,
        ),
        ResolutionPreset.high,
      );

      await _cameraController!.initialize();

      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Camera initialization error: $e');
      if (mounted) {
        setState(() {
          _isCameraInitialized = false;
        });
      }
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
      setState(() {
        _isProcessing = true;
      });

      final image = await _cameraController!.takePicture();
      _processImage(File(image.path));
    } catch (e) {
      debugPrint('Error taking picture: $e');
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _processImage(File image) async {
    setState(() {
      _image = image;
      _showPreview = true;
      _result = '';
    });

    try {
      // Gọi AI nhận diện
      final result = await FlowerClassifier.classifyImage(image.path);
      if (mounted) {
        setState(() {
          _result = result != null && result.isNotEmpty
              ? result[0]['label']
              : 'Không nhận diện được loại hoa';
          _isProcessing = false;
        });
      }
    } catch (e) {
      debugPrint('Error processing image: $e');
      if (mounted) {
        setState(() {
          _result = 'Lỗi khi xử lý ảnh';
          _isProcessing = false;
        });
      }
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

  Widget _buildCameraPreview() {
    if (!_isCameraInitialized) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Đang khởi tạo camera...'),
          ],
        ),
      );
    }

    if (_showPreview && _image != null) {
      return Stack(
        children: [
          Center(
            child: Image.file(
              _image!,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          if (_isProcessing)
            const Center(child: CircularProgressIndicator()),
        ],
      );
    }

    return Stack(
      children: [
        CameraPreview(_cameraController!),
        if (_isProcessing)
          const Center(child: CircularProgressIndicator()),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nhận diện hoa'),
        actions: [
          if (_currentIndex == 0 && !_showPreview)
            IconButton(
              icon: const Icon(Icons.photo_library),
              onPressed: _pickImage,
            ),
        ],
      ),
      body: _currentIndex == 0 ? _buildCameraPreview() : _screens[_currentIndex],
      floatingActionButton: _currentIndex == 0
          ? Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (!_showPreview)
            FloatingActionButton(
              heroTag: 'flash',
              onPressed: _toggleFlash,
              child: Icon(_getFlashIcon()),
            ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'capture',
            onPressed: _showPreview ? _backToCamera : _takePicture,
            child: Icon(_showPreview ? Icons.refresh : Icons.camera),
          ),
        ],
      )
          : null,
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