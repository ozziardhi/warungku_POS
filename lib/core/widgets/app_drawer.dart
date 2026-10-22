import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../features/home_pos/presentation/home_pos_page.dart';
import '../../features/manage_product/presentation/product_list_page.dart';
import '../../features/reports/presentation/sales_report_page.dart';
import '../../features/settings/presentation/settings_page.dart';

class AppDrawer extends StatelessWidget {
  final String currentRoute;

  const AppDrawer({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.background,
      child: SafeArea(
        top: false,
        left: false,
        right: false,
        bottom: true,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 56, 20, 24),
              color: AppColors.headline,
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.storefront_rounded,
                    size: 44,
                    color: AppColors.secondary,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Warungku',
                    style: TextStyle(
                      color: AppColors.buttonText,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Point of Sale & Kasir Aneka Es',
                    style: TextStyle(color: AppColors.secondary, fontSize: 13),
                  ),
                ],
              ),
            ),
            ListTile(
              selected: currentRoute == 'pos',
              // ignore: deprecated_member_use
              selectedTileColor: AppColors.secondary.withValues(alpha: 0.5),
              leading: const Icon(
                Icons.point_of_sale_rounded,
                color: AppColors.primary,
              ),
              title: const Text(
                'Kasir / Menu Utama',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.headline,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                if (currentRoute != 'pos') {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const HomePosPage()),
                  );
                }
              },
            ),
            ListTile(
              selected: currentRoute == 'products',
              selectedTileColor: AppColors.secondary.withValues(alpha: 0.5),
              leading: const Icon(
                Icons.inventory_2_rounded,
                color: AppColors.primary,
              ),
              title: const Text(
                'Data Barang',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.headline,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                if (currentRoute != 'products') {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const ProductListPage()),
                  );
                }
              },
            ),
            ListTile(
              selected: currentRoute == 'reports',
              selectedTileColor: AppColors.secondary.withValues(alpha: 0.5),
              leading: const Icon(
                Icons.receipt_long_rounded,
                color: AppColors.primary,
              ),
              title: const Text(
                'Laporan Penjualan',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.headline,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                if (currentRoute != 'reports') {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const SalesReportPage()),
                  );
                }
              },
            ),
            ListTile(
              selected: currentRoute == 'settings',
              selectedTileColor: AppColors.secondary.withValues(alpha: 0.5),
              leading: const Icon(
                Icons.settings_rounded,
                color: AppColors.primary,
              ),
              title: const Text(
                'Pengaturan',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.headline,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                if (currentRoute != 'settings') {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const SettingsPage()),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
