# Avatar Generation Setup Guide

This guide explains how to set up avatar generation functionality in the LIV Dating App.

## Features Added

### 1. Image Picker Integration
- **Gallery Selection**: Choose images from device gallery
- **Camera Support**: Take photos with front or rear camera
- **Image Optimization**: Automatic resizing and compression

### 2. Avatar Generation
- **2D Avatar**: Convert photos to cartoon-style avatars using DeepAI Toonify
- **3D Avatar**: Generate 3D avatars (Ready Player Me integration ready)
- **Real-time Preview**: See generated avatars immediately

### 3. User Interface
- **Bottom Sheet Menu**: Easy selection of image source
- **Loading Indicators**: Visual feedback during processing
- **Error Handling**: User-friendly error messages
- **Success Notifications**: Confirmation of successful operations

## Setup Instructions

### 1. Dependencies
The following dependencies have been added to `pubspec.yaml`:
```yaml
dependencies:
  http: ^1.2.0
  image_picker: ^1.0.7
```

### 2. API Configuration
Update the API keys in `lib/config/api_config.dart`:

```dart
class ApiConfig {
  // Replace with your actual DeepAI API key
  static const String deepAiApiKey = 'YOUR_DEEPAI_API_KEY';
  
  // Replace with your Ready Player Me API key (for 3D avatars)
  static const String readyPlayerMeApiKey = 'YOUR_READY_PLAYER_ME_API_KEY';
}
```

### 3. DeepAI Setup
1. Go to [DeepAI](https://deepai.org/)
2. Sign up for an account
3. Get your API key from the dashboard
4. Replace `YOUR_DEEPAI_API_KEY` in `api_config.dart`

### 4. Permissions
Add the following permissions to your platform-specific files:

#### Android (`android/app/src/main/AndroidManifest.xml`)
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
```

#### iOS (`ios/Runner/Info.plist`)
```xml
<key>NSCameraUsageDescription</key>
<string>This app needs access to camera to take photos for avatar generation</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>This app needs access to photo library to select images for avatar generation</string>
```

## Usage

### 1. Profile Screen Integration
The profile screen now includes:
- **Tap to Change**: Tap the profile picture to open image selection
- **Multiple Options**: Gallery, front camera, rear camera, and avatar generation
- **Real-time Updates**: Profile picture updates immediately

### 2. Image Selection Flow
1. User taps on profile picture
2. Bottom sheet appears with options:
   - Choose from Gallery
   - Take Photo (Front Camera)
   - Take Photo (Rear Camera)
   - Generate Avatar (requires selected image)

### 3. Avatar Generation Flow
1. User selects an image first
2. Taps "Generate Avatar" button
3. Chooses between 2D or 3D avatar
4. Waits for processing (loading indicator shown)
5. Generated avatar appears in profile

## Code Structure

### Files Created/Modified
- `lib/services/avatar_generator_service.dart` - Core avatar generation logic
- `lib/config/api_config.dart` - API configuration and settings
- `lib/screens/profile_screen.dart` - Updated with image picker functionality

### Key Classes
- `AvatarGeneratorService` - Handles image picking and avatar generation
- `ApiConfig` - Centralized API configuration
- `ProfileScreen` - Updated UI with avatar generation features

## API Integration

### DeepAI Toonify
- **Endpoint**: `https://api.deepai.org/api/toonify`
- **Method**: POST
- **Headers**: `api-key: YOUR_API_KEY`
- **Body**: Multipart form with image file
- **Response**: JSON with `output_url` field

### Ready Player Me (3D Avatars)
- **Status**: Placeholder implementation
- **Integration**: Ready for future implementation
- **Requirements**: 3D model viewer (e.g., `model_viewer_plus`)

## Error Handling

### Common Issues
1. **API Key Not Set**: Check `api_config.dart`
2. **Permission Denied**: Ensure camera/photo permissions are granted
3. **Network Error**: Check internet connection
4. **Image Too Large**: Images are automatically resized

### Error Messages
- "Failed to pick image from gallery"
- "Failed to take photo"
- "Please select an image first"
- "Failed to generate avatar"
- "Error generating avatar: [error details]"

## Customization

### Image Settings
Modify `ApiConfig` to change:
- Maximum image size
- Image quality
- Allowed file types
- Image dimensions

### UI Customization
- Button colors and styles
- Loading indicators
- Error message styling
- Success notifications

## Testing

### Test Scenarios
1. **Gallery Selection**: Test with various image formats
2. **Camera Functionality**: Test both front and rear cameras
3. **Avatar Generation**: Test with different image types
4. **Error Handling**: Test with invalid images and network issues
5. **UI Responsiveness**: Test on different screen sizes

### Debug Mode
Enable debug logging by adding:
```dart
print('Debug: Image selected - ${image.path}');
print('Debug: Avatar URL - $avatarUrl');
```

## Future Enhancements

### Planned Features
1. **3D Avatar Support**: Full Ready Player Me integration
2. **Avatar Customization**: Edit generated avatars
3. **Batch Processing**: Generate multiple avatars
4. **Cloud Storage**: Save avatars to cloud
5. **Social Sharing**: Share generated avatars

### Performance Optimizations
1. **Image Caching**: Cache generated avatars locally
2. **Background Processing**: Generate avatars in background
3. **Progressive Loading**: Show preview while processing
4. **Compression**: Optimize image sizes for faster uploads

## Support

For issues related to avatar generation:
1. Check API key configuration
2. Verify permissions are granted
3. Test with different image formats
4. Check network connectivity
5. Review error logs for specific issues

## Security Notes

- API keys are stored in configuration files
- Images are processed locally before upload
- No sensitive data is stored in generated avatars
- All API calls use HTTPS
- User permissions are properly requested and handled
