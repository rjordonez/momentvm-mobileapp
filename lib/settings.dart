import 'package:flutter/material.dart';
import 'mainscreen.dart';

void showSettingsDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          padding: const EdgeInsets.all(20.0),
          decoration: const BoxDecoration(
            color: Color(0xFF1C3532),
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop(); // Close the dialog and go back
                    },
                    child: Image.asset('assets/arrow.png', height: 30),
                  ),
                  const Expanded(
                    child: Text(
                      'Settings',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'Lexend',
                      ),
                    ),
                  ),
                  const SizedBox(width: 35), // Spacer for balance
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  showEndSessionDialog(context); // Show end session dialog
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6DB697),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  minimumSize: Size(MediaQuery.of(context).size.width * 0.8, 50),
                ),
                child: const Text(
                  'End Session',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Lexend',
                  ),
                ),
              ),
              const SizedBox(height: 15),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  showFeedbackDialog(context); // Show feedback dialog
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6DB697),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  minimumSize: Size(MediaQuery.of(context).size.width * 0.8, 50),
                ),
                child: const Text(
                  'Feedback',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Lexend',
                  ),
                ),
              ),
              const SizedBox(height: 15),
            ],
          ),
        ),
      );
    },
  );
}

void showEndSessionDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(20.0),
          decoration: const BoxDecoration(
            color: Color(0xFF1C3532),
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Wait!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'Lexend',
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'You can always skip ahead later, but your current XP will be lost if you end now.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontFamily: 'Lexend',
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog and continue learning
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6DB697),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  minimumSize: Size(MediaQuery.of(context).size.width * 0.8, 50),
                ),
                child: const Text(
                  'Keep Learning',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Lexend',
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const MainScreen()),
                    (route) => false,
                  ); // End session
                },
                child: const Text(
                  'End Session',
                  style: TextStyle(
                    color: Color(0xFFFF6666),
                    fontFamily: 'Lexend',
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

void showFeedbackDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(20.0),
          decoration: const BoxDecoration(
            color: Color(0xFF1C3532),
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop(); // Close feedback dialog and go back to settings
                      showSettingsDialog(context); // Return to the main settings page
                    },
                    child: Image.asset('assets/arrow.png', height: 30),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Did you find this content insightful?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'Lexend',
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () {
                      showMoreFeedbackDialog(context);
                    },
                    child: Column(
                      children: [
                        Image.asset('assets/unsatisfied.png', height: 60),
                        const SizedBox(height: 5),
                        const Text(
                          'Unsatisfied',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                            fontFamily: 'Lexend',
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      showMoreFeedbackDialog(context);
                    },
                    child: Column(
                      children: [
                        Image.asset('assets/ok.png', height: 60),
                        const SizedBox(height: 5),
                        const Text(
                          'Ok',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                            fontFamily: 'Lexend',
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      showMoreFeedbackDialog(context);
                    },
                    child: Column(
                      children: [
                        Image.asset('assets/loved.png', height: 60),
                        const SizedBox(height: 5),
                        const Text(
                          'I loved it',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                            fontFamily: 'Lexend',
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
    },
  );
}

void showMoreFeedbackDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(20.0),
          decoration: const BoxDecoration(
            color: Color(0xFF1C3532),
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Would you like us to know more?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'Lexend',
                ),
              ),
              const SizedBox(height: 20),
              Container(
                height: 100,
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const TextField(
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: InputDecoration(
                    hintText: 'Type your thoughts here...',
                    hintStyle: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF727272),
                      fontFamily: 'Lexend',
                    ),
                    border: InputBorder.none,
                  ),
                  style: TextStyle(
                    fontFamily: 'Lexend',
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close this dialog
                  showThankYouDialog(context); // Show the thank you dialog
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6DB697),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  minimumSize: Size(MediaQuery.of(context).size.width * 0.8, 50),
                ),
                child: const Text(
                  'Submit',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Lexend',
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Skip feedback and close the popup
                  showThankYouDialog(context); // Show the thank you dialog
                },
                child: const Text(
                  'Skip',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Lexend',
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
void showThankYouDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(20.0),
          decoration: const BoxDecoration(
            color: Color(0xFF1C3532),
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/horray.png',
                width: MediaQuery.of(context).size.width * 0.8, // Full width of the popup
                fit: BoxFit.cover, // Cover the available width
              ),
              const SizedBox(height: 20),
              const Text(
                'Thank You!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'Lexend',
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Your feedback helps us keep our app great for you.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontFamily: 'Lexend',
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the topmost popup
                  Navigator.of(context).pop(); // Close the second popup
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6DB697),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                ),
                child: const Text(
                  'Close',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Lexend',
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
