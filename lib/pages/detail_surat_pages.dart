import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';

class DetailSuratPages extends StatefulWidget {
  final int nomor;

  const DetailSuratPages({super.key, required this.nomor});

  @override
  State<DetailSuratPages> createState() => _DetailSuratPagesState();
}

class _DetailSuratPagesState extends State<DetailSuratPages> {
  Map<String, dynamic>? suratDetail;
  bool isLoading = true;
  final AudioPlayer audioPlayer = AudioPlayer();
  int? playingIndex; // Untuk menandai ayat mana yang sedang diputar

  @override
  void initState() {
    super.initState();
    fectDetailSurat();
  }

  @override
  void dispose() {
    audioPlayer.dispose(); // Bersihkan player saat keluar halaman
    super.dispose();
  }

  Future<void> fectDetailSurat() async {
    final url = Uri.parse("https://equran.id/api/v2/surat/${widget.nomor}");
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          suratDetail = data["data"];
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error: $e");
      setState(() => isLoading = false);
    }
  }

  void playAudio(String url, int index) async {
    try {
      if (playingIndex == index) {
        await audioPlayer.stop();
        setState(() => playingIndex = null);
      } else {
        await audioPlayer.stop();
        await audioPlayer.play(UrlSource(url));
        setState(() => playingIndex = index);
      }

      audioPlayer.onPlayerComplete.listen((event) {
        setState(() => playingIndex = null);
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Gagal memutar audio")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          suratDetail?["namaLatin"] ?? "Memuat...",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF588B76),
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF588B76)),
            )
          : suratDetail == null
          ? const Center(child: Text("Data tidak tersedia"))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: suratDetail!["ayat"].length + 1, // +1 untuk Header
              itemBuilder: (context, index) {
                if (index == 0) return _buildHeader();

                final ayat = suratDetail!["ayat"][index - 1];
                return _buildAyatItem(ayat, index - 1);
              },
            ),
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF588B76), Color(0xFF88B3A1)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            suratDetail!["namaLatin"],
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            "${suratDetail!["arti"]} • ${suratDetail!["jumlahAyat"]} Ayat",
            style: GoogleFonts.poppins(color: Colors.white70),
          ),
          const Divider(color: Colors.white24, height: 30),
          // Bismillah (Kecuali At-Tubah biasanya tetap ada di API)
          Text(
            "بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ",
            style: GoogleFonts.amiri(fontSize: 28, color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAyatItem(dynamic ayat, int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF588B76).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: const Color(0xFF588B76),
                child: Text(
                  ayat["nomorAyat"].toString(),
                  style: const TextStyle(fontSize: 12, color: Colors.white),
                ),
              ),
              const Spacer(),
              IconButton(
                icon: Icon(
                  playingIndex == index
                      ? Icons.stop_circle
                      : Icons.play_circle_fill,
                  color: const Color(0xFF588B76),
                ),
                onPressed: () {
                  // Menggunakan audio dari Misyari Rasyid (biasanya ada di field audio '01')
                  playAudio(ayat["audio"]["05"], index);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(
          ayat["teksArab"],
          textAlign: TextAlign.right,
          style: GoogleFonts.amiri(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            height: 2,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          ayat["teksIndonesia"],
          style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
        ),
        const SizedBox(height: 30),
        const Divider(),
      ],
    );
  }
}
