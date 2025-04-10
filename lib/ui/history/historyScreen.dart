import 'package:flutter/material.dart';

// Lớp mô hình dữ liệu cho hoa
class Flower {
  final String name;
  final String scientificName;
  final String description;
  final List<String> imageUrls;
  final String genus;
  final String bloomingSeason;
  final String color;

  const Flower({ // Thêm const constructor
    required this.name,
    required this.scientificName,
    required this.description,
    required this.imageUrls,
    required this.genus,
    required this.bloomingSeason,
    required this.color,
  });
}

class HistoryScreen extends StatelessWidget {
   HistoryScreen({super.key});

  // Bỏ const ở đây vì List không phải là constant
  final List<Flower> flowers = [
    const Flower( // Thêm const cho từng Flower
      name: "Hoa hồng đỏ",
      scientificName: "Rosa rubiginosa",
      description: "Hoa hồng đỏ là biểu tượng của tình yêu và sự lãng mạn. Loài hoa này có nguồn gốc từ Châu Âu và Châu Á.",
      imageUrls: [
        "https://example.com/rose1.jpg",
        "https://example.com/rose2.jpg",
      ],
      genus: "Rosa",
      bloomingSeason: "Quanh năm",
      color: "Đỏ",
    ),
    const Flower( // Thêm const cho từng Flower
      name: "Hoa hồng vàng",
      scientificName: "Rosa foetida",
      description: "Hoa hồng vàng tượng trưng cho tình bạn và sự quan tâm. Chúng có mùi thơm nhẹ và thường nở vào mùa xuân.",
      imageUrls: [
        "https://example.com/yellow-rose1.jpg",
      ],
      genus: "Rosa",
      bloomingSeason: "Mùa xuân",
      color: "Vàng",
    ),
    // Thêm các loài hoa khác tại đây
  ];

  // Hàm hiển thị dialog thông tin hoa
   void _showFlowerDetails(BuildContext context, Flower flower) {
     showDialog(
       context: context,
       builder: (BuildContext dialogContext) {  // Đổi tên context thành dialogContext để rõ ràng
         return AlertDialog(
           title: Text(flower.name),
           content: SingleChildScrollView(
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               mainAxisSize: MainAxisSize.min,
               children: [
                if (flower.imageUrls.isNotEmpty)
                  Image.network(
                    flower.imageUrls.first,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.image_not_supported, size: 100),
                  ),
                const SizedBox(height: 10),
                Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(
                        text: "Tên khoa học: ",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: flower.scientificName),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(
                        text: "Loài: ",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: flower.genus),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(
                        text: "Màu sắc: ",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: flower.color),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(
                        text: "Mùa nở: ",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: flower.bloomingSeason),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Mô tả:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(flower.description),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Đóng', style: TextStyle(color: Colors.red)), // Thêm style cho rõ ràng
              onPressed: () {
                Navigator.pop(dialogContext); // Sử dụng dialogContext và pop đơn giản
                debugPrint('Dialog đã đóng');
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch sử nhận diện'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt),
            onPressed: () {
              // Thêm chức năng lọc
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: flowers.length,
        itemBuilder: (context, index) {
          final flower = flowers[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.grey[200],
                child: flower.imageUrls.isNotEmpty
                    ? Image.network(
                  flower.imageUrls.first,
                  errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.image_not_supported),
                )
                    : const Icon(Icons.local_florist),
              ),
              title: Text(flower.name),
              subtitle: const Text('Nhận diện ngày 12/05/2024'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showFlowerDetails(context, flower),
            ),
          );
        },
      ),
    );
  }
}