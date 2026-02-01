import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AlMasuratPages extends StatelessWidget {
  final String fileName;
  final String title;

  const AlMasuratPages({
    super.key,
    required this.fileName,
    required this.title,
  });

  // Fungsi untuk memuat data dari folder lib/data/
  Future<List<dynamic>> loadJsonData() async {
    final String response = await rootBundle.loadString('lib/data/$fileName');
    return json.decode(response);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Al-Ma'surat $title",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF588B76),
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder(
        future: loadJsonData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF588B76)),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text("Terjadi kesalahan: ${snapshot.error}"));
          } else if (!snapshot.hasData || (snapshot.data as List).isEmpty) {
            return const Center(child: Text("Data kosong"));
          } else {
            final data = snapshot.data as List<dynamic>;
            return ListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: data.length,
              itemBuilder: (context, index) {
                final item = data[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Judul Bacaan & Jumlah Pengulangan
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                item['title'] ?? '',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF588B76),
                                ),
                              ),
                            ),
                            if (item['repeat'] != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF588B76,
                                    // ignore: deprecated_member_use
                                  ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  "Ulang: ${item['repeat']}x",
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const Divider(height: 25),

                        // Teks Arab
                        Text(
                          item['core'] ?? '',
                          textAlign: TextAlign.right,
                          style: GoogleFonts.amiri(
                            // Gunakan font Arab jika ada, atau default
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            height: 2,
                          ),
                        ),
                        const SizedBox(height: 15),

                        // Latin
                        Text(
                          item['latin'] ?? '',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontStyle: FontStyle.italic,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Terjemahan
                        Text(
                          item['terjemah'] ?? '',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
