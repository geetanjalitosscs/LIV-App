import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_windows/webview_windows.dart' as winwv;
import '../services/avtar_service.dart';
import '../theme/liv_theme.dart';

class AvatarCreatorScreen extends StatefulWidget {
  final String? initialAvatarId;

  const AvatarCreatorScreen({
    super.key,
    this.initialAvatarId,
  });

  @override
  State<AvatarCreatorScreen> createState() => _AvatarCreatorScreenState();
}

class _AvatarCreatorScreenState extends State<AvatarCreatorScreen> {
  WebViewController? _webController;
  winwv.WebviewController? _windowsController;
  bool _isLoading = true;
  Completer<String>? _exportCompleter;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  Future<void> _initializeWebView() async {
    try {
      if (kIsWeb) {
        // Web platform - use regular WebView
        _webController = WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setNavigationDelegate(
            NavigationDelegate(
              onPageFinished: (String url) {
                setState(() {
                  _isLoading = false;
                });
                _injectJavaScript();
              },
              onWebResourceError: (WebResourceError error) {
                print('WebView error: ${error.description}');
                setState(() {
                  _isLoading = false;
                });
                _showConnectionError();
              },
            ),
          );
        
        final String url = AvatarService.getAvatarCreatorUrl(
          initialAvatarId: widget.initialAvatarId,
        );
        await _webController!.loadRequest(Uri.parse(url));
      } else if (Platform.isWindows) {
        // Windows platform - use Windows WebView
        await _initWindowsWebView();
      } else {
        // Other platforms - use regular WebView
        _webController = WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setNavigationDelegate(
            NavigationDelegate(
              onPageFinished: (String url) {
                setState(() {
                  _isLoading = false;
                });
                _injectJavaScript();
              },
              onWebResourceError: (WebResourceError error) {
                print('WebView error: ${error.description}');
                setState(() {
                  _isLoading = false;
                });
                _showConnectionError();
              },
            ),
          );
        
        final String url = AvatarService.getAvatarCreatorUrl(
          initialAvatarId: widget.initialAvatarId,
        );
        await _webController!.loadRequest(Uri.parse(url));
      }
    } catch (e) {
      print('Error initializing WebView: $e');
      setState(() {
        _isLoading = false;
      });
      _showConnectionError();
    }
  }

  Future<void> _initWindowsWebView() async {
    try {
      final ctrl = winwv.WebviewController();
      await ctrl.initialize();

      final String url = AvatarService.getAvatarCreatorUrl(
        initialAvatarId: widget.initialAvatarId,
      );
      
      await ctrl.loadUrl(url);
      setState(() {
        _windowsController = ctrl;
        _isLoading = false;
      });
    } catch (e) {
      print('Error initializing Windows WebView: $e');
      setState(() {
        _isLoading = false;
      });
      _showConnectionError();
    }
  }

  void _injectJavaScript() {
    try {
      if (_webController != null) {
        _webController!.runJavaScript('''
          (function() {
            // Hide unnecessary UI elements
            const hide = () => {
              const elementsToHide = [
                'header', 'nav', '.navbar', '.header',
                'footer', '.footer', '.bottom-bar'
              ];
              elementsToHide.forEach(selector => {
                const elements = document.querySelectorAll(selector);
                elements.forEach(el => {
                  if (el) el.style.display = 'none';
                });
              });
            };
            
            // Watch for Copy button and extract URL
            const watchForCopyButton = () => {
              const copyButton = document.querySelector('button.MuiButtonBase-root.MuiButton-root.MuiButton-contained.MuiButton-containedPrimary.MuiButton-sizeMedium.MuiButton-containedSizeMedium.MuiButton-colorPrimary');
              if (copyButton && copyButton.innerText.includes('Copy')) {
                const urlInput = copyButton.closest('div').querySelector('input[type="text"], input[readonly]');
                if (urlInput && urlInput.value) {
                  const url = urlInput.value;
                  console.log('Found URL:', url);
                  // Send URL to Flutter
                  if (window.chrome && window.chrome.webview) {
                    window.chrome.webview.postMessage(url);
                  } else if (window.AvatarChannel) {
                    window.AvatarChannel.postMessage(url);
                  }
                }
              }
            };
            
            hide();
            watchForCopyButton();
            new MutationObserver(() => { hide(); watchForCopyButton(); }).observe(document.body,{subtree:true,childList:true,characterData:true});
          })();
        ''');
      }
    } catch (e) {
      print('Error injecting JavaScript: $e');
    }
  }

  Future<void> _handleAvatarUrl(String url) async {
    try {
      await AvatarService.downloadAvatar(url, context);
      if (mounted) {
        Navigator.of(context).pop(true); // Return true to indicate success
      }
    } catch (e) {
      print('Error handling avatar URL: $e');
    }
  }

  Future<void> _exportAvatar() async {
    try {
      _exportCompleter = Completer<String>();
      
      if (_webController != null) {
        await _webController!.runJavaScript('''
          // Request avatar export directly
          window.postMessage({source:'readyplayerme', eventName:'v1.frame.requestAvatarExport'}, '*');
          
          // Also try to find and click NEXT button if available
          setTimeout(() => {
            const nextButtons = Array.from(document.querySelectorAll('button, a, div[role="button"]'));
            const nextBtn = nextButtons.find(b => 
              b && b.innerText && b.innerText.trim().toUpperCase() === 'NEXT'
            );
            if (nextBtn) {
              nextBtn.style.display = 'block';
              nextBtn.style.visibility = 'visible';
              nextBtn.style.opacity = '1';
              nextBtn.disabled = false;
              nextBtn.removeAttribute('disabled');
              nextBtn.style.pointerEvents = 'auto';
              nextBtn.classList.remove('hidden', 'invisible', 'disabled');
              nextBtn.click();
            }
          }, 1000);
          
          // Watch for avatar export events and URL
          let urlFound = false;
          const findAndSendUrl = () => {
            const copyButtons = document.querySelectorAll('button');
            copyButtons.forEach(btn => {
              if (btn.innerText && btn.innerText.includes('Copy')) {
                const parent = btn.closest('div');
                if (parent) {
                  const input = parent.querySelector('input[type="text"], input[readonly]');
                  if (input && input.value && input.value.includes('.glb')) {
                    const url = input.value;
                    if (!urlFound) {
                      urlFound = true;
                      console.log('Found avatar URL:', url);
                      // Send to Flutter
                      if (window.chrome && window.chrome.webview) {
                        window.chrome.webview.postMessage(url);
                      } else if (window.AvatarChannel) {
                        window.AvatarChannel.postMessage(url);
                      }
                    }
                  }
                }
              }
            });
          };
          
          // Watch for changes
          const observer = new MutationObserver(() => {
            findAndSendUrl();
          });
          observer.observe(document.body, { childList: true, subtree: true });
          
          // Also check immediately
          setTimeout(findAndSendUrl, 500);
        ''');
      } else if (_windowsController != null) {
        // For Windows WebView, show a message to manually copy the URL
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please manually copy the avatar URL from the Ready Player Me interface and paste it in the app.'),
            duration: Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      print('Error exporting avatar: $e');
    }
  }

  void _showConnectionError() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.wifi_off, color: Colors.red, size: 28),
              SizedBox(width: 12),
              Text(
                'Connection Error',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Connection is weak or the avatar service is temporarily unavailable.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              Text(
                'Please check your internet connection and try again.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Return to avatar screen
              },
              child: Text(
                'Return to Avatar Screen',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF42A5F5),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                _initializeWebView(); // Retry
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF42A5F5),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Retry',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: LivDecorations.mainAppBackground,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Create Avatar',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              // Refresh functionality
            },
          ),
          IconButton(
            icon: const Icon(Icons.brightness_6, color: Colors.white),
            onPressed: () {
              // Dark mode toggle functionality
            },
          ),
          IconButton(
            icon: const Icon(Icons.save, color: Colors.white),
            onPressed: _exportAvatar,
            tooltip: 'Save Avatar',
          ),
        ],
      ),
      body: Stack(
        children: [
          if (_webController != null)
            WebViewWidget(controller: _webController!)
          else if (_windowsController != null)
            winwv.Webview(_windowsController!)
          else
            const Center(
              child: Text('WebView not available'),
            ),
          if (_isLoading)
            Container(
              color: Colors.white,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _windowsController?.dispose();
    super.dispose();
  }
}
