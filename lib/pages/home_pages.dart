import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_qolb/pages/surat_pages.dart';
import 'package:my_qolb/pages/almasurat_pages.dart';

class HomePages extends StatelessWidget {
  const HomePages({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Background Dasar Gradient
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF4A7262), // Hijau lebih gelap untuk kontras
                  Color(0xFF588B76),
                  Color(0xFF7CAF9A),
                ],
              ),
            ),
          ),

          // 2. Dekorasi Lingkaran (Aksen Estetik)
          Positioned(
            top: -60,
            right: -60,
            child: CircleAvatar(
              radius: 120,
              backgroundColor: Colors.white.withOpacity(0.1),
            ),
          ),

          // 3. Konten Utama
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),

                // Header Brand
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Assalamualaikum,",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      Text(
                        "Qolb.",
                        style: GoogleFonts.poppins(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Bagian Menu (Container Putih Melengkung)
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Color(
                        0xFFF8FBF9,
                      ), // Putih sedikit keabuan/hijau sangat muda
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 20,
                          offset: Offset(0, -5),
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 30),
                        child: Column(
                          children: [
                            // Garis indikator kecil
                            Container(
                              width: 50,
                              height: 5,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            const SizedBox(height: 30),

                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 30,
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.grid_view_rounded,
                                    color: Color(0xFF588B76),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    "Pilih Menu",
                                    style: GoogleFonts.poppins(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF2D4F42),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Menu Al-Quran
                            _buildMenuCard(
                              context,
                              title: "Al-Quran",
                              subtitle: "Bacaan 114 Surat",
                              icon: Icons.menu_book_rounded,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SuratPages(),
                                ),
                              ),
                            ),

                            // Menu Al-Ma'surat
                            _buildMenuCard(
                              context,
                              title: "Al-Ma'surat",
                              subtitle: "Dzikir Pagi & Petang",
                              icon: Icons.wb_sunny_outlined,
                              onTap: () => _showAlmasuratDialog(context),
                            ),

                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget kartu menu yang dipercantik
  Widget _buildMenuCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF588B76).withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(25),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFF588B76).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(icon, color: const Color(0xFF588B76), size: 30),
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
                          color: const Color(0xFF2D4F42),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAlmasuratDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(30),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(35)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              Text(
                "Pilih Jenis Al-Ma'surat",
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2D4F42),
                ),
              ),
              const SizedBox(height: 25),
              _buildDialogOption(
                context,
                title: "Al-Ma'surat Sugro",
                icon: Icons.wb_sunny_rounded,
                iconColor: Colors.orangeAccent,
                fileName: "sugro.json",
                displayTitle: "Sugro",
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Divider(thickness: 1),
              ),
              _buildDialogOption(
                context,
                title: "Al-Ma'surat Kubro",
                icon: Icons.nights_stay_rounded,
                iconColor: Colors.indigoAccent,
                fileName: "kubro.json",
                displayTitle: "Kubro",
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDialogOption(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color iconColor,
    required String fileName,
    required String displayTitle,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor),
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16),
      ),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                AlMasuratPages(fileName: fileName, title: displayTitle),
          ),
        );
      },
    );
  }
}
