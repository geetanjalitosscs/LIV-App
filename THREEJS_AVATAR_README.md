# Three.js Avatar System

This document explains how to use the Three.js-based 3D avatar generation system that creates more realistic and interactive human avatars.

## Overview

The Three.js avatar system provides:
- **Interactive 3D models** with real-time customization
- **Realistic proportions** based on anatomical standards
- **Multiple customization options** (body type, face shape, colors, etc.)
- **Unique design features** (triangular collar, half-sleeve effect, belt)
- **Orbit controls** for 360-degree viewing

## Files Structure

```
lib/
├── services/
│   └── threejs_avatar_service.dart    # Three.js service wrapper
├── widgets/
│   └── threejs_avatar_widget.dart     # Flutter widget integration
web/
└── threejs_avatar.html                # Three.js implementation
```

## Features

### 🎨 **Visual Features**
- **Triangular Collar**: Geometric design connecting neck to shoulders
- **Half-Sleeve Effect**: Realistic shirt sleeves with skin showing
- **Belt with Buckle**: Style-appropriate belt and metallic buckle
- **Proper Proportions**: Anatomically correct body measurements
- **Realistic Materials**: Standard materials with proper lighting

### 🎛️ **Customization Options**
- **Gender**: Male/Female with different proportions
- **Body Types**: Slim, Athletic, Muscular, Curvy
- **Face Shapes**: Oval, Round, Square, Heart
- **Hair Colors**: Black, Brown, Blonde, Red, Gray, White
- **Eye Colors**: Brown, Blue, Green, Hazel, Gray
- **Skin Tones**: Light, Medium, Olive, Tan, Dark
- **Styles**: Professional, Casual, Sporty, Elegant, Artistic
- **Accessories**: Beard (males), Glasses

### 🎮 **Interactive Controls**
- **Orbit Controls**: Rotate, pan, and zoom
- **Real-time Updates**: Instant avatar changes
- **Responsive Design**: Adapts to screen size

## Usage

### 1. **Web Implementation**

Open `web/threejs_avatar.html` in a browser to see the standalone Three.js avatar:

```html
<!-- Features include: -->
- Interactive 3D model
- Real-time customization panel
- Orbit controls
- Responsive design
- Shadow mapping
- Professional lighting
```

### 2. **Flutter Integration**

Use the `ThreeJSAvatarWidget` in your Flutter app:

```dart
ThreeJSAvatarWidget(
  gender: 'male',
  bodyType: 'athletic',
  faceType: 'oval',
  hasBeard: false,
  hasGlasses: true,
  hairColor: 'brown',
  eyeColor: 'blue',
  skinTone: 'medium',
  style: 'casual',
)
```

### 3. **Service Integration**

Use the `ThreeJSAvatarService` for programmatic control:

```dart
await ThreeJSAvatarService.instance.initializeAvatar(
  gender: 'female',
  bodyType: 'curvy',
  faceType: 'heart',
  hasBeard: false,
  hasGlasses: false,
  hairColor: 'blonde',
  eyeColor: 'green',
  skinTone: 'light',
  style: 'elegant',
);
```

## Technical Implementation

### **Three.js Components**

#### **Scene Setup**
```javascript
// Scene with background
scene = new THREE.Scene();
scene.background = new THREE.Color(0xeceff1);

// Camera with perspective
camera = new THREE.PerspectiveCamera(75, aspect, 0.1, 1000);
camera.position.set(0, 1.6, 5);

// Renderer with antialiasing
renderer = new THREE.WebGLRenderer({ antialias: true });
renderer.shadowMap.enabled = true;
```

#### **Lighting System**
```javascript
// Hemisphere light for ambient lighting
const hemi = new THREE.HemisphereLight(0xffffff, 0x444444, 1.0);

// Directional light for shadows
const dir = new THREE.DirectionalLight(0xffffff, 0.8);
dir.castShadow = true;
dir.shadow.mapSize.width = 2048;
```

#### **Materials**
```javascript
// Standard materials with realistic properties
const skinMat = new THREE.MeshStandardMaterial({ color: skinColor });
const clothMat = new THREE.MeshStandardMaterial({ color: clothingColor });
const hairMat = new THREE.MeshStandardMaterial({ color: hairColorHex });
```

### **Body Proportions System**

#### **Dynamic Proportions**
```javascript
function calculateProportions(bodyType, gender) {
  let proportions = {
    shoulderWidth: 1.0,
    torsoHeight: 1.2,
    torsoDepth: 0.5,
    upperArmRadius: 0.15,
    upperArmLength: 0.8,
    lowerArmRadius: 0.12,
    lowerArmLength: 0.6,
    thighRadius: 0.15, // Thinner than waist
    thighLength: 0.8,
    lowerLegRadius: 0.12,
    lowerLegLength: 0.8,
  };
  
  // Body type adjustments
  switch (bodyType.toLowerCase()) {
    case 'slim':
      proportions.shoulderWidth = 0.8;
      proportions.upperArmRadius = 0.12;
      proportions.thighRadius = 0.12;
      break;
    case 'athletic':
      proportions.shoulderWidth = 1.1;
      proportions.upperArmRadius = 0.18;
      proportions.thighRadius = 0.18;
      break;
    // ... more cases
  }
  
  // Gender adjustments
  if (gender.toLowerCase() === 'female') {
    proportions.shoulderWidth *= 0.9;
    proportions.thighRadius *= 1.1;
  }
  
  return proportions;
}
```

### **Unique Design Features**

#### **Triangular Collar**
```javascript
function createTriangularCollar(clothMat) {
  const triangleGeo = new THREE.ConeGeometry(0.8, 0.4, 3);
  const triangle = new THREE.Mesh(triangleGeo, clothMat);
  triangle.position.set(0, 1.5, 0);
  triangle.castShadow = true;
  avatar.add(triangle);
}
```

#### **Half-Sleeve Effect**
```javascript
function createHands(skinMat, clothMat) {
  const handGeo = new THREE.SphereGeometry(0.08, 16, 16);
  
  // Hand (skin part)
  const leftHand = new THREE.Mesh(handGeo, skinMat);
  leftHand.position.set(-0.6, 0.5, 0);
  
  // Sleeve cuff (clothing part)
  const sleeveGeo = new THREE.CylinderGeometry(0.1, 0.1, 0.1, 8);
  const leftSleeve = new THREE.Mesh(sleeveGeo, clothMat);
  leftSleeve.position.set(-0.6, 0.4, 0);
}
```

#### **Belt with Buckle**
```javascript
function createBelt(style) {
  const beltMat = new THREE.MeshStandardMaterial({ color: getBeltColor(style) });
  const buckleMat = new THREE.MeshStandardMaterial({ color: getBuckleColor(style) });
  
  // Belt
  const beltGeo = new THREE.CylinderGeometry(0.6, 0.6, 0.1, 8);
  const belt = new THREE.Mesh(beltGeo, beltMat);
  
  // Buckle
  const buckleGeo = new THREE.BoxGeometry(0.15, 0.08, 0.05);
  const buckle = new THREE.Mesh(buckleGeo, buckleMat);
}
```

## Color System

### **Skin Tones**
```javascript
function getSkinColor(skinTone) {
  const colors = {
    'light': 0xFFF5DEB3,    // Warmer light peach
    'medium': 0xFFDEB887,   // Warmer medium tan
    'olive': 0xFFDAA520,    // Warmer olive
    'tan': 0xFFCD853F,      // Warmer tan
    'dark': 0xFFA0522D      // Warmer dark brown
  };
  return colors[skinTone] || 0xFFDEB887;
}
```

### **Clothing Colors**
```javascript
function getClothingColor(style) {
  const colors = {
    'professional': 0xFF2C3E50,  // Dark blue-gray suit
    'casual': 0xFF3498DB,        // Blue t-shirt
    'sporty': 0xFFE74C3C,        // Red athletic wear
    'elegant': 0xFF1A1A1A,       // Black formal dress
    'artistic': 0xFF9B59B6       // Purple creative outfit
  };
  return colors[style] || 0xFF3498DB;
}
```

## Performance Optimization

### **Geometry Optimization**
- Use appropriate polygon counts for different body parts
- Reuse geometries where possible (left/right limbs)
- Use `clone()` for symmetric parts

### **Material Optimization**
- Use `MeshStandardMaterial` for realistic lighting
- Enable shadow mapping for depth
- Use appropriate texture sizes

### **Animation Optimization**
- Use `requestAnimationFrame` for smooth animation
- Dispose of unused geometries and materials
- Handle window resize efficiently

## Browser Compatibility

### **Required Features**
- WebGL support
- ES6 JavaScript support
- Canvas 2D context

### **Recommended Browsers**
- Chrome 60+
- Firefox 55+
- Safari 12+
- Edge 79+

## Troubleshooting

### **Common Issues**

1. **Avatar not loading**
   - Check WebGL support
   - Verify Three.js library loading
   - Check console for errors

2. **Performance issues**
   - Reduce polygon counts
   - Disable shadows if needed
   - Lower texture resolutions

3. **Controls not working**
   - Verify OrbitControls library
   - Check event listeners
   - Ensure proper initialization

### **Debug Tips**
- Use browser developer tools
- Check Three.js examples for reference
- Monitor performance with browser profiler

## Future Enhancements

### **Planned Features**
- **Animation System**: Walking, waving, gestures
- **Clothing System**: Multiple outfit options
- **Facial Expressions**: Smile, frown, etc.
- **Hair Styles**: Different haircuts and styles
- **Accessories**: Jewelry, hats, bags
- **Export Options**: Image, video, 3D model

### **Technical Improvements**
- **LOD System**: Level-of-detail for performance
- **Texture Mapping**: Realistic skin and fabric textures
- **Physics Integration**: Cloth simulation
- **VR Support**: Virtual reality compatibility

## Conclusion

The Three.js avatar system provides a powerful and flexible way to create realistic 3D human avatars with extensive customization options. The combination of proper anatomical proportions, unique design features, and interactive controls creates an engaging user experience that can be easily integrated into Flutter applications or used standalone on the web.

The system is designed to be extensible, allowing for easy addition of new features, body types, and customization options while maintaining good performance and visual quality.
