import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  bool _isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  void _initializeCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    _controller = CameraController(
      cameras.first,
      ResolutionPreset.max,
      enableAudio: false,
    );

    try {
      await _controller!.initialize();
      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Error inicializando cámara: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Vista previa de la cámara
            CameraPreview(_controller!),
            
            // Guía de alineación
            Center(
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),

            // Instrucciones y controles
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(20),
                color: Colors.black54,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Alinea el dibujo dentro del marco',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.flip_camera_android, color: Colors.white, size: 32),
                          onPressed: () async {
                            final cameras = await availableCameras();
                            final newCameraIndex = 
                                _controller!.description == cameras.first ? 1 : 0;
                            if (newCameraIndex < cameras.length) {
                              await _controller!.dispose();
                              setState(() {
                                _controller = CameraController(
                                  cameras[newCameraIndex],
                                  ResolutionPreset.max,
                                  enableAudio: false,
                                );
                                _controller!.initialize().then((_) {
                                  if (mounted) setState(() {});
                                });
                              });
                            }
                          },
                        ),
                        FloatingActionButton(
                          onPressed: () async {
                            try {
                              final image = await _controller!.takePicture();
                              debugPrint('Imagen capturada: ${image.path}');
                              // Aquí podrías procesar la imagen o mostrarla
                            } catch (e) {
                              debugPrint('Error al capturar: $e');
                            }
                          },
                          backgroundColor: Colors.white,
                          child: const Icon(Icons.camera, color: Colors.black),
                        ),
                        IconButton(
                          icon: const Icon(Icons.flash_off, color: Colors.white, size: 32),
                          onPressed: () async {
                            // Alternar flash
                            if (_controller!.value.flashMode == FlashMode.off) {
                              await _controller!.setFlashMode(FlashMode.torch);
                            } else {
                              await _controller!.setFlashMode(FlashMode.off);
                            }
                            setState(() {});
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}