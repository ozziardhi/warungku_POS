import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_drawer.dart';
import '../../../data/models/product_model.dart';
import '../../../data/models/transaction_model.dart';
import '../../home_pos/cubit/pos_cubit.dart';

class SalesReportPage extends StatefulWidget {
  const SalesReportPage({super.key});

  @override
  State<SalesReportPage> createState() => _SalesReportPageState();
}

class _SalesReportPageState extends State<SalesReportPage> {
  String _filterType = 'today';
  DateTime? _selectedDate;

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');
    final filterDateFormat = DateFormat('dd MMM yyyy');
    final box = Hive.box<TransactionModel>('transactions_box');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Laporan Penjualan',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.headline,
        foregroundColor: AppColors.buttonText,
      ),
      drawer: const AppDrawer(currentRoute: 'reports'),
      body: SafeArea(
        top: false,
        left: false,
        right: false,
        bottom: true,
        child: ValueListenableBuilder(
          valueListenable: box.listenable(),
          builder: (context, Box<TransactionModel> b, _) {
            final allTransactions = b.values.toList().reversed.toList();
            final now = DateTime.now();

            final filteredTransactions = allTransactions.where((trx) {
              if (_filterType == 'today') {
                return trx.date.year == now.year &&
                    trx.date.month == now.month &&
                    trx.date.day == now.day;
              } else if (_filterType == 'custom' && _selectedDate != null) {
                return trx.date.year == _selectedDate!.year &&
                    trx.date.month == _selectedDate!.month &&
                    trx.date.day == _selectedDate!.day;
              }
              return true;
            }).toList();

            final validTransactions = filteredTransactions
                .where((trx) => !(trx.isCancelled ?? false))
                .toList();
            final totalRevenue = validTransactions.fold(
              0.0,
              (sum, trx) => sum + trx.totalAmount,
            );
            final totalCash = validTransactions
                .where((trx) => (trx.paymentMethod ?? 'CASH') == 'CASH')
                .fold(0.0, (sum, trx) => sum + trx.totalAmount);
            final totalQris = validTransactions
                .where((trx) => trx.paymentMethod == 'QRIS')
                .fold(0.0, (sum, trx) => sum + trx.totalAmount);

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('Hari Ini', 'today'),
                        const SizedBox(width: 8),
                        _buildFilterChip('Semua Riwayat', 'all'),
                        const SizedBox(width: 8),
                        ActionChip(
                          avatar: const Icon(
                            Icons.calendar_month_rounded,
                            size: 16,
                            color: AppColors.headline,
                          ),
                          backgroundColor: _filterType == 'custom'
                              ? AppColors.secondary
                              : AppColors.buttonText,
                          side: const BorderSide(color: AppColors.secondary),
                          label: Text(
                            _filterType == 'custom' && _selectedDate != null
                                ? filterDateFormat.format(_selectedDate!)
                                : 'Pilih Tanggal',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.headline,
                              fontSize: 12,
                            ),
                          ),
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _selectedDate ?? DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now(),
                            );
                            if (picked != null) {
                              setState(() {
                                _filterType = 'custom';
                                _selectedDate = picked;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _filterType == 'today'
                                ? 'Pendapatan Hari Ini'
                                : (_filterType == 'custom' &&
                                          _selectedDate != null
                                      ? 'Pendapatan (${filterDateFormat.format(_selectedDate!)})'
                                      : 'Total Seluruh Pendapatan'),
                            style: const TextStyle(
                              color: AppColors.paragraph,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${validTransactions.length} Sukses',
                            style: const TextStyle(
                              color: AppColors.paragraph,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        currency.format(totalRevenue),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.headline,
                        ),
                      ),
                      const Divider(
                        color: AppColors.paragraph,
                        height: 16,
                        thickness: 0.3,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Cash: ${currency.format(totalCash)}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.paragraph,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'QRIS: ${currency.format(totalQris)}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.paragraph,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: filteredTransactions.isEmpty
                      ? const Center(
                          child: Text(
                            'Tidak ada transaksi pada periode ini.',
                            style: TextStyle(
                              color: AppColors.paragraph,
                              fontSize: 14,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 4,
                          ),
                          itemCount: filteredTransactions.length,
                          itemBuilder: (context, index) {
                            final trx = filteredTransactions[index];
                            final isQris = trx.paymentMethod == 'QRIS';
                            final isCancelled = trx.isCancelled ?? false;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              decoration: BoxDecoration(
                                color: isCancelled
                                    ? Colors.grey.shade100
                                    : AppColors.buttonText,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isCancelled
                                      ? Colors.grey.shade300
                                      : AppColors.secondary,
                                ),
                              ),
                              child: ExpansionTile(
                                shape: Border.all(color: Colors.transparent),
                                title: Row(
                                  children: [
                                    Text(
                                      currency.format(trx.totalAmount),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: isCancelled
                                            ? Colors.grey
                                            : AppColors.headline,
                                        decoration: isCancelled
                                            ? TextDecoration.lineThrough
                                            : null,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    if (isCancelled)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.red.shade50,
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                          border: Border.all(color: Colors.red),
                                        ),
                                        child: Text(
                                          'DIBATALKAN',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.red.shade800,
                                          ),
                                        ),
                                      )
                                    else
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isQris
                                              ? Colors.teal.shade50
                                              : Colors.orange.shade50,
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                          border: Border.all(
                                            color: isQris
                                                ? Colors.teal
                                                : Colors.orange,
                                          ),
                                        ),
                                        child: Text(
                                          trx.paymentMethod ?? 'CASH',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: isQris
                                                ? Colors.teal.shade800
                                                : Colors.orange.shade900,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                subtitle: Text(
                                  dateFormat.format(trx.date),
                                  style: TextStyle(
                                    color: isCancelled
                                        ? Colors.grey
                                        : AppColors.paragraph,
                                    fontSize: 13,
                                  ),
                                ),
                                children: [
                                  ...trx.items.map((item) {
                                    return ListTile(
                                      dense: true,
                                      title: Text(
                                        item.name,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: isCancelled
                                              ? Colors.grey
                                              : AppColors.headline,
                                          decoration: isCancelled
                                              ? TextDecoration.lineThrough
                                              : null,
                                        ),
                                      ),
                                      trailing: Text(
                                        '${item.quantity}x @ ${currency.format(item.price)}',
                                        style: const TextStyle(
                                          color: AppColors.paragraph,
                                        ),
                                      ),
                                    );
                                  }),
                                  if ((trx.paymentMethod ?? 'CASH') == 'CASH' &&
                                      !isCancelled)
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                        16,
                                        4,
                                        16,
                                        8,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Diterima: ${currency.format(trx.cashPaid ?? 0.0)}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: AppColors.paragraph,
                                            ),
                                          ),
                                          Text(
                                            'Kembalian: ${currency.format(trx.change ?? 0.0)}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: AppColors.paragraph,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  if (!isCancelled)
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                        16,
                                        4,
                                        16,
                                        12,
                                      ),
                                      child: SizedBox(
                                        width: double.infinity,
                                        child: OutlinedButton.icon(
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: AppColors.tertiary,
                                            side: const BorderSide(
                                              color: AppColors.tertiary,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          icon: const Icon(
                                            Icons.cancel_outlined,
                                            size: 18,
                                          ),
                                          label: const Text(
                                            'Batalkan Transaksi (Refund)',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          onPressed: () =>
                                              _confirmCancelTransaction(
                                                context,
                                                trx,
                                              ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _confirmCancelTransaction(BuildContext context, TransactionModel trx) {
    showDialog(
      context: context,
      builder: (dCtx) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Batalkan Transaksi?',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.headline,
          ),
        ),
        content: const Text(
          'Transaksi akan dibatalkan dan seluruh stok item pesanan ini akan otomatis dikembalikan ke stok toko.',
          style: TextStyle(color: AppColors.paragraph),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dCtx),
            child: const Text(
              'Tutup',
              style: TextStyle(color: AppColors.paragraph),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.tertiary,
              foregroundColor: AppColors.buttonText,
            ),
            onPressed: () {
              final productBox = Hive.box<ProductModel>('products_box');
              for (var item in trx.items) {
                final productIndex = productBox.values.toList().indexWhere(
                  (p) => p.id == item.productId,
                );
                if (productIndex != -1) {
                  final prod = productBox.getAt(productIndex);
                  if (prod != null) {
                    prod.stock += item.quantity;
                    prod.save();
                  }
                }
              }

              trx.isCancelled = true;
              trx.save();

              context.read<PosCubit>().loadProducts();

              Navigator.pop(dCtx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  backgroundColor: AppColors.headline,
                  content: Text(
                    'Transaksi berhasil dibatalkan & stok dikembalikan!',
                  ),
                ),
              );
            },
            child: const Text('Ya, Batalkan'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filterType == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.buttonText,
      side: const BorderSide(color: AppColors.secondary),
      labelStyle: TextStyle(
        color: isSelected ? AppColors.buttonText : AppColors.headline,
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _filterType = value;
          });
        }
      },
    );
  }
}
