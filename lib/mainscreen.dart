import 'package:flutter/material.dart';
import 'home.dart';
import 'profile.dart';
import 'roadmap.dart'; // Import the RoadmapPage

class MainScreen extends StatefulWidget {
  final bool showRoadmap;
  final String? roadmapTitle; // Make these nullable for flexibility
  final String? roadmapCategory;

  // Default Constructor for regular navigation without roadmap
  const MainScreen({
    Key? key,
  })  : showRoadmap = false,
        roadmapTitle = null,
        roadmapCategory = null,
        super(key: key);

  // Named Constructor to show roadmap with title and category
  const MainScreen.showRoadmap({
    Key? key,
    required this.roadmapTitle,
    required this.roadmapCategory,
  })  : showRoadmap = true,
        super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int? _selectedIndex; // Nullable to allow no selection for RoadmapPage
  Widget _currentPage = HomePage();

  static List<Widget> _pages = <Widget>[
    HomePage(),
    const ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    if (widget.showRoadmap && widget.roadmapTitle != null && widget.roadmapCategory != null) {
      // Show RoadmapPage without selecting any navigation tab
      _selectedIndex = -1; // No tab selected for RoadmapPage
      _currentPage = RoadmapPage(
        title: widget.roadmapTitle!, // Pass the roadmap title
        category: widget.roadmapCategory!, // Pass the roadmap category
      );
    } else {
      _selectedIndex = 0; // Default to HomePage
      _currentPage = _pages[_selectedIndex!];
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Update the selected index
      _currentPage = _pages[index]; // Change the page
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF19312F),
      body: Center(
        child: _currentPage, // Display the dynamically selected page
      ),
      bottomNavigationBar: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 1, // White separator thickness
              color: Colors.white, // White line separator
            ),
            const SizedBox(height: 5), // Space between separator and icons
            SizedBox(
              height: 60, // Smaller navbar height
              child: Theme(
                data: Theme.of(context).copyWith(
                  splashFactory: NoSplash.splashFactory, // Remove ripple effect
                ),
                child: BottomNavigationBar(
                  type: BottomNavigationBarType.fixed,
                  backgroundColor: const Color(0xFF19312F),
                  items: [
                    BottomNavigationBarItem(
                      icon: Image.asset(
                        'assets/home.png',
                        width: 20,
                        height: 20,
                        color: _selectedIndex == 0 ? Colors.white : Colors.grey,
                      ),
                      label: 'Home',
                    ),
                    BottomNavigationBarItem(
                      icon: Image.asset(
                        'assets/profile.png',
                        width: 20,
                        height: 20,
                        color: _selectedIndex == 1 ? Colors.white : Colors.grey,
                      ),
                      label: 'Profile',
                    ),
                  ],
                  currentIndex: _selectedIndex != -1 ? _selectedIndex! : 0, // Show Home as selected by default, none if Roadmap
                  selectedItemColor: Colors.white,
                  unselectedItemColor: Colors.grey,
                  onTap: _onItemTapped,
                  selectedLabelStyle: const TextStyle(
                    fontFamily: 'Lexend-Regular',
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontFamily: 'Lexend-Regular',
                  ),
                  elevation: 0,
                  showSelectedLabels: true,
                  showUnselectedLabels: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}