import 'package:flutter/material.dart';
import 'attendance_screen.dart'; // PENTING: Biar bisa pindah ke Home nanti
import 'dart:convert'; // Untuk mengolah JSON
import 'package:http/http.dart' as http; // Alat internet

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controller untuk mengambil teks inputan
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  // Warna Hijau sesuai desain Anda
  final Color _primaryGreen = const Color(0xFF2ECC71); 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 50),
              
              // 1. IKON PROFIL HIJAU BULAT
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: _primaryGreen,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person_outline, size: 50, color: Colors.white),
                ),
              ),
              
              const SizedBox(height: 30),
              
              // 2. TEKS SAMBUTAN
              const Center(
                child: Text(
                  "Selamat Datang",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ),
              const SizedBox(height: 8),
              const Center(
                child: Text(
                  "Masuk untuk mengakses dasbor kehadiran Anda",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ),

              const SizedBox(height: 40),

              // 3. INPUT ID
              const Text("ID", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),
              TextField(
                controller: _idController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                ),
              ),

              const SizedBox(height: 20),

              // 4. INPUT PASSWORD
              const Text("Password", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: true, // Biar password jadi titik-titik
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                ),
              ),

              const SizedBox(height: 10),
              
              // Lupa Sandi (Warna Hijau)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {}, 
                  child: Text("Lupa sandi ?", style: TextStyle(color: _primaryGreen, fontWeight: FontWeight.bold)),
                ),
              ),

              const SizedBox(height: 30),

              // 5. TOMBOL LOGIN (HIJAU)
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () async {
                    // 1. Ambil teks dari kolom input
                    // (Kita anggap kolom ID itu diisi Email ya, misal: putra@kantor.com)
                    String email = _idController.text;
                    String password = _passwordController.text;

                    // Cek kalau kosong
                    if (email.isEmpty || password.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Isi ID dan Password dulu bos!")),
                      );
                      return;
                    }

                   
                    // Pastikan HP dan Laptop di Wifi yang sama!
                   var url = Uri.parse('http://localhost/absensi_api/login.php');
                 

                    // OPSI 2: Kalau Run pakai HP ASLI (Satu Wifi)
                    // var url = Uri.parse('http://192.168.100.214/absensi_api/login.php');
                    try {
                      // 3. Kirim Paket (POST)
                     var response = await http.post(
                      url,
                      // TAMBAHKAN BARIS HEADERS INI:
                      headers: {"Content-Type": "application/json"}, 
                      
                      body: jsonEncode({
                        "email": email,
                        "password": password,
                      }),
                    );

                      // 4. Baca Balasan dari PHP
                      var data = jsonDecode(response.body);

                      if (data['success'] == true) {
                        // --- LOGIN BERHASIL ---
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Login Berhasil! Selamat datang."),
                              backgroundColor: Colors.green,
                            ),
                          );

                          // Pindah ke Halaman Utama
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => AttendanceScreen(user: data['data']),),
                          );
                        }
                      } else {
                        // --- LOGIN GAGAL ---
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Gagal: ${data['message']}"),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    } catch (e) {
                      // --- ERROR KONEKSI ---
                      debugPrint("Error: $e"); // Cek error di terminal debug
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Tidak bisa konek ke Server. Cek IP atau XAMPP!"),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryGreen,
                    foregroundColor: Colors.white, // Warna teks putih
                    elevation: 5,
                    shadowColor: _primaryGreen.withValues(alpha: 0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "Login",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}