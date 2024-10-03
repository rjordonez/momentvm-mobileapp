import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:sprint5/mainscreen.dart';

class CongratulationsPage extends StatefulWidget {
  const CongratulationsPage({Key? key}) : super(key: key);

  @override
  _CongratulationsPageState createState() => _CongratulationsPageState();
}

class _CongratulationsPageState extends State<CongratulationsPage> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    // Initialize the confetti controller
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    // Start the confetti animation
    _confettiController.play();
  }

  @override
  void dispose() {
    // Dispose the confetti controller to prevent memory leaks
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF193432),
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Confetti widget
          ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive, // Blast in all directions
            shouldLoop: false, // Do not loop the confetti animation
            colors: const [Colors.green, Colors.blue, Colors.pink, Colors.orange, Colors.purple],
          ),
          Center( // Center the content vertically and horizontally
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center, // Center horizontally
              children: [
                const Text(
                  'Congratulations!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontFamily: 'Lexend-Regular',
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'You have completed all activities.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontFamily: 'Lexend-Regular',
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () {
                    // Navigate back to the homepage or main menu
                   Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6DB697), // Button color
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontFamily: 'Lexend-Regular',
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
