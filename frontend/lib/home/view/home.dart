import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:line_icons/line_icons.dart';
import 'package:safe_zone/alerts/alerts.dart';
import 'package:safe_zone/guide/guide.dart';
import 'package:safe_zone/home/home.dart';
import 'package:safe_zone/map/map.dart';
import 'package:safe_zone/profile/models/user_score_model.dart';
import 'package:safe_zone/profile/profile.dart';
import 'package:safe_zone/profile/repository/incident_proximity_service.dart';
import 'package:safe_zone/profile/repository/scoring_repository.dart';
import 'package:safe_zone/profile/view/confirmation_result_dialog.dart';
import 'package:safe_zone/profile/view/incident_confirmation_dialog.dart';
import 'package:safe_zone/utils/api_config.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _HomeView();
  }
}

class _HomeView extends StatefulWidget {
  const _HomeView();

  @override
  State<_HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<_HomeView> {
  final PageController _pageController = PageController();
  IncidentProximityService? _proximityService;
  ScoringRepository? _scoringRepository;
  String? _deviceId;

  final List<Widget> _pages = [
    const MapScreen(),
    const AlertsScreen(),
    const GuideScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _initializeProximityMonitoring();
  }

  Future<void> _initializeProximityMonitoring() async {
    try {
      // Get device ID
      _deviceId = await _getDeviceId();
      
      // Initialize scoring repository
      final baseUrl = ApiConfig.getBaseUrl();
      _scoringRepository = ScoringRepository(baseUrl: baseUrl);
      
      // Initialize proximity service
      _proximityService = IncidentProximityService();
      
      // Register callback for nearby incidents
      _proximityService!.onNearbyIncident(_handleNearbyIncident);
      
      // Start monitoring
      await _proximityService!.startMonitoring(
        repository: _scoringRepository!,
        deviceId: _deviceId!,
        radiusKm: 0.5, // 500 meters
      );
    } catch (e) {
      debugPrint('Error initializing proximity monitoring: $e');
    }
  }

  Future<String> _getDeviceId() async {
    final deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      return androidInfo.id;
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      return iosInfo.identifierForVendor ?? 'unknown';
    }
    return 'unknown';
  }

  Future<void> _handleNearbyIncident(NearbyIncident incident) async {
    if (!mounted) return;

    // Show confirmation dialog
    final confirmed = await IncidentConfirmationDialog.show(context, incident);
    
    if (confirmed == true && mounted) {
      // User confirmed the incident
      try {
        final response = await _scoringRepository!.confirmIncident(
          incident.id,
          _deviceId!,
        );
        
        if (mounted) {
          // Show success dialog with points earned
          await ConfirmationResultDialog.show(context, response);
        }
      } catch (e) {
        if (mounted) {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error confirming incident: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _onPageChanged(int index) {
    context.read<BottomNavigationCubit>().navigateToTab(index);
  }

  @override
  void dispose() {
    _proximityService?.dispose();
    _scoringRepository?.dispose();
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
