import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For loading assets
import 'confidence.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<String, dynamic> coursesData = {}; // Variable to store the JSON data
  List<Map<String, String>> filteredCourses = []; // List to hold filtered courses
  String searchQuery = ''; // Search query
  bool isSearching = false; // To manage search bar visibility

  @override
  void initState() {
    super.initState();
    _loadCoursesData(); // Load JSON data on initialization
  }

  // Function to load JSON data
  Future<void> _loadCoursesData() async {
    final String response = await rootBundle.loadString('assets/courses.json');
    final data = json.decode(response);
    setState(() {
      coursesData = data['categories'];
      _filterCourses(); // Initialize filtered courses
    });
  }

  // Function to filter courses based on search query
  void _filterCourses() {
    List<Map<String, String>> tempList = [];

    coursesData.forEach((category, categoryData) {
      for (var course in categoryData['courses']) {
        final String courseName = course['course_name'] ?? '';
        if (courseName.toLowerCase().contains(searchQuery.toLowerCase())) {
          tempList.add({
            'category': category,
            'courseName': courseName,
          });
        }
      }
    });

    setState(() {
      filteredCourses = tempList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF19312F), // Background color
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with underline and search bar
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: isSearching
                      ? _buildSearchBar()
                      : _buildHeader(),
                ),
                const SizedBox(height: 20),

                // Display search results if there's a query
                if (searchQuery.isNotEmpty) ...[
                  _buildSearchResults(),
                ] else ...[
                  // Dynamically build sections based on JSON data
                  ...coursesData.keys.map((category) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader(category),
                        _buildHorizontalScrollSection(context, category),
                      ],
                    );
                  }).toList(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Courses',
              style: TextStyle(
                fontFamily: 'Lexend-Bold', // Lexend Bold font
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 5), // Space between text and underline
            Container(
              width: 220, // 30px longer than text
              height: 2,
              color: Colors.white, // Underline color
            ),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.search, color: Colors.white),
          onPressed: () {
            setState(() {
              isSearching = true; // Show search bar
            });
          },
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            autofocus: true,
            onChanged: (value) {
              setState(() {
                searchQuery = value;
                _filterCourses();
              });
            },
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Search...',
              hintStyle: TextStyle(color: Colors.white54),
              border: InputBorder.none,
              prefixIcon: Icon(Icons.search, color: Colors.white),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () {
            setState(() {
              searchQuery = '';
              isSearching = false; // Hide search bar
            });
          },
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String sectionTitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          sectionTitle,
          style: const TextStyle(
            fontFamily: 'Lexend-Bold', // Lexend Bold font
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildHorizontalScrollSection(BuildContext context, String sectionTitle) {
    final List<dynamic> courses = coursesData[sectionTitle]['courses'] ?? [];

    return SizedBox(
      height: 180, // Standard height for all sections
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const CustomScrollPhysics(), // Custom inertia
        itemCount: courses.length,
        itemBuilder: (context, index) {
          final String courseName = courses[index]['course_name'] ?? '';
          return GestureDetector(
            onTap: () {
              // Navigate to ConfidencePage on tap
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ConfidencePage(
                    category: sectionTitle,
                    courseName: courseName,
                  ),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0), // Spacing between cards
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 120, // Standard height for all boxes
                    width: 120,  // Standard width for all boxes
                    decoration: BoxDecoration(
                      color: const Color(0xFF5C8A6B), // Updated color for the squares
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    courseName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Lexend-Regular', // Lexend Regular font
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchResults() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: filteredCourses.map((course) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(course['category']!),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ConfidencePage(
                      category: course['category']!,
                      courseName: course['courseName']!,
                    ),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 120,
                      width: 120,
                      decoration: BoxDecoration(
                        color: const Color(0xFF5C8A6B),
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      course['courseName']!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Lexend-Regular',
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}

// Custom scroll physics for higher inertia sensitivity
class CustomScrollPhysics extends BouncingScrollPhysics {
  const CustomScrollPhysics({ScrollPhysics? parent}) : super(parent: parent);

  @override
  CustomScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return CustomScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  double get minFlingVelocity => 1.0; // Increase sensitivity by lowering the minimum fling velocity
}
