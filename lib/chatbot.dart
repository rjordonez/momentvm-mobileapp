import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'chatgpt.dart';  // Assuming this is where the GPT service is defined
import 'package:http/http.dart' as http;

class ChatBotPage extends StatefulWidget {
  final VoidCallback onNext;
  final String initialTerm;  // This is the normal text passed through the constructor

  const ChatBotPage({Key? key, required this.onNext, required this.initialTerm}) : super(key: key);

  @override
  _ChatBotPageState createState() => _ChatBotPageState();
}

class _ChatBotPageState extends State<ChatBotPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  late String normalText;  // This will be set from the initialTerm
  String exampleText = "Example:\nGenerating example text...";
  String explanationText = "";  // To store the explanation text
  String currentText = '';
  Map<String, String> audioFilePaths = {}; // To store the paths of the preloaded audio files
  bool isPlaying = false;
  bool hasExplainedMore = false;  // Track if the "Explain More" button has been pressed

  @override
  void initState() {
    super.initState();
    normalText = widget.initialTerm;  // Set the normalText from the constructor
    _preloadNormalTextAudio();
    _audioPlayer.onPlayerCompletion.listen((event) {
      _handleAudioCompletion();
    });
    _fetchAndGenerateExampleText(); // Fetch and generate the example text based on the term
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _preloadNormalTextAudio() async {
    final directory = await getTemporaryDirectory();
    await _fetchAndStoreAudio(normalText, 'normal', directory);
  }

  Future<void> _preloadExampleTextAudio() async {
    final directory = await getTemporaryDirectory();
    await _fetchAndStoreAudio(exampleText, 'example', directory);
  }

  Future<void> _preloadExplanationTextAudio() async {
    final directory = await getTemporaryDirectory();
    await _fetchAndStoreAudio(explanationText, 'explanation', directory);
  }

  Future<void> _fetchAndStoreAudio(String text, String key, Directory directory) async {
    if (!audioFilePaths.containsKey(key)) {
      final String apiKey = 'AIzaSyC83UDnamh0-rVUXzUuS0WcmSdcriI5eJo';
      final String url = 'https://texttospeech.googleapis.com/v1/text:synthesize?key=$apiKey';

      try {
        final response = await http.post(
          Uri.parse(url),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'input': {'text': text},
            'voice': {'languageCode': 'en-US', 'ssmlGender': 'MALE'},
            'audioConfig': {'audioEncoding': 'MP3'}
          }),
        );

        if (response.statusCode == 200) {
          final jsonResponse = jsonDecode(response.body);
          final audioContent = jsonResponse['audioContent'];
          final audioBytes = base64Decode(audioContent);

          final audioFile = File('${directory.path}/$key.mp3');
          await audioFile.writeAsBytes(audioBytes);

          audioFilePaths[key] = audioFile.path;
        } else {
          throw Exception('Failed to fetch audio: ${response.statusCode}');
        }
      } catch (e) {
        throw Exception('Error occurred while fetching audio: $e');
      }
    }
  }

  Future<void> _fetchAndGenerateExampleText() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/interests.json');

      if (await file.exists()) {
        final contents = await file.readAsString();
        final data = jsonDecode(contents);
        List<String> interests = List<String>.from(data['interests']);
        print(interests);

        if (interests.isNotEmpty) {
          // Pick a random interest
          String randomInterest = interests[Random().nextInt(interests.length)];

          // Call the GPT service to generate the example text
          final openAIService = Provider.of<OpenAIService>(context, listen: false);
          final response = await openAIService.gptAPICall(
              "Give a 20-word example of how the term ($normalText) relates to one of these interests: $randomInterest. Make sure to pick the one that is most applicable. Start it off with ... Just like in ($normalText) ... just like $randomInterest ");

          if (response != null) {
            setState(() {
              exampleText = response;
            });
            await _preloadExampleTextAudio();  // Preload the example audio after receiving the response
          } else {
            setState(() {
              exampleText = "Generated example not available";
            });
          }
        } else {
          setState(() {
            exampleText = "No interests found.";
          });
        }
      } else {
        setState(() {
          exampleText = "Interests file not found.";
        });
      }
    } catch (e) {
      setState(() {
        exampleText = "Error generating example text: $e";
      });
    }
  }

  Future<void> _fetchAndGenerateExplanation() async {
    try {
      // Call the GPT service to generate an additional explanation of the key term
      final openAIService = Provider.of<OpenAIService>(context, listen: false);
      final response = await openAIService.gptAPICall(
          "Provide a 30-word explanation of the term: $normalText.");

      if (response != null) {
        setState(() {
          explanationText = response;
          hasExplainedMore = true;  // Disable further explanation requests
        });
        await _preloadExplanationTextAudio();  // Preload the explanation audio after receiving the response
      } else {
        setState(() {
          explanationText = "No further explanation available.";
        });
      }
    } catch (e) {
      setState(() {
        explanationText = "Error generating further explanation: $e";
      });
    }
  }

  void _handleAudioCompletion() {
    setState(() {
      isPlaying = false;
    });
  }

  void _playText(String key) async {
    String? audioPath = audioFilePaths[key];
    if (audioPath != null) {
      await _audioPlayer.play(audioPath, isLocal: true);
      setState(() {
        isPlaying = true;
        currentText = key == 'normal' ? normalText : key == 'example' ? exampleText : explanationText;
      });
    }
  }

  void _onTextTap(String key) {
    if (key != currentText || !isPlaying) {
      _playText(key);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double chatboxLeftPadding = 16.0;
    final double chatboxWidth = MediaQuery.of(context).size.width * 0.8;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Chatbot Title',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Lexend-Bold',
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    )
                  
                  ],
                ),
                const SizedBox(height: 20.0),
                Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.bottomCenter,
                  children: [
                    Container(
                      constraints: BoxConstraints(
                        maxHeight: 350,  // Set max height to 350px
                      ),
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2B3F3A),
                        borderRadius: BorderRadius.circular(20.0),
                        border: Border.all(
                          color: const Color(0xFF727A73),
                          width: 2.0,
                        ),
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            RichText(
                              text: TextSpan(
                                text: normalText,
                                style: TextStyle(
                                  fontFamily: 'Lexend-Regular',
                                  fontSize: 15,
                                  color: Colors.white,
                                  decoration: currentText == normalText
                                      ? TextDecoration.underline
                                      : TextDecoration.none,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    _onTextTap('normal');
                                  },
                              ),
                            ),
                            const SizedBox(height: 20.0),
                            RichText(
                              text: TextSpan(
                                text: exampleText,
                                style: TextStyle(
                                  fontFamily: 'Lexend-Regular',
                                  fontSize: 15,
                                  color: Colors.grey,
                                  decoration: currentText == exampleText
                                      ? TextDecoration.underline
                                      : TextDecoration.none,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    _onTextTap('example');
                                  },
                              ),
                            ),
                            const SizedBox(height: 20.0),
                            if (hasExplainedMore)  // Only show the explanation text if "Explain More" has been pressed
                              RichText(
                                text: TextSpan(
                                  text: explanationText,
                                  style: TextStyle(
                                    fontFamily: 'Lexend-Regular',
                                    fontSize: 15,
                                    color: Colors.grey,
                                    decoration: currentText == explanationText
                                        ? TextDecoration.underline
                                        : TextDecoration.none,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      _onTextTap('explanation');
                                    },
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -17,  // Adjust position to place it correctly below the chatbox
                      child: CustomPaint(
                        painter: TrianglePainter(),
                        child: const SizedBox(
                          height: 20,
                          width: 40,
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Image.asset(
                    'assets/character.png',
                    height: 175,
                    width: 175,
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: hasExplainedMore
                            ? null
                            : () {
                                _fetchAndGenerateExplanation();  // Fetch further explanation when Explain More is pressed
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF36565),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          minimumSize: Size(
                            (MediaQuery.of(context).size.width * 0.44),
                            50,
                          ),
                        ),
                        child: const Text(
                          'Explain More...',
                          style: TextStyle(
                            fontFamily: 'Lexend-Regular',
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: widget.onNext,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF39C12E),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          minimumSize: Size(
                            (MediaQuery.of(context).size.width * 0.44),
                            50,
                          ),
                        ),
                        child: const Text(
                          'Understood',
                          style: TextStyle(
                            fontFamily: 'Lexend-Regular',
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
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

// Custom painter for the triangle below the chatbox
class TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF2B3F3A)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width / 2, size.height)
      ..lineTo(0, 0)
      ..lineTo(size.width, 0)
      ..close();

    final borderPaint = Paint()
      ..color = const Color(0xFF727A73)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawPath(path, paint);
    canvas.drawLine(Offset(0, 0), Offset(size.width / 2, size.height), borderPaint);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width / 2, size.height), borderPaint);
  }

  @override
  bool shouldRepaint(TrianglePainter oldDelegate) => false;
}
