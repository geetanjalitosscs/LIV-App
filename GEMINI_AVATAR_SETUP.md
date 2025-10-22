# Three.js 3D Avatar Generation Setup

This app now uses Three.js to generate interactive 3D avatars based on user specifications. The system creates realistic human-like avatars with proper anatomical proportions.

## 1. Three.js Integration

The avatar generation system uses Three.js for 3D rendering:
- **WebGL Renderer**: For hardware-accelerated 3D graphics
- **Scene Management**: Complete 3D scene with lighting and camera
- **Interactive Controls**: Orbit controls for viewing the avatar
- **Real-time Customization**: Dynamic avatar generation based on specifications

## 2. No API Key Required

Unlike the previous Gemini implementation, Three.js runs entirely in the browser:
- No external API calls needed
- No API key configuration required
- Works offline once loaded
- Faster generation times

## 3. Features

The 3D avatar generation system includes:

### Specifications Available:
- **Gender**: Male, Female, Non-binary
- **Body Type**: Slim, Athletic, Average, Muscular, Curvy
- **Face Shape**: Oval, Round, Square, Heart, Diamond
- **Hair Color**: Black, Brown, Blonde, Red, Gray, White
- **Eye Color**: Brown, Blue, Green, Hazel, Gray
- **Skin Tone**: Light, Medium, Olive, Tan, Dark
- **Style**: Casual, Professional, Artistic, Elegant, Sporty
- **Accessories**: Beard (for males), Glasses

### Generation Options:
1. **Text-to-Image**: Generate avatar from specifications only
2. **Image-to-Image**: Use a reference photo and modify it according to specifications

## 4. Usage

1. Navigate to Profile screen
2. Tap on the profile picture or "Generate Avatar" button
3. Choose specifications for your avatar
4. Optionally upload a reference image
5. Tap "Generate Avatar"
6. Review and save the generated avatar

## 5. API Costs

- Gemini API has free tier with usage limits
- Check [Google AI Studio pricing](https://aistudio.google.com/pricing) for current rates
- Image generation typically costs more than text generation

## 6. Troubleshooting

### Common Issues:

1. **"Failed to generate avatar" error**
   - Check if API key is correctly set
   - Verify internet connection
   - Check API quota limits

2. **"Please check your API key" error**
   - Ensure API key is valid and active
   - Check if API key has proper permissions

3. **Generation takes too long**
   - This is normal for image generation
   - Check internet connection speed
   - API may be experiencing high load

### Debug Steps:

1. Check console logs for detailed error messages
2. Verify API key format (should start with 'AIza...')
3. Test API key with a simple request
4. Check Gemini API status page for outages

## 7. Security Notes

- Never commit API keys to version control
- Consider using environment variables for production
- Monitor API usage to avoid unexpected charges
- Implement rate limiting for production use

## 8. Future Enhancements

Potential improvements:
- Save generated avatars locally
- Batch generation options
- Style transfer features
- Real-time preview
- Avatar history
- Social sharing options
