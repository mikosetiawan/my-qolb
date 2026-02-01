import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/shalat_model.dart';

class ShalatService {
  // Ganti baseUrl sesuai dengan endpoint API yang Anda gunakan
  static const String baseUrl = "https://api.myqolb.com/v1/shalat";

  // 1. Ambil Semua Provinsi
  Future<List<String>> getProvinsi() async {
    final response = await http.get(Uri.parse("$baseUrl/provinsi"));
    if (response.statusCode == 200) {
      return List<String>.from(jsonDecode(response.body)['data']);
    }
    throw "Gagal memuat provinsi";
  }

  // 2. Ambil Kota berdasarkan Provinsi
  Future<List<String>> getKota(String provinsi) async {
    final response = await http.get(Uri.parse("$baseUrl/kota/$provinsi"));
    if (response.statusCode == 200) {
      return List<String>.from(jsonDecode(response.body)['data']);
    }
    throw "Gagal memuat kota";
  }

  // 3. Ambil Jadwal Shalat harian
  Future<ShalatJadwal?> getJadwalHarian(String kota, String provinsi) async {
    final now = DateTime.now();
    final url = "$baseUrl/jadwal/$provinsi/$kota/${now.year}/${now.month}";

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List jadwalList = jsonDecode(response.body)['data']['jadwal'];
        // Cari jadwal yang tanggalnya sesuai hari ini
        final hariIni = jadwalList.firstWhere(
          (item) => item['tanggal'] == now.day,
          orElse: () => jadwalList[0],
        );
        return ShalatJadwal.fromJson(hariIni);
      }
    } catch (e) {
      print("Error: $e");
    }
    return null;
  }
}
