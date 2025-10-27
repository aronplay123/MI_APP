import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Pantalla de escaneo que muestra la cámara a pantalla completa.
class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> with WidgetsBindingObserver {
  CameraController? _controller;
  bool _isCameraInitialized = false;
  bool _hasError = false;
  String _errorMessage = '';
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void dispose() {
    _isDisposed = true;
    WidgetsBinding.instance.removeObserver(this);
    _disposeCamera();
    super.dispose();
  }

  Future<void> _disposeCamera() async {
    final CameraController? controller = _controller;
    if (controller != null && controller.value.isInitialized) {
      await controller.dispose();
    }
    if (!_isDisposed) {
      setState(() {
        _controller = null;
        _isCameraInitialized = false;
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_controller == null || !_controller!.value.isInitialized) return;

    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      _disposeCamera();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    try {
      // Reset error state
      setState(() {
        _hasError = false;
        _errorMessage = '';
      });

      // Get available cameras
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        throw CameraException('no_cameras', 'No cameras available');
      }

      // Select back camera
      final backCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      // Initialize controller with specific settings
      final controller = CameraController(
        backCamera,
        ResolutionPreset.max,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.bgra8888,
      );

      // Listen for errors during initialization
      controller.addListener(() {
        if (controller.value.hasError && mounted) {
          setState(() {
            _hasError = true;
            _errorMessage = 'Camera error: ${controller.value.errorDescription}';
          });
        }
      });

      try {
        await controller.initialize();
        
        // Configure additional settings after initialization
        await controller.lockCaptureOrientation(DeviceOrientation.portraitUp);
        await controller.setFlashMode(FlashMode.off);
        await controller.setFocusMode(FocusMode.auto);
        await controller.setExposureMode(ExposureMode.auto);
        
        if (!_isDisposed && mounted) {
          setState(() {
            _controller = controller;
            _isCameraInitialized = true;
          });
        } else {
          await controller.dispose();
        }
      } catch (e) {
        await controller.dispose();
        if (mounted) {
          setState(() {
            _hasError = true;
            _errorMessage = 'Failed to initialize camera: $e';
          });
        }
        return;
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = 'Camera initialization error: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Camera preview or error/loading state
            if (_hasError) 
              _buildErrorDisplay()
            else if (_controller != null && _isCameraInitialized)
              _buildCameraPreview()
            else
              const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),

            // Transparent AppBar
            _buildAppBar(),

            // Detection area placeholder
            if (!_hasError && _isCameraInitialized) 
              _buildDetectionArea(),

            // Help text
            if (!_hasError)
              _buildHelpText(),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorDisplay() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _initializeCamera,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraPreview() {
    return Transform.scale(
      scale: 1.0,
      child: AspectRatio(
        aspectRatio: 1 / _controller!.value.aspectRatio,
        child: CameraPreview(_controller!),
      ),
    );
  }

  Widget _buildAppBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        color: Colors.black26,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _buildDetectionArea() {
    return Center(
      child: Container(
        width: 260,
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white70, width: 2),
          color: Colors.black12,
        ),
      ),
    );
  }

  Widget _buildHelpText() {
    return Positioned(
      bottom: 24,
      left: 24,
      right: 24,
      child: Text(
        'Apunta tu cámara al dibujo para comenzar la detección',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Colors.white70,
          fontSize: 14,
        ),
      ),
    );
  }
}
