import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'controllers/auth_controller.dart';
import 'controllers/cesar_controller.dart';
import 'pages/login_page.dart';
import 'pages/encrypt_page.dart';
import 'pages/decrypt_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => CesarController()),
      ],
      child: MaterialApp(
        title: 'Cifra de César',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        initialRoute: '/',
        routes: {
          '/': (_) => const LoginPage(),
          '/encrypt': (_) => const EncryptPage(),
          '/decrypt': (_) => const DecryptPage(),
        },
      ),
    );
  }
}
