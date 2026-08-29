import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_drawer.dart';
import '../../../data/models/product_model.dart';
import '../../home_pos/cubit/pos_cubit.dart';

class ProductListPage extends StatelessWidget {
  const ProductListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final box = Hive.box<ProductModel>('products_box');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Data Barang',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.headline,
        foregroundColor: AppColors.buttonText,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, size: 26),
            tooltip: 'Tambah Barang',
            onPressed: () => _showProductForm(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: const AppDrawer(currentRoute: 'products'),
      body: SafeArea(
        top: false,
        left: false,
        right: false,
        bottom: true,
        child: ValueListenableBuilder(
          valueListenable: box.listenable(),
          builder: (context, Box<ProductModel> b, _) {
            final products = b.values.toList();

            if (products.isEmpty) {
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
                      'Belum ada data barang.\nTekan ikon + di pojok kanan atas.',
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
              padding: const EdgeInsets.all(14),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.buttonText,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: product.isActive
                          ? AppColors.secondary
                          : Colors.grey.shade300,
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              product.name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: product.isActive
                                    ? AppColors.headline
                                    : Colors.grey,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: product.isActive
                                  ? Colors.green.shade50
                                  : Colors.red.shade50,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: product.isActive
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                            child: Text(
                              product.isActive ? 'Aktif' : 'Non-Aktif',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: product.isActive
                                    ? Colors.green.shade800
                                    : Colors.red.shade800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Kode/ID: ${product.code}  •  Stok: ${product.stock} ${product.unit}\nHarga: ${currency.format(product.price)}',
                        style: const TextStyle(
                          color: AppColors.paragraph,
                          fontSize: 13,
                          height: 1.3,
                        ),
                      ),
                      const Divider(color: AppColors.secondary, height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Text(
                                'Status: ',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.paragraph,
                                ),
                              ),
                              Switch.adaptive(
                                value: product.isActive,
                                activeColor: AppColors.primary,
                                onChanged: (val) {
                                  product.isActive = val;
                                  product.save();
                                  context.read<PosCubit>().loadProducts();
                                },
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit_outlined,
                                  color: AppColors.primary,
                                ),
                                onPressed: () =>
                                    _showProductForm(context, product: product),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline_rounded,
                                  color: AppColors.tertiary,
                                ),
                                onPressed: () =>
                                    _confirmDelete(context, product),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _showProductForm(BuildContext context, {ProductModel? product}) {
    final formKey = GlobalKey<FormState>();
    final isEdit = product != null;

    final codeCtrl = TextEditingController(text: isEdit ? product.code : '');
    final nameCtrl = TextEditingController(text: isEdit ? product.name : '');
    final priceCtrl = TextEditingController(
      text: isEdit ? product.price.toStringAsFixed(0) : '',
    );
    final stockCtrl = TextEditingController(
      text: isEdit ? product.stock.toString() : '',
    );
    String selectedUnit = isEdit ? product.unit : 'pcs';
    bool isActive = isEdit ? product.isActive : true;

    final units = ['pcs', 'pack', 'bal'];

    InputDecoration inputDecor(String label) {
      return InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.paragraph),
        filled: true,
        fillColor: AppColors.buttonText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.secondary),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      );
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bCtx) => StatefulBuilder(
        builder: (context, setSheetState) {
          return SafeArea(
            top: false,
            left: false,
            right: false,
            bottom: true,
            child: Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isEdit ? 'Edit Barang' : 'Tambah Barang Baru',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.headline,
                        ),
                      ),
                      const Divider(color: AppColors.secondary),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: codeCtrl,
                        decoration: inputDecor(
                          'Kode Barang / ID (Misal: ES01)',
                        ),
                        validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: nameCtrl,
                        decoration: inputDecor('Nama Barang / Aneka Es'),
                        validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: priceCtrl,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: inputDecor('Harga Jual (Rp)'),
                        validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: stockCtrl,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: inputDecor('Jumlah Stok'),
                        validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: selectedUnit,
                        decoration: inputDecor('Satuan'),
                        items: units
                            .map(
                              (u) => DropdownMenuItem(
                                value: u,
                                child: Text(u.toUpperCase()),
                              ),
                            )
                            .toList(),
                        onChanged: (val) =>
                            setSheetState(() => selectedUnit = val!),
                      ),
                      const SizedBox(height: 8),
                      SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        title: const Text(
                          'Status Aktif',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.headline,
                          ),
                        ),
                        subtitle: const Text(
                          'Barang aktif akan muncul di kasir',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.paragraph,
                          ),
                        ),
                        value: isActive,
                        activeColor: AppColors.primary,
                        onChanged: (val) => setSheetState(() => isActive = val),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.buttonText,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              final box = Hive.box<ProductModel>(
                                'products_box',
                              );
                              if (isEdit) {
                                product.code = codeCtrl.text.trim();
                                product.name = nameCtrl.text.trim();
                                product.price = double.parse(priceCtrl.text);
                                product.stock = int.parse(stockCtrl.text);
                                product.unit = selectedUnit;
                                product.isActive = isActive;
                                product.save();
                              } else {
                                final newProduct = ProductModel(
                                  id: DateTime.now().millisecondsSinceEpoch
                                      .toString(),
                                  code: codeCtrl.text.trim(),
                                  name: nameCtrl.text.trim(),
                                  price: double.parse(priceCtrl.text),
                                  stock: int.parse(stockCtrl.text),
                                  unit: selectedUnit,
                                  isActive: isActive,
                                );
                                box.add(newProduct);
                              }

                              context.read<PosCubit>().loadProducts();
                              Navigator.pop(bCtx);
                            }
                          },
                          child: Text(
                            isEdit ? 'Simpan Perubahan' : 'Tambah Barang',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, ProductModel product) {
    showDialog(
      context: context,
      builder: (dCtx) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Hapus Barang?',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.headline,
          ),
        ),
        content: Text(
          'Yakin ingin menghapus "${product.name}"? Data barang akan terhapus permanen.',
          style: const TextStyle(color: AppColors.paragraph),
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
              backgroundColor: AppColors.tertiary,
              foregroundColor: AppColors.buttonText,
            ),
            onPressed: () {
              product.delete();
              context.read<PosCubit>().loadProducts();
              Navigator.pop(dCtx);
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}
