import 'dart:io';
import 'package:flutter/material.dart';

class PreviewScreen extends StatelessWidget {
  final String imagePath;

  const PreviewScreen({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Xem ảnh')),
      body: Column(
        children: [
          Expanded(child: Image.file(File(imagePath))),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.search),
              label: const Text('Nhận diện hoa'),
              onPressed: () {
                // TODO: Thêm xử lý AI tại đây
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đang xử lý ảnh...')),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
