import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_recognition_error.dart' as stt;
import 'package:speech_to_text/speech_to_text.dart' as stt;

class VoiceSearchIcon extends StatefulWidget {
  final TextEditingController controller;
  final Function(String)? onSearch;

  const VoiceSearchIcon({
    super.key,
    required this.controller,
    this.onSearch,
  });

  @override
  State<VoiceSearchIcon> createState() => _VoiceSearchIconState();
}

class _VoiceSearchIconState extends State<VoiceSearchIcon>
    with SingleTickerProviderStateMixin {
  late stt.SpeechToText _speech;
  late AnimationController _rippleController;

  bool _speechEnabled = false;
  bool _isListening = false;
  double _soundLevel = 0.0;

  OverlayEntry? _overlayEntry;

  final List<Color> googleColors = [
    Colors.blue,
    Colors.red,
    Colors.yellow,
    Colors.green,
  ];

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _rippleController =
    AnimationController(vsync: this, duration: const Duration(seconds: 1))
      ..repeat(reverse: true);
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    _speechEnabled = await _speech.initialize(
      onStatus: _handleStatus,
      onError: _handleError,
    );
    setState(() {});
  }

  void _handleStatus(String status) {
    debugPrint("Speech status: $status");

    if (status == 'done' && _isListening) {
      _stopListening();
    }
  }

  void _handleError(stt.SpeechRecognitionError error) {
    debugPrint("Speech error: ${error.errorMsg}");
    if (error.errorMsg == 'error_speech_timeout') {
      return;
    }
    if (error.permanent) {
      _stopListening();
    }
  }


  Future<void> _toggleListening() async {
    if (!_speechEnabled) {
      _showPermissionDialog();
      return;
    }
    if (!mounted) return;
    FocusScope.of(context).unfocus();

    if (_isListening) {
      _stopListening();
      return;
    }

    if (!await Permission.microphone.request().isGranted) {
      _showPermissionDialog();
      return;
    }

    setState(() => _isListening = true);
    _showListeningDialog();

    await _speech.listen(
      onResult: (result) {
        widget.controller.text = result.recognizedWords;

        if (result.finalResult &&
            widget.controller.text.trim().isNotEmpty) {
          widget.onSearch?.call(widget.controller.text.trim());
          _stopListening();
        }
      },
      onSoundLevelChange: (level) {
        if (mounted) {
          setState(() => _soundLevel = level);
        }
      },
      listenFor: const Duration(seconds: 15),
      pauseFor: const Duration(seconds: 5),
      cancelOnError: false,
      partialResults: true,
    );
  }

  void _stopListening() {
    if (!_isListening) return;

    _speech.stop();
    _removeOverlay();

    setState(() {
      _isListening = false;
      _soundLevel = 0;
    });
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Microphone Permission'),
        content: const Text(
          'Please enable microphone access to use voice search.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await Permission.microphone.request();
              _initSpeech();
            },
            child: const Text('Enable'),
          ),
        ],
      ),
    );
  }

  void _showListeningDialog() {
    if (_overlayEntry != null) return;

    _overlayEntry = OverlayEntry(
      builder: (_) => Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: Material(
          color: Colors.white,
          elevation: 12,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: _stopListening,
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 80,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      for (int i = 1; i <= 3; i++)
                        AnimatedBuilder(
                          animation: _rippleController,
                          builder: (_, __) {
                            final scale =
                                1 + (_rippleController.value * i * 0.4);
                            return Transform.scale(
                              scale: scale,
                              child: Container(
                                width: 60 * i.toDouble(),
                                height: 60 * i.toDouble(),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color:
                                  Colors.blue.withOpacity(0.15 / i),
                                ),
                              ),
                            );
                          },
                        ),
                      const Icon(CupertinoIcons.mic,
                          size: 36, color: Colors.blue),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (i) {
                    final h = (15 + (_soundLevel * 6 * (i + 1)))
                        .clamp(15, 50)
                        .toDouble();
                    return Container(
                      width: 10,
                      height: h,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: googleColors[i],
                        borderRadius: BorderRadius.circular(6),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 12),
                const Text("Listening...",
                    style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  void dispose() {
    _speech.stop();
    _rippleController.dispose();
    _removeOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        _isListening ? CupertinoIcons.mic_fill : CupertinoIcons.mic,
        color: _isListening ? Colors.red : Theme.of(context).primaryColor,
      ),
      onPressed: _toggleListening,
    );
  }
}
