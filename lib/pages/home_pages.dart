import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:my_qolb/pages/surat_pages.dart';
import 'package:my_qolb/pages/almasurat_pages.dart';

// --- SERVICE SECTION (Logika API & Lokasi) ---
class ShalatService {
  static const String baseUrl = "https://equran.id/api/v2/shalat";

  Future<Map<String, dynamic>> fetchFullJadwalData() async {
    try {
      // 1. Ambil Posisi GPS
      Position position = await _getGeoLocationPosition();

      // 2. Reverse Geocoding untuk cari nama kota
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      String city = placemarks[0].subAdministrativeArea ?? "Jakarta";
      String cleanCity = city
          .replaceAll(
            RegExp(r'Kabupaten|Kota|Kodya|Adm\.', caseSensitive: false),
            '',
          )
          .trim();

      // 3. Cari ID Kota di API
      final searchRes = await http.get(
        Uri.parse("$baseUrl/kota/cari/$cleanCity"),
      );
      String idKota = "1301"; // Default Jakarta jika tidak ketemu
      String displayCity = city;

      if (searchRes.statusCode == 200) {
        final searchData = jsonDecode(searchRes.body);
        if (searchData['data'] != null &&
            (searchData['data'] as List).isNotEmpty) {
          idKota = searchData['data'][0]['id'];
          displayCity = searchData['data'][0]['lokasi'];
        }
      }

      // 4. Ambil Jadwal Berdasarkan ID Kota & Tanggal Hari Ini
      final now = DateTime.now();
      final response = await http.get(
        Uri.parse(
          "$baseUrl/jadwal/$idKota/${now.year}/${now.month}/${now.day}",
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {"city": displayCity, "jadwal": data['data']['jadwal']};
      } else {
        throw "Gagal memuat jadwal dari server.";
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Position> _getGeoLocationPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) throw 'GPS Anda tidak aktif.';

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) throw 'Izin lokasi ditolak.';
    }

    if (permission == LocationPermission.deniedForever) {
      throw 'Izin lokasi ditolak permanen, aktifkan di pengaturan.';
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }
}

// --- UI SECTION ---
class HomePages extends StatefulWidget {
  const HomePages({super.key});

  @override
  State<HomePages> createState() => _HomePagesState();
}

class _HomePagesState extends State<HomePages> {
  final ShalatService _shalatService = ShalatService();
  Map<String, dynamic>? jadwalShalat;
  bool isShalatLoading = true;
  String errorMessage = "";
  String namaKota = "Mencari Lokasi...";

  @override
  void initState() {
    super.initState();
    _loadJadwal();
  }

  Future<void> _loadJadwal() async {
    try {
      setState(() {
        isShalatLoading = true;
        errorMessage = "";
      });

      final result = await _shalatService.fetchFullJadwalData();

      setState(() {
        jadwalShalat = result['jadwal'];
        namaKota = result['city'];
        isShalatLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isShalatLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF588B76), Colors.white],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 40),
                Text(
                  "Qolb.",
                  style: GoogleFonts.poppins(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),

                // Widget Jadwal Shalat Section
                _buildPrayerSection(),

                const SizedBox(height: 30),
                Text(
                  "Pilih Menu",
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF588B76),
                  ),
                ),
                const SizedBox(height: 20),

                _buildMenuCard(
                  context,
                  title: "Al-Quran",
                  subtitle: "Bacaan 114 Surat",
                  icon: Icons.menu_book_rounded,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SuratPages()),
                  ),
                ),

                _buildMenuCard(
                  context,
                  title: "Al-Ma'surat",
                  subtitle: "Dzikir Pagi & Petang",
                  icon: Icons.wb_sunny_outlined,
                  onTap: () => _showAlmasuratDialog(context),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPrayerSection() {
    if (isShalatLoading) {
      return const Padding(
        padding: EdgeInsets.all(40.0),
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (errorMessage.isNotEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
            TextButton(
              onPressed: _loadJadwal,
              child: const Text(
                "Coba Lagi",
                style: TextStyle(color: Colors.yellow),
              ),
            ),
          ],
        ),
      );
    }

    if (jadwalShalat == null) return const SizedBox();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Jadwal Shalat",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "$namaKota, ${jadwalShalat!['tanggal']}",
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              const Icon(Icons.mosque, color: Colors.white, size: 28),
            ],
          ),
          const Divider(color: Colors.white30, height: 30),

          // Row untuk Imsak dan Shalat
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _prayerItem("Imsak", jadwalShalat!['imsak']),
                _prayerItem("Subuh", jadwalShalat!['subuh']),
                _prayerItem("Dzuhur", jadwalShalat!['dzuhur']),
                _prayerItem("Ashar", jadwalShalat!['ashar']),
                _prayerItem("Maghrib", jadwalShalat!['maghrib']),
                _prayerItem("Isya", jadwalShalat!['isya']),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _prayerItem(String label, String time) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(color: Colors.white70, fontSize: 10),
          ),
          const SizedBox(height: 4),
          Text(
            time,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: const Color(0xFF588B76),
              radius: 30,
              child: Icon(icon, color: Colors.white, size: 30),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  void _showAlmasuratDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Pilih Jenis Al-Ma'surat",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.wb_sunny, color: Colors.orange),
                title: const Text("Al-Ma'surat Sugro"),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AlMasuratPages(
                        fileName: "sugro.json",
                        title: "Sugro",
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.nights_stay, color: Colors.indigo),
                title: const Text("Al-Ma'surat Kubro"),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AlMasuratPages(
                        fileName: "kubro.json",
                        title: "Kubro",
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
