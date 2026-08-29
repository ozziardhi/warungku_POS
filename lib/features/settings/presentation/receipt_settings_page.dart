import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_colors.dart';

class ReceiptSettingsPage extends StatefulWidget {
  const ReceiptSettingsPage({super.key});

  @override
  State<ReceiptSettingsPage> createState() => _ReceiptSettingsPageState();
}

class _ReceiptSettingsPageState extends State<ReceiptSettingsPage> {
  final _storeNameCtrl = TextEditingController();
  final _storeAddressCtrl = TextEditingController();
  final _storeFooterCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _storeNameCtrl.dispose();
    _storeAddressCtrl.dispose();
    _storeFooterCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _storeNameCtrl.text = prefs.getString('store_name') ?? 'Warungku';
      _storeAddressCtrl.text =
          prefs.getString('store_address') ?? 'Bekasi, Jawa Barat';
      _storeFooterCtrl.text =
          prefs.getString('store_footer') ?? 'Terima Kasih Telah Berbelanja!';
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('store_name', _storeNameCtrl.text.trim());
    await prefs.setString('store_address', _storeAddressCtrl.text.trim());
    await prefs.setString('store_footer', _storeFooterCtrl.text.trim());

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.headline,
          content: Text('Format struk berhasil disimpan!'),
        ),
      );
    }
  }

  InputDecoration _inputDecor(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.paragraph),
      filled: true,
      fillColor: AppColors.buttonText,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.secondary),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.secondary, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Format & Desain Struk',
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
            TextField(
              controller: _storeNameCtrl,
              decoration: _inputDecor('Nama Toko / Warung'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _storeAddressCtrl,
              decoration: _inputDecor('Alamat / Kontak Toko'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _storeFooterCtrl,
              decoration: _inputDecor('Pesan Footer Struk'),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.buttonText,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _saveSettings,
                icon: const Icon(Icons.save_rounded),
                label: const Text(
                  'Simpan Pengaturan Struk',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
