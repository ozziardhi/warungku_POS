import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/services/printer_service.dart';
import '../../../core/widgets/app_drawer.dart';
import '../../../data/models/transaction_model.dart';
import '../cubit/pos_cubit.dart';

class HomePosPage extends StatelessWidget {
  const HomePosPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Warungku',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.headline,
        foregroundColor: AppColors.buttonText,
      ),
      drawer: const AppDrawer(currentRoute: 'pos'),
      body: SafeArea(
        top: false,
        left: false,
        right: false,
        bottom: true,
        child: Stack(
          children: [
            BlocBuilder<PosCubit, PosState>(
              builder: (context, state) {
                if (state.products.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 64,
                          color: AppColors.paragraph.withOpacity(0.5),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Belum ada stok barang aktif.\nBuka menu samping untuk menambah produk.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.paragraph,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 110),
                  itemCount: state.products.length,
                  itemBuilder: (context, index) {
                    final product = state.products[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: AppColors.buttonText,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.secondary,
                          width: 1.5,
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        title: Text(
                          product.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.headline,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            'Stok: ${product.stock} ${product.unit}  •  Kode: ${product.code}\n${currency.format(product.price)}',
                            style: const TextStyle(
                              color: AppColors.paragraph,
                              height: 1.3,
                            ),
                          ),
                        ),
                        trailing: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.buttonText,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: product.stock > 0
                              ? () =>
                                    context.read<PosCubit>().addToCart(product)
                              : null,
                          icon: const Icon(Icons.add_shopping_cart, size: 16),
                          label: const Text(
                            'Pilih',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            const Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: _FloatingCartBar(),
            ),
          ],
        ),
      ),
    );
  }
}

class _FloatingCartBar extends StatelessWidget {
  const _FloatingCartBar();

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return BlocBuilder<PosCubit, PosState>(
      builder: (context, state) {
        if (state.cart.isEmpty) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.headline,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: AppColors.headline.withOpacity(0.25),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${state.totalItemCount} Item Terpilih',
                    style: const TextStyle(
                      color: AppColors.secondary,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    currency.format(state.totalPrice),
                    style: const TextStyle(
                      color: AppColors.buttonText,
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.buttonText,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => _showCartSheet(context),
                child: const Text(
                  'Lihat Keranjang',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCartSheet(BuildContext context) {
    final cubit = context.read<PosCubit>();
    final currency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return BlocProvider.value(
          value: cubit,
          child: BlocBuilder<PosCubit, PosState>(
            builder: (context, state) {
              return SafeArea(
                top: false,
                left: false,
                right: false,
                bottom: true,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  height: MediaQuery.of(context).size.height * 0.75,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Detail Pesanan',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.headline,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: AppColors.tertiary,
                            ),
                            onPressed: () {
                              cubit.clearCart();
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                      const Divider(color: AppColors.secondary),
                      Expanded(
                        child: ListView(
                          children: state.cart.values.map((item) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.buttonText,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.secondary),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.headline,
                                          ),
                                        ),
                                        Text(
                                          '${currency.format(item.price)} x ${item.quantity}',
                                          style: const TextStyle(
                                            color: AppColors.paragraph,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.remove_circle_outline,
                                      color: AppColors.paragraph,
                                    ),
                                    onPressed: () =>
                                        cubit.removeFromCart(item.productId),
                                  ),
                                  Text(
                                    '${item.quantity}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.headline,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.add_circle_outline,
                                      color: AppColors.primary,
                                    ),
                                    onPressed: () {
                                      final prod = cubit.productBox.values
                                          .firstWhere(
                                            (p) => p.id == item.productId,
                                          );
                                      cubit.addToCart(prod);
                                    },
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const Divider(color: AppColors.secondary),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total Pembayaran',
                              style: TextStyle(
                                fontSize: 15,
                                color: AppColors.paragraph,
                              ),
                            ),
                            Text(
                              currency.format(state.totalPrice),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.headline,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.buttonText,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: state.cart.isEmpty
                              ? null
                              : () => _choosePaymentMethodDialog(
                                  context,
                                  cubit,
                                  state.totalPrice,
                                ),
                          child: const Text(
                            'Bayar / Selesaikan Pesanan',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _choosePaymentMethodDialog(
    BuildContext context,
    PosCubit cubit,
    double totalAmount,
  ) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Pilih Metode Pembayaran',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.headline,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(
                Icons.money_rounded,
                color: AppColors.primary,
                size: 32,
              ),
              title: const Text(
                'Tunai (Cash)',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.headline,
                ),
              ),
              subtitle: const Text(
                'Input uang diterima & hitung kembalian',
                style: TextStyle(color: AppColors.paragraph, fontSize: 12),
              ),
              tileColor: AppColors.buttonText,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: const BorderSide(color: AppColors.secondary),
              ),
              onTap: () {
                Navigator.pop(dialogCtx);
                _showCashPaymentDialog(context, cubit, totalAmount);
              },
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(
                Icons.qr_code_scanner_rounded,
                color: AppColors.primary,
                size: 32,
              ),
              title: const Text(
                'QRIS',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.headline,
                ),
              ),
              subtitle: const Text(
                'Tampilkan barcode QRIS pembayaran',
                style: TextStyle(color: AppColors.paragraph, fontSize: 12),
              ),
              tileColor: AppColors.buttonText,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: const BorderSide(color: AppColors.secondary),
              ),
              onTap: () {
                Navigator.pop(dialogCtx);
                _showQrisPaymentDialog(context, cubit, totalAmount);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showCashPaymentDialog(
    BuildContext context,
    PosCubit cubit,
    double totalAmount,
  ) {
    final currency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final cashCtrl = TextEditingController();
    String? errorText;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dCtx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: AppColors.background,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              'Pembayaran Tunai (Cash)',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.headline,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Tagihan: ${currency.format(totalAmount)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.headline,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: cashCtrl,
                  keyboardType: TextInputType.number,
                  autofocus: true,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    labelText: 'Nominal Uang Diterima (Rp)',
                    errorText: errorText,
                    filled: true,
                    fillColor: AppColors.buttonText,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.secondary),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dCtx),
                child: const Text(
                  'Batal',
                  style: TextStyle(color: AppColors.paragraph),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.buttonText,
                ),
                onPressed: () {
                  final cash = double.tryParse(cashCtrl.text) ?? 0.0;
                  if (cash < totalAmount) {
                    setDialogState(() {
                      errorText = 'Nominal uang kurang!';
                    });
                    return;
                  }

                  final change = cash - totalAmount;
                  final lastTrx = cubit.checkout(
                    paymentMethod: 'CASH',
                    cashPaid: cash,
                    change: change,
                  );

                  Navigator.pop(dCtx);
                  Navigator.pop(context);

                  if (lastTrx != null) {
                    _showSuccessReceiptDialog(
                      context,
                      'CASH',
                      totalAmount,
                      change,
                      lastTrx,
                    );
                  }
                },
                child: const Text('Verifikasi & Bayar'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showQrisPaymentDialog(
    BuildContext context,
    PosCubit cubit,
    double totalAmount,
  ) async {
    final currency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final prefs = await SharedPreferences.getInstance();
    final qrisImagePath = prefs.getString('qris_image_path');

    if (!context.mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dCtx) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Center(
          child: Text(
            'Scan QRIS',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.headline,
            ),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Tagihan: ${currency.format(totalAmount)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColors.headline,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.buttonText,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.secondary, width: 2),
              ),
              child: qrisImagePath != null && File(qrisImagePath).existsSync()
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(qrisImagePath),
                        height: 200,
                        width: 200,
                        fit: BoxFit.contain,
                      ),
                    )
                  : const Column(
                      children: [
                        Icon(
                          Icons.qr_code_2_rounded,
                          size: 180,
                          color: AppColors.headline,
                        ),
                        SizedBox(height: 6),
                        Text(
                          'NMID: ID1020030040506',
                          style: TextStyle(
                            color: AppColors.paragraph,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Arahkan pelanggan scan QRIS diatas',
              style: TextStyle(color: AppColors.paragraph, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dCtx),
            child: const Text(
              'Batal',
              style: TextStyle(color: AppColors.tertiary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.buttonText,
            ),
            onPressed: () {
              final lastTrx = cubit.checkout(
                paymentMethod: 'QRIS',
                cashPaid: totalAmount,
                change: 0.0,
              );

              Navigator.pop(dCtx);
              Navigator.pop(context);

              if (lastTrx != null) {
                _showSuccessReceiptDialog(
                  context,
                  'QRIS',
                  totalAmount,
                  0.0,
                  lastTrx,
                );
              }
            },
            child: const Text('OK / Sudah Bayar'),
          ),
        ],
      ),
    );
  }

  void _showSuccessReceiptDialog(
    BuildContext context,
    String method,
    double totalAmount,
    double change,
    TransactionModel lastTransaction,
  ) {
    final currency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Column(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.green, size: 54),
            SizedBox(height: 8),
            Text(
              'Pembayaran Berhasil',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.headline,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Metode: $method',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.paragraph,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Total: ${currency.format(totalAmount)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColors.headline,
              ),
            ),
            if (change > 0) ...[
              const Divider(color: AppColors.secondary, height: 24),
              const Text(
                'Kembalian Pelanggan:',
                style: TextStyle(color: AppColors.paragraph, fontSize: 13),
              ),
              const SizedBox(height: 2),
              Text(
                currency.format(change),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ],
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.headline,
                    side: const BorderSide(color: AppColors.secondary),
                  ),
                  icon: const Icon(Icons.print_rounded, size: 18),
                  label: const Text('Cetak Struk'),
                  onPressed: () async {
                    final success = await PrinterService.printReceipt(
                      lastTransaction,
                    );
                    if (!success && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Printer belum terhubung! Buka Pengaturan.',
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.buttonText,
                  ),
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Selesai'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
