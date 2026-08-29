import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_colors.dart';

class QrisSettingsPage extends StatefulWidget {
  const QrisSettingsPage({super.key});

  @override
  State<QrisSettingsPage> createState() => _QrisSettingsPageState();
}

class _QrisSettingsPageState extends State<QrisSettingsPage> {
  String? _qrisImagePath;

  @override
  void initState() {
    super.initState();
    _loadQris();
  }

  Future<void> _loadQris() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _qrisImagePath = prefs.getString('qris_image_path');
    });
  }

  Future<void> _pickQrisImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('qris_image_path', pickedFile.path);

      setState(() {
        _qrisImagePath = pickedFile.path;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content: Text('Gambar QRIS berhasil disimpan!'),
          ),
        );
      }
    }
  }

  Future<void> _removeQrisImage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('qris_image_path');
    setState(() {
      _qrisImagePath = null;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.headline,
          content: Text('Gambar QRIS dikembalikan ke default'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Pengaturan QRIS',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.headline,
        foregroundColor: AppColors.buttonText,
      ),
      body: SafeArea(
        top: false,
        left: false,
        right: false,
        bottom: true,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.buttonText,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.secondary, width: 1.5),
              ),
              child: Column(
                children: [
                  Container(
                    height: 260,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.secondary),
                    ),
                    child:
                        _qrisImagePath != null &&
                            File(_qrisImagePath!).existsSync()
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(
                              File(_qrisImagePath!),
                              fit: BoxFit.contain,
                            ),
                          )
                        : const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.qr_code_2_rounded,
                                size: 90,
                                color: AppColors.paragraph,
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Belum ada gambar QRIS kustom',
                                style: TextStyle(
                                  color: AppColors.paragraph,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.buttonText,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: _pickQrisImage,
                          icon: const Icon(Icons.upload_file_rounded, size: 20),
                          label: Text(
                            _qrisImagePath == null
                                ? 'Upload Gambar QRIS'
                                : 'Ganti Gambar QRIS',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      if (_qrisImagePath != null) ...[
                        const SizedBox(width: 8),
                        IconButton(
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.red.shade50,
                            foregroundColor: AppColors.tertiary,
                            padding: const EdgeInsets.all(12),
                          ),
                          onPressed: _removeQrisImage,
                          icon: const Icon(Icons.delete_outline_rounded),
                          tooltip: 'Hapus Gambar QRIS',
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '* Gambar QRIS ini akan otomatis ditampilkan saat kasir memilih metode pembayaran QRIS.',
              style: TextStyle(
                color: AppColors.paragraph,
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
