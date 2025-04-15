import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
//import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  bool _notificationsEnabled = true;
  String _selectedLanguage = 'Tiếng Việt';
  bool _darkModeEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications') ?? true;
      _selectedLanguage = prefs.getString('language') ?? 'Tiếng Việt';
      _darkModeEnabled = prefs.getBool('darkMode') ?? false;
    });
  }

  Future<void> _saveNotificationSetting(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications', value);
    setState(() {
      _notificationsEnabled = value;
    });
  }

  Future<void> _changeLanguage() async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Chọn ngôn ngữ'),
        children: [
          RadioListTile(
            title: const Text('Tiếng Việt'),
            value: 'Tiếng Việt',
            groupValue: _selectedLanguage,
            onChanged: (value) => Navigator.pop(context, value),
          ),
          RadioListTile(
            title: const Text('English'),
            value: 'English',
            groupValue: _selectedLanguage,
            onChanged: (value) => Navigator.pop(context, value),
          ),
        ],
      ),
    );

    if (result != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('language', result);
      setState(() {
        _selectedLanguage = result;
      });
      // Cần restart app để áp dụng ngôn ngữ mới
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Khởi động lại ứng dụng để áp dụng ngôn ngữ mới'),
        ),
      );
    }
  }

  Future<void> _launchHelpURL() async {
    const url = 'https://help.nhandienhoa.com';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể mở trang trợ giúp')),
      );
    }
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'Nhận Diện Hoa',
      applicationVersion: '1.0.0',
      applicationIcon: const FlutterLogo(),
      children: [
        const Text('Ứng dụng nhận diện các loài hoa bằng AI'),
        const SizedBox(height: 16),
        const Text('Tác giả: Your Name'),
        Text('Ngôn ngữ: $_selectedLanguage'),
      ],
    );
  }

  Future<void> _toggleDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', value);
    setState(() {
      _darkModeEnabled = value;
    });
    // Cần restart app hoặc sử dụng Provider/Bloc để áp dụng theme
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt'),
      ),
      body: ListView(
        children: [
          // Cài đặt thông báo
          SwitchListTile(
            title: const Text('Thông báo'),
            subtitle: const Text('Bật/tắt thông báo từ ứng dụng'),
            secondary: const Icon(Icons.notifications),
            value: _notificationsEnabled,
            onChanged: _saveNotificationSetting,
          ),

          // Ngôn ngữ
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Ngôn ngữ'),
            subtitle: Text(_selectedLanguage),
            trailing: const Icon(Icons.chevron_right),
            onTap: _changeLanguage,
          ),

          // Chế độ tối
          SwitchListTile(
            title: const Text('Chế độ tối'),
            subtitle: const Text('Giao diện tối cho ứng dụng'),
            secondary: const Icon(Icons.dark_mode),
            value: _darkModeEnabled,
            onChanged: _toggleDarkMode,
          ),

          const Divider(),

          // Xóa cache
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text('Xóa dữ liệu cache'),
            subtitle: const Text('Giải phóng bộ nhớ ứng dụng'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Xác nhận'),
                  content: const Text('Bạn có chắc muốn xóa dữ liệu cache?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Hủy'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Xóa'),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                // Xử lý xóa cache ở đây
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã xóa dữ liệu cache')),
                );
              }
            },
          ),

          // Trợ giúp
          ListTile(
            leading: const Icon(Icons.help, color: Colors.blue),
            title: const Text('Trợ giúp'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _launchHelpURL,
          ),

          // Về ứng dụng
          ListTile(
            leading: const Icon(Icons.info, color: Colors.blue),
            title: const Text('Về ứng dụng'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _showAboutDialog,
          ),

          // Chia sẻ ứng dụng
          ListTile(
            leading: const Icon(Icons.share, color: Colors.green),
            title: const Text('Chia sẻ ứng dụng'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Chia sẻ ứng dụng
              Share.share(
                'Hãy thử ứng dụng Nhận Diện Hoa: https://play.google.com/store/apps/details?id=com.example.nhandienhoa',
              );
            },
          ),
        ],
      ),
    );
  }
}