import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HapticFeedback;
import 'game.dart'; // Adjust the import based on your project structure
import 'file-storage.dart'; // Import the FileStorage class

class RoadmapPage extends StatefulWidget {
  final String title;    // Course name (e.g., "Programming")
  final String category; // Category (e.g., "NIL")

  const RoadmapPage({Key? key, required this.title, required this.category})
      : super(key: key);

  @override
  _RoadmapPageState createState() => _RoadmapPageState();
}

class _RoadmapPageState extends State<RoadmapPage> {
  Map<String, dynamic>? coursesData;

  @override
  void initState() {
    super.initState();
    loadCourseData();
  }

  Future<void> loadCourseData() async {
    coursesData = await FileStorage.readCoursesData();
    setState(() {});
  }

  // Helper method to get activities
  List<dynamic> getActivities() {
    final categoryData = coursesData!['categories'][widget.category];
    final courses = categoryData['courses'] as List<dynamic>;
    final course = courses.firstWhere(
      (course) => course['course_name'] == widget.title,
      orElse: () => null,
    );
    final activities =
        course != null ? course['activities'] as List<dynamic> : [];
    return activities;
  }

  @override
  Widget build(BuildContext context) {
    if (coursesData == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final categoryData = coursesData!['categories'][widget.category];
    if (categoryData == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF19312F),
        body: Center(
          child: Text(
            'Category ${widget.category} not found.',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    final courses = categoryData['courses'] as List<dynamic>;
    final course = courses.firstWhere(
      (course) => course['course_name'] == widget.title,
      orElse: () => null,
    );

    if (course == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF19312F),
        body: Center(
          child: Text(
            'Course ${widget.title} not found.',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    final activities = course['activities'] as List<dynamic>;

    // Find the index of the first unfinished activity
    int firstUnfinishedIndex = activities.indexWhere((activity) =>
        activity.containsKey('activity') &&
        activity['activity']['finished'] == false);

    if (firstUnfinishedIndex == -1) {
      // All activities are finished; set index to the last one
      firstUnfinishedIndex = activities.length - 1;
    }

    bool isLeft = false;

    return Scaffold(
      backgroundColor: const Color(0xFF19312F),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with title and stats
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontFamily: 'Lexend-Bold',
                        fontSize: 24,
                        color: Colors.white,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          '500 XP',
                          style: const TextStyle(
                            fontFamily: 'Lexend-Regular',
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Image.asset(
                          'assets/xp.png',
                          width: 20,
                          height: 20,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '5',
                          style: const TextStyle(
                            fontFamily: 'Lexend-Regular',
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Image.asset(
                          'assets/fire.png',
                          width: 20,
                          height: 20,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '5',
                          style: const TextStyle(
                            fontFamily: 'Lexend-Regular',
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Image.asset(
                          'assets/heart.png',
                          width: 20,
                          height: 20,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                // Underline under the title
                Container(
                  width: widget.title.length * 10.0 + 45,
                  height: 2,
                  color: Colors.white,
                ),
                const SizedBox(height: 50),

                // Activities list
                ...List.generate(activities.length, (index) {
                  final activity = activities[index];

                  if (activity.containsKey('activity')) {
                    final activityDetails = activity['activity'];
                    final bool finished = activityDetails['finished'];
                    final isCurrent = (index == firstUnfinishedIndex);

                    final alignment = index == 0
                        ? Alignment.center
                        : (isLeft
                            ? const Alignment(-0.3, 0)
                            : const Alignment(0.3, 0));

                    if (index != 0) {
                      isLeft = !isLeft;
                    }

                    String image;
                    if (finished) {
                      image = 'assets/checked.png';
                    } else if (isCurrent) {
                      image = 'assets/start.png';
                    } else {
                      image = 'assets/locked.png';
                    }

                    // Calculate the activity index (excluding levels)
                    int activityIndex = _calculateActivityIndex(index);

                    return Column(
                      children: [
                        Align(
                          alignment: alignment,
                          child: IconWithPopup(
                            image: image,
                            isEnabled: finished || isCurrent,
                            onButtonPressed: () async {
                              // Navigate to GamePage and wait for it to finish
                              await Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => GamePage(
                                  category: widget.category,
                                  courseName: widget.title,
                                  activityIndex: activityIndex,
                                  lives: 5,
                                ),
                              ));

                              // After returning from GamePage, reload the course data
                              await loadCourseData();
                            },
                          ),
                        ),
                        const SizedBox(height: 30),
                      ],
                    );
                  }

                  if (activity.containsKey('level')) {
                    final levelDetails = activity['level'];
                    final int levelNumber = levelDetails['level_number'];

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: _buildLevelWidget(levelNumber),
                    );
                  }

                  return Container();
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  int _calculateActivityIndex(int currentIndex) {
    int actualIndex = 0;
    int activityIndex = 0;

    final activities = coursesData!['categories'][widget.category]['courses']
            .firstWhere(
                (course) => course['course_name'] == widget.title)['activities']
        as List<dynamic>;

    for (var i = 0; i < activities.length; i++) {
      if (activities[i].containsKey('activity')) {
        if (i == currentIndex) {
          activityIndex = actualIndex;
          break;
        }
        actualIndex++;
      }
    }

    return activityIndex;
  }

  Widget _buildLevelWidget(int levelNumber) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 8.0),
            height: 2,
            color: const Color(0xFF727A73),
          ),
        ),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFF42554F),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: const Color(0xFF727A73),
              width: 2,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            '$levelNumber',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontFamily: 'Lexend-Bold',
            ),
          ),
        ),
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 8.0),
            height: 2,
            color: const Color(0xFF727A73),
          ),
        ),
      ],
    );
  }
}

class IconWithPopup extends StatelessWidget {
  final String image;
  final bool isEnabled;
  final Future<void> Function() onButtonPressed;

  const IconWithPopup({
    Key? key,
    required this.image,
    required this.isEnabled,
    required this.onButtonPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isEnabled
          ? () {
              // Show the popup dialog
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    backgroundColor: const Color(0xFF2B3F3A),
                    contentPadding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                        color: const Color(0xFF727A73),
                        width: 2,
                      ),
                    ),
                    content: Container(
                      width: 250,
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: double.infinity,
                            height: 40,
                            child: ElevatedButton(
                              onPressed: () async {
                                Navigator.of(context).pop(); // Close the dialog
                                await onButtonPressed();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6DB697),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Start',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontFamily: 'Lexend-Bold',
                                ),
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
          : null,
      child: Image.asset(
        image,
        width: 70,
        height: 70,
      ),
    );
  }
}
