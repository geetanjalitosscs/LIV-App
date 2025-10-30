import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'threejs_avtar_service.dart';

class AvatarGeneratorService {
  static final AvatarGeneratorService _instance = AvatarGeneratorService._internal();
  static AvatarGeneratorService get instance => _instance;
  
  AvatarGeneratorService._internal();
  
  final ImagePicker _picker = ImagePicker();
  
  // Local avatar generation settings
  static const int _avatarSize = 200;
  static const double _borderRadius = 100.0;
  
  // Pick image from gallery
  Future<File?> pickImageFromGallery() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024.0,
        maxHeight: 1024.0,
        imageQuality: 85,
      );
      
      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      print('Error picking image from gallery: $e');
      return null;
    }
  }
  
  // Pick image from camera (front)
  Future<File?> pickImageFromCameraFront() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        maxWidth: 1024.0,
        maxHeight: 1024.0,
        imageQuality: 85,
      );
      
      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      print('Error picking image from front camera: $e');
      return null;
    }
  }
  
  // Pick image from camera (rear)
  Future<File?> pickImageFromCameraRear() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        maxWidth: 1024.0,
        maxHeight: 1024.0,
        imageQuality: 85,
      );
      
      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      print('Error picking image from rear camera: $e');
      return null;
    }
  }
  
  // Generate 3D avatar using Three.js with specifications
  Future<void> generateAvatar({
    Uint8List? inputImageBytes,
    required String gender,
    required String bodyType,
    required String faceType,
    required bool hasBeard,
    required bool hasGlasses,
    required String hairColor,
    required String eyeColor,
    required String skinTone,
    required String style,
  }) async {
    try {
      final threeJSService = ThreeJSAvtarService.instance;
      // Use the new config-driven builder so web avatar reflects UI-style options
      await threeJSService.initializeAvatarWithConfig({
        'gender': gender,
        'bodyType': bodyType,
        'face': faceType,
        'hair': 'short',
        'hairColor': hairColor,
        'eyeColor': eyeColor,
        'skinTone': skinTone,
        'style': style,
        'accessories': hasBeard ? 'beard' : (hasGlasses ? 'glasses' : 'none'),
        // Provide sensible clothing defaults; callers can extend later
        'top': 'hoodie',
        'bottom': 'jeans',
        'shoes': 'sneakers',
      });
    } catch (e) {
      print('Error generating 3D avatar with Three.js: $e');
    }
  }

  // Generate 3D avatar from text only (no input image)
  Future<void> generateAvatarFromText({
    required String gender,
    required String bodyType,
    required String faceType,
    required bool hasBeard,
    required bool hasGlasses,
    required String hairColor,
    required String eyeColor,
    required String skinTone,
    required String style,
  }) async {
    try {
      final threeJSService = ThreeJSAvtarService.instance;
      await threeJSService.initializeAvatarWithConfig({
        'gender': gender,
        'bodyType': bodyType,
        'face': faceType,
        'hair': 'short',
        'hairColor': hairColor,
        'eyeColor': eyeColor,
        'skinTone': skinTone,
        'style': style,
        'accessories': hasBeard ? 'beard' : (hasGlasses ? 'glasses' : 'none'),
        'top': 'hoodie',
        'bottom': 'jeans',
        'shoes': 'sneakers',
      });
    } catch (e) {
      print('Error generating 3D avatar from text: $e');
    }
  }
  
  // Generate 3D-style avatar using local image processing
  Future<Uint8List?> generate3DAvatar(Uint8List imageBytes) async {
    try {
      final ui.Codec codec = await ui.instantiateImageCodec(imageBytes);
      final ui.FrameInfo frameInfo = await codec.getNextFrame();
      final ui.Image originalImage = frameInfo.image;

      // Create a new image with 3D-style avatar styling
      final ui.PictureRecorder recorder = ui.PictureRecorder();
      final Canvas canvas = Canvas(recorder);
      
      // Create a circular clipping path
      final Path clipPath = Path()
        ..addOval(Rect.fromCircle(
          center: Offset(_avatarSize / 2, _avatarSize / 2),
          radius: _borderRadius,
        ));
      canvas.clipPath(clipPath);

      // Draw the original image scaled to fit the circle
      final Rect destRect = Rect.fromLTWH(0, 0, _avatarSize.toDouble(), _avatarSize.toDouble());
      final Rect srcRect = Rect.fromLTWH(0, 0, 
        originalImage.width.toDouble(), 
        originalImage.height.toDouble()
      );
      
      canvas.drawImageRect(originalImage, srcRect, destRect, Paint());

      // Add a 3D-style border with gradient effect
      final Paint borderPaint = Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFFed4273), Color(0xFFff6b9d), Color(0xFFed4273)],
          stops: [0.0, 0.5, 1.0],
        ).createShader(Rect.fromCircle(
          center: Offset(_avatarSize / 2, _avatarSize / 2),
          radius: _borderRadius,
        ))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6.0;
      
      canvas.drawCircle(
        Offset(_avatarSize / 2, _avatarSize / 2),
        _borderRadius - 3,
        borderPaint,
      );

      // Add inner shadow effect for 3D look
      final Paint shadowPaint = Paint()
        ..color = Colors.black.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      
      canvas.drawCircle(
        Offset(_avatarSize / 2 + 2, _avatarSize / 2 + 2),
        _borderRadius - 5,
        shadowPaint,
      );

      // Convert to image
      final ui.Picture picture = recorder.endRecording();
      final ui.Image avatarImage = await picture.toImage(_avatarSize, _avatarSize);
      final ByteData? byteData = await avatarImage.toByteData(format: ui.ImageByteFormat.png);
      
      if (byteData != null) {
        return byteData.buffer.asUint8List();
      }
      
      return null;
    } catch (e) {
      print('Error generating 3D avatar: $e');
      return null;
    }
  }
  
  // Show image source selection dialog
  Future<File?> showImageSourceDialog() async {
    // This method will be called from the UI to show the selection dialog
    // The actual dialog will be implemented in the UI layer
    return null;
  }
}
