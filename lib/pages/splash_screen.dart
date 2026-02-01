import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_qolb/pages/home_pages.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Reload 3 menit
    Future.delayed(Duration(seconds: 10), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const HomePages(),
        ), // Ganti ke HomePages
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF588B76), Color(0xFF588B26)],
          ),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Qolb.",
              style: GoogleFonts.poppins(
                fontSize: 100,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.none,
                color: Colors.white,
              ),
            ),
            Text(
              "by: mikodev",
              style: GoogleFonts.poppins(
                color: Colors.white,
                decoration: TextDecoration.none,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
