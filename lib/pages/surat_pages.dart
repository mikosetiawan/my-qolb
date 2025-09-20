import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:my_qolb/pages/detail_surat_pages.dart';
import 'package:url_launcher/url_launcher.dart';

class SuratPages extends StatefulWidget {
  const SuratPages({super.key});

  @override
  State<SuratPages> createState() => _SuratPagesState();
}

class _SuratPagesState extends State<SuratPages> {
  List<dynamic> suratList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fecthSurat();
  }

  // Buat fectSuratnya
  Future<void> fecthSurat() async {
    final url = Uri.parse("https://equran.id/api/v2/surat");

    try {
      final response = await http.get(url);
      // kondisi
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          suratList = data["data"];
          isLoading = false;
        });
      } else {
        throw Exception("Gagal reload data surat!");
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Qolb.",
          style: GoogleFonts.poppins(
            color: Color(0xFF588B76),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Color(0xFF588B76)),
            onPressed: () async {
              const url = "https://github.com/mikosetiawan"; // link GitHub
              final Uri uri = Uri.parse(url);

              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              } else {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Tidak bisa membuka link")),
                );
              }
            },
          ),
        ],
      ),

      body: Column(
        children: [
          Align(
            child: Container(
              alignment: Alignment.topCenter,
              width: 200,
              height: 250,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF588B76), Color(0xFFD0DED8)],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(150),
                  bottomRight: Radius.circular(150),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 100.0),
                child: Image.asset("assets/images/quran.png"),
              ),
            ),
          ),

          Expanded(
            child: isLoading
                ? Center(
                    child: CircularProgressIndicator(color: Color(0xFF588B76)),
                  )
                : ListView.builder(
                    itemCount: suratList.length,
                    itemBuilder: (context, index) {
                      final surat = suratList[index];
                      return Card(
                        margin: EdgeInsets.symmetric(
                          vertical: 6,
                          horizontal: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Color(0xFF588B76),
                            child: Text(
                              surat["nomor"].toString(),
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          title: Text(
                            surat["namaLatin"]!,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            "Jumlah Ayat: ${surat["jumlahAyat"].toString()}",
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    DetailSuratPages(nomor: surat["nomor"]),
                              ),
                            );
                            // Nanti bisa diarahkan ke detail surat
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Baca: ${surat["namaLatin"]}"),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
