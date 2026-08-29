import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_drawer.dart';
import 'printer_settings_page.dart';
import 'qris_settings_page.dart';
import 'receipt_settings_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Pengaturan',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.headline,
        foregroundColor: AppColors.buttonText,
      ),
      drawer: const AppDrawer(currentRoute: 'settings'),
      body: SafeArea(
        top: false,
        left: false,
        right: false,
        bottom: true,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSettingTile(
              context,
              icon: Icons.qr_code_2_rounded,
              title: 'Pengaturan QRIS Toko',
              subtitle: 'Upload dan perbarui foto barcode QRIS pembayaran',
              destination: const QrisSettingsPage(),
            ),
            const SizedBox(height: 12),
            _buildSettingTile(
              context,
              icon: Icons.receipt_rounded,
              title: 'Format & Desain Struk',
              subtitle: 'Ubah nama toko, alamat, dan pesan footer struk',
              destination: const ReceiptSettingsPage(),
            ),
            const SizedBox(height: 12),
            _buildSettingTile(
              context,
              icon: Icons.print_rounded,
              title: 'Koneksi Printer Bluetooth',
              subtitle: 'Hubungkan printer thermal kasir & tes cetak struk',
              destination: const PrinterSettingsPage(),
            ),
            const SizedBox(height: 12),
            _buildSettingTile(
              context,
              icon: Icons.import_export_rounded,
              title: 'Ekspor & Impor Data Barang',
              subtitle: 'Cadangkan (backup) atau pulihkan data dagangan',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Menu Ekspor & Impor akan segera hadir.'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? destination,
    VoidCallback? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.buttonText,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.secondary, width: 1.5),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.secondary.withOpacity(0.5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 26),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: AppColors.headline,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            subtitle,
            style: const TextStyle(color: AppColors.paragraph, fontSize: 12),
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios_rounded,
          size: 16,
          color: AppColors.paragraph,
        ),
        onTap:
            onTap ??
            () {
              if (destination != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => destination),
                );
              }
            },
      ),
    );
  }
}
