import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class FlowerClassifier {
  static Interpreter? _interpreter;
  static List<String>? _labels;
  static bool isModelLoaded = false;

  static Future<void> loadModel() async {
    try {
      print('Đang tải mô hình TFLite...');
      // Tải mô hình từ assets
      _interpreter = await Interpreter.fromAsset('flower_model.tflite');
      // Tải nhãn từ assets
      _labels = await _loadLabels('assets/labels.txt');
      print('Tải mô hình và nhãn thành công');
      isModelLoaded = true;
    } catch (e, stackTrace) {
      print('Lỗi tải mô hình: $e');
      print('Stack trace: $stackTrace');
      isModelLoaded = false;
      throw Exception('Lỗi tải mô hình: $e');
    }
  }

  static Future<List<String>> _loadLabels(String path) async {
    final labelsData = await rootBundle.loadString(path);
    return labelsData.split('\n').where((line) => line.isNotEmpty).toList();
  }

  static Future<List<dynamic>?> classifyImage(String imagePath) async {
    if (!isModelLoaded || _interpreter == null || _labels == null) {
      print('Mô hình chưa được tải');
      return null;
    }

    try {
      // Đọc và tiền xử lý ảnh
      final image = img.decodeImage(File(imagePath).readAsBytesSync());
      if (image == null) {
        print('Không thể đọc ảnh');
        return null;
      }

      // Thay đổi kích thước ảnh (giả sử mô hình yêu cầu 224x224, điều chỉnh nếu cần)
      final resizedImage = img.copyResize(image, width: 224, height: 224);

      // Chuyển đổi ảnh thành mảng số
      final input = _preprocessImage(resizedImage);

      // Chuẩn bị mảng đầu ra
      // Giả sử mô hình trả về xác suất cho mỗi lớp (điều chỉnh dựa trên mô hình của bạn)
      final output = List<double>.filled(_labels!.length, 0).reshape(
          [1, _labels!.length]);

      // Chạy suy luận
      _interpreter!.run(input, output);

      // Xử lý kết quả
      final results = _postprocessOutput(
          output[0], numResults: 5, threshold: 0.5);
      print('Kết quả phân loại: $results');
      return results;
    } catch (e, stackTrace) {
      print('Lỗi trong quá trình phân loại: $e');
      print('Stack trace: $stackTrace');
      return null;
    }
  }

  static List<List<List<double>>> _preprocessImage(img.Image image) {
    // Chuyển đổi ảnh thành mảng [224, 224, 3] với các giá trị được chuẩn hóa
    final input = List.generate(
      224,
          (i) =>
          List.generate(
            224,
                (j) => List<double>.filled(3, 0),
          ),
    );

    for (var i = 0; i < 224; i++) {
      for (var j = 0; j < 224; j++) {
        final pixel = image.getPixel(j, i);
        // Chuẩn hóa: (pixel - mean) / std
        input[i][j][0] =
            ((pixel.r / 255.0) - 127.5 / 255.0) / (127.5 / 255.0); // R
        input[i][j][1] =
            ((pixel.g / 255.0) - 127.5 / 255.0) / (127.5 / 255.0); // G
        input[i][j][2] =
            ((pixel.b / 255.0) - 127.5 / 255.0) / (127.5 / 255.0); // B
      }
    }

    return input;
  }

  static List<String> _postprocessOutput(List<double> output,
      {int numResults = 5, double threshold = 0.1}) {
    final indexed = List.generate(output.length, (i) => MapEntry(i, output[i]));
    indexed.sort((a, b) => b.value.compareTo(a.value)); // Sắp giảm dần

    final results = <String>[];
    for (final entry in indexed.take(numResults)) {
      if (entry.value > threshold) {
        results.add(
            '${_labels![entry.key]}: ${(entry.value * 100).toStringAsFixed(
                2)}%');
      }
    }
    return results;
  }
}