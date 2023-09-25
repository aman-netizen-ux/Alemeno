import 'dart:io';
import 'dart:math';
import 'package:alemeno_task/final_screen.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  bool _isCaptured = false;
  XFile?
      _capturedImage; //this variable stores the path to the captured image file
  final firebase_storage.Reference _storageReference =
      firebase_storage.FirebaseStorage.instance.ref();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

//dialog box which will be shown when the image is uploaded on the firebase
  Future<void> showSuccessDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Thank you for sharing food with me'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Your food is shared with me . It is looking tasty :))'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

//This function initializes the camera
  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    _controller = CameraController(
      firstCamera,
      ResolutionPreset.medium,
    );

    await _controller!.initialize();
    if (!mounted) {
      return;
    }
    setState(() {});
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

//This function captures the image, shows it on the screen, and uploads the same to the firebase.
  Future<void> _captureImage() async {
    try {
      final XFile capturedImage = await _controller!.takePicture();
      // Set flash mode to off after capturing the image
      await _controller!.setFlashMode(FlashMode.off);

      setState(() {
        _capturedImage = capturedImage;
        _isCaptured = true;
      });

      // Generate a unique image name using timestamp and a random string
      final imageName =
          '${DateTime.now().millisecondsSinceEpoch}_${_randomString(5)}.jpg';

      // Upload the captured image to Firebase Storage
      final file = File(capturedImage.path);
      final firebase_storage.Reference imageReference =
          _storageReference.child('images/$imageName');

      await imageReference.putFile(file);

      // download URL of the uploaded image for later use
      final imageUrl = await imageReference.getDownloadURL();

      debugPrint('Image uploaded to Firebase Storage. URL: $imageUrl');
      showSuccessDialog(context);
    } catch (e) {
      debugPrint(e as String?);
    }
  }

  String _randomString(int length) {
    const charset =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SafeArea(
        child: _controller != null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 62, 139, 58),
                            shape: const CircleBorder()),
                        child: const Icon(
                          Icons.arrow_back,
                          size: 40,
                        )),
                  ),
                  Expanded(
                      flex: 4,
                      child: Image.asset(
                        height: 350,
                        width: 350,
                        'assets/images/babyS.png',
                        alignment: Alignment.bottomCenter,
                      )),
                  Expanded(
                    flex: 6,
                    child: Container(
                      width: screenWidth,
                      decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(55),
                              topRight: Radius.circular(55)),
                          color: Color.fromARGB(255, 243, 240, 240)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Image.asset('assets/images/scanfood.png'),
                                _isCaptured
                                    ? _capturedImage != null
                                        ? Container(
                                            width: 250,
                                            height: 250,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                  color: const Color.fromARGB(
                                                      118, 255, 255, 255),
                                                  width: 4.0),
                                            ),
                                            child: ClipOval(
                                              child: Image.file(
                                                File(_capturedImage!.path),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          )
                                        : const CircularProgressIndicator()
                                    : Container(
                                        width: 200,
                                        height: 200,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Color.fromARGB(
                                              118, 255, 255, 255),
                                        ),
                                        child: ClipOval(
                                          child: CameraPreview(_controller!),
                                        ),
                                      )
                              ],
                            ),
                          ),
                          const SizedBox(height: 16.0),
                          Text(
                            _isCaptured
                                ? "Will you eat this?"
                                : "Share your meal",
                            style: GoogleFonts.andika(
                              fontWeight: FontWeight.w400,
                              fontSize: 40,
                            ),
                          ),
                          const SizedBox(height: 16.0),
                          _isCaptured
                              ? ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            const FinalScreen(),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color.fromARGB(
                                          255, 62, 139, 58),
                                      shape: const CircleBorder()),
                                  child: const Icon(
                                    Icons.check,
                                    size: 70,
                                  ))
                              : ElevatedButton(
                                  onPressed: _isCaptured ? null : _captureImage,
                                  style: ElevatedButton.styleFrom(
                                      minimumSize: const Size.fromHeight(60),
                                      backgroundColor: const Color.fromARGB(
                                          255, 62, 139, 58),
                                      shape: const CircleBorder()),
                                  child: const Icon(Icons.camera_alt, size: 40),
                                ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            : const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
