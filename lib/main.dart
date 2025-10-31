import 'package:ecommerce/providers/cart_provider.dart';
import 'package:ecommerce/services/cart_api_service.dart';
import 'package:ecommerce/pages/cart_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => CartProvider(CartApiService(userId: '123')),
        ),
      ],
      child: MaterialApp(
        title: 'E-commerce Cart',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: Colors.grey[200],
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.lightBlue,
            foregroundColor: Colors.white,
            elevation: 2,
          ),
          cardTheme: CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        home: const CartPage(),
      ),
    );
  }
}
