import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:intl/intl.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/transaction_model.dart';

class PrinterService {
  static Future<List<int>> generateReceiptBytes({
    required TransactionModel transaction,
    required String storeName,
    required String storeAddress,
    required String storeFooter,
    PaperSize paperSize = PaperSize.mm58,
  }) async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(paperSize, profile);
    List<int> bytes = [];

    final currency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    // Header Struk
    bytes += generator.text(
      storeName,
      styles: const PosStyles(
        align: PosAlign.center,
        bold: true,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
      ),
    );
    if (storeAddress.isNotEmpty) {
      bytes += generator.text(
        storeAddress,
        styles: const PosStyles(align: PosAlign.center),
      );
    }
    bytes += generator.hr();

    // Informasi Transaksi
    bytes += generator.text('Waktu : ${dateFormat.format(transaction.date)}');
    bytes += generator.text('Metode: ${transaction.paymentMethod ?? 'CASH'}');
    bytes += generator.hr();

    // Item Transaksi
    for (var item in transaction.items) {
      bytes += generator.text(item.name, styles: const PosStyles(bold: true));
      bytes += generator.row([
        PosColumn(
          text: '${item.quantity} x ${currency.format(item.price)}',
          width: 7,
        ),
        PosColumn(
          text: currency.format(item.price * item.quantity),
          width: 5,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);
    }
    bytes += generator.hr();

    // Total & Pembayaran
    bytes += generator.row([
      PosColumn(text: 'TOTAL', width: 6, styles: const PosStyles(bold: true)),
      PosColumn(
        text: currency.format(transaction.totalAmount),
        width: 6,
        styles: const PosStyles(align: PosAlign.right, bold: true),
      ),
    ]);

    if ((transaction.paymentMethod ?? 'CASH') == 'CASH') {
      bytes += generator.row([
        PosColumn(text: 'Tunai', width: 6),
        PosColumn(
          text: currency.format(transaction.cashPaid ?? 0.0),
          width: 6,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);
      bytes += generator.row([
        PosColumn(text: 'Kembali', width: 6),
        PosColumn(
          text: currency.format(transaction.change ?? 0.0),
          width: 6,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);
    }

    bytes += generator.hr();

    // Footer Struk
    if (storeFooter.isNotEmpty) {
      bytes += generator.text(
        storeFooter,
        styles: const PosStyles(align: PosAlign.center),
      );
    }

    bytes += generator.feed(2);
    bytes += generator.cut();

    return bytes;
  }

  static Future<bool> printReceipt(TransactionModel transaction) async {
    final isConnected = await PrintBluetoothThermal.connectionStatus;
    if (!isConnected) return false;

    final prefs = await SharedPreferences.getInstance();
    final storeName = prefs.getString('store_name') ?? 'Warungku';
    final storeAddress =
        prefs.getString('store_address') ?? 'Jl. Raya Aneka Es No. 1';
    final storeFooter =
        prefs.getString('store_footer') ?? 'Terima Kasih Atas Kunjungan Anda';

    final bytes = await generateReceiptBytes(
      transaction: transaction,
      storeName: storeName,
      storeAddress: storeAddress,
      storeFooter: storeFooter,
    );

    return await PrintBluetoothThermal.writeBytes(bytes);
  }
}
