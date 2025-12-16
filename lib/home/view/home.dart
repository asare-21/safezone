import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:line_icons/line_icons.dart';
import 'package:safe_zone/alerts/alerts.dart';
import 'package:safe_zone/home/home.dart';
import 'package:safe_zone/guide/guide.dart';
import 'package:safe_zone/profile/profile.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BottomNavigationCubit(),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatefulWidget {
  const _HomeView();

  @override
  State<_HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<_HomeView> {
  final PageController _pageController = PageController();

  final List<Widget> _pages = [
    const Center(child: Text('Home')),
    const AlertsScreen(),
    const GuideScreen(),
    const ProfileScreen(),
  ];

  void _onPageChanged(int index) {
    context.read<BottomNavigationCubit>().navigateToTab(index);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BottomNavigationCubit, BottomNavigationState>(
      listener: (context, state) {
        // Only jump to page if it's different from the current page
        // to avoid infinite loops when swiping
        if (_pageController.hasClients &&
            _pageController.page?.round() != state.index) {
          _pageController.jumpToPage(state.index);
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: PageView(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            children: _pages,
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: state.index,
            onTap: _onPageChanged,
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(LineIcons.home),
                label: 'Map',
              ),
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
      },
    );
  }
}
