import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/constants/app_colors.dart';
import 'data/models/product_model.dart';
import 'data/models/transaction_model.dart';
import 'features/home_pos/cubit/pos_cubit.dart';
import 'features/home_pos/presentation/home_pos_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  Hive.registerAdapter(ProductModelAdapter());
  Hive.registerAdapter(CartItemModelAdapter());
  Hive.registerAdapter(TransactionModelAdapter());

  final productBox = await Hive.openBox<ProductModel>('products_box');
  final transactionBox = await Hive.openBox<TransactionModel>(
    'transactions_box',
  );

  runApp(MyApp(productBox: productBox, transactionBox: transactionBox));
}

class MyApp extends StatelessWidget {
  final Box<ProductModel> productBox;
  final Box<TransactionModel> transactionBox;

  const MyApp({
    super.key,
    required this.productBox,
    required this.transactionBox,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => PosCubit(productBox, transactionBox)..loadProducts(),
        ),
      ],
      child: MaterialApp(
        title: 'Warungku',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: AppColors.background,
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
            secondary: AppColors.secondary,
            surface: AppColors.background,
            error: AppColors.tertiary,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: AppColors.headline,
            foregroundColor: AppColors.buttonText,
            elevation: 0,
          ),
          // Langsung panggil tanpa Theme.of(context)
          textTheme: GoogleFonts.interTextTheme(),
        ),
        home: const HomePosPage(),
      ),
    );
  }
}
