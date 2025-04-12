import 'package:tflite/tflite.dart';

class FlowerClassifier {
  // Load model một lần khi ứng dụng khởi chạy
  static Future<void> loadModel() async {
    await Tflite.loadModel(
      model: "assets/flower_model.tflite",  // Đảm bảo đường dẫn đúng
      labels: "assets/labels.txt",  // Đảm bảo bạn có file labels.txt nếu cần
    );
  }

  // Phương thức phân loại ảnh
  static Future<List?> classifyImage(String imagePath) async {
    return await Tflite.runModelOnImage(
      path: imagePath,
      imageMean: 127.5,
      imageStd: 127.5,
      numResults: 5,  // Số kết quả cần trả về
      threshold: 0.5,  // Ngưỡng độ chính xác
    );
  }

  // Giải phóng tài nguyên khi không sử dụng mô hình
  static void disposeModel() {
    Tflite.close();
  }
}
