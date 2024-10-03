import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

class TextToSpeechPage extends StatefulWidget {
  @override
  _TextToSpeechPageState createState() => _TextToSpeechPageState();
}

class _TextToSpeechPageState extends State<TextToSpeechPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool isLoading = false;
  bool isPlaying = false;
  bool isAudioAvailable = false;
  int apiCallCount = 0;
  int currentSentenceIndex = 0;

  final ScrollController _scrollController = ScrollController();
  double textSize = 16;
  bool isTextBold = false;

  List<String> sentences = [
    "This is the first sentence of a long paragraph that continues without spacing.",
    "Here comes the second sentence, seamlessly integrated into the text.",
    "The third sentence follows smoothly, keeping the narrative flowing.",
    "This is the fourth sentence, adding more context to the paragraph.",
    "Finally, the fifth sentence concludes this 200-word block of text, ensuring continuity."
  ];

  Duration? totalDuration;
  Duration currentPosition = Duration.zero;
  List<int> sentenceDurations = [];

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _toggleAudio() async {
    if (isPlaying) {
      _stopAudio();
    } else {
      if (isAudioAvailable) {
        _resumeAudio();
      } else {
        await _speakCombinedText(sentences.join(' '));
      }
    }
  }

  Future<void> _speakCombinedText(String text) async {
    setState(() {
      isLoading = true;
    });

    try {
       final String apiKey = 'AIzaSyC83UDnamh0-rVUXzUuS0WcmSdcriI5eJo'; // Your API key
      final String url = 'https://texttospeech.googleapis.com/v1/text:synthesize?key=$apiKey';

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'input': {'text': text},
          'voice': {'languageCode': 'en-US', 'ssmlGender': 'FEMALE'},
          'audioConfig': {'audioEncoding': 'MP3'}
        }),
      );

      if (response.statusCode == 200) {
        apiCallCount++;
        final jsonResponse = jsonDecode(response.body);
        final audioContent = jsonResponse['audioContent'];
        final audioBytes = base64Decode(audioContent);

        // Get the temporary directory on the device
        final directory = await getTemporaryDirectory();
        final audioFile = File('${directory.path}/output.mp3');

        // Write the audio data to a file
        await audioFile.writeAsBytes(audioBytes);

        // Play the audio file and track the duration
        await _audioPlayer.play(audioFile.path, isLocal: true);

        _audioPlayer.onDurationChanged.listen((Duration duration) {
          setState(() {
            totalDuration = duration;
            _calculateSentenceDurations();
          });
        });

        _audioPlayer.onAudioPositionChanged.listen((Duration position) {
          setState(() {
            currentPosition = position;
            _updateCurrentSentence();
          });
        });

        _audioPlayer.onPlayerCompletion.listen((event) {
          setState(() {
            currentSentenceIndex = sentences.length - 1;
            isPlaying = false;
          });
        });

        setState(() {
          isPlaying = true;
          isAudioAvailable = true;
        });
      } else {
        print('Request failed with status: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('An error occurred: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _stopAudio() async {
    await _audioPlayer.stop();
    setState(() {
      isPlaying = false;
    });
  }

  void _resumeAudio() async {
    await _audioPlayer.resume();
    setState(() {
      isPlaying = true;
    });
  }

  void _calculateSentenceDurations() {
    // Calculate approximate duration for each sentence based on its length
    int totalLength = sentences.fold(0, (sum, sentence) => sum + sentence.length);
    sentenceDurations = sentences
        .map((sentence) => (sentence.length / totalLength * totalDuration!.inMilliseconds).round())
        .toList();
  }

  void _updateCurrentSentence() {
    if (totalDuration != null && sentenceDurations.isNotEmpty) {
      int elapsedTime = 0;
      for (int i = 0; i < sentenceDurations.length; i++) {
        elapsedTime += sentenceDurations[i];
        if (currentPosition.inMilliseconds < elapsedTime) {
          setState(() {
            currentSentenceIndex = i;
          });
          break;
        }
      }
    }
  }

  void _onSentenceTap(int index) {
    if (totalDuration != null && sentenceDurations.isNotEmpty) {
      int targetPosition = sentenceDurations.sublist(0, index).fold(0, (sum, duration) => sum + duration);
      _audioPlayer.seek(Duration(milliseconds: targetPosition));
      setState(() {
        currentSentenceIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Text to Speech - API Calls: $apiCallCount')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _toggleAudio,
                    child: Text(isPlaying ? 'Stop Audio' : 'Play Audio'),
                  ),
            SizedBox(height: 20),
            Expanded(
              flex: 10,
              child: Stack(
                children: [
                  SingleChildScrollView(
                    controller: _scrollController,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ShaderMask(
                        shaderCallback: (bounds) {
                          return LinearGradient(
                            colors: [
                              Colors.white,
                              const Color(0xFF1B3533),
                            ],
                            stops: [0.0, 1.0],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ).createShader(bounds);
                        },
                        blendMode: BlendMode.srcIn,
                        child: RichText(
                          text: TextSpan(
                            children: sentences.asMap().entries.map((entry) {
                              int index = entry.key;
                              String sentence = entry.value;
                              return TextSpan(
                                text: sentence + (index < sentences.length - 1 ? ' ' : ''),
                                style: TextStyle(
                                  fontFamily: 'Lexend-Regular',
                                  fontSize: textSize,
                                  color: index == currentSentenceIndex
                                      ? Colors.yellow
                                      : Colors.white,
                                  fontWeight: index == currentSentenceIndex
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () => _onSentenceTap(index),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    bottom: 0,
                    child: Container(
                      width: 8,
                      margin: const EdgeInsets.only(right: 4.0),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          double maxExtent = _scrollController.hasClients
                              ? _scrollController.position.maxScrollExtent
                              : 1;
                          double scrollPosition = _scrollController.hasClients
                              ? (_scrollController.offset / maxExtent) *
                                  (constraints.maxHeight - 50)
                              : 0;
                          scrollPosition = scrollPosition.clamp(
                              0, constraints.maxHeight - 50);

                          return Align(
                            alignment: Alignment.topCenter,
                            child: Container(
                              height: 50,
                              width: 8,
                              margin: EdgeInsets.only(top: scrollPosition),
                              decoration: BoxDecoration(
                                color: const Color(0xFF6DB697),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
