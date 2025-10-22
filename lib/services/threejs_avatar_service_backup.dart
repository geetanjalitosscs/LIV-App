import 'dart:math' as math;
import 'package:flutter/foundation.dart';

class ThreeJSAvatarService {
  static final ThreeJSAvatarService _instance = ThreeJSAvatarService._internal();
  static ThreeJSAvatarService get instance => _instance;
  
  ThreeJSAvatarService._internal();
  
  // Web-specific objects - only available on web platform
  dynamic scene;
  dynamic camera;
  dynamic renderer;
  dynamic controls;
  dynamic avatar;
  Map<String, dynamic>? _config; // optional config mirrored from web UI

  // JS interop helper to call Vector3.set on properties like position/scale/rotation safely
  void _set3(dynamic parent, String prop, num x, num y, num z) {
    if (!kIsWeb) return;
    
    try {
      final p = parent[prop];
      if (p != null && p.callMethod != null) {
        p.callMethod('set', [x, y, z]);
      }
    } catch (_) {}
  }
  
  /// Initialize Three.js scene and create avatar
  Future<void> initializeAvatar({
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
    // Only run on web platform
    if (!kIsWeb) {
      print('Three.js avatar service only works on web platform');
      return;
    }

    await _initializeAvatarWeb(
      gender: gender,
      bodyType: bodyType,
      faceType: faceType,
      hasBeard: hasBeard,
      hasGlasses: hasGlasses,
      hairColor: hairColor,
      eyeColor: eyeColor,
      skinTone: skinTone,
      style: style,
    );
  }
  
  Future<void> _initializeAvatarWeb({
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
    // Web-specific implementation will be added here
    print('Initializing Three.js avatar (web implementation)');
    print('   Gender: $gender');
    print('   Body Type: $bodyType');
    print('   Face Type: $faceType');
    print('   Skin Tone: $skinTone');
    print('   Style: $style');
    print('   Hair Color: $hairColor');
    print('   Eye Color: $eyeColor');
    print('   Has Beard: $hasBeard');
    print('   Has Glasses: $hasGlasses');
  }

  /// Initialize using a config map similar to the web UI (index.html/script.js)
  /// Supported keys (string where applicable):
  /// - gender: 'male' | 'female'
  /// - bodyType: 'average' | 'slim' | 'athletic' | 'muscular' | 'curvy'
  /// - face: 'round' | 'oval' | 'square' | 'heart' | 'diamond'
  /// - eyes: 'normal' | 'big' | 'small'
  /// - eyeColor: '#rrggbb'
  /// - skinColor or skinTone: '#rrggbb' or 'light'|'medium'|'olive'|'tan'|'dark'
  /// - hair: 'short'|'medium'|'long'|'curly'|'wavy'|'braids'|'ponytail'|'buzz'|'bald'
  /// - hairColor: '#rrggbb' or named
  /// - accessories: 'none'|'glasses'|'hat'|'beard'|'earrings'|'necklace'|'watch'
  /// - top: 't-shirt'|'shirt'|'dress'|'hoodie'|'tank-top'
  /// - topColor: '#rrggbb'
  /// - bottom: 'jeans'|'shorts'|'skirt'|'pants'|'leggings'
  /// - bottomColor: '#rrggbb'
  /// - shoes: 'sneakers'|'boots'|'sandals'|'heels'|'barefoot'
  /// - shoeColor: '#rrggbb'
  Future<void> initializeAvatarWithConfig(Map<String, dynamic> config) async {
    if (!kIsWeb) {
      print('Three.js avatar service only works on web platform');
      return;
    }
    _config = Map<String, dynamic>.from(config);
    await _loadThreeJS();
    _createScene();
    _createCamera();
    _createRenderer();
    _addLights();
    _createAvatarFromConfig();
    _addControls();
    _animate();
    _handleResize();
  }

  void _createAvatarFromConfig() {
    final gender = (_getConfigString('gender') ?? 'male').toLowerCase();
    final bodyType = (_getConfigString('bodyType') ?? 'average').toLowerCase();
    final faceType = (_getConfigString('face') ?? 'oval').toLowerCase();
    final accessories = (_getConfigString('accessories') ?? 'none').toLowerCase();
    final hasBeard = accessories == 'beard';
    final hasGlasses = accessories == 'glasses';

    final eyeColor = _getConfigString('eyeColor');
    final hairColor = _getConfigString('hairColor');
    final skinColor = _getConfigString('skinColor') ?? _getConfigString('skinTone');
    final style = (_getConfigString('style') ?? 'casual');

    // Call existing pipeline; materials will be adjusted inside if config colors exist
    _createHumanAvatar(
      gender: gender,
      bodyType: bodyType,
      faceType: faceType,
      hasBeard: hasBeard,
      hasGlasses: hasGlasses,
      hairColor: hairColor ?? 'brown',
      eyeColor: eyeColor ?? 'brown',
      skinTone: skinColor ?? 'medium',
      style: style,
    );

    // Clothing and shoes based on config, overlaid on base avatar
    _applyClothingFromConfig();
  }

  String? _getConfigString(String key) {
    if (_config == null) return null;
    final v = _config![key];
    if (v == null) return null;
    return v.toString();
  }

  int? _hexToColorInt(String? hex) {
    if (hex == null) return null;
    final cleaned = hex.trim().toLowerCase();
    if (!cleaned.startsWith('#') || (cleaned.length != 7)) return null;
    try {
      final value = int.parse(cleaned.substring(1), radix: 16);
      // Add opaque alpha like other color helpers in this file
      return 0xFF000000 | value;
    } catch (_) {
      return null;
    }
  }
  
  /// Load Three.js library
  Future<void> _loadThreeJS() async {
    if (!kIsWeb) return;
    
    // Web-specific implementation
    await _loadThreeJSWeb();
  }
  
  Future<void> _loadThreeJSWeb() async {
    // This method will only be called on web platform
    print('Loading Three.js library (web implementation)');
  }
  
  /// Create Three.js scene
  void _createScene() {
    if (!kIsWeb) return;
    
    // Web-specific implementation
    _createSceneWeb();
  }
  
  void _createSceneWeb() {
    // This method will only be called on web platform
    print('Creating Three.js scene (web implementation)');
  }
  
  /// Create camera
  void _createCamera() {
    if (!kIsWeb) return;
    
    // Web-specific implementation
    _createCameraWeb();
  }
  
  void _createCameraWeb() {
    // This method will only be called on web platform
    print('Creating camera (web implementation)');
  }
  
  /// Create renderer
  void _createRenderer() {
    if (!kIsWeb) return;
    
    // Web-specific implementation
    _createRendererWeb();
  }
  
  void _createRendererWeb() {
    // This method will only be called on web platform
    print('Creating renderer (web implementation)');
  }
  
  /// Add lighting
  void _addLights() {
    if (!kIsWeb) return;
    
    // Web-specific implementation
    _addLightsWeb();
  }
  
  void _addLightsWeb() {
    // This method will only be called on web platform
    print('Adding lights (web implementation)');
  }
  
  /// Create human-like avatar with specifications
  void _createHumanAvatar({
    required String gender,
    required String bodyType,
    required String faceType,
    required bool hasBeard,
    required bool hasGlasses,
    required String hairColor,
    required String eyeColor,
    required String skinTone,
    required String style,
  }) {
    avatar = js.JsObject(js.context['THREE']['Group']);
    
    // Get colors based on specifications
    final skinColor = _getSkinColor(skinTone);
    final clothingColor = _getClothingColor(style);
    final hairColorHex = _getHairColor(hairColor);
    final eyeColorHex = _getEyeColor(eyeColor);
    
    // If config provides explicit hex colors, prefer them
    final cfgSkinInt = _hexToColorInt(_getConfigString('skinColor'));
    final cfgTopInt = _hexToColorInt(_getConfigString('topColor'));
    final cfgBottomInt = _hexToColorInt(_getConfigString('bottomColor'));
    final cfgHairInt = _hexToColorInt(_getConfigString('hairColor'));
    final cfgEyeInt = _hexToColorInt(_getConfigString('eyeColor'));

    // Create materials with better properties for human appearance
    final skinMat = js.JsObject(js.context['THREE']['MeshStandardMaterial'], [
      js.JsObject.jsify({
        'color': cfgSkinInt ?? skinColor,
        'roughness': 0.8,
        'metalness': 0.1
      })
    ]);
    final clothMat = js.JsObject(js.context['THREE']['MeshStandardMaterial'], [
      js.JsObject.jsify({
        'color': cfgTopInt ?? clothingColor,
        'roughness': 0.9,
        'metalness': 0.0
      })
    ]);
    final hairMat = js.JsObject(js.context['THREE']['MeshStandardMaterial'], [
      js.JsObject.jsify({
        'color': cfgHairInt ?? hairColorHex,
        'roughness': 0.7,
        'metalness': 0.0
      })
    ]);
    final eyeMat = js.JsObject(js.context['THREE']['MeshStandardMaterial'], [
      js.JsObject.jsify({
        'color': cfgEyeInt ?? eyeColorHex,
        'roughness': 0.2,
        'metalness': 0.0
      })
    ]);
    final eyeWhiteMat = js.JsObject(js.context['THREE']['MeshStandardMaterial'], [
      js.JsObject.jsify({
        'color': 0xffffff,
        'roughness': 0.3,
        'metalness': 0.0
      })
    ]);
    
    // Calculate proportions based on body type
    final proportions = _calculateProportions(bodyType, gender);
    
    // Create head with face type
    _createHead(faceType, skinMat, hairMat, eyeMat, eyeWhiteMat, hasBeard, hasGlasses, gender);
    
    // Create neck with more natural curve
    _createNeck(skinMat);
    
    // Create curved collar
    _createCurvedCollar(clothMat);
    
    // Create torso with curves and gender-specific shape
    _createCurvedTorso(bodyType, gender, clothMat, proportions);
    
    // Create arms with natural curves
    _createCurvedArms(bodyType, skinMat, clothMat, proportions);
    
    // Create legs with natural thigh curves
    _createCurvedLegs(bodyType, gender, clothMat, proportions);
    
    // Create belt with rounded edges
    _createRoundedBelt(style);
    
    scene.callMethod('add', [avatar]);
  }
  
  /// Create head with face type specifications and more natural curves
  void _createHead(String faceType, js.JsObject skinMat, js.JsObject hairMat, 
                  js.JsObject eyeMat, js.JsObject eyeWhiteMat, bool hasBeard, bool hasGlasses, String gender) {
    // Head geometry based on face type with more natural curves
    js.JsObject headGeo;
    switch (faceType.toLowerCase()) {
      case 'round':
        headGeo = js.JsObject(js.context['THREE']['SphereGeometry'], [0.32, 32, 24]);
        break;
      case 'square':
        // Rounded cube for more natural square face
        headGeo = js.JsObject(js.context['THREE']['SphereGeometry'], [0.3, 16, 12]);
        break;
      case 'heart':
        // More oval shape for heart face
        headGeo = js.JsObject(js.context['THREE']['SphereGeometry'], [0.3, 32, 16]);
        break;
      default: // oval
        headGeo = js.JsObject(js.context['THREE']['SphereGeometry'], [0.3, 32, 20]);
    }
    
    final head = js.JsObject(js.context['THREE']['Mesh'], [headGeo, skinMat]);
    head['position']['set'](0, 2.2, 0);
    
    // Scale head based on face type for more natural look
    if (faceType.toLowerCase() == 'square') {
      head['scale']['set'](1.1, 1.0, 1.0);
    } else if (faceType.toLowerCase() == 'heart') {
      head['scale']['set'](1.0, 1.1, 1.0);
    } else if (faceType.toLowerCase() == 'oval') {
      head['scale']['set'](0.9, 1.1, 1.0);
    }
    
    avatar.callMethod('add', [head]);
    
    // Create hair: if config has explicit style, use it; else fallback to gender-based hair
    if ((_getConfigString('hair') ?? '').isNotEmpty) {
      _createHairByStyle(_getConfigString('hair')!.toLowerCase(), hairMat, gender);
    } else {
      _createRealisticHair(gender, hairMat);
    }
    
    // Create realistic eyes with size options
    _createRealisticEyes(eyeMat, eyeWhiteMat);
    
    // Create glasses if needed
    if (hasGlasses) {
      _createStylishGlasses();
    }
    
    // Create beard if needed
    if (hasBeard && gender.toLowerCase() == 'male') {
      _createRealisticBeard(hairMat);
    }
    
    // Add nose for more human appearance
    _createNose(skinMat);
    
    // Add lips
    _createLips(skinMat);
  }
  
  /// Create realistic hair based on gender
  void _createRealisticHair(String gender, js.JsObject hairMat) {
    if (gender.toLowerCase() == 'female') {
      // Female hair - flowing and layered with smooth curves
      final hairBase = js.JsObject(js.context['THREE']['SphereGeometry'], [0.34, 32, 24]);
      final hair = js.JsObject(js.context['THREE']['Mesh'], [hairBase, hairMat]);
      hair['position']['set'](0, 2.28, 0);
      hair['scale']['set'](1.25, 1.1, 1.35);
      avatar.callMethod('add', [hair]);
      
      // Add flowing hair layers
      final hairLayer1 = js.JsObject(js.context['THREE']['SphereGeometry'], [0.30, 24, 16]);
      final layer1 = js.JsObject(js.context['THREE']['Mesh'], [hairLayer1, hairMat]);
      layer1['position']['set'](0, 2.05, -0.18);
      layer1['scale']['set'](1.35, 0.9, 1.5);
      avatar.callMethod('add', [layer1]);
      
      // Add side hair volume
      final sideHair = js.JsObject(js.context['THREE']['SphereGeometry'], [0.25, 20, 12]);
      final leftSide = js.JsObject(js.context['THREE']['Mesh'], [sideHair, hairMat]);
      leftSide['position']['set'](-0.28, 2.15, -0.1);
      leftSide['scale']['set'](0.8, 1.2, 1.3);
      avatar.callMethod('add', [leftSide]);
      
      final rightSide = leftSide.callMethod('clone', []);
      rightSide['position']['set'](0.28, 2.15, -0.1);
      avatar.callMethod('add', [rightSide]);
      
      // Add back hair length
      final backHair = js.JsObject(js.context['THREE']['SphereGeometry'], [0.28, 20, 16]);
      final back = js.JsObject(js.context['THREE']['Mesh'], [backHair, hairMat]);
      back['position']['set'](0, 1.8, -0.25);
      back['scale']['set'](1.2, 1.3, 1.6);
      avatar.callMethod('add', [back]);
    } else {
      // Male hair - shorter and more structured with smooth curves
      final hairGeo = js.JsObject(js.context['THREE']['SphereGeometry'], [0.30, 24, 18]);
      final hair = js.JsObject(js.context['THREE']['Mesh'], [hairGeo, hairMat]);
      hair['position']['set'](0, 2.38, 0);
      hair['scale']['set'](1.08, 0.65, 1.08);
      avatar.callMethod('add', [hair]);
      
      // Add front hair part
      final frontHair = js.JsObject(js.context['THREE']['SphereGeometry'], [0.25, 16, 12]);
      final front = js.JsObject(js.context['THREE']['Mesh'], [frontHair, hairMat]);
      front['position']['set'](0, 2.42, 0.15);
      front['scale']['set'](0.9, 0.4, 0.8);
      avatar.callMethod('add', [front]);
      
      // Add side hair parts
      final sideHair = js.JsObject(js.context['THREE']['SphereGeometry'], [0.18, 12, 8]);
      final leftSide = js.JsObject(js.context['THREE']['Mesh'], [sideHair, hairMat]);
      leftSide['position']['set'](-0.22, 2.35, 0.05);
      leftSide['scale']['set'](0.7, 0.6, 0.9);
      avatar.callMethod('add', [leftSide]);
      
      final rightSide = leftSide.callMethod('clone', []);
      rightSide['position']['set'](0.22, 2.35, 0.05);
      avatar.callMethod('add', [rightSide]);
    }
  }

  /// Create hair using explicit style like the web UI
  void _createHairByStyle(String style, js.JsObject hairMat, String gender) {
    final s = style.toLowerCase();
    if (s == 'bald') {
      return; // no hair added
    }
    if (s == 'short') {
      final geo = js.JsObject(js.context['THREE']['SphereGeometry'], [0.30, 24, 18]);
      final mesh = js.JsObject(js.context['THREE']['Mesh'], [geo, hairMat]);
      mesh['position']['set'](0, 2.38, 0);
      mesh['scale']['set'](1.08, 0.65, 1.08);
      avatar.callMethod('add', [mesh]);
      return;
    }
    if (s == 'medium') {
      final geo = js.JsObject(js.context['THREE']['SphereGeometry'], [0.34, 28, 20]);
      final mesh = js.JsObject(js.context['THREE']['Mesh'], [geo, hairMat]);
      mesh['position']['set'](0, 2.28, 0);
      mesh['scale']['set'](1.2, 0.8, 1.25);
      avatar.callMethod('add', [mesh]);
      return;
    }
    if (s == 'long') {
      final capGeo = js.JsObject(js.context['THREE']['SphereGeometry'], [0.36, 28, 20]);
      final cap = js.JsObject(js.context['THREE']['Mesh'], [capGeo, hairMat]);
      cap['position']['set'](0, 2.25, 0);
      cap['scale']['set'](1.25, 0.9, 1.35);
      avatar.callMethod('add', [cap]);
      final backGeo = js.JsObject(js.context['THREE']['SphereGeometry'], [0.3, 24, 16]);
      final back = js.JsObject(js.context['THREE']['Mesh'], [backGeo, hairMat]);
      back['position']['set'](0, 2.0, -0.22);
      back['scale']['set'](1.2, 1.4, 1.6);
      avatar.callMethod('add', [back]);
      return;
    }
    if (s == 'curly') {
      // base short
      _createHairByStyle('short', hairMat, gender);
      // curls as torus rings around
      final curlGeo = js.JsObject(js.context['THREE']['TorusGeometry'], [0.08, 0.02, 8, 16]);
      for (int i = 0; i < 10; i++) {
        final curl = js.JsObject(js.context['THREE']['Mesh'], [curlGeo, hairMat]);
        final angle = (3.14159 * 2 / 10) * i;
        final x = math.cos(angle) * 0.28;
        final z = math.sin(angle) * 0.28;
        curl['position']['set'](x, 2.35 + (i % 2) * 0.05, z);
        avatar.callMethod('add', [curl]);
      }
      return;
    }
    if (s == 'wavy') {
      _createHairByStyle('medium', hairMat, gender);
      final strandGeo = js.JsObject(js.context['THREE']['CylinderGeometry'], [0.01, 0.01, 0.5, 8]);
      for (int i = 0; i < 8; i++) {
        final strand = js.JsObject(js.context['THREE']['Mesh'], [strandGeo, hairMat]);
        final angle = (3.14159 * 2 / 8) * i;
        final x = math.cos(angle) * 0.30;
        final z = math.sin(angle) * 0.30;
        strand['position']['set'](x, 2.2, z);
        strand['rotation']['set'](0, angle, 0.2);
        avatar.callMethod('add', [strand]);
      }
      return;
    }
    if (s == 'braids') {
      _createHairByStyle('short', hairMat, gender);
      final braidGeo = js.JsObject(js.context['THREE']['CylinderGeometry'], [0.03, 0.03, 0.7, 8]);
      final left = js.JsObject(js.context['THREE']['Mesh'], [braidGeo, hairMat]);
      left['position']['set'](-0.28, 2.05, -0.15);
      left['rotation']['set'](0.2, 0, 0);
      avatar.callMethod('add', [left]);
      final right = left.callMethod('clone', []);
      right['position']['set'](0.28, 2.05, -0.15);
      avatar.callMethod('add', [right]);
      return;
    }
    if (s == 'ponytail') {
      _createHairByStyle('short', hairMat, gender);
      final tailGeo = js.JsObject(js.context['THREE']['CylinderGeometry'], [0.06, 0.05, 0.7, 12]);
      final tail = js.JsObject(js.context['THREE']['Mesh'], [tailGeo, hairMat]);
      tail['position']['set'](0, 2.15, -0.28);
      tail['rotation']['set'](0.25, 0, 0);
      avatar.callMethod('add', [tail]);
      return;
    }
    if (s == 'buzz') {
      final geo = js.JsObject(js.context['THREE']['SphereGeometry'], [0.32, 24, 18]);
      final mesh = js.JsObject(js.context['THREE']['Mesh'], [geo, hairMat]);
      mesh['position']['set'](0, 2.32, 0);
      mesh['scale']['set'](1.05, 0.5, 1.05);
      mesh['material']['transparent'] = true;
      mesh['material']['opacity'] = 0.85;
      avatar.callMethod('add', [mesh]);
      return;
    }
    // fallback by gender
    _createRealisticHair(gender, hairMat);
  }

  void _applyClothingFromConfig() {
    final top = (_getConfigString('top') ?? 't-shirt').toLowerCase();
    final bottom = (_getConfigString('bottom') ?? 'jeans').toLowerCase();
    final shoes = (_getConfigString('shoes') ?? 'sneakers').toLowerCase();
    final accessories = (_getConfigString('accessories') ?? 'none').toLowerCase();

    final topColor = _hexToColorInt(_getConfigString('topColor')) ?? _getClothingColor(_getConfigString('style') ?? 'casual');
    final bottomColor = _hexToColorInt(_getConfigString('bottomColor')) ?? topColor;
    final shoeColor = _hexToColorInt(_getConfigString('shoeColor')) ?? _getShoeColor('casual');

    final topMat = js.JsObject(js.context['THREE']['MeshStandardMaterial'], [js.JsObject.jsify({'color': topColor, 'roughness': 0.9})]);
    final bottomMat = js.JsObject(js.context['THREE']['MeshStandardMaterial'], [js.JsObject.jsify({'color': bottomColor, 'roughness': 0.9})]);
    final shoeMat = js.JsObject(js.context['THREE']['MeshStandardMaterial'], [js.JsObject.jsify({'color': shoeColor, 'roughness': 0.7})]);

    // Top (simple box over torso)
    if (top != 'tank-top') {
      final geo = js.JsObject(js.context['THREE']['BoxGeometry'], [0.9, 1.3, 0.6]);
      final mesh = js.JsObject(js.context['THREE']['Mesh'], [geo, topMat]);
      mesh['position']['set'](0, 1.2, 0);
      avatar.callMethod('add', [mesh]);
      // hoodie hood
      if (top == 'hoodie') {
        final hoodGeo = js.JsObject(js.context['THREE']['SphereGeometry'], [0.55, 16, 16, 0, 6.28318, 0, 2.35619]);
        final hood = js.JsObject(js.context['THREE']['Mesh'], [hoodGeo, topMat]);
        hood['position']['set'](0, 1.5, -0.35);
        hood['scale']['set'](0.5, 0.5, 0.5);
        avatar.callMethod('add', [hood]);
      }
    } else {
      // tank-top smaller area
      final geo = js.JsObject(js.context['THREE']['BoxGeometry'], [0.8, 1.0, 0.5]);
      final mesh = js.JsObject(js.context['THREE']['Mesh'], [geo, topMat]);
      mesh['position']['set'](0, 1.15, 0);
      avatar.callMethod('add', [mesh]);
    }

    // Bottom
    if (bottom == 'skirt') {
      final geo = js.JsObject(js.context['THREE']['CylinderGeometry'], [0.8, 1.2, 0.8, 16]);
      final mesh = js.JsObject(js.context['THREE']['Mesh'], [geo, bottomMat]);
      mesh['position']['set'](0, 0.6, 0);
      avatar.callMethod('add', [mesh]);
    } else if (bottom == 'shorts') {
      final geo = js.JsObject(js.context['THREE']['CylinderGeometry'], [0.28, 0.28, 0.8, 12]);
      final left = js.JsObject(js.context['THREE']['Mesh'], [geo, bottomMat]);
      left['position']['set'](-0.22, 0.25, 0);
      avatar.callMethod('add', [left]);
      final right = left.callMethod('clone', []);
      right['position']['set'](0.22, 0.25, 0);
      avatar.callMethod('add', [right]);
    } else {
      // jeans/pants/leggings
      final geo = js.JsObject(js.context['THREE']['CylinderGeometry'], [0.28, 0.26, 1.6, 16]);
      final left = js.JsObject(js.context['THREE']['Mesh'], [geo, bottomMat]);
      left['position']['set'](-0.22, -0.1, 0);
      avatar.callMethod('add', [left]);
      final right = left.callMethod('clone', []);
      right['position']['set'](0.22, -0.1, 0);
      avatar.callMethod('add', [right]);
    }

    // Shoes
    if (shoes != 'barefoot') {
      final geo = js.JsObject(js.context['THREE']['BoxGeometry'], [0.3, 0.2, 0.8]);
      final left = js.JsObject(js.context['THREE']['Mesh'], [geo, shoeMat]);
      left['position']['set'](-0.22, -0.85, 0.2);
      avatar.callMethod('add', [left]);
      final right = left.callMethod('clone', []);
      right['position']['set'](0.22, -0.85, 0.2);
      avatar.callMethod('add', [right]);
    }

    // Additional accessories beyond beard/glasses (handled earlier)
    if (accessories == 'hat') {
      final hatGeo = js.JsObject(js.context['THREE']['CylinderGeometry'], [0.6, 0.6, 0.4, 16]);
      final hatMat = topMat;
      final hat = js.JsObject(js.context['THREE']['Mesh'], [hatGeo, hatMat]);
      hat['position']['set'](0, 2.1, 0);
      avatar.callMethod('add', [hat]);
      final brimGeo = js.JsObject(js.context['THREE']['CylinderGeometry'], [0.8, 0.8, 0.05, 16]);
      final brim = js.JsObject(js.context['THREE']['Mesh'], [brimGeo, hatMat]);
      brim['position']['set'](0, 1.9, 0);
      avatar.callMethod('add', [brim]);
    } else if (accessories == 'earrings') {
      final earGeo = js.JsObject(js.context['THREE']['SphereGeometry'], [0.03, 8, 8]);
      final earMat = js.JsObject(js.context['THREE']['MeshStandardMaterial'], [js.JsObject.jsify({'color': 0xFFFFD700})]);
      final left = js.JsObject(js.context['THREE']['Mesh'], [earGeo, earMat]);
      left['position']['set'](-0.35, 2.15, -0.02);
      avatar.callMethod('add', [left]);
      final right = left.callMethod('clone', []);
      right['position']['set'](0.35, 2.15, -0.02);
      avatar.callMethod('add', [right]);
    } else if (accessories == 'necklace') {
      final torus = js.JsObject(js.context['THREE']['TorusGeometry'], [0.35, 0.015, 8, 32]);
      final mat = js.JsObject(js.context['THREE']['MeshStandardMaterial'], [js.JsObject.jsify({'color': 0xFFFFD700})]);
      final mesh = js.JsObject(js.context['THREE']['Mesh'], [torus, mat]);
      mesh['position']['set'](0, 1.0, 0.2);
      mesh['rotation']['set'](1.5708, 0, 0);
      avatar.callMethod('add', [mesh]);
    } else if (accessories == 'watch') {
      final bandGeo = js.JsObject(js.context['THREE']['TorusGeometry'], [0.08, 0.015, 8, 16]);
      final bandMat = js.JsObject(js.context['THREE']['MeshStandardMaterial'], [js.JsObject.jsify({'color': 0x8B4513})]);
      final band = js.JsObject(js.context['THREE']['Mesh'], [bandGeo, bandMat]);
      band['position']['set'](0.9, 0.95, 0);
      band['rotation']['set'](0, 0, 1.5708);
      avatar.callMethod('add', [band]);
      final faceGeo = js.JsObject(js.context['THREE']['CylinderGeometry'], [0.05, 0.05, 0.02, 16]);
      final faceMat = js.JsObject(js.context['THREE']['MeshStandardMaterial'], [js.JsObject.jsify({'color': 0xFFFFFF})]);
      final face = js.JsObject(js.context['THREE']['Mesh'], [faceGeo, faceMat]);
      face['position']['set'](0.9, 0.95, 0);
      face['rotation']['set'](1.5708, 0, 0);
      avatar.callMethod('add', [face]);
    }
  }
  
  /// Create realistic eyes with white base and colored iris
  void _createRealisticEyes(js.JsObject eyeMat, js.JsObject eyeWhiteMat) {
    // Eye socket depth
    final socketDepth = 0.28;
    
    // Left eye - white oval base (using flattened sphere)
    final eyeWhiteGeo = js.JsObject(js.context['THREE']['SphereGeometry'], [0.09, 20, 14]);
    final leftEyeWhite = js.JsObject(js.context['THREE']['Mesh'], [eyeWhiteGeo, eyeWhiteMat]);
    leftEyeWhite['position']['set'](-0.12, 2.25, socketDepth);
    leftEyeWhite['scale']['set'](1.4, 0.8, 0.6); // Make it oval shaped
    avatar.callMethod('add', [leftEyeWhite]);
    
    // Left iris - colored oval
    final irisGeo = js.JsObject(js.context['THREE']['SphereGeometry'], [0.045, 16, 12]);
    final leftIris = js.JsObject(js.context['THREE']['Mesh'], [irisGeo, eyeMat]);
    leftIris['position']['set'](-0.12, 2.25, socketDepth + 0.06);
    leftIris['scale']['set'](1.2, 1.2, 0.5); // Slightly oval iris
    avatar.callMethod('add', [leftIris]);
    
    // Left pupil - small black circle
    final pupilMat = js.JsObject(js.context['THREE']['MeshStandardMaterial'], [
      js.JsObject.jsify({'color': 0x000000, 'roughness': 0.1})
    ]);
    final pupilGeo = js.JsObject(js.context['THREE']['SphereGeometry'], [0.02, 12, 8]);
    final leftPupil = js.JsObject(js.context['THREE']['Mesh'], [pupilGeo, pupilMat]);
    leftPupil['position']['set'](-0.12, 2.25, socketDepth + 0.07);
    leftPupil['scale']['set'](1.0, 1.0, 0.3);
    avatar.callMethod('add', [leftPupil]);
    
    // Right eye - white oval base
    final rightEyeWhite = leftEyeWhite.callMethod('clone', []);
    rightEyeWhite['position']['set'](0.12, 2.25, socketDepth);
    avatar.callMethod('add', [rightEyeWhite]);
    
    // Right iris - colored oval
    final rightIris = leftIris.callMethod('clone', []);
    rightIris['position']['set'](0.12, 2.25, socketDepth + 0.06);
    avatar.callMethod('add', [rightIris]);
    
    // Right pupil
    final rightPupil = leftPupil.callMethod('clone', []);
    rightPupil['position']['set'](0.12, 2.25, socketDepth + 0.07);
    avatar.callMethod('add', [rightPupil]);
    
    // Add subtle highlights to eyes
    final highlightMat = js.JsObject(js.context['THREE']['MeshStandardMaterial'], [
      js.JsObject.jsify({
        'color': 0xffffff,
        'transparent': true,
        'opacity': 0.8,
        'roughness': 0.1,
        'metalness': 0.0
      })
    ]);
    
    final highlightGeo = js.JsObject(js.context['THREE']['SphereGeometry'], [0.01, 8, 6]);
    
    // Left eye highlight
    final leftHighlight = js.JsObject(js.context['THREE']['Mesh'], [highlightGeo, highlightMat]);
    leftHighlight['position']['set'](-0.1, 2.27, socketDepth + 0.08);
    avatar.callMethod('add', [leftHighlight]);
    
    // Right eye highlight
    final rightHighlight = leftHighlight.callMethod('clone', []);
    rightHighlight['position']['set'](0.1, 2.27, socketDepth + 0.08);
    avatar.callMethod('add', [rightHighlight]);
    
    // Add eyelashes for more realistic look
    _createEyelashes();
  }
  
  /// Create stylish glasses
  void _createStylishGlasses() {
    final frameMat = js.JsObject(js.context['THREE']['MeshStandardMaterial'], [
      js.JsObject.jsify({'color': 0x2c3e50, 'roughness': 0.3, 'metalness': 0.7})
    ]);
    final glassMat = js.JsObject(js.context['THREE']['MeshStandardMaterial'], [
      js.JsObject.jsify({
        'color': 0x87ceeb,
        'transparent': true,
        'opacity': 0.2,
        'roughness': 0.1,
        'metalness': 0.0
      })
    ]);
    
    // Left lens frame (torus for rounded rectangle)
    final frameGeo = js.JsObject(js.context['THREE']['TorusGeometry'], [0.13, 0.02, 8, 16]);
    final leftFrame = js.JsObject(js.context['THREE']['Mesh'], [frameGeo, frameMat]);
    leftFrame['position']['set'](-0.12, 2.25, 0.29);
    avatar.callMethod('add', [leftFrame]);
    
    // Left lens
    final lensGeo = js.JsObject(js.context['THREE']['SphereGeometry'], [0.11, 16, 12]);
    final leftLens = js.JsObject(js.context['THREE']['Mesh'], [lensGeo, glassMat]);
    leftLens['position']['set'](-0.12, 2.25, 0.29);
    leftLens['scale']['set'](1.0, 1.0, 0.1);
    avatar.callMethod('add', [leftLens]);
    
    // Right frame and lens
    final rightFrame = leftFrame.callMethod('clone', []);
    rightFrame['position']['set'](0.12, 2.25, 0.29);
    avatar.callMethod('add', [rightFrame]);
    
    final rightLens = leftLens.callMethod('clone', []);
    rightLens['position']['set'](0.12, 2.25, 0.29);
    avatar.callMethod('add', [rightLens]);
    
    // Bridge
    final bridgeGeo = js.JsObject(js.context['THREE']['CylinderGeometry'], [0.015, 0.015, 0.08, 8]);
    final bridge = js.JsObject(js.context['THREE']['Mesh'], [bridgeGeo, frameMat]);
    bridge['position']['set'](0, 2.25, 0.29);
    bridge['rotation']['set'](0, 0, 1.5708); // 90 degrees
    avatar.callMethod('add', [bridge]);
    
    // Temples
    final templeGeo = js.JsObject(js.context['THREE']['CylinderGeometry'], [0.01, 0.01, 0.4, 6]);
    final leftTemple = js.JsObject(js.context['THREE']['Mesh'], [templeGeo, frameMat]);
    leftTemple['position']['set'](-0.25, 2.25, 0.1);
    leftTemple['rotation']['set'](0, -0.3, 1.5708);
    avatar.callMethod('add', [leftTemple]);
    
    final rightTemple = leftTemple.callMethod('clone', []);
    rightTemple['position']['set'](0.25, 2.25, 0.1);
    rightTemple['rotation']['set'](0, 0.3, 1.5708);
    avatar.callMethod('add', [rightTemple]);
  }
  
  /// Create realistic beard
  void _createRealisticBeard(js.JsObject hairMat) {
    // Main beard shape
    final beardGeo = js.JsObject(js.context['THREE']['SphereGeometry'], [0.22, 16, 12]);
    final beard = js.JsObject(js.context['THREE']['Mesh'], [beardGeo, hairMat]);
    beard['position']['set'](0, 1.95, 0.22);
    beard['scale']['set'](1.2, 0.8, 0.8);
    avatar.callMethod('add', [beard]);
    
    // Mustache
    final mustacheGeo = js.JsObject(js.context['THREE']['SphereGeometry'], [0.12, 12, 8]);
    final mustache = js.JsObject(js.context['THREE']['Mesh'], [mustacheGeo, hairMat]);
    mustache['position']['set'](0, 2.1, 0.27);
    mustache['scale']['set'](1.4, 0.4, 0.6);
    avatar.callMethod('add', [mustache]);
  }
  
  /// Create nose
  void _createNose(js.JsObject skinMat) {
    final noseGeo = js.JsObject(js.context['THREE']['SphereGeometry'], [0.04, 8, 6]);
    final nose = js.JsObject(js.context['THREE']['Mesh'], [noseGeo, skinMat]);
    nose['position']['set'](0, 2.15, 0.32);
    nose['scale']['set'](0.8, 1.2, 1.0);
    avatar.callMethod('add', [nose]);
  }
  
  /// Create lips
  void _createLips(js.JsObject skinMat) {
    final lipsMat = js.JsObject(js.context['THREE']['MeshStandardMaterial'], [
      js.JsObject.jsify({
        'color': _getLipColor(),
        'roughness': 0.4,
        'metalness': 0.0
      })
    ]);
    
    final lipsGeo = js.JsObject(js.context['THREE']['SphereGeometry'], [0.06, 8, 4]);
    final lips = js.JsObject(js.context['THREE']['Mesh'], [lipsGeo, lipsMat]);
    lips['position']['set'](0, 2.0, 0.3);
    lips['scale']['set'](1.2, 0.3, 0.8);
    avatar.callMethod('add', [lips]);
  }
  
  /// Create eyelashes
  void _createEyelashes() {
    final lashMat = js.JsObject(js.context['THREE']['MeshStandardMaterial'], [
      js.JsObject.jsify({'color': 0x1a1a1a})
    ]);
    
    final lashGeo = js.JsObject(js.context['THREE']['SphereGeometry'], [0.09, 8, 4]);
    
    // Left eyelashes
    final leftLash = js.JsObject(js.context['THREE']['Mesh'], [lashGeo, lashMat]);
    leftLash['position']['set'](-0.12, 2.3, 0.3);
    leftLash['scale']['set'](1.0, 0.1, 0.5);
    avatar.callMethod('add', [leftLash]);
    
    // Right eyelashes
    final rightLash = leftLash.callMethod('clone', []);
    rightLash['position']['set'](0.12, 2.3, 0.3);
    avatar.callMethod('add', [rightLash]);
  }
  
  /// Create curved neck
  void _createNeck(js.JsObject skinMat) {
    final neckGeo = js.JsObject(js.context['THREE']['CylinderGeometry'], [0.16, 0.18, 0.35, 12]);
    final neck = js.JsObject(js.context['THREE']['Mesh'], [neckGeo, skinMat]);
    neck['position']['set'](0, 1.75, 0);
    avatar.callMethod('add', [neck]);
  }
  
  /// Create curved collar
  void _createCurvedCollar(js.JsObject clothMat) {
    // V-neck collar with curves
    final collarGeo = js.JsObject(js.context['THREE']['SphereGeometry'], [0.4, 12, 8]);
    final collar = js.JsObject(js.context['THREE']['Mesh'], [collarGeo, clothMat]);
    collar['position']['set'](0, 1.5, 0);
    collar['scale']['set'](1.8, 0.3, 1.0);
    avatar.callMethod('add', [collar]);
  }
  
  /// Create curved torso with gender-specific shapes
  void _createCurvedTorso(String bodyType, String gender, js.JsObject clothMat, Map<String, double> proportions) {
    if (gender.toLowerCase() == 'female') {
      // Female torso with smooth curves - using higher resolution sphere
      final torsoGeo = js.JsObject(js.context['THREE']['SphereGeometry'], [0.45, 32, 24]);
      final torso = js.JsObject(js.context['THREE']['Mesh'], [torsoGeo, clothMat]);
      torso['position']['set'](0, 1.2, 0);
      torso['scale']['set'](
        proportions['shoulderWidth']! * 0.9,
        proportions['torsoHeight']! * 1.2,
        proportions['torsoDepth']! * 0.8
      );
      avatar.callMethod('add', [torso]);
      
      // Add waist definition with smooth curves
      final waistGeo = js.JsObject(js.context['THREE']['SphereGeometry'], [0.32, 24, 16]);
      final waist = js.JsObject(js.context['THREE']['Mesh'], [waistGeo, clothMat]);
      waist['position']['set'](0, 0.85, 0);
      waist['scale']['set'](0.75, 0.5, 0.75);
      avatar.callMethod('add', [waist]);
      
      // Add hip area for feminine curve
      final hipGeo = js.JsObject(js.context['THREE']['SphereGeometry'], [0.38, 24, 16]);
      final hips = js.JsObject(js.context['THREE']['Mesh'], [hipGeo, clothMat]);
      hips['position']['set'](0, 0.5, 0);
      hips['scale']['set'](1.1, 0.6, 0.9);
      avatar.callMethod('add', [hips]);
    } else {
      // Male torso - broader shoulders with smooth curves
      final torsoGeo = js.JsObject(js.context['THREE']['SphereGeometry'], [0.48, 32, 24]);
      final torso = js.JsObject(js.context['THREE']['Mesh'], [torsoGeo, clothMat]);
      torso['position']['set'](0, 1.2, 0);
      torso['scale']['set'](
        proportions['shoulderWidth']! * 1.1,
        proportions['torsoHeight']! * 1.1,
        proportions['torsoDepth']! * 0.9
      );
      avatar.callMethod('add', [torso]);
      
      // Add chest definition
      final chestGeo = js.JsObject(js.context['THREE']['SphereGeometry'], [0.42, 24, 16]);
      final chest = js.JsObject(js.context['THREE']['Mesh'], [chestGeo, clothMat]);
      chest['position']['set'](0, 1.35, 0.1);
      chest['scale']['set'](1.0, 0.7, 0.8);
      avatar.callMethod('add', [chest]);
    }
  }
  
  /// Create curved arms with natural proportions
  void _createCurvedArms(String bodyType, js.JsObject skinMat, js.JsObject clothMat, Map<String, double> proportions) {
    // Upper arms with smooth natural curves - higher resolution
    final upperArmGeo = js.JsObject(js.context['THREE']['SphereGeometry'], [0.14, 24, 16]);
    
    // Left upper arm
    final leftUpperArm = js.JsObject(js.context['THREE']['Mesh'], [upperArmGeo, skinMat]);
    leftUpperArm['position']['set'](-proportions['shoulderWidth']! / 2 - 0.15, 1.3, 0);
    leftUpperArm['rotation']['set'](0, 0, 0.2);
    leftUpperArm['scale']['set'](
      proportions['upperArmRadius']! * 1.1,
      proportions['upperArmLength']! * 1.6,
      proportions['upperArmRadius']! * 1.1
    );
    avatar.callMethod('add', [leftUpperArm]);
    
    // Right upper arm
    final rightUpperArm = leftUpperArm.callMethod('clone', []);
    rightUpperArm['position']['set'](proportions['shoulderWidth']! / 2 + 0.15, 1.3, 0);
    rightUpperArm['rotation']['set'](0, 0, -0.2);
    avatar.callMethod('add', [rightUpperArm]);
    
    // Forearms with smooth curves - higher resolution
    final forearmGeo = js.JsObject(js.context['THREE']['SphereGeometry'], [0.11, 20, 14]);
    
    // Left forearm
    final leftForearm = js.JsObject(js.context['THREE']['Mesh'], [forearmGeo, skinMat]);
    leftForearm['position']['set'](-proportions['shoulderWidth']! / 2 - 0.35, 0.8, 0);
    leftForearm['rotation']['set'](0, 0, 0.1);
    leftForearm['scale']['set'](
      proportions['lowerArmRadius']! * 1.1,
      proportions['lowerArmLength']! * 1.4,
      proportions['lowerArmRadius']! * 1.1
    );
    avatar.callMethod('add', [leftForearm]);
    
    // Right forearm
    final rightForearm = leftForearm.callMethod('clone', []);
    rightForearm['position']['set'](proportions['shoulderWidth']! / 2 + 0.35, 0.8, 0);
    rightForearm['rotation']['set'](0, 0, -0.1);
    avatar.callMethod('add', [rightForearm]);
    
    // Enhanced hands
    _createEnhancedHands(skinMat, clothMat);
  }
  
  /// Enhanced hands with smooth curves
  void _createEnhancedHands(js.JsObject skinMat, js.JsObject clothMat) {
    // Hand palm with smooth curves - higher resolution
    final palmGeo = js.JsObject(js.context['THREE']['SphereGeometry'], [0.07, 16, 12]);
    
    // Left hand
    final leftPalm = js.JsObject(js.context['THREE']['Mesh'], [palmGeo, skinMat]);
    leftPalm['position']['set'](-0.65, 0.45, 0);
    leftPalm['scale']['set'](1.3, 1.1, 0.7);
    avatar.callMethod('add', [leftPalm]);
    
    // Add fingers to left hand
    _createSmoothFingers(-0.65, 0.55, skinMat, true);
    
    // Right hand
    final rightPalm = leftPalm.callMethod('clone', []);
    rightPalm['position']['set'](0.65, 0.45, 0);
    avatar.callMethod('add', [rightPalm]);
    
    // Add fingers to right hand
    _createSmoothFingers(0.65, 0.55, skinMat, false);
    
    // Wrist cuffs with smooth curves
    final cuffGeo = js.JsObject(js.context['THREE']['SphereGeometry'], [0.10, 16, 12]);
    final cuffMat = clothMat;
    
    final leftCuff = js.JsObject(js.context['THREE']['Mesh'], [cuffGeo, cuffMat]);
    leftCuff['position']['set'](-0.65, 0.32, 0);
    leftCuff['scale']['set'](1.2, 0.4, 1.2);
    avatar.callMethod('add', [leftCuff]);
    
    final rightCuff = leftCuff.callMethod('clone', []);
    rightCuff['position']['set'](0.65, 0.32, 0);
    avatar.callMethod('add', [rightCuff]);
  }
  
  /// Create smooth fingers for hands
  void _createSmoothFingers(double handX, double handY, js.JsObject skinMat, bool isLeft) {
    final fingerGeo = js.JsObject(js.context['THREE']['SphereGeometry'], [0.018, 8, 6]);
    
    // Create 4 fingers with smooth curves (thumb separate)
    for (int i = 0; i < 4; i++) {
      final finger = js.JsObject(js.context['THREE']['Mesh'], [fingerGeo, skinMat]);
      final offsetX = isLeft ? -0.08 + (i * 0.05) : 0.08 - (i * 0.05);
      finger['position']['set'](handX + offsetX, handY, 0.05);
      finger['scale']['set'](1.1, 2.8, 1.1);
      avatar.callMethod('add', [finger]);
      
      // Add finger joints for more realism
      final jointGeo = js.JsObject(js.context['THREE']['SphereGeometry'], [0.015, 6, 4]);
      final joint1 = js.JsObject(js.context['THREE']['Mesh'], [jointGeo, skinMat]);
      joint1['position']['set'](handX + offsetX, handY + 0.015, 0.05);
      joint1['scale']['set'](1.2, 0.8, 1.2);
      avatar.callMethod('add', [joint1]);
      
      final joint2 = js.JsObject(js.context['THREE']['Mesh'], [jointGeo, skinMat]);
      joint2['position']['set'](handX + offsetX, handY + 0.03, 0.05);
      joint2['scale']['set'](1.2, 0.8, 1.2);
      avatar.callMethod('add', [joint2]);
    }
    
    // Thumb with smooth curves
    final thumbGeo = js.JsObject(js.context['THREE']['SphereGeometry'], [0.02, 8, 6]);
    final thumb = js.JsObject(js.context['THREE']['Mesh'], [thumbGeo, skinMat]);
    final thumbOffsetX = isLeft ? 0.08 : -0.08;
    thumb['position']['set'](handX + thumbOffsetX, handY - 0.05, 0.08);
    thumb['scale']['set'](1.3, 2.2, 1.3);
    thumb['rotation']['set'](0.3, 0, isLeft ? -0.5 : 0.5);
    avatar.callMethod('add', [thumb]);
    
    // Thumb joint
    final thumbJointGeo = js.JsObject(js.context['THREE']['SphereGeometry'], [0.017, 6, 4]);
    final thumbJoint = js.JsObject(js.context['THREE']['Mesh'], [thumbJointGeo, skinMat]);
    thumbJoint['position']['set'](handX + thumbOffsetX, handY - 0.035, 0.08);
    thumbJoint['scale']['set'](1.2, 0.8, 1.2);
    thumbJoint['rotation']['set'](0.3, 0, isLeft ? -0.5 : 0.5);
    avatar.callMethod('add', [thumbJoint]);
  }
  
  /// Create curved legs with gender-specific shapes
  void _createCurvedLegs(String bodyType, String gender, js.JsObject clothMat, Map<String, double> proportions) {
    // Thighs with smooth natural curves - higher resolution
    final thighGeo = js.JsObject(js.context['THREE']['SphereGeometry'], [0.15, 24, 16]);
    
    // Left thigh with gender-specific curves
    final leftThigh = js.JsObject(js.context['THREE']['Mesh'], [thighGeo, clothMat]);
    leftThigh['position']['set'](-0.22, 0.25, 0);
    if (gender.toLowerCase() == 'female') {
      leftThigh['scale']['set'](
        proportions['thighRadius']! * 1.4,
        proportions['thighLength']! * 1.5,
        proportions['thighRadius']! * 1.3
      );
    } else {
      leftThigh['scale']['set'](
        proportions['thighRadius']! * 1.3,
        proportions['thighLength']! * 1.4,
        proportions['thighRadius']! * 1.2
      );
    }
    avatar.callMethod('add', [leftThigh]);
    
    // Right thigh
    final rightThigh = leftThigh.callMethod('clone', []);
    rightThigh['position']['set'](0.22, 0.25, 0);
    avatar.callMethod('add', [rightThigh]);
    
    // Knees with smooth curve - higher resolution
    final kneeGeo = js.JsObject(js.context['THREE']['SphereGeometry'], [0.11, 16, 12]);
    final kneeMat = clothMat;
    
    final leftKnee = js.JsObject(js.context['THREE']['Mesh'], [kneeGeo, kneeMat]);
    leftKnee['position']['set'](-0.22, -0.15, 0);
    leftKnee['scale']['set'](1.1, 0.7, 1.1);
    avatar.callMethod('add', [leftKnee]);
    
    final rightKnee = leftKnee.callMethod('clone', []);
    rightKnee['position']['set'](0.22, -0.15, 0);
    avatar.callMethod('add', [rightKnee]);
    
    // Lower legs (calves) with natural shape - higher resolution
    final calfGeo = js.JsObject(js.context['THREE']['SphereGeometry'], [0.12, 20, 14]);
    
    final leftCalf = js.JsObject(js.context['THREE']['Mesh'], [calfGeo, clothMat]);
    leftCalf['position']['set'](-0.22, -0.45, 0);
    leftCalf['scale']['set'](
      proportions['lowerLegRadius']! * 1.4,
      proportions['lowerLegLength']! * 1.3,
      proportions['lowerLegRadius']! * 1.4
    );
    avatar.callMethod('add', [leftCalf]);
    
    final rightCalf = leftCalf.callMethod('clone', []);
    rightCalf['position']['set'](0.22, -0.45, 0);
    avatar.callMethod('add', [rightCalf]);
    
    // Ankles with smooth curves
    final ankleGeo = js.JsObject(js.context['THREE']['SphereGeometry'], [0.07, 16, 12]);
    final ankleMat = js.JsObject(js.context['THREE']['MeshStandardMaterial'], [
      js.JsObject.jsify({
        'color': _getSkinColor('medium'),
        'roughness': 0.8,
        'metalness': 0.1
      })
    ]);
    
    final leftAnkle = js.JsObject(js.context['THREE']['Mesh'], [ankleGeo, ankleMat]);
    leftAnkle['position']['set'](-0.22, -0.75, 0);
    avatar.callMethod('add', [leftAnkle]);
    
    final rightAnkle = leftAnkle.callMethod('clone', []);
    rightAnkle['position']['set'](0.22, -0.75, 0);
    avatar.callMethod('add', [rightAnkle]);
    
    // Enhanced feet with more realistic shape
    _createEnhancedFeet(bodyType);
  }
  
  /// Create enhanced feet with better shape
  void _createEnhancedFeet(String bodyType) {
    // Shoe material with style variation
    final shoeMat = js.JsObject(js.context['THREE']['MeshStandardMaterial'], [
      js.JsObject.jsify({
        'color': _getShoeColor('casual'),
        'roughness': 0.7,
        'metalness': 0.1
      })
    ]);
    
    // Foot base (more realistic shape)
    final footGeo = js.JsObject(js.context['THREE']['SphereGeometry'], [0.12, 12, 8]);
    
    // Left foot
    final leftFoot = js.JsObject(js.context['THREE']['Mesh'], [footGeo, shoeMat]);
    leftFoot['position']['set'](-0.22, -0.85, 0.15);
    leftFoot['scale']['set'](1.0, 0.6, 2.2);
    avatar.callMethod('add', [leftFoot]);
    
    // Right foot
    final rightFoot = leftFoot.callMethod('clone', []);
    rightFoot['position']['set'](0.22, -0.85, 0.15);
    avatar.callMethod('add', [rightFoot]);
    
    // Shoe details (laces/straps)
    _createShoeDetails();
  }
  
  /// Create shoe details
  void _createShoeDetails() {
    final detailMat = js.JsObject(js.context['THREE']['MeshStandardMaterial'], [
      js.JsObject.jsify({'color': 0xffffff, 'roughness': 0.8})
    ]);
    
    // Shoe laces
    final laceGeo = js.JsObject(js.context['THREE']['CylinderGeometry'], [0.01, 0.01, 0.15, 4]);
    
    for (int i = 0; i < 3; i++) {
      // Left shoe laces
      final leftLace = js.JsObject(js.context['THREE']['Mesh'], [laceGeo, detailMat]);
      leftLace['position']['set'](-0.22, -0.8 + (i * 0.05), 0.25);
      leftLace['rotation']['set'](1.5708, 0, 0);
      avatar.callMethod('add', [leftLace]);
      
      // Right shoe laces
      final rightLace = leftLace.callMethod('clone', []);
      rightLace['position']['set'](0.22, -0.8 + (i * 0.05), 0.25);
      avatar.callMethod('add', [rightLace]);
    }
  }
  
  /// Create rounded belt with buckle details
  void _createRoundedBelt(String style) {
    final beltMat = js.JsObject(js.context['THREE']['MeshStandardMaterial'], [
      js.JsObject.jsify({
        'color': _getBeltColor(style),
        'roughness': 0.7,
        'metalness': 0.2
      })
    ]);
    final buckleMat = js.JsObject(js.context['THREE']['MeshStandardMaterial'], [
      js.JsObject.jsify({
        'color': _getBuckleColor(style),
        'roughness': 0.3,
        'metalness': 0.8
      })
    ]);
    
    // Belt with rounded edges
    final beltGeo = js.JsObject(js.context['THREE']['TorusGeometry'], [0.55, 0.04, 8, 16]);
    final belt = js.JsObject(js.context['THREE']['Mesh'], [beltGeo, beltMat]);
    belt['position']['set'](0, 0.65, 0);
    avatar.callMethod('add', [belt]);
    
    // Belt buckle with more detail
    final buckleGeo = js.JsObject(js.context['THREE']['SphereGeometry'], [0.06, 8, 6]);
    final buckle = js.JsObject(js.context['THREE']['Mesh'], [buckleGeo, buckleMat]);
    buckle['position']['set'](0, 0.65, 0.4);
    buckle['scale']['set'](1.5, 1.0, 0.3);
    avatar.callMethod('add', [buckle]);
    
    // Buckle prong
    final prongGeo = js.JsObject(js.context['THREE']['CylinderGeometry'], [0.01, 0.01, 0.08, 4]);
    final prong = js.JsObject(js.context['THREE']['Mesh'], [prongGeo, buckleMat]);
    prong['position']['set'](0, 0.65, 0.42);
    prong['rotation']['set'](1.5708, 0, 0);
    avatar.callMethod('add', [prong]);
  }
  
  /// Calculate proportions based on body type
  Map<String, double> _calculateProportions(String bodyType, String gender) {
    Map<String, double> proportions = {
      'shoulderWidth': 1.0,
      'torsoHeight': 1.2,
      'torsoDepth': 0.5,
      'upperArmRadius': 0.15,
      'upperArmLength': 0.8,
      'lowerArmRadius': 0.12,
      'lowerArmLength': 0.6,
      'thighRadius': 0.15, // Thinner than waist
      'thighLength': 0.8,
      'lowerLegRadius': 0.12,
      'lowerLegLength': 0.8,
    };
    
    // Adjust for body type
    switch (bodyType.toLowerCase()) {
      case 'slim':
        proportions['shoulderWidth'] = 0.8;
        proportions['upperArmRadius'] = 0.12;
        proportions['thighRadius'] = 0.12;
        break;
      case 'athletic':
        proportions['shoulderWidth'] = 1.1;
        proportions['upperArmRadius'] = 0.18;
        proportions['thighRadius'] = 0.18;
        break;
      case 'muscular':
        proportions['shoulderWidth'] = 1.2;
        proportions['upperArmRadius'] = 0.2;
        proportions['thighRadius'] = 0.2;
        break;
      case 'curvy':
        proportions['shoulderWidth'] = 1.0;
        proportions['upperArmRadius'] = 0.16;
        proportions['thighRadius'] = 0.18;
        break;
    }
    
    // Gender adjustments
    if (gender.toLowerCase() == 'female') {
      proportions['shoulderWidth'] = (proportions['shoulderWidth'] ?? 1.0) * 0.9;
      proportions['thighRadius'] = (proportions['thighRadius'] ?? 0.15) * 1.1;
    }
    
    return proportions;
  }
  
  /// Add orbit controls
  void _addControls() {
    if (!kIsWeb) return;
    controls = js.JsObject(js.context['THREE']['OrbitControls'], [camera, renderer['domElement']]);
    _set3(controls, 'target', 0, 1.2, 0);
    controls.callMethod('update', []);
  }
  
  /// Animation loop
  void _animate() {
    if (!kIsWeb) return;
    void tick(num _) {
      renderer.callMethod('render', [scene, camera]);
      js.context.callMethod('requestAnimationFrame', [tick]);
    }
    js.context.callMethod('requestAnimationFrame', [tick]);
  }
  
  /// Handle window resize
  void _handleResize() {
    if (!kIsWeb) return;
    html.window.onResize.listen((event) {
      camera['aspect'] = html.window.innerWidth! / html.window.innerHeight!;
      camera.callMethod('updateProjectionMatrix', []);
      renderer['setSize'](html.window.innerWidth!, html.window.innerHeight!);
    });
  }
  
  /// Color helper methods
  int _getSkinColor(String skinTone) {
    switch (skinTone.toLowerCase()) {
      case 'light':
        return 0xFFF5DEB3;
      case 'medium':
        return 0xFFDEB887;
      case 'olive':
        return 0xFFDAA520;
      case 'tan':
        return 0xFFCD853F;
      case 'dark':
        return 0xFFA0522D;
      default:
        return 0xFFDEB887;
    }
  }
  
  int _getClothingColor(String style) {
    switch (style.toLowerCase()) {
      case 'professional':
        return 0xFF2C3E50;
      case 'casual':
        return 0xFF3498DB;
      case 'sporty':
        return 0xFFE74C3C;
      case 'elegant':
        return 0xFF1A1A1A;
      case 'artistic':
        return 0xFF9B59B6;
      default:
        return 0xFF3498DB;
    }
  }
  
  int _getHairColor(String hairColor) {
    switch (hairColor.toLowerCase()) {
      case 'black':
        return 0xFF1A1A1A;
      case 'brown':
        return 0xFF8B4513;
      case 'blonde':
        return 0xFFDAA520;
      case 'red':
        return 0xFFA0522D;
      case 'gray':
        return 0xFF696969;
      case 'white':
        return 0xFFF5F5F5;
      default:
        return 0xFF8B4513;
    }
  }
  
  int _getEyeColor(String eyeColor) {
    switch (eyeColor.toLowerCase()) {
      case 'brown':
        return 0xFF8B4513;
      case 'blue':
        return 0xFF4169E1;
      case 'green':
        return 0xFF228B22;
      case 'hazel':
        return 0xFF8B7355;
      case 'gray':
        return 0xFF708090;
      default:
        return 0xFF8B4513;
    }
  }
  
  int _getLipColor() {
    return 0xFFDC7B7B; // Natural lip color
  }
  
  int _getBeltColor(String style) {
    switch (style.toLowerCase()) {
      case 'professional':
        return 0xFF1A1A1A;
      case 'casual':
        return 0xFF8B4513;
      case 'sporty':
        return 0xFF2C3E50;
      case 'elegant':
        return 0xFF000000;
      case 'artistic':
        return 0xFF6A1B9A;
      default:
        return 0xFF8B4513;
    }
  }
  
  int _getBuckleColor(String style) {
    switch (style.toLowerCase()) {
      case 'professional':
        return 0xFFFFD700;
      case 'casual':
        return 0xFFC0C0C0;
      case 'sporty':
        return 0xFFFFFFFF;
      case 'elegant':
        return 0xFFFFD700;
      case 'artistic':
        return 0xFFF39C12;
      default:
        return 0xFFC0C0C0;
    }
  }
  
  int _getShoeColor(String style) {
    switch (style.toLowerCase()) {
      case 'professional':
        return 0xFF1A1A1A;
      case 'casual':
        return 0xFF8B4513;
      case 'sporty':
        return 0xFFFFFFFF;
      case 'elegant':
        return 0xFF000000;
      case 'artistic':
        return 0xFF6A1B9A;
      default:
        return 0xFF8B4513;
    }
  }
  
  /// Dispose of resources
  void dispose() {
    if (renderer != null) {
      renderer.callMethod('dispose', []);
    }
  }
}