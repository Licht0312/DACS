import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'previewScreen.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  bool _isCameraReady = false;
  FlashMode _flashMode = FlashMode.off; // Chế độ flash mặc định là tắt

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  // Hàm khởi tạo camera
  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    _controller = CameraController(
      cameras.first,
      ResolutionPreset.medium,
    );

    await _controller.initialize();
    if (mounted) {
      setState(() => _isCameraReady = true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Hàm chuyển đổi chế độ flash
  void _toggleFlashMode() {
    setState(() {
      if (_flashMode == FlashMode.off) {
        _flashMode = FlashMode.auto; // Chuyển sang chế độ tự động
      } else if (_flashMode == FlashMode.auto) {
        _flashMode = FlashMode.torch; // Chuyển sang chế độ bật
      } else {
        _flashMode = FlashMode.off; // Chuyển sang chế độ tắt
      }
    });

    // Áp dụng chế độ flash cho camera
    _controller.setFlashMode(_flashMode);
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraReady) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chụp ảnh hoa'),
        actions: [
          IconButton(
            icon: Icon(
              _flashMode == FlashMode.off
                  ? Icons.flash_off
                  : _flashMode == FlashMode.auto
                  ? Icons.flash_auto
                  : Icons.flash_on,
            ),
            onPressed: _toggleFlashMode, // Chuyển đổi chế độ flash
          ),
        ],
      ),
      body: Stack(
        children: [
          CameraPreview(_controller),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: FloatingActionButton(
                backgroundColor: Colors.green,
                onPressed: () async {
                  try {
                    if (!_controller.value.isInitialized) return;

                    final image = await _controller.takePicture();

                    if (!mounted) return;

                    // Chuyển sang màn hình hiển thị ảnh để chuẩn bị scan
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PreviewScreen(imagePath: image.path),
                      ),
                    );
                  } catch (e) {
                    print('Lỗi khi chụp ảnh: $e');
                  }
                }, // Chức năng chụp ảnh
                child: const Icon(Icons.camera, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
