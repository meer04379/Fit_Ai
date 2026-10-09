import 'dart:ui' as ui;
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/app_colors.dart';
import 'analyzing_meal_screen.dart';

class FoodScannerScreen extends StatefulWidget {
  const FoodScannerScreen({super.key});

  @override
  State<FoodScannerScreen> createState() => _FoodScannerScreenState();
}

class _FoodScannerScreenState extends State<FoodScannerScreen>
    with SingleTickerProviderStateMixin {
  List<CameraDescription> _cameras = [];
  CameraController? _cameraController;
  int _selectedCameraIndex = 0;
  bool _isCameraInitialized = false;
  bool _isInitializing = true;
  String? _cameraError;
  bool _isFlashOn = false;
  bool _isLoadingCapture = false;
  late AnimationController _pulseController;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _initCamera();
  }

  Future<void> _initCamera() async {
    setState(() {
      _isInitializing = true;
      _cameraError = null;
    });

    try {
      // Set a 3.5 second safety timeout so it never hangs indefinitely
      await Future.any([
        _startCameraSetup(),
        Future.delayed(const Duration(seconds: 4), () {
          if (!_isCameraInitialized) {
            throw Exception('Camera initialization timed out. Please allow camera access in browser.');
          }
        }),
      ]);
    } catch (e) {
      debugPrint('[Camera] Init exception: $e');
      if (mounted) {
        setState(() {
          _isCameraInitialized = false;
          _isInitializing = false;
          _cameraError = 'Camera access not allowed or webcam in use by another app.';
        });
      }
    }
  }

  Future<void> _startCameraSetup() async {
    _cameras = await availableCameras();
    if (_cameras.isNotEmpty) {
      int rearIndex = _cameras.indexWhere(
          (c) => c.lensDirection == CameraLensDirection.back);
      _selectedCameraIndex = rearIndex != -1 ? rearIndex : 0;
      await _setupController(_cameras[_selectedCameraIndex]);
    } else {
      if (mounted) {
        setState(() {
          _isCameraInitialized = false;
          _isInitializing = false;
          _cameraError = 'No camera found on this device.';
        });
      }
    }
  }

  Future<void> _setupController(CameraDescription camera) async {
    final oldController = _cameraController;
    if (oldController != null) {
      await oldController.dispose();
    }

    final controller = CameraController(
      camera,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    try {
      await controller.initialize();
      if (mounted) {
        setState(() {
          _cameraController = controller;
          _isCameraInitialized = true;
          _isInitializing = false;
          _cameraError = null;
        });
      }
    } catch (e) {
      debugPrint('[Camera] Controller setup error: $e');
      if (mounted) {
        setState(() {
          _isCameraInitialized = false;
          _isInitializing = false;
          _cameraError = 'Please allow camera permission in browser address bar.';
        });
      }
    }
  }

  Future<void> _flipCamera() async {
    if (_cameras.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Only 1 camera found on this laptop/device'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      _isCameraInitialized = false;
      _isInitializing = true;
    });

    _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras.length;
    await _setupController(_cameras[_selectedCameraIndex]);
  }

  Future<void> _toggleFlash() async {
    if (_cameraController == null || !_isCameraInitialized) return;
    try {
      _isFlashOn = !_isFlashOn;
      await _cameraController!.setFlashMode(
        _isFlashOn ? FlashMode.torch : FlashMode.off,
      );
      setState(() {});
    } catch (e) {
      debugPrint('[Camera] Flash toggle note: $e');
    }
  }

  Future<Uint8List> _downscaleImageBytes(Uint8List rawBytes) async {
    if (rawBytes.lengthInBytes <= 400 * 1024) return rawBytes;
    try {
      final codec = await ui.instantiateImageCodec(
        rawBytes,
        targetWidth: 1024,
      );
      final frame = await codec.getNextFrame();
      final byteData = await frame.image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData != null) {
        return byteData.buffer.asUint8List();
      }
    } catch (e) {
      debugPrint('[FoodScanner] Downscale error: $e');
    }
    return rawBytes;
  }

  Future<void> _capturePhoto() async {
    if (_isLoadingCapture) return;

    if (_cameraController != null && _isCameraInitialized) {
      try {
        setState(() => _isLoadingCapture = true);
        final XFile file = await _cameraController!.takePicture();
        final Uint8List rawBytes = await file.readAsBytes();
        final Uint8List optimizedBytes = await _downscaleImageBytes(rawBytes);
        setState(() => _isLoadingCapture = false);

        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AnalyzingMealScreen(
                imageBytes: optimizedBytes,
                imagePath: file.path,
              ),
            ),
          );
        }
        return;
      } catch (e) {
        debugPrint('[Camera] Take picture error: $e');
        setState(() => _isLoadingCapture = false);
      }
    }

    // Direct Camera Picker Trigger
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: _isFrontCamera
            ? CameraDevice.front
            : CameraDevice.rear,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (photo != null) {
        final bytes = await photo.readAsBytes();
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AnalyzingMealScreen(
                imageBytes: bytes,
                imagePath: photo.path,
              ),
            ),
          );
        }
        return;
      }
    } catch (_) {}

    // Fallback: Pick from gallery or sample
    _pickFromGallery();
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (photo != null) {
        final bytes = await photo.readAsBytes();
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AnalyzingMealScreen(
                imageBytes: bytes,
                imagePath: photo.path,
              ),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('[Camera] Gallery pick error: $e');
    }
  }

  void _testWithSampleFood() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AnalyzingMealScreen(),
      ),
    );
  }

  bool get _isFrontCamera {
    if (_cameras.isEmpty || _selectedCameraIndex >= _cameras.length) return false;
    return _cameras[_selectedCameraIndex].lensDirection == CameraLensDirection.front;
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 1. If camera is NOT initialized and NOT initializing, show dedicated clickable fallback screen
    if (!_isCameraInitialized && !_isInitializing) {
      return Scaffold(
        backgroundColor: const Color(0xFF090D10),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.white, size: 24),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'AI Food Scanner',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
        ),
        body: _buildFallbackView(),
      );
    }

    // 2. If camera is initializing, show connecting screen with direct fallback options
    if (_isInitializing) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.white, size: 24),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Connecting Camera...',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(AppColors.primary),
              ),
              const SizedBox(height: 20),
              const Text(
                'Starting camera stream...',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: _pickFromGallery,
                icon: const Icon(Icons.photo_library_outlined, size: 18),
                label: const Text('Upload Photo Instead'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white30),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 3. Live Camera Viewfinder with overlay controls
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Camera Feed
          Positioned.fill(
            child: _buildCameraPreview(),
          ),

          // 2. Overlay Scanner Reticle & Controls
          SafeArea(
            child: Column(
              children: [
                // Top Header Row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Close Button
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.close, color: Colors.white, size: 24),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),

                      // Title
                      const Text(
                        'AI Food Scanner',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),

                      // Flash Toggle
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(
                            _isFlashOn ? Icons.flash_on : Icons.flash_off,
                            color: _isFlashOn ? AppColors.warning : Colors.white,
                            size: 22,
                          ),
                          onPressed: _toggleFlash,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 6),

                // Camera Mode Indicator Tag
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _isFrontCamera ? const Color(0xFF38BDF8) : AppColors.primary,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _isFrontCamera ? Icons.face_rounded : Icons.restaurant_rounded,
                        color: _isFrontCamera ? const Color(0xFF38BDF8) : AppColors.primary,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _isFrontCamera ? '🤳 Front Camera (Selfie)' : '📷 Back Camera (Food)',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Center Reticle Scanner Target (Ignored for pointers so it never blocks clicks)
                IgnorePointer(
                  child: AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      final scale = 1.0 + (_pulseController.value * 0.03);
                      final color = _isFrontCamera ? const Color(0xFF38BDF8) : AppColors.primary;

                      return Transform.scale(
                        scale: scale,
                        child: Container(
                          width: 270,
                          height: 270,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(
                              color: color.withValues(alpha: 0.8),
                              width: 2.5,
                            ),
                          ),
                          child: Stack(
                            children: [
                              _buildCorner(Alignment.topLeft, color),
                              _buildCorner(Alignment.topRight, color),
                              _buildCorner(Alignment.bottomLeft, color),
                              _buildCorner(Alignment.bottomRight, color),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 16),

                // Helper Text Prompt
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _isFrontCamera
                        ? 'Align food or selfie inside frame'
                        : 'Center your food in the frame',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),

                const Spacer(),

                // Bottom Camera Control Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 36.0, vertical: 24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Gallery Upload Button
                      GestureDetector(
                        onTap: _pickFromGallery,
                        behavior: HitTestBehavior.opaque,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                              ),
                              child: const Icon(Icons.photo_library_rounded, color: Colors.white, size: 24),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Gallery',
                              style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),

                      // Large Shutter Capture Button
                      GestureDetector(
                        onTap: _capturePhoto,
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          width: 82,
                          height: 82,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                          ),
                          padding: const EdgeInsets.all(4),
                          child: Container(
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                            child: Center(
                              child: _isLoadingCapture
                                  ? const SizedBox(
                                      width: 28,
                                      height: 28,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 3,
                                        valueColor: AlwaysStoppedAnimation(AppColors.primary),
                                      ),
                                    )
                                  : Container(
                                      width: 58,
                                      height: 58,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: _isFrontCamera ? const Color(0xFF0284C7) : AppColors.primary,
                                      ),
                                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 30),
                                    ),
                            ),
                          ),
                        ),
                      ),

                      // Flip Camera Button (Front <-> Back)
                      GestureDetector(
                        onTap: _flipCamera,
                        behavior: HitTestBehavior.opaque,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: _isFrontCamera
                                    ? const Color(0xFF0284C7).withValues(alpha: 0.8)
                                    : Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: _isFrontCamera
                                      ? const Color(0xFF38BDF8)
                                      : Colors.white.withValues(alpha: 0.2),
                                ),
                              ),
                              child: const Icon(Icons.flip_camera_ios_rounded, color: Colors.white, size: 24),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _isFrontCamera ? 'Front 🤳' : 'Back 📷',
                              style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraPreview() {
    if (_isCameraInitialized && _cameraController != null) {
      return LayoutBuilder(
        builder: (context, constraints) {
          return SizedBox(
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _cameraController!.value.previewSize?.height ?? constraints.maxWidth,
                height: _cameraController!.value.previewSize?.width ?? constraints.maxHeight,
                child: CameraPreview(_cameraController!),
              ),
            ),
          );
        },
      );
    }
    return const SizedBox();
  }

  Widget _buildFallbackView() {
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.4), width: 2),
                ),
                child: const Icon(Icons.camera_alt_outlined, color: AppColors.primary, size: 38),
              ),
              const SizedBox(height: 18),
              const Text(
                'Food Scanner Ready',
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                _cameraError ?? 'Select a meal photo to analyze nutrition with Gemini AI, or retry camera.',
                style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),

              // Action 1: Upload Photo (Primary Large Button)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _pickFromGallery,
                  icon: const Icon(Icons.file_upload_outlined, size: 22),
                  label: const Text(
                    'Upload Food Photo',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 3,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Action 2: Try Sample Food Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _testWithSampleFood,
                  icon: const Icon(Icons.fastfood_rounded, size: 20, color: AppColors.warning),
                  label: const Text(
                    'Try Sample Food (Biryani Demo)',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: Colors.white24),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Action 3: Retry Webcam Button
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: _initCamera,
                  icon: const Icon(Icons.refresh_rounded, size: 20, color: Colors.white70),
                  label: const Text(
                    'Retry Webcam Connection',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white70),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Info card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white10),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, color: Colors.white54, size: 18),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Tip: To use live camera on Chrome, click the Lock / Settings icon (🔒) in the address bar next to localhost, allow Camera, then click "Retry Webcam".',
                        style: TextStyle(color: Colors.white54, fontSize: 12, height: 1.3),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCorner(Alignment alignment, Color color) {
    return Align(
      alignment: alignment,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          border: Border(
            top: alignment == Alignment.topLeft || alignment == Alignment.topRight
                ? BorderSide(color: color, width: 4)
                : BorderSide.none,
            bottom: alignment == Alignment.bottomLeft || alignment == Alignment.bottomRight
                ? BorderSide(color: color, width: 4)
                : BorderSide.none,
            left: alignment == Alignment.topLeft || alignment == Alignment.bottomLeft
                ? BorderSide(color: color, width: 4)
                : BorderSide.none,
            right: alignment == Alignment.topRight || alignment == Alignment.bottomRight
                ? BorderSide(color: color, width: 4)
                : BorderSide.none,
          ),
        ),
      ),
    );
  }
}
