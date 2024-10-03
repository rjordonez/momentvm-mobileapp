import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:sprint5/mainscreen.dart';
import 'file-storage.dart'; // Import the FileStorage class
import 'chatbot.dart';
import 'context.dart';
import 'video.dart';
import 'quiz.dart';
import 'end.dart';
import 'settings.dart'; // Import the settings functions
import 'congratulations.dart';

class GamePage extends StatefulWidget {
  final String category;
  final String courseName;
  final int activityIndex; // Index among activities only (excluding levels)
  final int lives;

  const GamePage({
    Key? key,
    required this.category,
    required this.courseName,
    required this.activityIndex,
    required this.lives,
  }) : super(key: key);

  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  Map<String, dynamic>? coursesData;
  int activityListIndex = 0; // Index in the full activities list (including levels)
  int activityCounter = 0; // Number of activities completed (excluding levels)
  int totalActivities = 1;
  int totalQuizActivities = 0; // Total number of quiz activities
  int lives = 5;
  int currentLevel = 1;
  String currentActivity = 'quiz';
  Map<String, dynamic>? currentActivityData;
  List<bool> answersList = [];

  @override
  void initState() {
    super.initState();
    lives = widget.lives;
    _loadCoursesData();
  }

  Future<void> _loadCoursesData() async {
    coursesData = await FileStorage.readCoursesData();
    if (coursesData == null || coursesData!.isEmpty) {
      // Handle the case where data couldn't be loaded
      print('Failed to load courses data.');
      return;
    }
    setState(() {
      _calculateTotalActivities();
      activityListIndex = _getActivityListIndexFromActivityIndex(widget.activityIndex);
      _setInitialActivity();
    });
  }

  void _calculateTotalActivities() {
    final course = _getCourseData(widget.category, widget.courseName);
    if (course != null) {
      final activities = course['activities'] as List<dynamic>;

      // Total activities (excluding levels)
      totalActivities = activities
          .where((dynamic activityItem) {
            if (activityItem is Map<String, dynamic>) {
              return activityItem.containsKey('activity');
            } else {
              return false;
            }
          })
          .length;

      // Total quiz activities
      totalQuizActivities = activities
          .where((dynamic activityItem) {
            if (activityItem is Map<String, dynamic> && activityItem.containsKey('activity')) {
              final activityCode = activityItem['activity']['activity_code'];
              final activityType = _getActivityType(activityCode);
              return activityType == 'quiz';
            } else {
              return false;
            }
          })
          .length;
    }
  }

  int _getCurrentQuizQuestionNumber() {
    final course = _getCourseData(widget.category, widget.courseName);
    if (course == null) return 0;

    final activities = course['activities'] as List<dynamic>;

    int quizNumber = 0;

    for (int i = 0; i <= activityListIndex; i++) {
      final activityItem = activities[i];
      if (activityItem is Map<String, dynamic> && activityItem.containsKey('activity')) {
        final activityCode = activityItem['activity']['activity_code'];
        final activityType = _getActivityType(activityCode);
        if (activityType == 'quiz') {
          quizNumber++;
        }
      }
    }

    return quizNumber;
  }

  int _getActivityListIndexFromActivityIndex(int activityIndex) {
    final course = _getCourseData(widget.category, widget.courseName);
    if (course == null) return 0;

    final activities = course['activities'] as List<dynamic>;
    int activityCount = -1;
    for (int i = 0; i < activities.length; i++) {
      final item = activities[i];
      if (item is Map<String, dynamic> && item.containsKey('activity')) {
        activityCount++;
        if (activityCount == activityIndex) {
          return i;
        }
      }
    }
    return activities.length - 1;
  }

  Map<String, dynamic>? _getCourseData(String category, String courseName) {
    if (coursesData == null) {
      return null;
    }
    final categoryData = coursesData!['categories']?[category];
    if (categoryData == null) {
      return null;
    }
    final courses = categoryData['courses'] as List<dynamic>;
    final course = courses.firstWhere(
      (dynamic courseItem) =>
          courseItem is Map<String, dynamic> &&
          courseItem['course_name'] == courseName,
      orElse: () => null,
    );
    return course as Map<String, dynamic>?;
  }

  void _setInitialActivity() {
    final course = _getCourseData(widget.category, widget.courseName);
    if (course == null) return;

    final activities = course['activities'] as List<dynamic>;

    activityCounter = widget.activityIndex + 1;

    while (activityListIndex < activities.length) {
      var currentItem = activities[activityListIndex];
      if (currentItem is Map<String, dynamic>) {
        if (currentItem.containsKey('activity')) {
          final activity = currentItem['activity'];
          final activityCode = activity['activity_code'];
          currentActivity = _getActivityType(activityCode);
          currentActivityData = activity;
          break;
        } else if (currentItem.containsKey('level')) {
          activityListIndex += 1;
        } else {
          activityListIndex += 1;
        }
      } else {
        activityListIndex += 1;
      }
    }
  }

  void _onNext(bool isAnswerCorrect) {
    setState(() {
      answersList.add(isAnswerCorrect);
      if (!isAnswerCorrect) {
        lives = max(0, lives - 1);
      }

      // Update the 'finished' status of the current activity
      _markCurrentActivityAsFinished();

      _moveToNextActivity();
    });
  }

  void _markCurrentActivityAsFinished() async {
    final course = _getCourseData(widget.category, widget.courseName);
    if (course == null) return;

    final activities = course['activities'] as List<dynamic>;

    // Ensure the index is within bounds
    if (activityListIndex >= 0 && activityListIndex < activities.length) {
      final currentItem = activities[activityListIndex];
      if (currentItem is Map<String, dynamic> && currentItem.containsKey('activity')) {
        final activity = currentItem['activity'];
        activity['finished'] = true;

        // Save the updated courses data to the local file
        await FileStorage.writeCoursesData(coursesData!);

        // Print the updated activity
        print('Updated activity:\n${jsonEncode(activity)}');
      }
    }
  }

void _moveToNextActivity() {
  final course = _getCourseData(widget.category, widget.courseName);
  if (course == null) return;

  final activities = course['activities'] as List<dynamic>;

  activityListIndex += 1;

  while (activityListIndex < activities.length) {
    final nextItem = activities[activityListIndex];
    if (nextItem is Map<String, dynamic>) {
      if (nextItem.containsKey('activity')) {
        activityCounter += 1;
        final activity = nextItem['activity'];
        final activityCode = activity['activity_code'];
        currentActivity = _getActivityType(activityCode);
        currentActivityData = activity;
        _loadCurrentActivity(); // Load the new activity
        return;
      } else if (nextItem.containsKey('level')) {
        currentLevel = nextItem['level']['level_number'];
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => LessonCompletePage(
              answersList: answersList,
              level: currentLevel,
              hearts: lives,
              category: widget.category,
              courseName: widget.courseName,
              activityIndex: activityCounter,
            ),
          ),
        );
        return;
      } else {
        activityListIndex += 1;
      }
    } else {
      activityListIndex += 1;
    }
  }

  // Check if lives are depleted
  if (lives <= 0) {
    // Navigate back to the main screen
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const MainScreen(),
      ),
    );
  } else if (activityListIndex >= activities.length) {
    // All activities completed, navigate to CongratulationsPage
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const CongratulationsPage(),
      ),
    );
  }
}

  void _loadCurrentActivity() {
    setState(() {
      // Refresh the UI with the new activity
    });
  }

  // Updated _getActivityType function with corrected mappings
  String _getActivityType(String activityCode) {
    switch (activityCode) {
      case '0':
        return 'quiz';
      case '1':
        return 'video';
      case '2':
        return 'chatbot'; // Corrected mapping
      case '3':
        return 'context'; // Corrected mapping
      default:
        return 'unknown';
    }
  }

  List<String> _parseQuizOptions(List<dynamic> options) {
    return options.map((option) => option.toString().substring(3)).toList(); // Remove 'A) ' prefix
  }

  String _parseCorrectAnswer(String correctAnswer) {
    final options = currentActivityData?['content']?['options'] ?? [];
    int index = correctAnswer.codeUnitAt(0) - 'A'.codeUnitAt(0);
    if (index >= 0 && index < options.length) {
      return options[index].substring(3); // Remove the 'A) ' prefix
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    if (coursesData == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    double progressValue = (activityCounter - 1) / totalActivities;
    if (progressValue < 0) progressValue = 0.0;
    if (progressValue > 1) progressValue = 1.0;

    return Container(
      // Background gradient
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF2A2F29), Color(0xFF193432)],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  showSettingsDialog(context);
                },
                child: const Icon(Icons.settings, color: Colors.white),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Container(
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.white,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progressValue,
                      backgroundColor: Colors.transparent,
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6DB697)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Row(
                children: [
                  Text(
                    '$lives',
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  const SizedBox(width: 4),
                  Image.asset('assets/heart.png', width: 24, height: 24),
                ],
              ),
            ],
          ),
        ),
        body: Builder(
          builder: (context) {
            // Based on currentActivity, return the appropriate page
            if (currentActivity == 'video') {
              return VideoPage(
                onNext: () => _onNext(true),
                transcript: currentActivityData?['content']?['transcript'] ?? '',
                title: currentActivityData?['title'] ?? '',
                videoPath: 'assets/${currentActivityData?['videopath'] ?? ''}',
              );
            } else if (currentActivity == 'quiz') {
              final quizContent = currentActivityData?['content'];
              return QuizPage(
                questionNumber: _getCurrentQuizQuestionNumber(),
                totalQuestions: totalQuizActivities,
                question: quizContent?['question'] ?? '',
                answers: _parseQuizOptions(quizContent?['options'] ?? []),
                correctAnswer: _parseCorrectAnswer(quizContent?['correct_answer'] ?? ''),
                explanation: quizContent?['explanation'] ?? '',
                onNext: _onNext,
              );
            } else if (currentActivity == 'context') {
              return ContextPage(
                onNext: () => _onNext(true),
                title: currentActivityData?['title'] ?? '',
                imagePath: 'assets/${currentActivityData?['content']?['image'] ?? ''}',
                text: currentActivityData?['content']?['text'] ?? '',
              );
            } else if (currentActivity == 'chatbot') {
              return ChatBotPage(
                onNext: () => _onNext(true),
                initialTerm: currentActivityData?['content']?['text'] ?? '',
              );
            } else {
              return const Center(child: Text('No Activity Found'));
            }
          },
        ),
      ),
    );
  }
}
