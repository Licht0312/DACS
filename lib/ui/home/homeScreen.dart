import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:app_doan_nhandien/flower_classifier.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  CameraController? _controller;
  File? _capturedImage;
  String _recognitionResult = '';
  bool _isLoading = false;
  FlashMode _flashMode = FlashMode.off;
  bool _isCameraInitialized = false;
  bool _isProcessingImage = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        debugPrint('No cameras found');
        return;
      }

      _controller = CameraController(
        cameras.firstWhere(
              (camera) => camera.lensDirection == CameraLensDirection.back,
          orElse: () => cameras.first,
        ),
        ResolutionPreset.high,
      );

      await _controller!.initialize();
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

  Future<void> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final image = await _controller!.takePicture();
      _processImage(File(image.path));
    } catch (e) {
      debugPrint('Error taking picture: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImageFromGallery() async {
    if (_isProcessingImage) return;

    try {
      setState(() {
        _isProcessingImage = true;
        _isLoading = true;
      });

      // Giải phóng camera trước khi mở gallery
      if (_controller != null && _isCameraInitialized) {
        await _controller!.dispose();
        setState(() {
          _isCameraInitialized = false;
        });
      }

      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200, // Giới hạn kích thước ảnh
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        await _processImage(File(pickedFile.path));
      }
    } catch (e, stackTrace) {
      debugPrint('Error picking image: $e');
      debugPrint('Stack trace: $stackTrace');
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingImage = false;
          _isLoading = false;
        });
      }
      // Khởi tạo lại camera sau khi xử lý ảnh xong
      if (!_isCameraInitialized) {
        await _initializeCamera();
      }
    }
  }

  Future<void> _processImage(File image) async {
    setState(() {
      _capturedImage = image;
      _recognitionResult = '';
    });

    try {
      final results = await FlowerClassifier.classifyImage(image.path);

      if (mounted) {
        setState(() {
          // Kiểm tra kết quả theo nhiều cấp độ để tránh lỗi
          if (results != null && results is List && results.isNotEmpty) {
            // Kiểm tra cấu trúc object kết quả
            final firstResult = results[0];
            if (firstResult is Map && firstResult.containsKey('label')) {
              _recognitionResult = firstResult['label'].toString();
            } else {
              _recognitionResult = 'Kết quả không đúng định dạng';
            }
          } else {
            _recognitionResult = 'Không nhận diện được loại hoa';
          }
          _isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      debugPrint('Error processing image: $e');
      debugPrint('Stack trace: $stackTrace');

      if (mounted) {
        setState(() {
          // Phân loại lỗi cụ thể hơn
          if (e.toString().contains('timeout')) {
            _recognitionResult = 'Lỗi: Quá thời gian xử lý';
          } else if (e.toString().contains('connection')) {
            _recognitionResult = 'Lỗi kết nối';
          } else {
            _recognitionResult = 'Lỗi khi xử lý ảnh: ${e.toString().split(':').first}';
          }
          _isLoading = false;
        });
      }
    }
  }

  void _toggleFlash() {
    if (_controller == null || !_controller!.value.isInitialized) return;

    setState(() {
      _flashMode = _flashMode == FlashMode.off ? FlashMode.torch : FlashMode.off;
      _controller!.setFlashMode(_flashMode);
    });
  }

  IconData _getFlashIcon() {
    return _flashMode == FlashMode.torch ? Icons.flash_on : Icons.flash_off;
  }

  Widget _buildCameraPreview() {
    if (!_isCameraInitialized) {
      return Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              Text(
                'Đang khởi tạo camera...',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              TextButton(
                onPressed: _initializeCamera,
                child: const Text('Thử lại'),
              )
            ]),
      );
    }

    if (_capturedImage != null) {
      return Stack(
        children: [
          Positioned.fill(
            child: Image.file(
              _capturedImage!,
              fit: BoxFit.cover,
            ),
          ),
          if (_recognitionResult.isNotEmpty)
            Positioned(
              bottom: 150,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                color: Colors.black54,
                child: Text(
                  'Kết quả: $_recognitionResult',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      );
    }

    return CameraPreview(_controller!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nhận diện hoa'),
        actions: [
          IconButton(
            icon: const Icon(Icons.photo_library),
            onPressed: _pickImageFromGallery,
            tooltip: 'Chọn ảnh từ thư viện',
          ),
        ],
      ),
      body: Stack(
        children: [
          _buildCameraPreview(),
          if (_isLoading)
            const Center(child: CircularProgressIndicator()),
          // Đặt nút ở góc dưới giữa màn hình
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton(
                  heroTag: 'flash',
                  onPressed: _toggleFlash,
                  child: Icon(_getFlashIcon()),
                  tooltip: 'Bật/Tắt đèn flash',
                ),
                const SizedBox(width: 40),
                FloatingActionButton(
                  heroTag: 'capture',
                  onPressed: _takePicture,
                  child: const Icon(Icons.camera_alt),
                  tooltip: 'Chụp ảnh',
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0, // Vị trí mặc định là Trang chủ
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Trang chủ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Tra cứu',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Cài đặt',
          ),
        ],
        onTap: (index) {
          // Thêm điều hướng sang các trang khác nếu cần

          if (index == 1) {
            Navigator.pushNamed(context, '/lookup');
          } else if (index == 2) {
            Navigator.pushNamed(context, '/settings');
          }
        },
      ),
    );
  }
}