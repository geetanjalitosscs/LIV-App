import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class Avtar2DService {
  static final Avtar2DService _instance = Avtar2DService._internal();
  factory Avtar2DService() => _instance;
  Avtar2DService._internal();

  static Avtar2DService get instance => _instance;

  /// Generate a 2D avatar image based on specifications
  Future<Uint8List?> generateAvatarImage({
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
      // Create a custom painter for the avatar
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final size = const Size(400, 400);

      // Draw the avatar
      _drawAvatar(canvas, size, {
        'gender': gender,
        'bodyType': bodyType,
        'faceType': faceType,
        'hasBeard': hasBeard,
        'hasGlasses': hasGlasses,
        'hairColor': hairColor,
        'eyeColor': eyeColor,
        'skinTone': skinTone,
        'style': style,
      });

      // Convert to image
      final picture = recorder.endRecording();
      final image = await picture.toImage(size.width.toInt(), size.height.toInt());
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      
      picture.dispose();
      image.dispose();

      return byteData?.buffer.asUint8List();
    } catch (e) {
      print('Error generating 2D avatar: $e');
      return null;
    }
  }

  void _drawAvatar(Canvas canvas, Size size, Map<String, dynamic> props) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    
    // Background
    final backgroundPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), backgroundPaint);

    // Calculate proportions based on 8-head figure
    final headUnit = size.height / 8;
    
    // Head
    final headRadius = headUnit * 0.8;
    final headCenterY = headUnit * 1.5;
    
    // Draw head
    final headPaint = Paint()
      ..color = _getSkinColor(props['skinTone'])
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(
      Offset(centerX, headCenterY),
      headRadius,
      headPaint,
    );

    // Draw hair
    final hairPaint = Paint()
      ..color = _getHairColor(props['hairColor'])
      ..style = PaintingStyle.fill;
    
    final hairRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(centerX, headCenterY - headRadius * 0.3),
        width: headRadius * 2.2,
        height: headRadius * 1.2,
      ),
      const Radius.circular(20),
    );
    canvas.drawRRect(hairRect, hairPaint);

    // Draw eyes
    final eyePaint = Paint()
      ..color = _getEyeColor(props['eyeColor'])
      ..style = PaintingStyle.fill;
    
    // Left eye
    canvas.drawCircle(
      Offset(centerX - headRadius * 0.3, headCenterY - headRadius * 0.2),
      headRadius * 0.08,
      eyePaint,
    );
    
    // Right eye
    canvas.drawCircle(
      Offset(centerX + headRadius * 0.3, headCenterY - headRadius * 0.2),
      headRadius * 0.08,
      eyePaint,
    );

    // Draw nose
    final nosePaint = Paint()
      ..color = _getSkinColor(props['skinTone']).withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(
      Offset(centerX, headCenterY + headRadius * 0.1),
      headRadius * 0.05,
      nosePaint,
    );

    // Draw mouth
    final mouthPaint = Paint()
      ..color = Colors.red[300]!
      ..style = PaintingStyle.fill;
    
    final mouthRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(centerX, headCenterY + headRadius * 0.4),
        width: headRadius * 0.4,
        height: headRadius * 0.15,
      ),
      const Radius.circular(8),
    );
    canvas.drawRRect(mouthRect, mouthPaint);

    // Draw beard (if applicable)
    if (props['hasBeard'] && props['gender'] == 'male') {
      final beardPaint = Paint()
        ..color = _getHairColor(props['hairColor'])
        ..style = PaintingStyle.fill;
      
      final beardRect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(centerX, headCenterY + headRadius * 0.6),
          width: headRadius * 1.2,
          height: headRadius * 0.4,
        ),
        const Radius.circular(15),
      );
      canvas.drawRRect(beardRect, beardPaint);
    }

    // Draw glasses (if applicable)
    if (props['hasGlasses']) {
      final glassesPaint = Paint()
        ..color = Colors.grey[800]!
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      
      // Left lens
      canvas.drawCircle(
        Offset(centerX - headRadius * 0.3, headCenterY - headRadius * 0.2),
        headRadius * 0.15,
        glassesPaint,
      );
      
      // Right lens
      canvas.drawCircle(
        Offset(centerX + headRadius * 0.3, headCenterY - headRadius * 0.2),
        headRadius * 0.15,
        glassesPaint,
      );
      
      // Bridge
      canvas.drawLine(
        Offset(centerX - headRadius * 0.15, headCenterY - headRadius * 0.2),
        Offset(centerX + headRadius * 0.15, headCenterY - headRadius * 0.2),
        glassesPaint,
      );
    }

    // Draw neck
    final neckPaint = Paint()
      ..color = _getSkinColor(props['skinTone'])
      ..style = PaintingStyle.fill;
    
    final neckRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(centerX, headCenterY + headRadius * 1.2),
        width: headRadius * 0.6,
        height: headRadius * 0.4,
      ),
      const Radius.circular(8),
    );
    canvas.drawRRect(neckRect, neckPaint);

    // Draw torso/shirt
    final torsoPaint = Paint()
      ..color = _getClothingColor(props['style'])
      ..style = PaintingStyle.fill;
    
    final torsoRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(centerX, headCenterY + headRadius * 2.5),
        width: headRadius * 1.8,
        height: headRadius * 2.0,
      ),
      const Radius.circular(15),
    );
    canvas.drawRRect(torsoRect, torsoPaint);

    // Draw arms
    final armPaint = Paint()
      ..color = _getClothingColor(props['style'])
      ..style = PaintingStyle.fill;
    
    // Left arm
    final leftArmRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(centerX - headRadius * 1.2, headCenterY + headRadius * 2.0),
        width: headRadius * 0.6,
        height: headRadius * 1.5,
      ),
      const Radius.circular(10),
    );
    canvas.drawRRect(leftArmRect, armPaint);
    
    // Right arm
    final rightArmRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(centerX + headRadius * 1.2, headCenterY + headRadius * 2.0),
        width: headRadius * 0.6,
        height: headRadius * 1.5,
      ),
      const Radius.circular(10),
    );
    canvas.drawRRect(rightArmRect, armPaint);

    // Draw hands
    final handPaint = Paint()
      ..color = _getSkinColor(props['skinTone'])
      ..style = PaintingStyle.fill;
    
    // Left hand
    canvas.drawCircle(
      Offset(centerX - headRadius * 1.2, headCenterY + headRadius * 2.8),
      headRadius * 0.2,
      handPaint,
    );
    
    // Right hand
    canvas.drawCircle(
      Offset(centerX + headRadius * 1.2, headCenterY + headRadius * 2.8),
      headRadius * 0.2,
      handPaint,
    );

    // Draw legs
    final legPaint = Paint()
      ..color = Colors.grey[800]!
      ..style = PaintingStyle.fill;
    
    // Left leg
    final leftLegRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(centerX - headRadius * 0.4, headCenterY + headRadius * 4.2),
        width: headRadius * 0.6,
        height: headRadius * 1.8,
      ),
      const Radius.circular(8),
    );
    canvas.drawRRect(leftLegRect, legPaint);
    
    // Right leg
    final rightLegRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(centerX + headRadius * 0.4, headCenterY + headRadius * 4.2),
        width: headRadius * 0.6,
        height: headRadius * 1.8,
      ),
      const Radius.circular(8),
    );
    canvas.drawRRect(rightLegRect, legPaint);

    // Draw feet
    final footPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;
    
    // Left foot
    final leftFootRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(centerX - headRadius * 0.4, headCenterY + headRadius * 5.2),
        width: headRadius * 0.8,
        height: headRadius * 0.3,
      ),
      const Radius.circular(5),
    );
    canvas.drawRRect(leftFootRect, footPaint);
    
    // Right foot
    final rightFootRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(centerX + headRadius * 0.4, headCenterY + headRadius * 5.2),
        width: headRadius * 0.8,
        height: headRadius * 0.3,
      ),
      const Radius.circular(5),
    );
    canvas.drawRRect(rightFootRect, footPaint);
  }

  Color _getSkinColor(String tone) {
    switch (tone.toLowerCase()) {
      case 'light':
        return const Color(0xFFF5DEB3);
      case 'medium':
        return const Color(0xFFDEB887);
      case 'olive':
        return const Color(0xFFCD853F);
      case 'tan':
        return const Color(0xFFD2B48C);
      case 'dark':
        return const Color(0xFF8B4513);
      default:
        return const Color(0xFFDEB887);
    }
  }

  Color _getHairColor(String color) {
    switch (color.toLowerCase()) {
      case 'black':
        return const Color(0xFF2D3748);
      case 'brown':
        return const Color(0xFF8B4513);
      case 'blonde':
        return const Color(0xFFF6E05E);
      case 'red':
        return const Color(0xFFC53030);
      case 'gray':
        return const Color(0xFF718096);
      case 'white':
        return const Color(0xFFF7FAFC);
      default:
        return const Color(0xFF8B4513);
    }
  }

  Color _getEyeColor(String color) {
    switch (color.toLowerCase()) {
      case 'brown':
        return const Color(0xFF8B4513);
      case 'blue':
        return const Color(0xFF3182CE);
      case 'green':
        return const Color(0xFF38A169);
      case 'hazel':
        return const Color(0xFFD69E2E);
      case 'gray':
        return const Color(0xFF718096);
      default:
        return const Color(0xFF8B4513);
    }
  }

  Color _getClothingColor(String style) {
    switch (style.toLowerCase()) {
      case 'casual':
        return const Color(0xFF2B6CB0);
      case 'professional':
        return const Color(0xFF2D3748);
      case 'artistic':
        return const Color(0xFF9F7AEA);
      case 'elegant':
        return const Color(0xFF4A5568);
      case 'sporty':
        return const Color(0xFFE53E3E);
      default:
        return const Color(0xFF2B6CB0);
    }
  }
}
