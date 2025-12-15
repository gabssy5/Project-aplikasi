import 'package:flutter/material.dart';
import 'package:flutter_application_2/screens/leave_screen.dart';
import 'salary_screen.dart'; // Pastikan nama file sesuai
import 'dart:async';
// ... import di atas biarkan sama ...
import 'package:http/http.dart' as http; // <--- JANGAN LUPA TAMBAH INI
import 'dart:convert'; // <--- DAN INI

class AttendanceScreen extends StatefulWidget {
  // Tambahkan variabel penampung data user
  final Map<String, dynamic> user; 


  const AttendanceScreen({super.key, required this.user});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}
class _AttendanceScreenState extends State<AttendanceScreen> {
  // Data Navigasi
  int _selectedIndex = 0;
  String _workedHours = "00:00";
  // Data Absensi (JANGAN FINAL, karena nilainya akan berubah)
  bool _isClockedIn = false; 
  
  
  // Timer Jam Realtime
  late Timer _timer;
  String _currentTimeStr = "00:00:00"; 
  
  final String _currentLocation = "Kantor Pusat"; 
  String get _employeeName => widget.user['name'];
  final Color _primaryGreen = const Color(0xFF4CAF50);
 
  // --- SAAT APLIKASI DIBUKA ---
  @override
  void initState() {
    super.initState();
    print("DEBUG: User ID yang dikirim ke PHP adalah: ${widget.user['id']}");
    _startTimer();       // 1. Jalankan Jam Digital
    _checkTodayStatus(); // 2. Cek ke Server: "Saya udah absen belum?"
  }

  @override
  void dispose() {
    _timer.cancel(); // Matikan timer biar HP gak panas
    super.dispose();
  }

  // --- FUNGSI JAM DIGITAL ---
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          final now = DateTime.now();
          _currentTimeStr = 
              "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";
        });
      }
    });
  }

  // --- FUNGSI CEK STATUS (KUNCI PERMASALAHAN ABANG) ---
Future<void> _checkTodayStatus() async {
  var url = Uri.parse('http://localhost/absensi_api/cek_status.php'); 
  
  try {
    var response = await http.post(
      url,
      // 1. INI KUNCINYA (Label Paket):
      headers: {'Content-Type': 'application/json'}, 
      
      // 2. Bungkus ID jadi String biar PHP tidak bingung
      body: jsonEncode({
        "user_id": widget.user['id'].toString(), 
      }),
    );
    
    // Cek responnya
    if (!mounted) return;
    var data = jsonDecode(response.body);
    
    // Kalau sukses, tombol berubah jadi merah
    if (data['success'] == true) {
      setState(() {
        _isClockedIn = (data['status'] == 'Hadir'); 
        String jamMasuk = data['time_in'] ?? "00:00:00";
        String jamPulang = data['time_out'] ?? "00:00:00";
        
        _workedHours = _calculateDuration(jamMasuk, jamPulang);
      });
    }

  } catch (e) {
    debugPrint("Error: $e");
  }
  
}


  // ... (Lanjut ke fungsi _toggleCheckStatus yang sudah Abang buat) ...

  // --- FUNGSI ABSEN KE SERVER ---
Future<void> _toggleCheckStatus() async {
    var url = Uri.parse('http://localhost/absensi_api/absen.php'); 

    try {
      // 1. Ini proses menunggu (Async)
      var response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "user_id": widget.user['id'].toString(), 
        }),
      );

      // 2. --- SISIPKAN MANTRA INI DI SINI ---
      // Artinya: "Kalau layarnya udah gak ada, berhenti. Jangan lanjut."
      if (!mounted) return; 
      // ------------------------------------

      // 3. Baru deh aman pakai context di bawah ini
      var data = jsonDecode(response.body);

      if (data['success'] == true) {
        setState(() {
           // ... update data ...
           _isClockedIn = !_isClockedIn;
          
        });

        await _checkTodayStatus();
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message']), backgroundColor: Colors.green),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar( // Ini juga aman
          SnackBar(content: Text("Gagal: ${data['message']}"), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      // Di sini juga harus cek mounted kalau mau pakai SnackBar error
      if (!mounted) return; 
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error Koneksi"), backgroundColor: Colors.red),
      );
    }
  }

 

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _buildBodyContent(),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 1),
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: _primaryGreen,
          unselectedItemColor: Colors.grey,
          items: [
            BottomNavigationBarItem(
              icon: Image.asset(
                'assets/image/home.png', // Sesuai nama file Anda
                width: 24, // Kita atur ukurannya biar pas
                height: 24,
                color: _selectedIndex == 0
                    ? _primaryGreen
                    : Colors.grey, // Biar bisa berubah warna
              ),
              label: 'Beranda',
            ),

            // TOMBOL 2: WALLET
            BottomNavigationBarItem(
              icon: Image.asset(
                'assets/image/wallet.png', // Sesuai nama file Anda
                width: 24,
                height: 24,
                color: _selectedIndex == 1 ? _primaryGreen : Colors.grey,
              ),
              label: 'Penggajian',
            ),

            // TOMBOL 3: CALLENDER (Sesuai ejaan file Anda)
            BottomNavigationBarItem(
              icon: Image.asset(
                'assets/image/callender.png', // Sesuai nama file Anda (typo gapapa, asal sama)
                width: 24,
                height: 24,
                color: _selectedIndex == 2 ? _primaryGreen : Colors.grey,
              ),
              label: 'Cuti',
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET KOMPONEN ---

Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'WELCOME BACK,',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            Text(
              _employeeName, // Ini Nama Abang (Putra Ramadhan)
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            
            // --- BAGIAN INI YANG KITA UBAH ---
            Text(
              _getFormattedDate(), // <--- Panggil Fungsi Tanggal di sini!
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            // ---------------------------------
          ],
        ),
        
        // Foto Profil
        CircleAvatar(
          radius: 25,
          backgroundColor: Colors.grey.shade200,
          child: const Icon(Icons.person, color: Colors.blueGrey),
        ),
      ],
    );
  }

  Widget _buildCheckInButton(BuildContext context) {
    // Desain Tombol Melingkar Besar
    return Column(
      children: [
        GestureDetector(
          onTap: _toggleCheckStatus,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _isClockedIn ? Colors.red.shade600 : _primaryGreen,
              boxShadow: [
                BoxShadow(
                  color: _primaryGreen.withValues(alpha: 0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _isClockedIn ? Icons.exit_to_app : Icons.fingerprint,
                  size: 50,
                  color: Colors.white,
                ),
                const SizedBox(height: 8),
                Text(
                  _isClockedIn ? 'CHECK-OUT' : 'CHECK-IN',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  _isClockedIn ? 'End your day' : 'Start your day',
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusCards() {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'CURRENT TIME',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 5),
                Text(
                  _currentTimeStr, // <--- GANTI INI BIAR JAMNYA JALAN
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
// ... dst

            // Kolom Lokasi
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Row(
                  children: [
                    Icon(Icons.near_me, size: 14, color: Colors.grey),
                    SizedBox(width: 4),
                    Text(
                      'LOCATION',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  _currentLocation,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Row(
                  children: [
                    Icon(Icons.circle, size: 8, color: Colors.green),
                    SizedBox(width: 4),
                    Text(
                      'In Range',
                      style: TextStyle(color: Colors.green, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityCards() {
    // Kartu Jam Kerja dan Lembur
    return Row(
      children: [
        Expanded(
          child: _activityCard(
            title: 'HOURS WORKED',
            value: _workedHours,
            subtitle: 'Today',
            icon: Icons.access_time,
            
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: _activityCard(
            title: 'OVERTIME',
            value: '00:00',
            subtitle: 'No overtime yet',
            icon: Icons.nights_stay,
          ),
        ),
      ],
    );
  }

  Widget _activityCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    
  }) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 5),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              subtitle,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
         
          ],
        ),
      ),
    );
  }

  // --- FUNGSI PENGATUR HALAMAN (Taruh di dalam class) ---
  Widget _buildBodyContent() {
    if (_selectedIndex == 0) {
      // === HALAMAN 1: BERANDA ===
      // Paste (Tempel) kodingan SingleChildScrollView yang tadi di-CUT di sini!
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),

        child: Column(
          children: [
            const SizedBox(height: 40),

            _buildHeader(context),

            const SizedBox(height: 30),

            _buildCheckInButton(context),

            const SizedBox(height: 30),

            _buildStatusCards(),

            const SizedBox(height: 20),

            _buildActivityCards(),
          ],
        ),
      );
    } else if (_selectedIndex == 1) {
      // === HALAMAN 2: PENGGAJIAN ===
      return const SalaryScreen(); // Ini memanggil file baru tadi
    } else {
      return const  LeaveScreen();
    }
  }
  // FUNGSI HITUNG DURASI (Wajib Ada)
// FUNGSI HITUNG DURASI (PAKAI DETIK)
  String _calculateDuration(String? start, String? end) {
    if (start == null || end == null || start == "00:00:00" || end == "00:00:00") {
      return "00:00:00";
    }
    try {
      DateTime t1 = DateTime.parse("2025-01-01 $start");
      DateTime t2 = DateTime.parse("2025-01-01 $end");
      Duration diff = t2.difference(t1);

      String twoDigits(int n) => n.toString().padLeft(2, "0");
      String hours = twoDigits(diff.inHours);
      String minutes = twoDigits(diff.inMinutes.remainder(60));
      String seconds = twoDigits(diff.inSeconds.remainder(60)); // Detik

      return "$hours:$minutes:$seconds"; 
    } catch (e) {
      return "00:00:00";
    }
  }
  // FUNGSI BUAT TANGGAL CANTIK (Otomatis Hari Ini)
  String _getFormattedDate() {
    // Daftar Nama Hari & Bulan
    List<String> days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"];
    List<String> months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];

    DateTime now = DateTime.now();
    
    // Ambil nama hari (weekday mulai dari 1=Senin, jadi dikurang 1 buat index array)
    String dayName = days[now.weekday - 1]; 
    String monthName = months[now.month - 1];
    
    return "$dayName, $monthName ${now.day}, ${now.year}";
  }
}
