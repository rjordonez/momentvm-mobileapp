// onboarding_page.dart

import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'mainscreen.dart'; // Ensure this exists

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  _OnboardingPageState createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  int currentPage = 0;
  final int totalPages = 5;

  final _emailController = TextEditingController();
  final _interestControllers = List.generate(3, (_) => TextEditingController());
  final _formKeyPage3 = GlobalKey<FormState>();
  final _formKeyPage4 = GlobalKey<FormState>();

  Future<void> _saveInterestsToFile() async {
    final interests = _interestControllers.map((controller) => controller.text).toList();

    try {
      final file = await _localFile();

      // Create the file with an empty structure if it doesn't exist
      if (!(await file.exists())) {
        await file.writeAsString(jsonEncode({'interests': []}));
        print('Created new interests.json file at ${file.path}');
      }

      // Read the existing file content
      String content = await file.readAsString();
      print('Existing content in file: $content');
      
      Map<String, dynamic> jsonContent = jsonDecode(content);
      
      // Update the JSON content
      jsonContent['interests'] = interests;
      
      // Write the updated content back to the file
      await file.writeAsString(jsonEncode(jsonContent));
      print('Interests successfully saved.');
    } catch (e) {
      print('Error saving interests: $e');
    }
  }

  Future<File> _localFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/interests.json');
  }

  void _nextPage() async {
    print('Current page: $currentPage'); // Debug: Track the current page number

    if (currentPage == 3) {  // Assuming the email form is on the fourth page (index 3)
      if (_formKeyPage3.currentState?.validate() ?? false) {
        print('Email form validated successfully'); // Debug: Email form validated
      } else {
        print('Email form validation failed'); // Debug: Email form validation failed
        return; // If the form is invalid, do not proceed
      }
    } else if (currentPage == 4) {  // Assuming interests are on the last page (index 4)
      if (_formKeyPage4.currentState?.validate() ?? false) {
        print('Interest form validated successfully. Saving interests...'); // Debug: Interest form validated
        await _saveInterestsToFile();
        // After saving interests, navigate to MainScreen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
        return;
      } else {
        print('Interest form validation failed'); // Debug: Interest form validation failed
        return;
      }
    }

    setState(() {
      if (currentPage < totalPages - 1) {
        currentPage++;
        print('Navigating to page: $currentPage'); // Debug: Navigation to the next page
      } else {
        print('Navigating to loading screen'); // Debug: Navigation to loading screen
        // Instead of navigating to LoadingScreen, navigate directly to MainScreen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      }
    });
  }

  void _skipToPage(int page) {
    setState(() {
      currentPage = page;
    });
  }

  Widget _buildPageIndicator() {
    if (currentPage > 2) return const SizedBox(); // Hide on pages 4 and 5
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),  // Add 30px space between page indicator and button
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (index) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 5.0),
            width: currentPage == index ? 30.0 : 5.0, // Wider for the current page
            height: 4.0,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(2.0),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildPageContent() {
    switch (currentPage) {
      case 0:
        return _buildInfoPage(
          title: 'Gain confidence \nwith momentvm',
          description: 'Compete, learn, and grow with Momentvm’s personalized, athlete-centric approach.',
          imagePath: 'assets/info-1.png',
        );
      case 1:
        return _buildInfoPage(
          title: 'Bite Sized Learning',
          description: 'Unlock financial wisdom within clicks at your own pace. Momentvm provides bite-sized financial literacy lessons.',
          imagePath: 'assets/info-2.png',
        );
      case 2:
        return _buildInfoPage(
          title: 'Are you ready to learn?',
          description: 'Start your personalized journey today.',
          imagePath: 'assets/onboarding-3.png',
        );
      case 3:
        return _buildEmailForm();
      case 4:
        return _buildInterestsForm();
      default:
        return const SizedBox();
    }
  }

  Widget _buildInfoPage({required String title, required String description, required String imagePath}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, // Vertically center content
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Lexend-Bold',
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              description,
              textAlign: TextAlign.center, // Center text horizontally
              style: const TextStyle(
                fontFamily: 'Lexend-Regular',
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 40),
          Image(
            image: AssetImage(imagePath),
            width: 325, // Adjust image width
            height: 325, // Adjust image height
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }

  Widget _buildEmailForm() {
    return Center(
      child: Form(
        key: _formKeyPage3,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Horizontally center
            crossAxisAlignment: CrossAxisAlignment.center, // Horizontally center text
            children: [
              const Text(
                'Let’s set up your account',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Lexend-Bold',
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'What is your email?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Lexend-Regular',
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: MediaQuery.of(context).size.width * 0.7, // 70% width of screen
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                    hintText: 'Enter your email',
                    border: InputBorder.none,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInterestsForm() {
    return Center(
      child: Form(
        key: _formKeyPage4,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Centered vertically and horizontally
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Let’s set up your account',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Lexend-Bold',
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Enter your interests',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Lexend-Regular',
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              ..._interestControllers.map((controller) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.7, // 70% width
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TextFormField(
                      controller: controller,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                        hintText: 'Enter an interest',
                        border: InputBorder.none,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter an interest';
                        }
                        return null;
                      },
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus(); // Dismiss keyboard on tap outside
      },
      child: Scaffold(
        extendBodyBehindAppBar: true, // Ensures background extends behind the app bar
        body: Stack(
          children: [
            // Full-screen background image
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/background.png'),
                  fit: BoxFit.cover, // Ensure the background image covers the entire screen
                ),
              ),
            ),
            SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (currentPage <= 2) // Show skip button only for the first 3 pages
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Align(
                        alignment: Alignment.topRight,
                        child: GestureDetector(
                          onTap: () {
                            _skipToPage(3); // Skip to the 4th page
                          },
                          child: const Text(
                            'Skip',
                            style: TextStyle(
                              fontFamily: 'Lexend-Regular',
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  Expanded(
                    child: _buildPageContent(),
                  ),
                  if (currentPage <= 2) _buildPageIndicator(), // Page indicator only for first 3 pages

                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: GestureDetector(
                      onTap: _nextPage,
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.8,
                        height: 50,
                        decoration: BoxDecoration(
                          color: const Color(0xFF89AE95),
                          borderRadius: BorderRadius.circular(20), // Rounded to 20
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
                            fontFamily: 'Lexend-Regular',
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
          ],
        ),
      ),
    );
  }
}
