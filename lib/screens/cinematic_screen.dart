import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:google_fonts/google_fonts.dart';

class CinematicScreen extends StatefulWidget {
  const CinematicScreen({super.key});

  @override
  State<CinematicScreen> createState() => _CinematicScreenState();
}

class _CinematicScreenState extends State<CinematicScreen> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    // Delay to get arguments from route
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeVideo();
    });
  }

  void _initializeVideo() {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (args == null || args['videoPath'] == null) {
      setState(() {
        _hasError = true;
        _errorMessage = 'No video path provided';
      });
      return;
    }

    final String videoPath = args['videoPath'];

    try {
      _controller = VideoPlayerController.asset(videoPath)
        ..initialize()
            .then((_) {
              if (mounted) {
                setState(() {
                  _isInitialized = true;
                });
                _controller.play();
              }
            })
            .catchError((error) {
              if (mounted) {
                setState(() {
                  _hasError = true;
                  _errorMessage = 'Error loading video: $error';
                });
              }
            });

      // Listen for video completion
      _controller.addListener(() {
        if (_controller.value.position >= _controller.value.duration) {
          if (mounted) {
            _navigateToNextScreen();
          }
        }
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Error initializing video: $e';
      });
    }
  }

  void _navigateToNextScreen() {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final String nextRoute = args?['nextRoute'] ?? '/menu';

    _controller.pause();
    Navigator.of(context).pushReplacementNamed(nextRoute);
  }

  void _skipCinematic() {
    _navigateToNextScreen();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Disable back button
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Stack(
            children: [
              // Video Player
              if (_isInitialized && !_hasError)
                Center(
                  child: AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  ),
                ),

              // Loading Indicator
              if (!_isInitialized && !_hasError)
                const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: Colors.white),
                      SizedBox(height: 20),
                      Text(
                        'Cargando cinemática...',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ],
                  ),
                ),

              // Error Message
              if (_hasError)
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 64,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Error',
                        style: GoogleFonts.orbitron(
                          color: Colors.red,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Text(
                          _errorMessage,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: _navigateToNextScreen,
                        child: const Text('Continuar'),
                      ),
                    ],
                  ),
                ),

              // Skip Button (Top Right)
              if (_isInitialized && !_hasError)
                Positioned(
                  top: 20,
                  right: 20,
                  child: GestureDetector(
                    onTap: _skipCinematic,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.5),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'SALTAR',
                            style: GoogleFonts.pressStart2p(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.fast_forward,
                            color: Colors.white,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // Video Progress Indicator (Bottom)
              if (_isInitialized && !_hasError)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: VideoProgressIndicator(
                    _controller,
                    allowScrubbing: false,
                    colors: const VideoProgressColors(
                      playedColor: Colors.orange,
                      bufferedColor: Colors.grey,
                      backgroundColor: Colors.white24,
                    ),
                    padding: const EdgeInsets.all(0),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
