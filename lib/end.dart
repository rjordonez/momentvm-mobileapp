import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For Haptic feedback
import 'package:sprint5/game.dart';

class LessonCompletePage extends StatefulWidget {
  final List<bool> answersList;
  final int level;
  final int hearts;
  final String category;
  final String courseName;
  final int activityIndex;

  const LessonCompletePage({
    Key? key,
    required this.answersList,
    required this.level,
    required this.hearts,
    required this.category,
    required this.courseName,
    required this.activityIndex,
  }) : super(key: key);

  @override
  _LessonCompletePageState createState() => _LessonCompletePageState();
}

class _LessonCompletePageState extends State<LessonCompletePage>
    with SingleTickerProviderStateMixin {
  double sliderPosition = 0;
  bool showSlider = false;
  late AnimationController _controller;
  late Animation<double> _animation;
  int starCount = 0;
  int currentQuestionIndex = -1; // For tracking the hovered data point

  @override
  void initState() {
    super.initState();
    _calculateStars();

    // Initialize animation controller for stars
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animation =
        Tween<double>(begin: 0, end: starCount.toDouble()).animate(_controller)
          ..addListener(() {
            setState(() {});
          });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _calculateStars() {
    double correctPercentage =
        widget.answersList.where((answer) => answer).length /
            widget.answersList.length;
    if (correctPercentage < 0.33) {
      starCount = 1;
    } else if (correctPercentage < 0.66) {
      starCount = 2;
    } else {
      starCount = 3;
    }
  }

  @override
  Widget build(BuildContext context) {
    double graphWidth = MediaQuery.of(context).size.width * 0.8;

    // Update the xpText based on currentQuestionIndex
    String xpText = '500 XP earned';
    if (currentQuestionIndex != -1) {
      // Calculate correct answers up to the current question index
      int correctAnswers = 0;
      for (int i = 0; i <= currentQuestionIndex; i++) {
        if (widget.answersList[i]) {
          correctAnswers++;
        }
      }
      xpText = 'Questions Correct: $correctAnswers';
    }

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF2A2F29), Color(0xFF193432)],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20), // Adjusted padding
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Lesson Complete! Level ${widget.level}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontFamily: 'Lexend-Regular',
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    '+10XP',
                    style: TextStyle(
                      color: Color(0xFF6DB697),
                      fontSize: 24,
                      fontFamily: 'Lexend-Regular',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 50), // Stars positioned 50 pixels below the text
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    _animation.value >= 1
                        ? 'assets/star-filled.png'
                        : 'assets/star.png',
                    width: 65,
                    height: 65,
                  ),
                  const SizedBox(width: 10),
                  Transform.translate(
                    offset: const Offset(0, -30), // Offset the middle star upwards
                    child: Image.asset(
                      _animation.value >= 2
                          ? 'assets/star-filled.png'
                          : 'assets/star.png',
                      width: 80,
                      height: 80,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Image.asset(
                    _animation.value >= 3
                        ? 'assets/star-filled.png'
                        : 'assets/star.png',
                    width: 65,
                    height: 65,
                  ),
                ],
              ),
              const Spacer(), // Space between stars and rectangle
              Container(
                width: MediaQuery.of(context).size.width * 0.9,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF2B3F3A),
                  border: Border.all(
                    color: const Color(0xFF727A73),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Updated to use xpText
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'You',
                          style: TextStyle(
                            color: Color(0xFF6DB697),
                            fontSize: 16,
                            fontFamily: 'Lexend-Regular',
                          ),
                        ),
                        Text(
                          xpText,
                          style: const TextStyle(
                            color: Color(0xFF6DB697),
                            fontSize: 16,
                            fontFamily: 'Lexend-Regular',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: graphWidth,
                      height: 250, // Height for the graph
                      child: GestureDetector(
                        onHorizontalDragStart: (details) {
                          setState(() {
                            showSlider = true;
                            _updateSlider(details.localPosition.dx, graphWidth);
                          });
                        },
                        onHorizontalDragUpdate: (details) {
                          setState(() {
                            _updateSlider(details.localPosition.dx, graphWidth);
                          });
                        },
                        onHorizontalDragEnd: (details) {
                          setState(() {
                            showSlider = false;
                            currentQuestionIndex = -1;
                          });
                        },
                        onHorizontalDragCancel: () {
                          setState(() {
                            showSlider = false;
                            currentQuestionIndex = -1;
                          });
                        },
                        child: CustomPaint(
                          size: Size(graphWidth, 250),
                          painter: GraphPainter(
                            sliderPosition,
                            showSlider,
                            widget.answersList,
                            currentQuestionIndex,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(), // Space between rectangle and button
              Padding(
                padding: const EdgeInsets.only(bottom: 30.0), // Adjust for the bottom spacing
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      children: [
                        Positioned(
                          left: 5, // Offset the shadow slightly on X-axis
                          top: 5, // Offset the shadow slightly on Y-axis
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.9,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A2927), // Darker color for the shadow
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                        InkWell(
                          splashColor: Colors.transparent, // Disable ripple effect
                          onTap: () {
                            HapticFeedback.heavyImpact(); // Trigger haptic feedback
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => GamePage(
                                  category: widget.category,
                                  courseName: widget.courseName,
                                  activityIndex: widget.activityIndex,
                                  lives: widget.hearts,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.9,
                            decoration: BoxDecoration(
                              color: const Color(0xFF6DB697),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            alignment: Alignment.center,
                            child: Text(
                              'Continue to level ${widget.level + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontFamily: 'Lexend-Regular',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        // Logic for "Not now"
                      },
                      child: const Text(
                        'Not now',
                        style: TextStyle(
                          color: Color(0xFF6DB697),
                          fontSize: 16,
                          fontFamily: 'Lexend-Regular',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _updateSlider(double localDx, double graphWidth) {
    double clampedDx = localDx.clamp(0.0, graphWidth);
    double xStep = graphWidth / (widget.answersList.length - 1);
    currentQuestionIndex = (clampedDx / xStep)
        .round()
        .clamp(0, widget.answersList.length - 1);
    sliderPosition = xStep * currentQuestionIndex;
  }
}
class GraphPainter extends CustomPainter {
  final double sliderPosition;
  final bool showSlider;
  final List<bool> answersList;
  final int currentQuestionIndex;

  GraphPainter(this.sliderPosition, this.showSlider, this.answersList, this.currentQuestionIndex);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint gridLinePaint = Paint()
      ..color = const Color(0xFF1C2724)
      ..strokeWidth = 1;

    // Drawing horizontal grid lines
    for (int i = 1; i < 6; i++) {
      double dy = size.height * i / 6;
      canvas.drawLine(Offset(0, dy), Offset(size.width, dy), gridLinePaint);
    }

    // Prepare to store the data points
    List<Offset> dataPoints = [];

    // Calculate the data points
    double xStep = size.width / (answersList.length - 1);
    double currentY = size.height;
    double yStep = size.height / answersList.length;

    for (int i = 0; i < answersList.length; i++) {
      double x = xStep * i;

      if (answersList[i]) {
        currentY -= yStep; // Increase when correct
      }
      // Save the point
      dataPoints.add(Offset(x, currentY));
    }

    // Draw lines between the data points
    final Paint graphLinePaint = Paint()
      ..color = const Color(0xFF6DB697) // Set the line color to green
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    if (dataPoints.isNotEmpty) {
      Path path = Path();
      path.moveTo(dataPoints[0].dx, dataPoints[0].dy);
      for (int i = 1; i < dataPoints.length; i++) {
        path.lineTo(dataPoints[i].dx, dataPoints[i].dy);
      }
      canvas.drawPath(path, graphLinePaint);
    }

    // Draw dots at each data point
    final Paint dotPaint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < dataPoints.length; i++) {
      Offset point = dataPoints[i];
      if (i == currentQuestionIndex && showSlider) {
        dotPaint.color = Colors.yellow; // Highlighted dot
        canvas.drawCircle(point, 6, dotPaint);
      } else {
        dotPaint.color = const Color(0xFF6DB697); // Set dot color to green
        canvas.drawCircle(point, 4, dotPaint);
      }
    }

    // Draw the vertical slider line if the slider is visible
    if (showSlider) {
      final Paint sliderLinePaint = Paint()
        ..color = Colors.white
        ..strokeWidth = 2;

      const double dashWidth = 5;
      const double dashSpace = 5;
      double startY = 0;

      while (startY < size.height) {
        canvas.drawLine(
          Offset(sliderPosition, startY),
          Offset(sliderPosition, startY + dashWidth),
          sliderLinePaint,
        );
        startY += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}