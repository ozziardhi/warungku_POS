import 'package:flutter/material.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/services/printer_service.dart';
import '../../../data/models/transaction_model.dart';

class PrinterSettingsPage extends StatefulWidget {
  const PrinterSettingsPage({super.key});

  @override
  State<PrinterSettingsPage> createState() => _PrinterSettingsPageState();
}

class _PrinterSettingsPageState extends State<PrinterSettingsPage> {
  List<BluetoothInfo> _devices = [];
  bool _isLoading = false;
  bool _isConnected = false;
  String _connectedMac = '';

  @override
  void initState() {
    super.initState();
    _loadPrinterData();
  }

  Future<void> _loadPrinterData() async {
    final prefs = await SharedPreferences.getInstance();
    final status = await PrintBluetoothThermal.connectionStatus;
    setState(() {
      _isConnected = status;
      _connectedMac = prefs.getString('printer_mac') ?? '';
    });
  }

  Future<void> _scanDevices() async {
    setState(() => _isLoading = true);
    final isPermissionGranted =
        await PrintBluetoothThermal.isPermissionBluetoothGranted;
    if (!isPermissionGranted) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Izin Bluetooth belum diberikan!')),
        );
      }
      return;
    }

    final devices = await PrintBluetoothThermal.pairedBluetooths;
    setState(() {
      _devices = devices;
      _isLoading = false;
    });
  }

  Future<void> _connectPrinter(String macAddress) async {
    setState(() => _isLoading = true);
    final result = await PrintBluetoothThermal.connect(
      macPrinterAddress: macAddress,
    );
    final prefs = await SharedPreferences.getInstance();

    if (result) {
      await prefs.setString('printer_mac', macAddress);
      setState(() {
        _isConnected = true;
        _connectedMac = macAddress;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content: Text('Printer Berhasil Terhubung!'),
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.tertiary,
            content: Text('Gagal Menghubungkan ke Printer!'),
          ),
        );
      }
    }
    setState(() => _isLoading = false);
  }

  Future<void> _disconnectPrinter() async {
    await PrintBluetoothThermal.disconnect;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('printer_mac');
    setState(() {
      _isConnected = false;
      _connectedMac = '';
    });
  }

  Future<void> _testPrint() async {
    if (!_isConnected) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Printer belum terhubung!')));
      return;
    }

    final dummyTrx = TransactionModel(
      id: 'TEST01',
      date: DateTime.now(),
      items: [
        CartItemModel(
          productId: '1',
          name: 'Es Teler Spesial',
          price: 15000,
          quantity: 2,
        ),
        CartItemModel(
          productId: '2',
          name: 'Es Jeruk Nipis',
          price: 5000,
          quantity: 1,
        ),
      ],
      totalAmount: 35000,
      paymentMethod: 'CASH',
      cashPaid: 50000,
      change: 15000,
    );

    final success = await PrinterService.printReceipt(dummyTrx);
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.tertiary,
          content: Text('Gagal mengirim data cetak!'),
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
          'Koneksi Printer',
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
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.buttonText,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.secondary),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Status Printer Thermal',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.headline,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _isConnected
                          ? Colors.green.shade50
                          : Colors.red.shade50,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: _isConnected ? Colors.green : Colors.red,
                      ),
                    ),
                    child: Text(
                      _isConnected ? 'Terhubung' : 'Terputus',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _isConnected
                            ? Colors.green.shade800
                            : Colors.red.shade800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.headline,
                      side: const BorderSide(
                        color: AppColors.secondary,
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: _isLoading ? null : _scanDevices,
                    icon: const Icon(Icons.bluetooth_searching_rounded),
                    label: const Text('Scan Printer'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.headline,
                      foregroundColor: AppColors.buttonText,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: _isConnected ? _testPrint : null,
                    icon: const Icon(Icons.print_rounded),
                    label: const Text('Tes Cetak'),
                  ),
                ),
              ],
            ),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              ),
            const SizedBox(height: 16),
            if (_devices.isNotEmpty) ...[
              const Text(
                'Daftar Perangkat Bluetooth:',
                style: TextStyle(
                  color: AppColors.paragraph,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              ..._devices.map((device) {
                final isCurrent = _connectedMac == device.macAdress;
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: AppColors.buttonText,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isCurrent ? Colors.green : AppColors.secondary,
                    ),
                  ),
                  child: ListTile(
                    leading: Icon(
                      Icons.print_outlined,
                      color: isCurrent ? Colors.green : AppColors.paragraph,
                    ),
                    title: Text(
                      device.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.headline,
                      ),
                    ),
                    subtitle: Text(
                      device.macAdress,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.paragraph,
                      ),
                    ),
                    trailing: isCurrent && _isConnected
                        ? TextButton(
                            onPressed: _disconnectPrinter,
                            child: const Text(
                              'Putuskan',
                              style: TextStyle(color: AppColors.tertiary),
                            ),
                          )
                        : ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.buttonText,
                            ),
                            onPressed: () => _connectPrinter(device.macAdress),
                            child: const Text('Hubungkan'),
                          ),
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}
