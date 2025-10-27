import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:permission_handler/permission_handler.dart';

class MLScanScreen extends StatefulWidget {
  const MLScanScreen({super.key});

  @override
  State<MLScanScreen> createState() => _MLScanScreenState();
}

class _MLScanScreenState extends State<MLScanScreen> {
  bool _isPermissionGranted = false;
  late final Future<void> _future;
  CameraController? _cameraController;
  ImageLabeler? _imageLabeler;
  bool _isBusy = false;

  @override
  void initState() {
    super.initState();
    _future = _requestCameraPermission();
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    _isPermissionGranted = status == PermissionStatus.granted;
    
    // Inicializar el labeler
    final modelPath = 'assets/ml/object_labeler.tflite';
    final options = LocalLabelerOptions(modelPath: modelPath);
    _imageLabeler = ImageLabeler(options: options);

    if (_isPermissionGranted) {
      _initializeCamera();
    }
  }

  void _initializeCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    _cameraController = CameraController(
      cameras.first, 
      ResolutionPreset.medium,
      enableAudio: false,
    );

    await _cameraController?.initialize();
    await _cameraController?.startImageStream(_processImage);
    
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _processImage(CameraImage image) async {
    if (_isBusy) return;
    _isBusy = true;

    try {
      // Convertir la imagen a formato InputImage
      final inputImage = InputImage.fromBytes(
        bytes: image.planes[0].bytes,
        metadata: InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: InputImageRotation.rotation0deg,
          format: InputImageFormat.bgra8888,
          bytesPerRow: image.planes[0].bytesPerRow,
        ),
      );

      final labels = await _imageLabeler?.processImage(inputImage);
      
      if (labels != null && labels.isNotEmpty) {
        for (final label in labels) {
          debugPrint('Label: ${label.label}, Confidence: ${label.confidence}');
          // Aquí puedes implementar la lógica para mostrar el modelo 3D
          // cuando se detecte el dibujo específico
        }
      }
    } catch (e) {
      debugPrint('Error procesando imagen: $e');
    }

    _isBusy = false;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _future,
      builder: (context, snapshot) {
        return Stack(
          children: [
            if (_cameraController?.value.isInitialized ?? false)
              CameraPreview(_cameraController!)
            else
              const Center(child: CircularProgressIndicator()),
            Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Apunta al dibujo para detectarlo',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _imageLabeler?.close();
    super.dispose();
  }
}