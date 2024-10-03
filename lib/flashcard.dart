import 'package:flutter/material.dart';

class FlashcardPage extends StatefulWidget {
  const FlashcardPage({Key? key}) : super(key: key);

  @override
  _FlashcardPageState createState() => _FlashcardPageState();
}

class _FlashcardPageState extends State<FlashcardPage> with SingleTickerProviderStateMixin {
  bool _isFlipped = false; // Track the state of the card (flipped or not)
  late AnimationController _controller;
  late Animation<double> _flipAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500), // Animation duration
      vsync: this,
    );

    _flipAnimation = Tween(begin: 0.0, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _flipCard() {
    if (_isFlipped) {
      _controller.reverse(); // Reverse the animation if flipped
    } else {
      _controller.forward(); // Forward the animation if not flipped
    }
    _isFlipped = !_isFlipped; // Toggle the card state
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center( // Center the entire column content vertically and horizontally
            child: Column(
              mainAxisSize: MainAxisSize.min, // Only take the required space vertically
              children: [
                const Center(
                  child: Text(
                    'Tap to Flip',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 20),

                // Flashcard with flip animation
                GestureDetector(
                  onTap: _flipCard,
                  child: AnimatedBuilder(
                    animation: _flipAnimation,
                    builder: (context, child) {
                      // Calculate the rotation angle
                      double angle = _flipAnimation.value * 3.14; // Pi for a half rotation
                      bool isFrontVisible = _flipAnimation.value < 0.5;

                      return Transform(
                        transform: Matrix4.identity()
                          ..rotateX(isFrontVisible ? angle : angle + 3.14), // Flip the backside correctly
                        alignment: Alignment.center,
                        child: isFrontVisible
                            ? Container(
                                key: const ValueKey('front'), // Unique key for the front side
                                width: 300,
                                height: 200,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.blue, width: 2),
                                ),
                                child: const Center(
                                  child: Text(
                                    'This is the front side of the card.', // Text on the front side
                                    style: TextStyle(fontSize: 24, color: Colors.blue),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              )
                            : Container(
                                key: const ValueKey('back'), // Unique key for the back side
                                width: 300,
                                height: 200,
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Center(
                                  child: Text(
                                    'Now you see the back side!', // Text on the back side
                                    style: TextStyle(fontSize: 24, color: Colors.white),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Next button at the bottom
          Positioned(
            bottom: 16,
            right: 16,
            child: ElevatedButton(
              onPressed: () {
                // Handle the next action here
              },
              child: const Text('Next'),
            ),
          ),
        ],
      ),
    );
  }
}
