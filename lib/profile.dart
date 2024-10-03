import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:fl_chart/fl_chart.dart'; // Import fl_chart

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  List<String> interests = [];
  final TextEditingController _newInterestController = TextEditingController();
  bool isEditing = false; // Flag to indicate if in edit mode
  String userName = 'Rex'; // Replace with dynamic user data if available

  @override
  void initState() {
    super.initState();
    _loadInterests();
  }

  // Function to get the local file path
  Future<File> _localFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/interests.json');
  }

  // Load interests from the local JSON file
  Future<void> _loadInterests() async {
    try {
      final file = await _localFile();
      if (await file.exists()) {
        final content = await file.readAsString();
        final Map<String, dynamic> jsonContent = jsonDecode(content);
        setState(() {
          interests = List<String>.from(jsonContent['interests'] ?? []);
        });
      }
    } catch (e) {
      print('Error loading interests: $e');
    }
  }

  // Add a new interest and save to file
  Future<void> _addInterest(String newInterest) async {
    if (newInterest.isNotEmpty) {
      setState(() {
        interests.add(newInterest);
      });
      await _saveInterestsToFile();
    }
  }

  // Remove an interest by index and save to file
  Future<void> _removeInterest(int index) async {
    setState(() {
      interests.removeAt(index);
    });
    await _saveInterestsToFile();
  }

  // Save interests to the local JSON file
  Future<void> _saveInterestsToFile() async {
    try {
      final file = await _localFile();
      final jsonContent = jsonEncode({'interests': interests});
      await file.writeAsString(jsonContent);
    } catch (e) {
      print('Error saving interests: $e');
    }
  }

  // Toggle edit mode for interests
  void _toggleEditMode() {
    setState(() {
      isEditing = !isEditing;
    });
  }

  // Show dialog to add a new interest
  Future<void> _showAddInterestDialog() async {
    _newInterestController.clear();
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2B3F3A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: const Text(
            'Add Interest',
            style: TextStyle(
              fontFamily: 'Lexend-Bold',
              color: Colors.white,
            ),
          ),
          content: TextField(
            controller: _newInterestController,
            decoration: InputDecoration(
              hintText: 'Enter new interest',
              hintStyle: const TextStyle(color: Colors.white70),
              filled: true,
              fillColor: const Color(0xFF3E544D),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: BorderSide.none,
              ),
            ),
            style: const TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontFamily: 'Lexend-Regular',
                  color: Colors.white,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                _addInterest(_newInterestController.text);
                Navigator.of(context).pop();
              },
              child: const Text(
                'Add',
                style: TextStyle(
                  fontFamily: 'Lexend-Regular',
                  color: Color(0xFF6DB697),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Data for the graph to show increase, decrease, then higher increase
  final List<double> performanceData = [20, 50, 30, 70, 40, 80, 60];

  @override
  Widget build(BuildContext context) {
    // Screen width for responsive design
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFF1A2927), // Background color
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0), // General padding
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting Text
              Text(
                'Hello, $userName',
                style: const TextStyle(
                  fontFamily: 'Lexend-Bold',
                  fontSize: 24,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              // Green Line
              Container(
                margin: const EdgeInsets.only(left: 2),
                width: screenWidth * 0.5,
                height: 4,
                color: const Color(0xFF6DB697),
              ),
              const SizedBox(height: 20),
              // Your Statistics
              const Text(
                'Your statistics',
                style: TextStyle(
                  fontFamily: 'Lexend-Bold',
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              // First Row: Best Streak and Total Earned
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      imagePath: 'assets/fire.png',
                      title: 'Best Streak',
                      value: '4 Days',
                      titleColor: const Color(0xFFA6B6B3),
                      valueColor: const Color(0xFFFFA41C),
                      isImageRight: false, // Image on the left
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      imagePath: 'assets/xp.png',
                      title: 'Total Earned',
                      value: '500 XP',
                      titleColor: const Color(0xFFA6B6B3),
                      valueColor: const Color(0xFF6DB697),
                      isImageRight: false, // Image on the left
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Second Row: Calendar and Performance Graph
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildCalendarCard(
                      title: 'September 2024',
                      color: const Color(0xFF2B3F3A),
                      titleColor: const Color(0xFFA6B6B3),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildPerformanceGraph(),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Interests Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Interests',
                    style: TextStyle(
                      fontFamily: 'Lexend-Bold',
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                  GestureDetector(
                    onTap: _toggleEditMode,
                    child: Text(
                      isEditing ? 'Done' : 'Edit',
                      style: const TextStyle(
                        fontFamily: 'Lexend-Regular',
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Update Interests Text
              const Center(
                child: Text(
                  'Update your interests anytime to get relevant courses tailored to you.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Lexend-Regular',
                    fontSize: 14,
                    color: Color(0xFFA6B6B3),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Interests Tags
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: [
                  ...interests.map((interest) {
                    return GestureDetector(
                      onLongPress: _toggleEditMode,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2B3F3A),
                          borderRadius: BorderRadius.circular(20),
                          border: isEditing
                              ? Border.all(color: Colors.red, width: 2)
                              : null,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              interest,
                              style: const TextStyle(
                                fontFamily: 'Lexend-Regular',
                                color: Colors.white,
                              ),
                            ),
                            if (isEditing)
                              GestureDetector(
                                onTap: () {
                                  _removeInterest(
                                      interests.indexOf(interest));
                                },
                                child: const Padding(
                                  padding: EdgeInsets.only(left: 8.0),
                                  child: Icon(
                                    Icons.remove_circle,
                                    color: Colors.red,
                                    size: 20,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                  // Add Interest Button
                  if (isEditing)
                    GestureDetector(
                      onTap: _showAddInterestDialog,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2B3F3A),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // Widget to build each statistics card
  Widget _buildStatCard({
    required String imagePath,
    required String title,
    required String value,
    required Color titleColor,
    required Color valueColor,
    required bool isImageRight,
  }) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: isImageRight
            ? [
                // Texts on the left
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontFamily: 'Lexend-Regular',
                          fontSize: 14,
                          color: titleColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        value,
                        style: TextStyle(
                          fontFamily: 'Lexend-Regular',
                          fontSize: 18,
                          color: valueColor,
                        ),
                      ),
                    ],
                  ),
                ),
                // Image on the right
                Image.asset(
                  imagePath,
                  width: 50,
                  height: 50,
                ),
              ]
            : [
                // Image on the left
                Image.asset(
                  imagePath,
                  width: 50,
                  height: 50,
                ),
                const SizedBox(width: 10),
                // Texts on the right
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontFamily: 'Lexend-Regular',
                          fontSize: 14,
                          color: titleColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        value,
                        style: TextStyle(
                          fontFamily: 'Lexend-Regular',
                          fontSize: 18,
                          color: valueColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
      ),
    );
  }

  // Widget to build the calendar card
  Widget _buildCalendarCard({
    required String title,
    required Color color,
    required Color titleColor,
  }) {
    List<Widget> generateCalendarDays() {
      List<Widget> dayWidgets = [];
      int daysInMonth = 30; // You can dynamically calculate this
      for (int day = 1; day <= daysInMonth; day++) {
        dayWidgets.add(
          Center(
            child: Text(
              '$day',
              style: const TextStyle(
                fontFamily: 'Lexend-Regular',
                fontSize: 12,
                color: Color(0xFFA6B6B3),
              ),
            ),
          ),
        );
      }
      return dayWidgets;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Lexend-Regular',
              fontSize: 16,
              color: titleColor,
            ),
          ),
          const SizedBox(height: 10),
          // Calendar Grid
          AspectRatio(
            aspectRatio: 1, // Ensures the grid is square
            child: GridView.count(
              crossAxisCount: 7,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: generateCalendarDays(),
            ),
          ),
        ],
      ),
    );
  }
Widget _buildPerformanceGraph() {
  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: const Color(0xFF2B3F3A),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Dot and "You" Label at the top
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Color(0xFF6DB697),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            const Text(
              'You',
              style: TextStyle(
                fontFamily: 'Lexend-Regular',
                fontSize: 16,
                color: Color(0xFFA6B6B3),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // Graph using fl_chart
        AspectRatio(
          aspectRatio: 1, // Ensures the graph is square
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false, // Hide vertical lines
                drawHorizontalLine: true, // Show horizontal lines
                horizontalInterval: 20, // Adjust interval as needed
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: const Color(0xFF1C2724),
                    strokeWidth: 1,
                  );
                },
              ),
              titlesData: FlTitlesData(
                show: true,
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              borderData: FlBorderData(show: false),
              minY: 0,
              maxY: 100,
              lineBarsData: [
                LineChartBarData(
                  spots: performanceData.asMap().entries.map((e) {
                    return FlSpot(e.key.toDouble(), e.value);
                  }).toList(),
                  isCurved: true,
                  color: const Color(0xff00aaff),
                  barWidth: 2,
                  dotData: FlDotData(show: false),
                  belowBarData: BarAreaData(show: false),
                ),
              ],
              lineTouchData: LineTouchData(enabled: false),
            ),
          ),
        ),
      ],
    ),
  );
}

}
