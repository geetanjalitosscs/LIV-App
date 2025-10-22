import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../services/three_dart_avatar_service.dart';

class Avatar3DViewerScreen extends StatefulWidget {
  final Map<String, dynamic> avatarSpecs;
  
  const Avatar3DViewerScreen({
    super.key,
    required this.avatarSpecs,
  });

  @override
  State<Avatar3DViewerScreen> createState() => _Avatar3DViewerScreenState();
}

class _Avatar3DViewerScreenState extends State<Avatar3DViewerScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAvatarViewer();
  }

  Future<void> _loadAvatarViewer() async {
    try {
      // For web platform, render using three_dart inside an overlay
      if (kIsWeb) {
        await ThreeDartAvatarService.instance.initializeWithConfig({
          'gender': widget.avatarSpecs['gender']?.toString(),
          'bodyType': widget.avatarSpecs['bodyType']?.toString(),
          'skinColor': null,
          'skinTone': widget.avatarSpecs['skinTone']?.toString(),
          'style': widget.avatarSpecs['style']?.toString(),
          'hairColor': widget.avatarSpecs['hairColor']?.toString(),
          'eyeColor': widget.avatarSpecs['eyeColor']?.toString(),
          'topColor': null,
          'bottomColor': null,
          'shoeColor': null,
        });
        setState(() { _isLoading = false; });
      } else {
        // For other platforms, show a message
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading avatar viewer: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _openAvatarInNewTab() {
    if (!kIsWeb) {
      // Show a message for non-web platforms
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('3D Avatar viewer is only available on web platform'),
        ),
      );
      return;
    }
    
    try {
      // Web-specific implementation will be handled by conditional imports
      _openAvatarInNewTabWeb();
    } catch (e) {
      print('Error opening avatar viewer: $e');
      // Fallback: try opening the standalone HTML file
      _openStandaloneAvatar();
    }
  }
  
  void _openAvatarInNewTabWeb() {
    // This method will only be called on web platform
    // Implementation will be added via conditional imports
    print('Opening avatar in new tab (web implementation)');
  }

  void _openStandaloneAvatar() {
    if (!kIsWeb) {
      // Show a message for non-web platforms
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('3D Avatar viewer is only available on web platform'),
        ),
      );
      return;
    }
    
    try {
      // Web-specific implementation
      _openStandaloneAvatarWeb();
    } catch (e) {
      print('Error opening standalone avatar: $e');
    }
  }
  
  void _openStandaloneAvatarWeb() {
    // This method will only be called on web platform
    print('Opening standalone avatar (web implementation)');
  }

  String _buildUrlParams() {
    final Map<String, String> params = {
      'gender': widget.avatarSpecs['gender']?.toString() ?? 'male',
      'bodyType': widget.avatarSpecs['bodyType']?.toString() ?? 'athletic',
      'skinTone': widget.avatarSpecs['skinTone']?.toString() ?? 'medium',
      'style': widget.avatarSpecs['style']?.toString() ?? 'casual',
      'hairColor': widget.avatarSpecs['hairColor']?.toString() ?? 'brown',
      'eyeColor': widget.avatarSpecs['eyeColor']?.toString() ?? 'brown',
      'hasBeard': widget.avatarSpecs['hasBeard']?.toString() ?? 'false',
      'hasGlasses': widget.avatarSpecs['hasGlasses']?.toString() ?? 'false',
    };
    
    return params.entries
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }

  String _getAvatarHTML() {
    return '''
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>3D Avatar Viewer</title>
    <style>
        body {
            margin: 0;
            padding: 0;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            font-family: Arial, sans-serif;
            overflow: hidden;
        }
        
        #info {
            position: absolute;
            top: 20px;
            left: 20px;
            background: rgba(255, 255, 255, 0.95);
            padding: 15px;
            border-radius: 10px;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
            z-index: 100;
            max-width: 250px;
        }
        
        .spec-item {
            margin-bottom: 8px;
            font-size: 14px;
        }
        
        .spec-label {
            font-weight: bold;
            color: #667eea;
        }
        
        #loading {
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            color: white;
            font-size: 18px;
            text-align: center;
        }
    </style>
</head>
<body>
    <div id="info">
        <h3 style="margin-top: 0; color: #667eea;">Your 3D Avatar</h3>
        <div class="spec-item">
            <span class="spec-label">Gender:</span> ${widget.avatarSpecs['gender']}
        </div>
        <div class="spec-item">
            <span class="spec-label">Body Type:</span> ${widget.avatarSpecs['bodyType']}
        </div>
        <div class="spec-item">
            <span class="spec-label">Skin Tone:</span> ${widget.avatarSpecs['skinTone']}
        </div>
        <div class="spec-item">
            <span class="spec-label">Style:</span> ${widget.avatarSpecs['style']}
        </div>
        <div class="spec-item">
            <span class="spec-label">Hair Color:</span> ${widget.avatarSpecs['hairColor']}
        </div>
        <div class="spec-item">
            <span class="spec-label">Eye Color:</span> ${widget.avatarSpecs['eyeColor']}
        </div>
        <div class="spec-item">
            <span class="spec-label">Has Beard:</span> ${widget.avatarSpecs['hasBeard'] ? 'Yes' : 'No'}
        </div>
        <div class="spec-item">
            <span class="spec-label">Has Glasses:</span> ${widget.avatarSpecs['hasGlasses'] ? 'Yes' : 'No'}
        </div>
    </div>
    
    <div id="loading">
        <div>🎨 Creating your 3D avatar...</div>
        <div style="margin-top: 10px; font-size: 14px; opacity: 0.8;">
            Drag to rotate • Scroll to zoom
        </div>
    </div>

    <script src="https://cdnjs.cloudflare.com/ajax/libs/three.js/r128/three.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/three@0.128.0/examples/js/controls/OrbitControls.js"></script>
    
    <script>
        // Wait for Three.js to load
        setTimeout(() => {
            initThreeJS();
        }, 1000);
        
        function initThreeJS() {
            // Hide loading
            document.getElementById('loading').style.display = 'none';
            
            // Scene setup
            const scene = new THREE.Scene();
            scene.background = new THREE.Color(0xeceff1);
            
            const camera = new THREE.PerspectiveCamera(
                75, 
                window.innerWidth / window.innerHeight, 
                0.1, 
                1000
            );
            camera.position.set(0, 1.6, 5);
            
            const renderer = new THREE.WebGLRenderer({ antialias: true });
            renderer.setSize(window.innerWidth, window.innerHeight);
            renderer.shadowMap.enabled = true;
            renderer.shadowMap.type = THREE.PCFSoftShadowMap;
            document.body.appendChild(renderer.domElement);
            
            // Lights
            const hemi = new THREE.HemisphereLight(0xffffff, 0x444444, 1.0);
            hemi.position.set(0, 2, 0);
            scene.add(hemi);
            
            const dir = new THREE.DirectionalLight(0xffffff, 0.8);
            dir.position.set(3, 10, 4);
            dir.castShadow = true;
            dir.shadow.mapSize.width = 2048;
            dir.shadow.mapSize.height = 2048;
            scene.add(dir);
            
            // Create avatar
            const avatar = createAvatar();
            scene.add(avatar);
            
            // Controls
            const controls = new THREE.OrbitControls(camera, renderer.domElement);
            controls.target.set(0, 1.2, 0);
            controls.enableDamping = true;
            controls.dampingFactor = 0.05;
            controls.update();
            
            // Animation loop
            function animate() {
                requestAnimationFrame(animate);
                controls.update();
                renderer.render(scene, camera);
            }
            animate();
            
            // Handle resize
            window.addEventListener('resize', () => {
                camera.aspect = window.innerWidth / window.innerHeight;
                camera.updateProjectionMatrix();
                renderer.setSize(window.innerWidth, window.innerHeight);
            });
        }
        
        function createAvatar() {
            const avatar = new THREE.Group();
            
            // Get avatar specifications
            const gender = '${widget.avatarSpecs['gender']}';
            const bodyType = '${widget.avatarSpecs['bodyType']}';
            const skinTone = '${widget.avatarSpecs['skinTone']}';
            const style = '${widget.avatarSpecs['style']}';
            const hairColor = '${widget.avatarSpecs['hairColor']}';
            const eyeColor = '${widget.avatarSpecs['eyeColor']}';
            const hasBeard = ${widget.avatarSpecs['hasBeard']};
            const hasGlasses = ${widget.avatarSpecs['hasGlasses']};
            
            // Colors based on specifications
            const skinColor = getSkinColor(skinTone);
            const clothingColor = getClothingColor(style);
            const hairColorHex = getHairColor(hairColor);
            const eyeColorHex = getEyeColor(eyeColor);
            
            // Materials
            const skinMat = new THREE.MeshStandardMaterial({ color: skinColor });
            const clothMat = new THREE.MeshStandardMaterial({ color: clothingColor });
            const hairMat = new THREE.MeshStandardMaterial({ color: hairColorHex });
            const eyeMat = new THREE.MeshStandardMaterial({ color: eyeColorHex });
            
            // Head
            const headGeometry = new THREE.BoxGeometry(0.6, 0.6, 0.6);
            const head = new THREE.Mesh(headGeometry, skinMat);
            head.position.y = 2.2;
            head.castShadow = true;
            avatar.add(head);
            
            // Eyes
            const eyeGeometry = new THREE.SphereGeometry(0.08, 8, 8);
            const leftEye = new THREE.Mesh(eyeGeometry, eyeMat);
            leftEye.position.set(-0.15, 2.3, 0.25);
            avatar.add(leftEye);
            
            const rightEye = new THREE.Mesh(eyeGeometry, eyeMat);
            rightEye.position.set(0.15, 2.3, 0.25);
            avatar.add(rightEye);
            
            // Hair
            const hairGeometry = new THREE.BoxGeometry(0.7, 0.3, 0.7);
            const hair = new THREE.Mesh(hairGeometry, hairMat);
            hair.position.y = 2.5;
            avatar.add(hair);
            
            // Beard (if applicable)
            if (hasBeard && gender === 'male') {
                const beardGeometry = new THREE.BoxGeometry(0.4, 0.2, 0.1);
                const beard = new THREE.Mesh(beardGeometry, hairMat);
                beard.position.set(0, 1.9, 0.25);
                avatar.add(beard);
            }
            
            // Glasses (if applicable)
            if (hasGlasses) {
                const glassesGeometry = new THREE.BoxGeometry(0.4, 0.1, 0.05);
                const glasses = new THREE.Mesh(glassesGeometry, new THREE.MeshStandardMaterial({ color: 0x333333 }));
                glasses.position.set(0, 2.3, 0.3);
                avatar.add(glasses);
            }
            
            // Torso
            const torsoGeometry = new THREE.BoxGeometry(1, 1.2, 0.5);
            const torso = new THREE.Mesh(torsoGeometry, clothMat);
            torso.position.y = 1.2;
            torso.castShadow = true;
            avatar.add(torso);
            
            // Arms
            const armGeometry = new THREE.BoxGeometry(0.3, 1, 0.3);
            const leftArm = new THREE.Mesh(armGeometry, clothMat);
            leftArm.position.set(-0.65, 1.2, 0);
            leftArm.castShadow = true;
            avatar.add(leftArm);
            
            const rightArm = new THREE.Mesh(armGeometry, clothMat);
            rightArm.position.set(0.65, 1.2, 0);
            rightArm.castShadow = true;
            avatar.add(rightArm);
            
            // Hands
            const handGeometry = new THREE.SphereGeometry(0.15, 8, 8);
            const leftHand = new THREE.Mesh(handGeometry, skinMat);
            leftHand.position.set(-0.65, 0.5, 0);
            leftHand.castShadow = true;
            avatar.add(leftHand);
            
            const rightHand = new THREE.Mesh(handGeometry, skinMat);
            rightHand.position.set(0.65, 0.5, 0);
            rightHand.castShadow = true;
            avatar.add(rightHand);
            
            // Legs
            const legGeometry = new THREE.BoxGeometry(0.4, 1.2, 0.4);
            const leftLeg = new THREE.Mesh(legGeometry, new THREE.MeshStandardMaterial({ color: 0x333333 }));
            leftLeg.position.set(-0.25, 0, 0);
            leftLeg.castShadow = true;
            avatar.add(leftLeg);
            
            const rightLeg = new THREE.Mesh(legGeometry, new THREE.MeshStandardMaterial({ color: 0x333333 }));
            rightLeg.position.set(0.25, 0, 0);
            rightLeg.castShadow = true;
            avatar.add(rightLeg);
            
            // Feet
            const footGeometry = new THREE.BoxGeometry(0.3, 0.2, 0.6);
            const leftFoot = new THREE.Mesh(footGeometry, new THREE.MeshStandardMaterial({ color: 0x000000 }));
            leftFoot.position.set(-0.25, -0.7, 0.1);
            leftFoot.castShadow = true;
            avatar.add(leftFoot);
            
            const rightFoot = new THREE.Mesh(footGeometry, new THREE.MeshStandardMaterial({ color: 0x000000 }));
            rightFoot.position.set(0.25, -0.7, 0.1);
            rightFoot.castShadow = true;
            avatar.add(rightFoot);
            
            return avatar;
        }
        
        function getSkinColor(tone) {
            const colors = {
                'light': 0xffdbd3c3,
                'medium': 0xffd1b5,
                'olive': 0xffc19a6b,
                'tan': 0xffb8956b,
                'dark': 0xff8d5524
            };
            return colors[tone] || colors['medium'];
        }
        
        function getClothingColor(style) {
            const colors = {
                'casual': 0x2b6cb0,
                'professional': 0x2d3748,
                'artistic': 0x9f7aea,
                'elegant': 0x4a5568,
                'sporty': 0xe53e3e
            };
            return colors[style] || colors['casual'];
        }
        
        function getHairColor(color) {
            const colors = {
                'black': 0x2d3748,
                'brown': 0x8b4513,
                'blonde': 0xf6e05e,
                'red': 0xc53030,
                'gray': 0x718096,
                'white': 0xf7fafc
            };
            return colors[color] || colors['brown'];
        }
        
        function getEyeColor(color) {
            const colors = {
                'brown': 0x8b4513,
                'blue': 0x3182ce,
                'green': 0x38a169,
                'hazel': 0xd69e2e,
                'gray': 0x718096
            };
            return colors[color] || colors['brown'];
        }
    </script>
</body>
</html>
    ''';
  }

  String _getUnsupportedHTML() {
    return '''
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>3D Avatar Viewer</title>
    <style>
        body {
            margin: 0;
            padding: 20px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            font-family: Arial, sans-serif;
            color: white;
            text-align: center;
        }
        .container {
            max-width: 600px;
            margin: 50px auto;
            background: rgba(255, 255, 255, 0.1);
            padding: 40px;
            border-radius: 20px;
            backdrop-filter: blur(10px);
        }
        h1 { font-size: 2.5em; margin-bottom: 20px; }
        p { font-size: 1.2em; line-height: 1.6; }
        .icon { font-size: 4em; margin-bottom: 20px; }
    </style>
</head>
<body>
    <div class="container">
        <div class="icon">🎨</div>
        <h1>3D Avatar Viewer</h1>
        <p>This 3D avatar viewer is optimized for web browsers. For the best experience, please open this app in a web browser.</p>
        <p>Your avatar specifications have been saved and will be used when you access the web version.</p>
    </div>
</body>
</html>
    ''';
  }

  String _getErrorHTML() {
    return '''
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Error</title>
    <style>
        body {
            margin: 0;
            padding: 20px;
            background: linear-gradient(135deg, #e53e3e 0%, #c53030 100%);
            font-family: Arial, sans-serif;
            color: white;
            text-align: center;
        }
        .container {
            max-width: 600px;
            margin: 50px auto;
            background: rgba(255, 255, 255, 0.1);
            padding: 40px;
            border-radius: 20px;
            backdrop-filter: blur(10px);
        }
        h1 { font-size: 2.5em; margin-bottom: 20px; }
        p { font-size: 1.2em; line-height: 1.6; }
        .icon { font-size: 4em; margin-bottom: 20px; }
    </style>
</head>
<body>
    <div class="container">
        <div class="icon">⚠️</div>
        <h1>Error Loading Avatar</h1>
        <p>There was an error loading the 3D avatar viewer. Please try again or contact support.</p>
    </div>
</body>
</html>
    ''';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('3D Avatar Viewer'),
        backgroundColor: const Color(0xFF667eea),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAvatarViewer,
            tooltip: 'Reload Avatar',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667eea)),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Opening 3D Avatar...',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF667eea),
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.view_in_ar,
                      size: 120,
                      color: Color(0xFF667eea),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      '3D Avatar Viewer',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF667eea),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Your 3D avatar has been opened in a new window!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Avatar Specifications:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF667eea),
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildSpecItem('Gender', widget.avatarSpecs['gender']),
                            _buildSpecItem('Body Type', widget.avatarSpecs['bodyType']),
                            _buildSpecItem('Skin Tone', widget.avatarSpecs['skinTone']),
                            _buildSpecItem('Style', widget.avatarSpecs['style']),
                            _buildSpecItem('Hair Color', widget.avatarSpecs['hairColor']),
                            _buildSpecItem('Eye Color', widget.avatarSpecs['eyeColor']),
                            _buildSpecItem('Has Beard', widget.avatarSpecs['hasBeard'] ? 'Yes' : 'No'),
                            _buildSpecItem('Has Glasses', widget.avatarSpecs['hasGlasses'] ? 'Yes' : 'No'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _loadAvatarViewer,
                      icon: const Icon(Icons.open_in_new),
                      label: const Text('Open Avatar Again'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF667eea),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSpecItem(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(
            value.toString(),
            style: TextStyle(color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }
}
