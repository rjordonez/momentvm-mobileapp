import 'package:flutter/material.dart';
import 'package:sprint5/mainscreen.dart';

class ConfidencePage extends StatefulWidget {
  final String category; // New parameter
  final String courseName; // New parameter

  const ConfidencePage({
    super.key,
    required this.category, // Required parameter
    required this.courseName, // Required parameter
  });

  @override
  _ConfidencePageState createState() => _ConfidencePageState();
}

class _ConfidencePageState extends State<ConfidencePage> {
  int? _selectedIndex; // Variable to track selected button index

  void _onButtonTapped(int index) {
    setState(() {
      if (_selectedIndex == index) {
        _selectedIndex = null;
      } else {
        _selectedIndex = index;
      }
    });
  }

 void _nextPage(String roadmapTitle, String roadmapCategory) {
  if (_selectedIndex != null) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => MainScreen.showRoadmap(
          roadmapTitle: roadmapTitle,
          roadmapCategory: roadmapCategory,
        ),
      ),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF19312F), // Same background color as homepage
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  "Let’s evaluate your confidence level",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Lexend-Bold',
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "How confident are you about this topic?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Lexend-Regular',
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                _buildConfidenceButton('Very Confident', 0),
                _buildConfidenceButton('Confident', 1),
                _buildConfidenceButton('Still Learning', 2),
                _buildConfidenceButton('Have no idea', 3),
              ],
            ),
          ),
          // "Continue" button positioned near the bottom and horizontally centered
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter, // Horizontally centered
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: GestureDetector(
  onTap: () {
    _nextPage(widget.courseName, widget.category,); // Call _nextPage with the parameters inside the onTap closure
  },
 
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.8,
                        height: 50,
                        decoration: BoxDecoration(
                          color: _selectedIndex != null
                              ? const Color(0xFF5C8A6B)
                              : const Color(0xFF74897B),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          'Continue',
                          style: TextStyle(
                            fontFamily: 'Lexend-Bold',
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfidenceButton(String text, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: GestureDetector(
        onTap: () => _onButtonTapped(index),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.7, // Adjust width for all buttons
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: _selectedIndex == index ? const Color(0xFF5C8A6B) : Colors.white,
            border: Border.all(
              color: _selectedIndex == index ? const Color(0xFF5C8A6B) : Colors.grey,
              width: 2.0,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
              color: _selectedIndex == index ? Colors.white : Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Lexend-Regular',
            ),
          ),
        ),
      ),
    );
  }
}
