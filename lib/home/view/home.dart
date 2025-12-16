import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:safe_zone/alerts/alerts.dart';
import 'package:safe_zone/profile/profile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final PageController _pageController = PageController();

  final List<Widget> _pages = [
    const Center(child: Text('Home')),
    const AlertsScreen(),
    const Center(child: Text('Guide')),
    const Center(child: Text('Profile')),
  ];

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
    _onItemTapped(index);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: const [
          Center(child: Text('Map Screen')),
          Center(child: Text('Alerts Screen')),
          Center(child: Text('Guide Screen')),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onPageChanged,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(LineIcons.map), label: 'Map'),
          BottomNavigationBarItem(
            icon: Icon(LineIcons.bell),
            label: 'Alerts',
          ),
          BottomNavigationBarItem(
            icon: Icon(LineIcons.alternateShield),
            label: 'Guide',
          ),

          BottomNavigationBarItem(
            icon: Icon(LineIcons.cog),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
