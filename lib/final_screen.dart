import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FinalScreen extends StatelessWidget {
  const FinalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: Text(
      "GOOD JOB",
      style: GoogleFonts.lilitaOne(
        fontSize: 60,
        color: const Color.fromARGB(255, 62, 139, 58),
        fontWeight: FontWeight.w400,
      ),
    )));
  }
}
