# Avatar Customization Guide

This guide explains how to modify body proportions, colors, styles, and other aspects of avatar generation in the Live Date app.

## Table of Contents
1. [Overview](#overview)
2. [File Structure](#file-structure)
3. [Body Proportions System](#body-proportions-system)
4. [Color Customization](#color-customization)
5. [Style Modifications](#style-modifications)
6. [Drawing Methods](#drawing-methods)
7. [Advanced Customizations](#advanced-customizations)
8. [API Integration](#api-integration)

## Overview

The avatar generation system uses a custom Flutter Canvas-based approach to create realistic human avatars. The system is built around the **8-head figure drawing standard** used in classical art, ensuring anatomically correct proportions.

### Key Components:
- **Proportion Calculator**: Calculates body measurements based on head units
- **Drawing Methods**: Individual methods for each body part
- **Color System**: Centralized color management
- **Style System**: Clothing and appearance variations

## File Structure

```
lib/services/
├── threejs_avatar_service.dart  # Main 3D avatar generation logic
├── avatar_generator_service.dart # Service wrapper
└── user_service.dart           # User data management
```

**Main File**: `lib/services/threejs_avatar_service.dart` contains all 3D avatar generation logic using Three.js.

## Body Proportions System

### Core Concept: Head Unit System

The avatar uses a **head unit** as the base measurement unit, following classical art proportions:

```dart
final double headUnit = canvasSize / 8.5; // Slightly compressed for avatar view
```

### Base Proportions (Lines 204-247)

All measurements are calculated relative to the head unit:

```dart
Map<String, dynamic> proportions = {
  // Head measurements
  'headCenterX': canvasSize / 2.0,        // Center horizontally
  'headCenterY': headUnit * 0.7,           // Position from top
  'headWidth': headUnit * 0.8,             // Head width
  'headHeight': headUnit * 0.9,            // Head height
  
  // Face measurements  
  'eyeY': headUnit * 0.6,                  // Eye position
  'eyeSpacing': headUnit * 0.25,           // Distance between eyes
  'eyeWidth': headUnit * 0.15,             // Eye width
  'eyeHeight': headUnit * 0.08,            // Eye height
  'noseY': headUnit * 0.8,                 // Nose position
  'noseWidth': headUnit * 0.06,            // Nose width
  'noseHeight': headUnit * 0.9,            // Nose height
  'mouthY': headUnit * 0.95,               // Mouth position
  'mouthWidth': headUnit * 0.18,           // Mouth width
  'mouthHeight': headUnit * 0.05,          // Mouth height
  
  // Neck measurements
  'neckY': headUnit * 1.3,                 // Neck position
  'neckWidth': headUnit * 0.35,            // Neck width
  'neckHeight': headUnit * 0.25,           // Neck height
  
  // Torso measurements  
  'shoulderY': headUnit * 1.8,             // Shoulder position
  'chestY': headUnit * 2.8,                // Chest position
  'waistY': headUnit * 3.5,                // Waist position
  'hipY': headUnit * 4.2,                 // Hip position
  
  // Limb measurements
  'armLength': headUnit * 2.8,             // Arm length
  'legLength': headUnit * 4.0,             // Leg length
  'handSize': headUnit * 0.12,             // Hand size
  'footLength': headUnit * 0.25,           // Foot length
};
```

### Body Type Modifiers (Lines 249-286)

Different body types are created using multipliers:

```dart
switch (bodyType.toLowerCase()) {
  case 'slim':
    shoulderWidthMultiplier = 0.85;    // Narrower shoulders
    waistWidthMultiplier = 0.8;        // Narrower waist
    hipWidthMultiplier = 0.85;        // Narrower hips
    armThicknessMultiplier = 1.0;     // Thinner arms
    legThicknessMultiplier = 1.5;     // Thinner legs
    break;
    
  case 'athletic':
    shoulderWidthMultiplier = 1.15;   // Broader shoulders
    waistWidthMultiplier = 0.9;        // Narrower waist
    hipWidthMultiplier = 0.95;        // Narrower hips
    armThicknessMultiplier = 1.2;     // Thicker arms
    legThicknessMultiplier = 2.0;     // Thicker legs
    break;
    
  case 'muscular':
    shoulderWidthMultiplier = 1.25;   // Very broad shoulders
    waistWidthMultiplier = 0.95;      // Narrow waist
    hipWidthMultiplier = 1.0;         // Normal hips
    armThicknessMultiplier = 1.4;     // Very thick arms
    legThicknessMultiplier = 2.2;     // Very thick legs
    break;
    
  case 'curvy':
    shoulderWidthMultiplier = 1.0;    // Normal shoulders
    waistWidthMultiplier = 1.1;        // Wider waist
    hipWidthMultiplier = 1.2;          // Wider hips
    armThicknessMultiplier = 1.8;     // Thicker arms
    legThicknessMultiplier = 2.7;     // Thicker legs
    break;
}
```

### Gender Adjustments (Lines 288-294)

```dart
if (gender.toLowerCase() == 'female') {
  hipWidthMultiplier += 0.1;          // Wider hips for females
  waistWidthMultiplier -= 0.05;      // Narrower waist for females
} else {
  shoulderWidthMultiplier += 0.1;    // Broader shoulders for males
}
```

## Color Customization

### Skin Colors (Lines 1509-1524)

```dart
Color _getSkinColor(String skinTone) {
  switch (skinTone.toLowerCase()) {
    case 'light':
      return const Color(0xFFF5DEB3); // Warmer light peach
    case 'medium':
      return const Color(0xFFDEB887); // Warmer medium tan
    case 'olive':
      return const Color(0xFFDAA520); // Warmer olive
    case 'tan':
      return const Color(0xFFCD853F); // Warmer tan
    case 'dark':
      return const Color(0xFFA0522D); // Warmer dark brown
    default:
      return const Color(0xFFDEB887); // Default warmer medium
  }
}
```

### Hair Colors (Lines 1526-1543)

```dart
Color _getHairColor(String hairColor) {
  switch (hairColor.toLowerCase()) {
    case 'black':
      return const Color(0xFF1A1A1A);
    case 'brown':
      return const Color(0xFF8B4513);
    case 'blonde':
      return const Color(0xFFDAA520);
    case 'red':
      return const Color(0xFFA0522D);
    case 'gray':
      return const Color(0xFF696969);
    case 'white':
      return const Color(0xFFF5F5F5);
    default:
      return const Color(0xFF8B4513);
  }
}
```

### Clothing Colors (Lines 1441-1456)

```dart
Color _getClothingColor(String style) {
  switch (style.toLowerCase()) {
    case 'professional':
      return const Color(0xFF2C3E50); // Dark blue-gray suit
    case 'casual':
      return const Color(0xFF3498DB); // Blue t-shirt
    case 'sporty':
      return const Color(0xFFE74C3C); // Red athletic wear
    case 'elegant':
      return const Color(0xFF1A1A1A); // Black formal dress
    case 'artistic':
      return const Color(0xFF9B59B6); // Purple creative outfit
    default:
      return const Color(0xFF3498DB); // Blue casual
  }
}
```

## Style Modifications

### Adding New Body Types

To add a new body type (e.g., 'petite'):

1. **Add to the switch statement** (around line 256):
```dart
case 'petite':
  shoulderWidthMultiplier = 0.75;    // Very narrow shoulders
  waistWidthMultiplier = 0.7;        // Very narrow waist
  hipWidthMultiplier = 0.8;          // Narrow hips
  armThicknessMultiplier = 0.8;      // Very thin arms
  legThicknessMultiplier = 1.2;      // Very thin legs
  break;
```

2. **Update UI options** in your avatar setup screen to include 'petite'

### Adding New Styles

To add a new clothing style (e.g., 'bohemian'):

1. **Add color definition**:
```dart
case 'bohemian':
  return const Color(0xFF8B4513); // Earthy brown
```

2. **Add clothing details** in `_drawClothingDetails` method (around line 1304):
```dart
case 'bohemian':
  // Bohemian patterns
  for (int i = 0; i < 8; i++) {
    final double angle = (i * 2 * pi) / 8;
    final double x = headCenterX + 25 * cos(angle);
    final double y = chestY - 10 + 20 * sin(angle);
    canvas.drawCircle(Offset(x, y), 4, accentPaint..style = PaintingStyle.fill);
  }
  break;
```

## Drawing Methods

### Method Structure

Each body part has its own drawing method:

- `_drawRealisticHair()` - Hair styling and texture
- `_drawRealisticHead()` - Head shape and face contours
- `_drawFacialFeatures()` - Eyes, nose, mouth, eyebrows
- `_drawNeckWithProperConnection()` - Neck and collar area
- `_drawRealisticTorsoWithClothing()` - Torso and clothing
- `_drawRealisticArmsWithJoints()` - Arms with elbow joints
- `_drawRealisticLegsWithJoints()` - Legs with knee joints
- `_addRealisticShadingAndHighlights()` - Lighting effects

### Modifying Face Shapes

Face shapes are defined in `_drawRealisticHead()` (lines 439-496):

```dart
switch (faceType.toLowerCase()) {
  case 'oval':
    // Oval face - longer than wide
    final Rect faceRect = Rect.fromCenter(
      center: Offset(headCenterX, headCenterY),
      width: headWidth,
      height: headHeight * 1.1,
    );
    facePath.addOval(faceRect);
    break;
    
  case 'round':
    // Round face - equal width and height
    final Rect faceRect = Rect.fromCenter(
      center: Offset(headCenterX, headCenterY),
      width: headWidth * 1.1,
      height: headWidth * 1.1,
    );
    facePath.addOval(faceRect);
    break;
    
  case 'square':
    // Square face - angular with rounded corners
    final Rect faceRect = Rect.fromCenter(
      center: Offset(headCenterX, headCenterY),
      width: headWidth,
      height: headWidth,
    );
    final RRect roundedRect = RRect.fromRectAndRadius(faceRect, const Radius.circular(8));
    facePath.addRRect(roundedRect);
    break;
    
  case 'heart':
    // Heart shape - wider at top, narrow at bottom
    facePath.moveTo(headCenterX, headCenterY - headHeight * 0.5);
    // ... heart shape path definition
    break;
}
```

### Adding New Face Shapes

To add a new face shape (e.g., 'diamond'):

```dart
case 'diamond':
  // Diamond face - narrow at top and bottom, wide at cheeks
  facePath.moveTo(headCenterX, headCenterY - headHeight * 0.4);
  facePath.quadraticBezierTo(
    headCenterX - headWidth * 0.3, headCenterY - headHeight * 0.1,
    headCenterX - headWidth * 0.5, headCenterY + headHeight * 0.1
  );
  facePath.quadraticBezierTo(
    headCenterX - headWidth * 0.4, headCenterY + headHeight * 0.3,
    headCenterX, headCenterY + headHeight * 0.4
  );
  facePath.quadraticBezierTo(
    headCenterX + headWidth * 0.4, headCenterY + headHeight * 0.3,
    headCenterX + headWidth * 0.5, headCenterY + headHeight * 0.1
  );
  facePath.quadraticBezierTo(
    headCenterX + headWidth * 0.3, headCenterY - headHeight * 0.1,
    headCenterX, headCenterY - headHeight * 0.4
  );
  break;
```

## Advanced Customizations

### Canvas Size and Resolution

The avatar is generated on a 700x700 canvas (line 165):

```dart
const int canvasSize = 700;
```

To change resolution:
```dart
const int canvasSize = 1024; // Higher resolution
```

### Background Customization

Background is defined in lines 169-176:

```dart
final Paint backgroundPaint = Paint()
  ..shader = const LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF5F7FA), Color(0xFFE8EDF5)], // Light blue-gray gradient
  ).createShader(Rect.fromLTWH(0, 0, canvasSize.toDouble(), canvasSize.toDouble()));
```

To change background:
```dart
colors: [Color(0xFFFFFFFF), Color(0xFFF0F0F0)], // White to light gray
// or
colors: [Color(0xFFE8F4FD), Color(0xFFB8D4F0)], // Light blue gradient
```

### Pose Modifications

Currently, avatars are drawn in a standing pose. To modify the pose, you would need to:

1. **Adjust Y positions** in the proportions calculation
2. **Modify drawing methods** to change limb angles
3. **Update joint positions** for different poses

Example for a slight lean:
```dart
// In _calculateHumanProportions, adjust center positions
'headCenterX': canvasSize / 2.0 + 10, // Slight lean to the right
```

### Adding Accessories

To add accessories like hats, jewelry, or bags:

1. **Create new drawing methods**:
```dart
void _drawHat(Canvas canvas, Map<String, dynamic> props, String hatColor) {
  final Paint hatPaint = Paint()..color = _getHatColor(hatColor);
  // Hat drawing logic
}
```

2. **Call the method** in the main generation function:
```dart
_drawHat(canvas, humanProportions, hatColor);
```

## API Integration

### Gemini API Integration

The system integrates with Google's Gemini API for AI-generated avatars:

- **API Key**: Set in line 15 (`_apiKey`)
- **Base URL**: Configured in line 16
- **Prompt Building**: Custom prompts in `_buildAvatarPrompt()` method

### Fallback System

If the API fails, the system falls back to the custom Canvas-based avatar generation.

## Testing Changes

### Quick Testing

1. **Modify a single parameter** (e.g., change a color value)
2. **Run the app** and generate an avatar
3. **Observe the change** in the generated avatar

### Systematic Testing

1. **Test each body type** with different combinations
2. **Test each style** with different colors
3. **Test edge cases** (very small/large values)
4. **Test on different screen sizes**

## Common Modifications

### Making Avatars Taller/Shorter

Adjust the head unit calculation:
```dart
final double headUnit = canvasSize / 7.5; // Taller (was 8.5)
final double headUnit = canvasSize / 9.5; // Shorter
```

### Making Avatars Wider/Narrower

Adjust the base width multipliers:
```dart
proportions['shoulderWidth'] = headUnit * 1.6 * shoulderWidthMultiplier; // Wider
proportions['shoulderWidth'] = headUnit * 1.2 * shoulderWidthMultiplier; // Narrower
```

### Changing Overall Scale

Modify the canvas size:
```dart
const int canvasSize = 512;  // Smaller avatars
const int canvasSize = 1024; // Larger avatars
```

## Troubleshooting

### Common Issues

1. **Distorted proportions**: Check that multipliers are reasonable (0.5-2.0 range)
2. **Missing body parts**: Ensure all drawing methods are called in the correct order
3. **Color issues**: Verify color values are valid hex codes
4. **Performance**: Large canvas sizes may affect performance

### Debug Tips

1. **Add print statements** to see calculated values:
```dart
print('Head unit: $headUnit');
print('Shoulder width: ${proportions['shoulderWidth']}');
```

2. **Test individual methods** by commenting out others
3. **Use Flutter Inspector** to debug canvas drawing

## Conclusion

This avatar generation system provides a flexible foundation for creating realistic human avatars. By understanding the proportion system and drawing methods, you can customize every aspect of the avatar generation process to meet your specific needs.

Remember to test changes thoroughly and maintain the anatomical accuracy that makes the avatars look realistic and professional.
