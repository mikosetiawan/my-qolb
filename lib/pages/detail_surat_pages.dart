import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DetailSuratPages extends StatefulWidget {
  final int nomor;

  const DetailSuratPages({super.key, required this.nomor});

  @override
  State<DetailSuratPages> createState() => _DetailSuratPagesState();
}

class _DetailSuratPagesState extends State<DetailSuratPages> {
  Map<String, dynamic>? suratDetail;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fectDetailSurat();
  }

  // Buat fecth Detail suratnya
  Future<void> fectDetailSurat() async {
    final url = Uri.parse("https://equran.id/api/v2/surat/${widget.nomor}");

    try {
      final response = await http.get(url);
      // kondisi
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          suratDetail = data["data"];
          isLoading = false;
        });
      } else {
        throw Exception("Gagal reload data detail!");
      }
    } catch (e) {
      print("Error: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(suratDetail?["namaLatin"] ?? "Loading...")),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF588B76)),
            )
          : suratDetail == null
          ? const Center(child: Text("Data tidak tersedia"))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: suratDetail!["ayat"].length,
              itemBuilder: (context, index) {
                final ayat = suratDetail!["ayat"][index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Color(0xFF588B76),
                      child: Text(
                        ayat["nomorAyat"].toString(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(
                      ayat["teksArab"],
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontSize: 20),
                    ),
                    subtitle: Text(
                      ayat["teksIndonesia"],
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
