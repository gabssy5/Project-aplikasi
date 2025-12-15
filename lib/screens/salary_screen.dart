import 'package:flutter/material.dart';

class SalaryScreen extends StatefulWidget {
  const SalaryScreen({super.key});

  @override
  State<SalaryScreen> createState() => _SalaryScreenState();
}

class _SalaryScreenState extends State<SalaryScreen> {
  // Variabel untuk Dropdown Periode
  String _selectedPeriod = 'November 2025';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // AppBar sederhana sesuai desain
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            // Nanti diisi logika kembali
          },
        ),
        title: const Text(
          "Detail Slip Gaji",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. TEXT PILIH PERIODE & DROPDOWN
            const Text("Pilih Periode", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: DropdownButton<String>(
                value: _selectedPeriod,
                isExpanded: true,
                underline: const SizedBox(), // Hilangkan garis bawah bawaan
                items: <String>['November 2025', 'Oktober 2025', 'September 2025']
                    .map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedPeriod = newValue!;
                  });
                },
              ),
            ),

            const SizedBox(height: 25),

            // 2. KARTU BIRU UTAMA (GAJI BERSIH)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: const Color(0xFF1E2633), // Warna Biru Gelap sesuai gambar
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Text(
                    "GAJI BERSIH",
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Rp 12,455,000",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(color: Colors.white24, height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Status: Paid",
                        style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        _selectedPeriod,
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  )
                ],
              ),
            ),

            const SizedBox(height: 25),

            // 3. KARTU PENDAPATAN
            _buildDetailCard(
              title: "Pendapatan",
              amount: "+ Rp 12,455,000",
              amountColor: Colors.green.shade100,
              textColor: Colors.green.shade800,
              items: [
                {"label": "Gaji Pokok", "value": "Rp 12,455,000"},
                {"label": "Tunjangan", "value": "Rp 0"}, // Contoh
              ],
            ),

            const SizedBox(height: 15),

            // 4. KARTU PEMOTONGAN
            _buildDetailCard(
              title: "Pemotongan",
              amount: "- Rp 500,000", // Contoh potongan
              amountColor: Colors.red.shade100,
              textColor: Colors.red.shade800,
              items: [
                {"label": "BPJS", "value": "Rp 200,000"},
                {"label": "Pajak", "value": "Rp 300,000"},
              ],
            ),

            const SizedBox(height: 30),

            // 5. TOMBOL DOWNLOAD PDF
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E2633), // Warna Biru Gelap
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                icon: const Icon(Icons.download, color: Colors.white),
                label: const Text(
                  "Download PDF",
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Fungsi Pembantu untuk Membuat Kartu Detail (Biar kodingan rapi)
  Widget _buildDetailCard({
    required String title,
    required String amount,
    required Color amountColor,
    required Color textColor,
    required List<Map<String, String>> items,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(color: Colors.grey.shade100, blurRadius: 10, offset: const Offset(0, 5))
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: amountColor,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(amount, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ],
          ),
          const Divider(height: 25),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(item['label']!, style: const TextStyle(color: Colors.grey)),
                Text(item['value']!, style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          )),
        ],
      ),
    );
  }
}