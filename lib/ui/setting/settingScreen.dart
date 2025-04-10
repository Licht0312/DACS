import 'package:flutter/material.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt'),
      ),
      body: ListView(
        children: [
          const ListTile(
            leading: Icon(Icons.notifications),
            title: Text('Thông báo'),
            trailing: Icon(Icons.chevron_right),
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Ngôn ngữ'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {}, // Thay đổi ngôn ngữ
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.help, color: Colors.blue),
            title: const Text('Trợ giúp'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {}, // Mở trợ giúp
          ),
          ListTile(
            leading: const Icon(Icons.info, color: Colors.blue),
            title: const Text('Về ứng dụng'),
            trailing: const Icon(Icons.chevron_right),
            onTap: (

                ) {}, // Thông tin ứng dụng
          ),

        ],
      ),
    );
  }
}