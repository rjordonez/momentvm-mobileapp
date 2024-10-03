import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class QuizPage extends StatefulWidget {
  final int questionNumber; // Dynamic question number
  final int totalQuestions; // Total number of questions
  final String question; // The quiz question
  final List<String> answers; // Potential answers
  final String correctAnswer; // The correct answer
  final String explanation; // Explanation for the correct answer
  final Function(bool) onNext; // Callback to handle the next activity

  const QuizPage({
    Key? key,
    required this.questionNumber,
    required this.totalQuestions,
    required this.question,
    required this.answers,
    required this.correctAnswer,
    required this.explanation,
    required this.onNext,
  }) : super(key: key);

  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  final AudioCache _audioCache = AudioCache(); // Use AudioCache to load audio
  String selectedAnswer = '';
  bool isAnswerCorrect = false;
  bool isAnswerSelected = false;
  bool isCollapsed = true; // Track if the bottom sheet is collapsed or expanded
  double currentHeight = 50; // Initial collapsed height
  double minHeight = 50; // Minimum height (collapsed)
  String explanation = '';
  bool isBottomSheetVisible = false; // Track if the bottom sheet is visible

  @override
  void initState() {
    super.initState();
    // Reset all the state variables when the widget is initialized
    resetState();
  }
  void didUpdateWidget(covariant QuizPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.questionNumber != oldWidget.questionNumber) {
      resetState(); // Reset the state when the question number changes
    }
  }

  void resetState() {
    selectedAnswer = '';
    isAnswerCorrect = false;
    isAnswerSelected = false;
    isCollapsed = true;
    currentHeight = minHeight; // Reset to collapsed height
    explanation = '';
    isBottomSheetVisible = false;
  }

  void checkAnswer(String answer) {
    if (isAnswerSelected) return; // Prevent multiple selections

    setState(() {
      selectedAnswer = answer;
      isAnswerCorrect = answer == widget.correctAnswer;
      isAnswerSelected = true;
      isBottomSheetVisible = true;
      explanation = isAnswerCorrect
          ? widget.explanation
          : 'Incorrect. The correct answer is "${widget.correctAnswer}".\n\n${widget.explanation}';

      // Play sound based on the answer's correctness
      if (isAnswerCorrect) {
        _audioCache.play('win.mp3'); // Play win sound
      } else {
        _audioCache.play('lose.mp3'); // Play lose sound
      }

      // Show the explanation popup fully expanded
      currentHeight = MediaQuery.of(context).size.height * 0.5; // Full expanded height
      isCollapsed = false; // Bottom sheet is open
    });
  }

  // Handle dragging logic for the bottom sheet
  void handleDrag(DragUpdateDetails details) {
    setState(() {
      currentHeight -= details.primaryDelta!;
      if (currentHeight < minHeight) {
        currentHeight = minHeight; // Limit to collapsed height
      }
      if (currentHeight > MediaQuery.of(context).size.height * 0.5) {
        currentHeight = MediaQuery.of(context).size.height * 0.5; // Limit to max expanded height
      }
    });
  }

  void handleDragEnd(DragEndDetails details) {
    setState(() {
      if (currentHeight < (minHeight + MediaQuery.of(context).size.height * 0.5) / 2) {
        currentHeight = minHeight; // Collapse
        isCollapsed = true;
      } else {
        currentHeight = MediaQuery.of(context).size.height * 0.5; // Expand
        isCollapsed = false;
      }
    });
  }

  // Function to toggle bottom sheet on tap
  void toggleBottomSheet() {
    setState(() {
      if (isCollapsed) {
        currentHeight = MediaQuery.of(context).size.height * 0.5; // Expand
        isCollapsed = false;
      } else {
        currentHeight = minHeight; // Collapse
        isCollapsed = true;
      }
    });
  }

  void goToNextQuestion() {
    // Proceed to the next question and reset the state
    widget.onNext(isAnswerCorrect); // Call the onNext callback
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Transparent to see gradient from GamePage
      body: Stack(
        children: [
          // Main Quiz Page
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // The question counter and question text in the same rectangle
                  Container(
                    width: double.infinity, // Full width
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2B3F3A), // Inside color
                      borderRadius: BorderRadius.circular(30.0), // Border radius
                      border: Border.all(
                        color: const Color(0xFF727A73), // Stroke color
                        width: 2.0,
                      ),
                    ),
                    child: Column(
                      children: [
                        // Question counter
                        RichText(
                          text: TextSpan(
                            text: 'Question ',
                            style: const TextStyle(
                              fontFamily: 'Lexend-Regular',
                              fontSize: 18,
                              color: Colors.white,
                            ),
                            children: <TextSpan>[
                              TextSpan(
                                text: '${widget.questionNumber}',
                                style: const TextStyle(
                                  fontFamily: 'Lexend-Bold',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                              TextSpan(
                                text: '/${widget.totalQuestions}',
                                style: const TextStyle(
                                  fontFamily: 'Lexend-Regular',
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),

                        // The question text
                        Text(
                          widget.question,
                          style: const TextStyle(
                            fontFamily: 'Lexend-Bold',
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20), // Space before answers

                  // Answer options
                  Wrap(
                    spacing: 10.0,
                    runSpacing: 10.0,
                    alignment: WrapAlignment.center,
                    children: widget.answers.map((answer) {
                      return GestureDetector(
                        onTap: () {
                          if (!isAnswerSelected) {
                            checkAnswer(answer); // Check the answer
                          }
                        },
                        child: Container(
                          width: widget.answers.length == 2
                              ? MediaQuery.of(context).size.width * 0.45 // 45% width for 2 answers
                              : MediaQuery.of(context).size.width, // 100% width for 4 answers
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: isAnswerSelected
                                ? (answer == selectedAnswer
                                    ? (isAnswerCorrect
                                        ? const Color(0xFF36B42C)
                                        : const Color(0xFFE85E5E))
                                    : const Color(0xFFFFFFFF))
                                : const Color(0xFFFFFFFF),
                            borderRadius: BorderRadius.circular(10.0),
                            border: Border.all(
                              color: Colors.grey,
                              width: 1.0,
                            ),
                          ),
                          child: Text(
                            answer,
                            style: TextStyle(
                              fontFamily: 'Lexend-Regular',
                              fontSize: 18,
                              color: isAnswerSelected && answer == selectedAnswer
                                  ? Colors.white
                                  : Colors.black,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),

          // Only show the bottom sheet if an answer has been selected
          if (isBottomSheetVisible)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: GestureDetector(
                onVerticalDragUpdate: handleDrag, // Handle drag updates
                onVerticalDragEnd: handleDragEnd, // Handle drag end to snap
                onTap: toggleBottomSheet, // Handle tap to toggle expand/collapse
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200), // Smooth transition
                  height: currentHeight, // Dynamic height
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: isAnswerCorrect ? const Color(0xFF36B42C) : const Color(0xFFE85E5E),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Arrow at the top to indicate interaction
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Align(
                          alignment: Alignment.topRight,
                          child: Icon(
                            isCollapsed ? Icons.arrow_upward : Icons.arrow_downward,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      if (!isCollapsed) // Only show content when expanded
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isAnswerCorrect ? "Wow, Correct!" : "Oops, that's wrong",
                                style: const TextStyle(
                                  fontFamily: 'Lexend-Bold',
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                explanation,
                                style: const TextStyle(
                                  fontFamily: 'Lexend-Regular',
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      const Spacer(),
                      if (!isCollapsed) // Only show button when expanded
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: ElevatedButton(
                              onPressed: goToNextQuestion,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                shadowColor: Colors.black,
                                elevation: 5,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                'Next',
                                style: TextStyle(
                                  color: isAnswerCorrect ? const Color(0xFF36B42C) : const Color(0xFFE85E5E),
                                  fontFamily: 'Lexend-Bold',
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
