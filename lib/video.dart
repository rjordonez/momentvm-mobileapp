import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPage extends StatefulWidget {
  final VoidCallback onNext;
  final String transcript;
  final String title;
  final String videoPath; // Video path

  const VideoPage({
    Key? key,
    required this.onNext,
    required this.transcript,
    required this.title,
    required this.videoPath,
  }) : super(key: key);

  @override
  _VideoPageState createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer(widget.videoPath);
  }

  @override
  void didUpdateWidget(VideoPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoPath != widget.videoPath) {
      print("Video path changed from ${oldWidget.videoPath} to ${widget.videoPath}");
      _changeVideo(widget.videoPath);
    }
  }

  Future<void> _initializeVideoPlayer(String path) async {
    print("Initializing video player with path: $path");

    // Dispose the previous controller if it exists
    if (_controller != null) {
      print("Disposing existing video controller.");
      await _controller!.pause();
      await _controller!.dispose();
      _controller = null;
    }

    // Initialize the VideoPlayerController with the new video path
    if (_isAssetPath(path)) {
      print("Using Asset VideoPlayerController.");
      _controller = VideoPlayerController.asset(path);
    } else {
      print("Using Network VideoPlayerController.");
      _controller = VideoPlayerController.network(path);
    }

    try {
      await _controller!.initialize();
      print("Video controller initialized successfully.");
      setState(() {
        // Update state to reflect controller is ready
      });
      _controller!.play(); // Auto-play the video (optional)
      print("Video playback started.");
    } catch (e) {
      print("Error initializing video player: $e");
    }
  }

  bool _isAssetPath(String path) {
    // Simple check to determine if the path is an asset
    return path.startsWith('assets/');
  }

  Future<void> _changeVideo(String newPath) async {
    print("Changing video to path: $newPath");
    await _initializeVideoPlayer(newPath);
  }

  @override
  void dispose() {
    if (_controller != null) {
      print("Disposing video controller.");
      _controller!.pause(); // Pause the video if it's still playing
      _controller!.dispose();
      _controller = null;
    }
    super.dispose();
  }

  void _showTranscript() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        builder: (_, controller) => TranscriptPage(
          onClose: () {
            Navigator.pop(context);
          },
          transcript: widget.transcript, // Pass the transcript
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print("Building VideoPage widget.");

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(
            child: Column(
              children: [
                // Display the video title
                Container(
                  padding: const EdgeInsets.all(16.0),
                  alignment: Alignment.center,
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    color: Colors.black, // Video background
                    child: _controller != null && _controller!.value.isInitialized
                        ? AspectRatio(
                            aspectRatio: _controller!.value.aspectRatio,
                            child: VideoPlayer(_controller!),
                          )
                        : const Center(
                            child: CircularProgressIndicator(), // Show loading spinner until the video is ready
                          ),
                  ),
                ),
                Container(
                  height: 70,
                  color: Colors.transparent, // Transparent background
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: _showTranscript, // Show the transcript modal
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF354D47),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                          ),
                          child: const Text(
                            'Show Transcript',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: widget.onNext, // Call the onNext function
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6DB697),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                          ),
                          child: const Text(
                            'Continue',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class TranscriptPage extends StatefulWidget {
  final VoidCallback onClose;
  final String transcript;

  const TranscriptPage({
    Key? key,
    required this.onClose,
    required this.transcript,
  }) : super(key: key);

  @override
  _TranscriptPageState createState() => _TranscriptPageState();
}

class _TranscriptPageState extends State<TranscriptPage> {
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    setState(() {
      _scrollOffset = _scrollController.offset;
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF2B3F3A), // Background color
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with 'Transcript' title and close button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Transcript',
                style: TextStyle(
                  fontFamily: 'Lexend-Bold',
                  fontSize: 24,
                  color: Colors.white,
                ),
              ),
              GestureDetector(
                onTap: widget.onClose, // Close the modal when the button is tapped
                child: Image.asset(
                  'assets/ex.png', // Path to your close button image
                  height: 35,
                  width: 35,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Transcript content with gradient text
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: DynamicGradientText(
                scrollOffset: _scrollOffset,
                textSize: 16.0,
                text: widget.transcript, // Display the transcript text
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DynamicGradientText extends StatelessWidget {
  final double scrollOffset;
  final double textSize;
  final String text;

  const DynamicGradientText({
    Key? key,
    required this.scrollOffset,
    required this.textSize,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return ShaderMask(
          shaderCallback: (bounds) {
            double height = bounds.height;
            double startGradient = (scrollOffset / height).clamp(0.0, 1.0);
            double endGradient = ((scrollOffset + constraints.maxHeight) / height).clamp(0.0, 1.0);

            return LinearGradient(
              colors: [
                Colors.white, // Start with white
                const Color.fromARGB(255, 59, 74, 72), // End with deep green color
              ],
              stops: [startGradient, endGradient],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcIn,
          child: Text(
            text,
            style: TextStyle(
              fontFamily: 'Lexend-Regular',
              fontSize: textSize, // Use dynamic text size
              color: Colors.white, // Base color for gradient text
            ),
            textAlign: TextAlign.left,
          ),
        );
      },
    );
  }
}
