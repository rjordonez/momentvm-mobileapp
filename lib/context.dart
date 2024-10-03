import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

class ContextPage extends StatefulWidget {
  final VoidCallback onNext; // Callback to handle the next activity
  final String title; // Title of the page
  final String imagePath; // Path to the image
  final String text; // Body text

  const ContextPage({
    Key? key,
    required this.onNext,
    required this.title,
    required this.imagePath,
    required this.text,
  }) : super(key: key);

  @override
  _ContextPageState createState() => _ContextPageState();
}

class _ContextPageState extends State<ContextPage> {
  final ScrollController _scrollController = ScrollController();
  final AudioPlayer _audioPlayer = AudioPlayer();

  bool isAudioOn = false;
  bool isPlaying = false;
  bool isTextBold = false;
  int currentSentenceIndex = 0;
  double textSize = 16;
  List<String> sentences = [];
  Map<int, String> audioFilePaths = {}; // To store the paths of the preloaded audio files

  @override
  void initState() {
    super.initState();
    sentences = widget.text.split('.').map((s) => s.trim() + '.').toList();
    _scrollController.addListener(_onScroll);

    _preloadAudioFiles(); // Preload the audio files when the widget is initialized

    _audioPlayer.onPlayerCompletion.listen((event) {
      _handleAudioCompletion();
    });


  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _scrollController.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    setState(() {});
  }

  Future<void> _preloadAudioFiles() async {
    final directory = await getTemporaryDirectory();

    for (int i = 0; i < sentences.length; i++) {
      String sentence = sentences[i];
      String audioPath = await _fetchAndStoreAudio(sentence, directory, i);
      audioFilePaths[i] = audioPath;
    }
  }

  Future<String> _fetchAndStoreAudio(String sentence, Directory directory, int index) async {
    final String apiKey = '';

    final String url = 'https://texttospeech.googleapis.com/v1/text:synthesize?key=$apiKey';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'input': {'text': sentence},
          'voice': {'languageCode': 'en-US', 'ssmlGender': 'MALE'},
          'audioConfig': {'audioEncoding': 'MP3'}
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final audioContent = jsonResponse['audioContent'];
        final audioBytes = base64Decode(audioContent);

        final audioFile = File('${directory.path}/output_$index.mp3');
        await audioFile.writeAsBytes(audioBytes);

        return audioFile.path;
      } else {
        throw Exception('Failed to fetch audio: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error occurred while fetching audio: $e');
    }
  }

  void _handleAudioCompletion() {
    if (isAudioOn) {
      setState(() {
        isPlaying = false;
        currentSentenceIndex++;
        if (currentSentenceIndex < sentences.length) {
          Future.delayed(const Duration(milliseconds: 500), () {
            _playSentence(currentSentenceIndex);
          });
        } else {
          isAudioOn = false; // Stop playing if all sentences are done
        }
      });
    }
  }

  void _playSentence(int index) async {
    if (isAudioOn) {
      String? audioPath = audioFilePaths[index];
      if (audioPath != null) {
        await _audioPlayer.play(audioPath, isLocal: true);
        setState(() {
          isPlaying = true;
        });
      }
    }
  }

  void toggleAudioMode() {
    setState(() {
      isAudioOn = !isAudioOn;
      if (isAudioOn) {
        // Resume from the last sentence index if the audio was turned off previously
        _playSentence(currentSentenceIndex);
      } else {
        _audioPlayer.stop();
      }
    });
  }

  void _playSelectedSentence(int index) {
    setState(() {
      currentSentenceIndex = index;
      _playSentence(currentSentenceIndex);
    });
  }

  void toggleTextSize() {
    setState(() {
      isTextBold = !isTextBold;
      textSize = isTextBold ? 20 : 16;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 40.0, bottom: 20.0),
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                      fontFamily: 'Lexend-Bold',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Container(
                  height: 125,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0),
                    image: DecorationImage(
                      image: AssetImage(widget.imagePath),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  flex: 10,
                  child: Stack(
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) {
                          return LinearGradient(
                            colors: [
                              Colors.white, // Start with white color
                              const Color(0xFF1B3533), // End with the desired color
                            ],
                            stops: [0.0, 1.0],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ).createShader(bounds);
                        },
                        blendMode: BlendMode.srcIn, // Use srcIn to affect the text color
                        child: SingleChildScrollView(
                          controller: _scrollController,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: RichText(
                              text: TextSpan(
                                children: sentences.asMap().entries.map((entry) {
                                  int idx = entry.key;
                                  String sentence = entry.value;
                                  bool isHighlighted = idx == currentSentenceIndex && isAudioOn;

                                  return TextSpan(
                                    text: sentence + ' ',
                                    style: TextStyle(
                                      decoration: isHighlighted
                                          ? TextDecoration.underline
                                          : TextDecoration.none,
                                      decorationStyle: isHighlighted
                                          ? TextDecorationStyle.dotted
                                          : TextDecorationStyle.solid,
                                      decorationColor: isHighlighted
                                          ? Colors.white
                                          : Colors.transparent,
                                      fontFamily: 'Lexend-Regular',
                                      fontSize: textSize,
                                      color: Colors.white,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        _playSelectedSentence(idx);
                                      },
                                  );
                                }).toList(),
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: toggleAudioMode,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isAudioOn
                              ? const Color(0xFF354D47)
                              : const Color(0xFF2B3F3A),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          minimumSize: const Size(35, 35),
                        ),
                        child: Image.asset(
                          'assets/iconHeadphones.png',
                          height: 13,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: toggleTextSize,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isTextBold
                              ? const Color(0xFF354D47)
                              : const Color(0xFF2B3F3A),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          minimumSize: const Size(35, 35),
                        ),
                        child: const Text(
                          'Aa',
                          style: TextStyle(
                            fontFamily: 'Lexend-Regular',
                            fontSize: 15,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: widget.onNext,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6DB697),
                          shadowColor: Colors.black,
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                          minimumSize: const Size(120, 40),
                        ),
                        child: const Text(
                          'Continue',
                          style: TextStyle(
                            fontFamily: 'Lexend-Regular',
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  double _calculateTextBodyHeight(BuildContext context) {
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox != null && renderBox.hasSize) {
      return renderBox.size.height;
    }
    return MediaQuery.of(context).size.height;
  }
}
