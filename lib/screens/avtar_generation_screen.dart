import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/avtar_generator_service.dart';
import '../services/avtar_2d_service.dart';
import '../theme/liv_theme.dart';
import 'avtar_3d_viewer_screen.dart';

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}

class AvatarGenerationScreen extends StatefulWidget {
  const AvatarGenerationScreen({super.key});

  @override
  State<AvatarGenerationScreen> createState() => _AvatarGenerationScreenState();
}

class _AvatarGenerationScreenState extends State<AvatarGenerationScreen> {
  final AvatarGeneratorService _avatarService = AvatarGeneratorService.instance;
  final Avtar2DService _avatar2DService = Avtar2DService.instance;
  
  // Avatar specifications
  String _gender = 'male';
  String _bodyType = 'athletic';
  String _faceType = 'oval';
  bool _hasBeard = false;
  bool _hasGlasses = false;
  String _hairColor = 'brown';
  String _eyeColor = 'brown';
  String _skinTone = 'medium';
  String _style = 'casual';
  
  // Image handling
  Uint8List? _selectedImageBytes;
  Uint8List? _generatedAvatarBytes;
  bool _isGenerating = false;
  bool _useInputImage = false;
  bool _avatarGenerated = false;
  
  // Available options
  static const List<String> genders = ['male', 'female', 'non-binary'];
  static const List<String> bodyTypes = ['slim', 'athletic', 'average', 'muscular', 'curvy'];
  static const List<String> faceTypes = ['oval', 'round', 'square', 'heart', 'diamond'];
  static const List<String> hairColors = ['black', 'brown', 'blonde', 'red', 'gray', 'white'];
  static const List<String> eyeColors = ['brown', 'blue', 'green', 'hazel', 'gray'];
  static const List<String> skinTones = ['light', 'medium', 'olive', 'tan', 'dark'];
  static const List<String> styles = ['casual', 'professional', 'artistic', 'elegant', 'sporty'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generate Avatar'),
        backgroundColor: const Color(0xFF667eea),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Input Image Section
            _buildInputImageSection(),
            const SizedBox(height: 24),
            
            // Specifications Section
            _buildSpecificationsSection(),
            const SizedBox(height: 24),
            
            // Generate Button
            _buildGenerateButton(),
            const SizedBox(height: 24),
            
            // Generated Avatar Display
            if (_avatarGenerated) _buildGeneratedAvatarSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildInputImageSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.image, color: Color(0xFF667eea)),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Reference Image (Optional)',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Image display or placeholder
            Center(
              child: GestureDetector(
                onTap: _showImageSourceDialog,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _selectedImageBytes != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.memory(
                            _selectedImageBytes!,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tap to add image',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Toggle for using input image
            Row(
              children: [
                Checkbox(
                  value: _useInputImage,
                  onChanged: (value) {
                    setState(() {
                      _useInputImage = value ?? false;
                    });
                  },
                ),
                const Text('Use this image as reference for generation'),
              ],
            ),
            
            if (_selectedImageBytes != null)
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _selectedImageBytes = null;
                    _useInputImage = false;
                  });
                },
                icon: const Icon(Icons.delete),
                label: const Text('Remove Image'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecificationsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.tune, color: Color(0xFF667eea)),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Avatar Specifications',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Gender
            _buildDropdownField('Gender', _gender, genders, (value) {
              setState(() {
                _gender = value!;
                // Reset beard for non-male genders
                if (value != 'male') _hasBeard = false;
              });
            }),
            
            // Body Type
            _buildDropdownField('Body Type', _bodyType, bodyTypes, (value) {
              setState(() => _bodyType = value!);
            }),
            
            // Face Type
            _buildDropdownField('Face Shape', _faceType, faceTypes, (value) {
              setState(() => _faceType = value!);
            }),
            
            // Hair Color
            _buildDropdownField('Hair Color', _hairColor, hairColors, (value) {
              setState(() => _hairColor = value!);
            }),
            
            // Eye Color
            _buildDropdownField('Eye Color', _eyeColor, eyeColors, (value) {
              setState(() => _eyeColor = value!);
            }),
            
            // Skin Tone
            _buildDropdownField('Skin Tone', _skinTone, skinTones, (value) {
              setState(() => _skinTone = value!);
            }),
            
            // Style
            _buildDropdownField('Style', _style, styles, (value) {
              setState(() => _style = value!);
            }),
            
            const SizedBox(height: 16),
            
            // Checkboxes for optional features
            Row(
              children: [
                Checkbox(
                  value: _hasBeard,
                  onChanged: _gender == 'male' ? (value) {
                    setState(() => _hasBeard = value ?? false);
                  } : null,
                ),
                Text(
                  'Beard (${_gender == 'male' ? 'available' : 'not available for this gender'})',
                  style: TextStyle(
                    color: _gender == 'male' ? null : Colors.grey[600],
                  ),
                ),
              ],
            ),
            
            Row(
              children: [
                Checkbox(
                  value: _hasGlasses,
                  onChanged: (value) {
                    setState(() => _hasGlasses = value ?? false);
                  },
                ),
                const Text('Glasses'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownField(
    String label,
    String value,
    List<String> options,
    ValueChanged<String?> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: value,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: options.map((String option) {
              return DropdownMenuItem<String>(
                value: option,
                child: Text(option[0].toUpperCase() + option.substring(1)),
              );
            }).toList(),
            onChanged: onChanged,
            autovalidateMode: AutovalidateMode.disabled,
          ),
        ],
      ),
    );
  }

  Widget _buildGenerateButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: _isGenerating ? null : _generateAvatar,
        icon: _isGenerating
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.auto_fix_high),
        label: Text(_isGenerating ? 'Generating...' : 'Generate Avatar'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFed4273),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildGeneratedAvatarSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Generated Avatar',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // 2D Avatar Preview
            if (_generatedAvatarBytes != null) ...[
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!, width: 2),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.memory(
                    _generatedAvatarBytes!,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Profile Picture Preview',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF667eea),
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // 3D Avatar Display Area
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!, width: 2),
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[50],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.view_in_ar,
                    size: 48,
                    color: Color(0xFF667eea),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '3D Avatar Available',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF667eea),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• ${_gender.capitalize()} • ${_bodyType.capitalize()} • ${_skinTone.capitalize()} • ${_style.capitalize()}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _open3DAvatarViewer,
                    icon: const Icon(Icons.open_in_new, size: 16),
                    label: const Text('View 3D'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF667eea),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _regenerateAvatar,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Regenerate'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _saveAvatar,
                  icon: const Icon(Icons.save),
                  label: const Text('Use as Avatar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showImageSourceDialog() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImageFromGallery();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take Photo'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImageFromCamera();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024.0,
        maxHeight: 1024.0,
        imageQuality: 85,
      );
      
      if (pickedFile != null) {
        final Uint8List imageBytes = await pickedFile.readAsBytes();
        setState(() {
          _selectedImageBytes = imageBytes;
          _useInputImage = true;
        });
      }
    } catch (e) {
      _showErrorSnackBar('Failed to pick image from gallery');
    }
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? pickedFile = await ImagePicker().pickImage(
        source: ImageSource.camera,
        maxWidth: 1024.0,
        maxHeight: 1024.0,
        imageQuality: 85,
      );
      
      if (pickedFile != null) {
        final Uint8List imageBytes = await pickedFile.readAsBytes();
        setState(() {
          _selectedImageBytes = imageBytes;
          _useInputImage = true;
        });
      }
    } catch (e) {
      _showErrorSnackBar('Failed to take photo');
    }
  }

  Future<void> _generateAvatar() async {
    setState(() {
      _isGenerating = true;
    });

    try {
      // Generate 3D avatar using Three.js
      if (_useInputImage && _selectedImageBytes != null) {
        await _avatarService.generateAvatar(
          inputImageBytes: _selectedImageBytes,
          gender: _gender,
          bodyType: _bodyType,
          faceType: _faceType,
          hasBeard: _hasBeard,
          hasGlasses: _hasGlasses,
          hairColor: _hairColor,
          eyeColor: _eyeColor,
          skinTone: _skinTone,
          style: _style,
        );
      } else {
        await _avatarService.generateAvatarFromText(
          gender: _gender,
          bodyType: _bodyType,
          faceType: _faceType,
          hasBeard: _hasBeard,
          hasGlasses: _hasGlasses,
          hairColor: _hairColor,
          eyeColor: _eyeColor,
          skinTone: _skinTone,
          style: _style,
        );
      }

      // Generate 2D avatar for profile picture
      _generatedAvatarBytes = await _avatar2DService.generateAvatarImage(
        gender: _gender,
        bodyType: _bodyType,
        faceType: _faceType,
        hasBeard: _hasBeard,
        hasGlasses: _hasGlasses,
        hairColor: _hairColor,
        eyeColor: _eyeColor,
        skinTone: _skinTone,
        style: _style,
      );

      setState(() {
        _isGenerating = false;
        _avatarGenerated = true;
      });

      _showSuccessSnackBar('Avatar generated successfully!');
    } catch (e) {
      setState(() {
        _isGenerating = false;
      });
      _showErrorSnackBar('Error generating avatar: $e');
    }
  }

  Future<void> _regenerateAvatar() async {
    await _generateAvatar();
  }

  Future<void> _saveAvatar() async {
    if (_avatarGenerated && _generatedAvatarBytes != null) {
      try {
        // Show loading dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return const AlertDialog(
              content: Row(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 20),
                  Text('Setting as profile picture...'),
                ],
              ),
            );
          },
        );

        // Simulate saving the avatar (in a real app, you'd save to user profile)
        await Future.delayed(const Duration(seconds: 1));

        // Close loading dialog
        Navigator.of(context).pop();

        // Show success message
        _showSuccessSnackBar('Avatar set as profile picture!');

        // Navigate back to profile screen with avatar data
        Navigator.pop(context, _generatedAvatarBytes);
      } catch (e) {
        // Close loading dialog if still open
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
        _showErrorSnackBar('Error setting avatar: $e');
      }
    } else {
      _showErrorSnackBar('Please generate an avatar first');
    }
  }

  Future<void> _open3DAvatarViewer() async {
    try {
      // Navigate to the 3D avatar viewer screen
      final avatarSpecs = {
        'gender': _gender,
        'bodyType': _bodyType,
        'faceType': _faceType,
        'skinTone': _skinTone,
        'style': _style,
        'hairColor': _hairColor,
        'eyeColor': _eyeColor,
        'hasBeard': _hasBeard,
        'hasGlasses': _hasGlasses,
      };
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Avatar3DViewerScreen(avatarSpecs: avatarSpecs),
        ),
      );
    } catch (e) {
      _showErrorSnackBar('Could not open 3D viewer: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }
}
