import 'package:flutter/material.dart';
import 'flower_data.dart';
import 'package:app_doan_nhandien/ui/lookup/lib/model/flower.dart';

class LookupScreen extends StatelessWidget {
  const LookupScreen({super.key});

  void _showFlowerDetails(BuildContext context, Flower flower) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(flower.name),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (flower.imageUrls.isNotEmpty)
                  Image.network(flower.imageUrls.first),
                Text("Tên khoa học: ${flower.scientificName}"),
                Text("Loài: ${flower.genus}"),
                Text("Màu sắc: ${flower.color}"),
                Text("Mùa nở: ${flower.bloomingSeason}"),
                Text("Mô tả: ${flower.description}"),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("Đóng"),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lịch sử nhận diện')),
      body: ListView.builder(
        itemCount: flowerData.length,
        itemBuilder: (context, index) {
          final flower = flowerData[index];
          return ListTile(
            leading: flower.imageUrls.isNotEmpty
                ? Image.network(flower.imageUrls.first)
                : const Icon(Icons.local_florist),
            title: Text(flower.name),
            onTap: () => _showFlowerDetails(context, flower),
          );
        },
      ),
    );
  }
}
