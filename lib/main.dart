import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

List<CameraDescription> _availableCameras = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    _availableCameras = await availableCameras();
  } on CameraException catch (e) {
    debugPrint('Camera Error: ${e.description}');
  }
  runApp(const InstagramVisionApp());
}

class InstagramVisionApp extends StatelessWidget {
  const InstagramVisionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(brightness: Brightness.dark),
      home: const CameraPortal(),
    );
  }
}

class CameraPortal extends StatefulWidget {
  const CameraPortal({super.key});

  @override
  State<CameraPortal> createState() => _CameraPortalState();
}

class _CameraPortalState extends State<CameraPortal> {
  CameraController? _controller;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    if (_availableCameras.isEmpty) return;

    // Use ResolutionPreset.high for that crisp Instagram quality
    _controller = CameraController(
      _availableCameras[0],
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.bgra8888,
    );

    try {
      await _controller!.initialize();
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint("Camera init failed: $e");
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. FULL SCREEN INSTAGRAM-STYLE PREVIEW
          // We wrap the preview in a SizedBox that fills the screen
          SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.cover, // This crops the 16:9 feed to fit your 19.5:9 screen
              child: SizedBox(
                width: _controller!.value.previewSize!.height,
                height: _controller!.value.previewSize!.width,
                child: CameraPreview(_controller!),
              ),
            ),
          ),

          // 2. SEMI-TRANSPARENT OVERLAYS (Like Story UI)
          Positioned(
            top: 60,
            left: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black38,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                children: [
                  Icon(Icons.flash_on, color: Colors.white, size: 18),
                  SizedBox(width: 10),
                  Text("16:9 aspect ratio", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),

          // 3. YOLO FOCUS BOX
          Center(
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}