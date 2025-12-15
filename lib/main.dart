import 'package:flutter/material.dart';


import 'screens/login_screen.dart'; 
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikasi Absensi',
      debugShowCheckedModeBanner: false, // Biar banner 'debug' hilang
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      // Di sini kita arahkan agar aplikasi langsung membuka AttendanceScreen
      home: const LoginScreen(),
    );
  }
}