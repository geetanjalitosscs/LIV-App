import 'dart:async';
import 'dart:io';
import '../config/paths.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_windows/webview_windows.dart' as winwv;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../services/user_service.dart';

// Custom dialog functions
Future<void> _showErrorDialog(BuildContext context) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: const Color(0xFF2D2D2D),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.warning,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Important',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: const Text(
          'Please click Save before selecting Next. Your avtar won\'t be saved otherwise. Go back and come again.',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'OK',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      );
    },
  );
}

Future<void> _showSuccessDialog(BuildContext context) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: const Color(0xFF2D2D2D),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Success',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: const Text(
          'Your avtar is saved.',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Navigate back to home screen with success flag
              Navigator.of(context).pop(true);
            },
            style: TextButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'OK',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      );
    },
  );
}

class AvtarCreatorScreen extends StatefulWidget {
  const AvtarCreatorScreen({super.key, this.initialAvatarId});

  final String? initialAvatarId;

  @override
  State<AvtarCreatorScreen> createState() => _AvtarCreatorScreenState();
}

class _AvtarCreatorScreenState extends State<AvtarCreatorScreen> {
  late final WebViewController controller;
  winwv.WebviewController? _windowsController;
  StreamSubscription<dynamic>? _windowsMessageSub;
  String? avatarUrl;
  bool avatarSaved = false;
  Completer<String>? _exportCompleter;

  @override
  void initState() {
    super.initState();
    try {
      if (!kIsWeb && Platform.isWindows) {
        _initWindowsWebView();
      } else {
        controller = WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..addJavaScriptChannel(
            'AvatarChannel',
            onMessageReceived: (JavaScriptMessage msg) async {
              try {
                final String url = msg.message;
                print('Received avatar URL: $url');
                setState(() => avatarUrl = url);
                if (_exportCompleter != null && !_exportCompleter!.isCompleted) {
                  _exportCompleter!.complete(url);
                }
                // Don't auto-download here, wait for Save button
              } catch (e) {
                print('Error handling avatar URL: $e');
              }
            },
          )
          ..setNavigationDelegate(
            NavigationDelegate(
              onPageFinished: (String url) {
                try {
                  controller.runJavaScript('''
                    window.addEventListener('message', (event) => {
                      if (event.data?.source === 'readyplayerme') {
                        if (event.data.eventName === 'v1.avatar.exported') {
                          AvatarChannel.postMessage(event.data.data.url);
                        }
                      }
                    });
                    // Hide PlayerZero promo and similar overlays
                    (function(){
                      const hide = ()=>{
                        const nodes = Array.from(document.querySelectorAll('*'));
                        nodes.forEach(n=>{
                          if(n.textContent && n.textContent.includes('PlayerZero')){
                            n.style.display='none';
                          }
                          // Hide share modal elements
                          if(n.textContent && n.textContent.includes('Copy the link')){
                            n.style.display='none';
                          }
                        });
                        // Try clicking X close buttons if present
                        const closers = Array.from(document.querySelectorAll("button, div[role='button']"))
                          .filter(b=>b && (b.ariaLabel==='Close' || b.innerText.trim()==='×' || b.innerText.trim()==='X'));
                        closers.forEach(b=>{ try { b.click(); } catch(e){} });
                      };
                      
                      // Also watch for Copy button and extract URL
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
                } catch (e) {
                  print('Error injecting JavaScript: $e');
                }
              },
            ),
          );
        final String base = 'https://readyplayer.me/avatar?frameApi';
        final String url = widget.initialAvatarId == null
            ? base
            : '$base&avatarId=${Uri.encodeComponent(widget.initialAvatarId!)}';
        controller.loadRequest(Uri.parse(url));
      }
    } catch (e) {
      print('Error initializing WebView: $e');
    }
  }

  Future<void> _initWindowsWebView() async {
    try {
      final ctrl = winwv.WebviewController();
      await ctrl.initialize();
      await ctrl.addScriptToExecuteOnDocumentCreated('''
        window.addEventListener('message', (event) => {
          if (event.data?.source === 'readyplayerme') {
            if (event.data.eventName === 'v1.avatar.exported') {
              if (window.chrome && window.chrome.webview) {
                window.chrome.webview.postMessage(event.data.data.url);
              }
            }
          }
        });
        // Hide PlayerZero promo and similar overlays
        (function(){
          const hide = ()=>{
            const nodes = Array.from(document.querySelectorAll('*'));
            nodes.forEach(n=>{
              if(n.textContent && n.textContent.includes('PlayerZero')){
                n.style.display='none';
              }
              if(n.textContent && n.textContent.includes('Copy the link')){
                n.style.display='none';
              }
            });
          const closers = Array.from(document.querySelectorAll("button, div[role='button']"))
            .filter(b=>b && (b.ariaLabel==='Close' || b.innerText.trim()==='×' || b.innerText.trim()==='X'));
          closers.forEach(b=>{ try { b.click(); } catch(e){} });
          };
          
          // Also watch for Copy button and extract URL
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
                }
              }
            }
          };
          
          document.addEventListener('DOMContentLoaded', () => { hide(); watchForCopyButton(); });
          hide();
          watchForCopyButton();
          new MutationObserver(() => { hide(); watchForCopyButton(); }).observe(document.documentElement,{subtree:true,childList:true,characterData:true});
        })();
      ''');
      _windowsMessageSub = ctrl.webMessage.listen((message) async {
        try {
          if (message is String && message.isNotEmpty) {
            print('Windows WebView received URL: $message');
            setState(() => avatarUrl = message);
            if (_exportCompleter != null && !_exportCompleter!.isCompleted) {
              _exportCompleter!.complete(message);
            }
            // Don't auto-download here, wait for Save button
          }
        } catch (e) {
          print('Error handling Windows WebView message: $e');
        }
      });
      final String base = 'https://readyplayer.me/avatar?frameApi';
      final String url = widget.initialAvatarId == null
          ? base
          : '$base&avatarId=${Uri.encodeComponent(widget.initialAvatarId!)}';
      await ctrl.loadUrl(url);
      setState(() {
        _windowsController = ctrl;
      });
    } catch (e) {
      print('Error initializing Windows WebView: $e');
    }
  }

  Future<void> _downloadAvatar(String url) async {
    try {
      if (kIsWeb) {
        // On web, trigger browser download/open
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Avatar opened in a new tab for download")),
        );
        return;
      }

      // Request storage permission only for non-web platforms
      if (Platform.isAndroid || Platform.isIOS || Platform.isMacOS) {
        if (!await Permission.storage.request().isGranted) {
          if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Storage permission denied")),
            );
          }
          return;
        }
      }

      // Extract avatar ID from RPM url .../{id}.glb
      final uri = Uri.parse(url);
      final segments = uri.pathSegments;
      final String fileName = segments.isNotEmpty ? segments.last : 'avatar.glb';
      final String avatarId = fileName.replaceAll('.glb', '');
      
      print('Downloading avatar from: $url');
      print('Avatar ID: $avatarId');

      Directory uploads;
      if (Platform.isWindows) {
        // Save to requested absolute directory on Windows
        uploads = Directory(AppPaths.windowsUploads);
      } else {
        final dir = await getApplicationDocumentsDirectory();
        uploads = Directory('${dir.path}/uploads');
      }
      
      print('Saving to directory: ${uploads.path}');
      if (!await uploads.exists()) {
        await uploads.create(recursive: true);
      }

      // Download GLB
      final glbResp = await http.get(Uri.parse(url));
      final glbPath = '${uploads.path}/$fileName';
      await File(glbPath).writeAsBytes(glbResp.bodyBytes);

      // Try to download PNG preview using the same id
      final pngUrl = Uri.parse('https://models.readyplayer.me/$avatarId.png');
      String? pngPath;
      try {
        final pngResp = await http.get(pngUrl);
        if (pngResp.statusCode == 200) {
          pngPath = '${uploads.path}/$avatarId.png';
          await File(pngPath).writeAsBytes(pngResp.bodyBytes);
        }
      } catch (_) {}

      // Persist references
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('lastAvatarId', avatarId);
      await prefs.setString('lastAvatarGlbPath', glbPath);
      if (pngPath != null) {
        await prefs.setString('lastAvatarPngPath', pngPath);
      }

      if (!mounted) return;
      
      print('Avatar saved successfully! GLB: $glbPath, PNG: $pngPath');
      // Show custom success dialog
      await _showSuccessDialog(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save avtar: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final actions = <Widget>[
        Container(
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          onPressed: () async {
          // Direct approach: Request export and save without requiring NEXT button
          _exportCompleter = Completer<String>();
          try {
            const js = '''
              // Direct avatar export - no need for NEXT button
              console.log('Attempting direct avatar export...');
              
              // Method 1: Try direct export request
              try {
                window.postMessage({source:'readyplayerme', eventName:'v1.frame.requestAvatarExport'}, '*');
                console.log('Direct export request sent');
              } catch (e) {
                console.log('Direct export failed:', e);
              }
              
              // Method 2: Look for existing avatar URL in the page
              const findAvatarUrl = () => {
                // Check for avatar URLs in various places
                const urlInputs = document.querySelectorAll('input[type="text"], input[readonly], textarea');
                for (let input of urlInputs) {
                  if (input.value && input.value.includes('.glb')) {
                    console.log('Found avatar URL:', input.value);
                    return input.value;
                  }
                }
                
                // Check for URLs in data attributes
                const elements = document.querySelectorAll('[data-url], [data-avatar-url], [data-model-url]');
                for (let el of elements) {
                  const url = el.getAttribute('data-url') || el.getAttribute('data-avatar-url') || el.getAttribute('data-model-url');
                  if (url && url.includes('.glb')) {
                    console.log('Found avatar URL in data attribute:', url);
                    return url;
                  }
                }
                
                return null;
              };
              
              // Try to find avatar URL immediately
              const avatarUrl = findAvatarUrl();
              if (avatarUrl) {
                console.log('Avatar URL found immediately:', avatarUrl);
                // Send URL to Flutter
                if (window.chrome && window.chrome.webview) {
                  window.chrome.webview.postMessage(avatarUrl);
                } else if (window.AvatarChannel) {
                  window.AvatarChannel.postMessage(avatarUrl);
                }
              } else {
                console.log('No avatar URL found, waiting for export...');
                // Set up observer to watch for URL changes
                const observer = new MutationObserver(() => {
                  const url = findAvatarUrl();
                  if (url) {
                    console.log('Avatar URL found via observer:', url);
                    observer.disconnect();
                    // Send URL to Flutter
                    if (window.chrome && window.chrome.webview) {
                      window.chrome.webview.postMessage(url);
                    } else if (window.AvatarChannel) {
                      window.AvatarChannel.postMessage(url);
                    }
                  }
                });
                observer.observe(document.body, { childList: true, subtree: true, attributes: true });
                
                // Also try clicking NEXT button as fallback
                setTimeout(() => {
                  const nextButtons = Array.from(document.querySelectorAll('button, a, div[role="button"]'));
                  const nextBtn = nextButtons.find(b => 
                    b && b.innerText && b.innerText.trim().toUpperCase() === 'NEXT'
                  );
                  if (nextBtn) {
                    console.log('Clicking NEXT button as fallback');
                    nextBtn.style.display = 'block';
                    nextBtn.style.visibility = 'visible';
                    nextBtn.style.opacity = '1';
                    nextBtn.disabled = false;
                    nextBtn.removeAttribute('disabled');
                    nextBtn.style.pointerEvents = 'auto';
                    nextBtn.classList.remove('hidden', 'invisible', 'disabled');
                    nextBtn.click();
                  }
                }, 2000);
              }
              
              // Watch for avatar export events and URL
              let urlFound = false;
              const findAndSendUrl = () => {
                if (urlFound) return;
                
                // Method 1: Listen for avatar export events
                const checkForExportEvent = () => {
                  // Check if avatar export completed
                  const exportComplete = document.querySelector('[data-testid="export-complete"], .export-complete, .avatar-exported');
                  if (exportComplete) {
                    console.log('Export completed, looking for URL...');
                    // Look for URL in the export result
                    const urlInputs = document.querySelectorAll('input[type="text"], input[readonly], textarea');
                    for (let input of urlInputs) {
                      if (input.value && input.value.includes('models.readyplayer.me') && input.value.includes('.glb')) {
                        const url = input.value;
                        console.log('Found URL via export completion:', url);
                        urlFound = true;
                        if (window.chrome && window.chrome.webview) {
                          window.chrome.webview.postMessage(url);
                        } else if (window.AvatarChannel) {
                          window.AvatarChannel.postMessage(url);
                        }
                        return;
                      }
                    }
                  }
                };
                
                checkForExportEvent();
                
                // Method 2: Look for Copy button and input field
                const copyButton = document.querySelector('button.MuiButtonBase-root.MuiButton-root.MuiButton-contained.MuiButton-containedPrimary.MuiButton-sizeMedium.MuiButton-containedSizeMedium.MuiButton-colorPrimary');
                if (copyButton && copyButton.innerText.includes('Copy')) {
                  const urlInput = copyButton.closest('div').querySelector('input[type="text"], input[readonly]');
                  if (urlInput && urlInput.value) {
                    const url = urlInput.value;
                    console.log('Found URL via Copy button:', url);
                    urlFound = true;
                    if (window.chrome && window.chrome.webview) {
                      window.chrome.webview.postMessage(url);
                    } else if (window.AvatarChannel) {
                      window.AvatarChannel.postMessage(url);
                    }
                    return;
                  }
                }
                
                // Method 3: Look for any input field with GLB URL
                const inputs = document.querySelectorAll('input[type="text"], input[readonly]');
                for (let input of inputs) {
                  if (input.value && input.value.includes('models.readyplayer.me') && input.value.includes('.glb')) {
                    const url = input.value;
                    console.log('Found URL via input field:', url);
                    urlFound = true;
                    if (window.chrome && window.chrome.webview) {
                      window.chrome.webview.postMessage(url);
                    } else if (window.AvatarChannel) {
                      window.AvatarChannel.postMessage(url);
                    }
                    return;
                  }
                }
                
                // Method 4: Look for URL in page text
                const bodyText = document.body.innerText;
                const urlMatch = bodyText.match(/https:\\/\\/models\\.readyplayer\\.me\\/[a-zA-Z0-9]+\\.glb/);
                if (urlMatch) {
                  const url = urlMatch[0];
                  console.log('Found URL via text search:', url);
                  urlFound = true;
                  if (window.chrome && window.chrome.webview) {
                    window.chrome.webview.postMessage(url);
                  } else if (window.AvatarChannel) {
                    window.AvatarChannel.postMessage(url);
                  }
                  return;
                }
              };
              
              // Try multiple times with increasing delays
              setTimeout(findAndSendUrl, 2000);
              setTimeout(findAndSendUrl, 5000);
              setTimeout(findAndSendUrl, 8000);
              setTimeout(findAndSendUrl, 12000);
              setTimeout(findAndSendUrl, 18000);
              
              // Also retry clicking NEXT button if URL not found after some time
              setTimeout(() => {
                if (!urlFound) {
                  console.log('Retrying NEXT button click...');
                  const retryButtons = Array.from(document.querySelectorAll('button, a, div[role="button"]'));
                  retryButtons.forEach(btn => {
                    if (btn && btn.innerText && btn.innerText.trim().toUpperCase() === 'NEXT') {
                      btn.style.display = 'block';
                      btn.style.visibility = 'visible';
                      btn.style.opacity = '1';
                      btn.disabled = false;
                      btn.removeAttribute('disabled');
                      btn.style.pointerEvents = 'auto';
                      btn.classList.remove('hidden', 'invisible', 'disabled');
                      btn.click();
                    }
                  });
                }
              }, 5000);
              
              // Hide share modal if it appears
              setTimeout(() => {
                const shareElements = Array.from(document.querySelectorAll('*'));
                shareElements.forEach(el => {
                  if (el.textContent && el.textContent.includes('Copy the link')) {
                    el.style.display = 'none';
                  }
                });
                // Try to close any modals
                const closeBtns = Array.from(document.querySelectorAll('button, div[role="button"]'))
                  .filter(b => b && (b.ariaLabel === 'Close' || b.innerText.trim() === '×' || b.innerText.trim() === 'X'));
                closeBtns.forEach(b => { try { b.click(); } catch(e){} });
              }, 2000);
            ''';
            
            if (!kIsWeb && Platform.isWindows) {
              await _windowsController?.executeScript(js);
            } else {
              await controller.runJavaScript(js);
            }
            
            if (avatarUrl != null && avatarUrl!.isNotEmpty) {
              _exportCompleter!.complete(avatarUrl!);
            }
            
            // Wait for URL with timeout, but also check if we already have it
            String url;
            if (avatarUrl != null && avatarUrl!.isNotEmpty) {
              url = avatarUrl!;
            } else {
              url = await _exportCompleter!.future.timeout(const Duration(seconds: 30));
            }
            await _downloadAvatar(url);
          } catch (e) {
            print('Save button error: $e');
            if (mounted) {
              // Show custom error dialog
              await _showErrorDialog(context);
            }
            // Reset the completer so user can try again
            setState(() {
              _exportCompleter = null;
            });
          }
        },
        child: const Text(
          'Save',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      ),
    ];

    if (!kIsWeb && Platform.isWindows) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF42A5F5), Color(0xFFE91E63)],
              ),
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text(
            'Create Avtar',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          actions: actions,
        ),
        body: _windowsController == null
            ? const Center(child: CircularProgressIndicator())
            : winwv.Webview(_windowsController!),
      );
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF42A5F5), Color(0xFFE91E63)],
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Create Avtar',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        actions: actions,
      ),
      body: WebViewWidget(controller: controller),
    );
  }

  @override
  void dispose() {
    try {
      _windowsMessageSub?.cancel();
      _windowsController?.dispose();
      _exportCompleter = null;
    } catch (e) {
      print('Error disposing resources: $e');
    }
    super.dispose();
  }

  Future<void> _saveCurrentAvatar() async {
    if (avatarUrl == null || avatarUrl!.isEmpty) return;
    try {
      // Extract avatar ID from RPM url .../{id}.glb
      final uri = Uri.parse(avatarUrl!);
      final segments = uri.pathSegments;
      final String fileName = segments.isNotEmpty ? segments.last : 'avatar.glb';
      final String avatarId = fileName.replaceAll('.glb', '');

      if (kIsWeb) {
        await launchUrl(Uri.parse(avatarUrl!), mode: LaunchMode.externalApplication);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Saved externally on Web')),
          );
        }
        return;
      }

      Directory uploads;
      if (!kIsWeb && Platform.isWindows) {
        // Save to requested absolute directory on Windows
        uploads = Directory(AppPaths.windowsUploads);
      } else {
        final dir = await getApplicationDocumentsDirectory();
        uploads = Directory('${dir.path}/uploads');
      }
      if (!await uploads.exists()) {
        await uploads.create(recursive: true);
      }

      // Download GLB
      final glbResp = await http.get(Uri.parse(avatarUrl!));
      final glbPath = '${uploads.path}/$fileName';
      await File(glbPath).writeAsBytes(glbResp.bodyBytes);

      // Try to download PNG preview using the same id (Ready Player Me serves a PNG preview)
      final pngUrl = Uri.parse('https://models.readyplayer.me/$avatarId.png');
      String? pngPath;
      try {
        final pngResp = await http.get(pngUrl);
        if (pngResp.statusCode == 200) {
          pngPath = '${uploads.path}/$avatarId.png';
          await File(pngPath).writeAsBytes(pngResp.bodyBytes);
        }
      } catch (_) {}

      // Persist references
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('lastAvatarId', avatarId);
      await prefs.setString('lastAvatarGlbPath', glbPath);
      if (pngPath != null) {
        await prefs.setString('lastAvatarPngPath', pngPath);
      }

      // Update UserService to set this as the selected avatar
      if (pngPath != null && mounted) {
        final userService = Provider.of<UserService>(context, listen: false);
        userService.selectAvatar(pngPath);
      }

      if (!mounted) return;
      await _showSuccessDialog(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save: $e')),
      );
    }
  }
}
