import 'package:alemeno_task/camera_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Align(
        alignment: Alignment.bottomCenter,
        heightFactor: 13,
        child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => CameraScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 62, 139, 58),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(35))),
            child: Text("Share your meal",
                style: GoogleFonts.andika(fontWeight: FontWeight.w400))),
      ),
    );
  }
}
