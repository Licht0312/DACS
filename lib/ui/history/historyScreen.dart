import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch sử nhận diện'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt),
            onPressed: () {}, // Thêm chức năng lọc
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: 10, // Số lượng item demo
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage("null"),
              ),
              title: Text('Hoa hồng #${index + 1}'),
              subtitle: const Text('Nhận diện ngày 12/05/2024'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {}, // Xem chi tiết
            ),
          );
        },
      ),
    );
  }
}