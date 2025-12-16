import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class AuthenticationScreen extends StatefulWidget {
  const AuthenticationScreen({super.key});

  @override
  State<AuthenticationScreen> createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen> {
  PageController pageController = PageController();
  int _currentPage = 0;

  List<AuthenticationPage> get _pages => [
    AuthenticationPage(
      imagePath: 'assets/images/welcome.jpg',
      title: 'Welcome to SafeZone',
      description:
          'Your safety is our priority. Stay connected with your trusted contacts.',
      icon: Icons.shield_outlined,
    ),
    AuthenticationPage(
      imagePath: 'assets/images/real-time.jpg',
      title: 'Real-time Location',
      description:
          'Share your location with loved ones in real-time for added security.',
      icon: Icons.location_on_outlined,
    ),
    AuthenticationPage(
      imagePath: 'assets/images/emergency.jpg',
      title: 'Instant Emergency Alerts',
      description:
          'Send immediate alerts to emergency contacts with just one tap.',
      icon: Icons.emergency_outlined,
    ),
  ];

  @override
  void initState() {
    super.initState();
    pageController.addListener(() {
      setState(() {
        _currentPage = pageController.page?.round() ?? 0;
      });
    });
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = _currentPage == _pages.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header with skip button
              if (!isLastPage) ...[
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      pageController.animateToPage(
                        _pages.length - 1,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                      );
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                    ),
                    child: const Text(
                      'Skip',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
              ] else
                const SizedBox(height: 40),

              // Page content
              Expanded(
                flex: 3,
                child: PageView.builder(
                  controller: pageController,
                  onPageChanged: (value) => setState(() {
                    _currentPage = value;
                  }),
                  itemBuilder: (context, index) {
                    final page = _pages[index];
                    return _authenticationPageView(context, page, index);
                  },
                  itemCount: _pages.length,
                ),
              ),

              // Progress indicator with page numbers
              _buildPageIndicator(),
              const SizedBox(height: 24),

              // Action buttons
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ShadButton(
                      onPressed: isLastPage
                          ? () {
                              // Navigate to auth
                            }
                          : () {
                              pageController.nextPage(
                                duration: const Duration(milliseconds: 400),
                                curve: Curves.easeInOut,
                              );
                            },

                      child: Text(
                        isLastPage ? 'Get Started' : 'Continue',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPageIndicator() {
    final theme = Theme.of(context);

    return Column(
      children: [
        DotsIndicator(
          dotsCount: _pages.length,
          position: _currentPage.toDouble(),
          decorator: DotsDecorator(
            size: const Size.square(6),
            activeSize: const Size(24, 6),
            activeShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(3),
            ),
            activeColor: theme.colorScheme.primary,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.16),
            spacing: const EdgeInsets.symmetric(horizontal: 4),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          '${_currentPage + 1}/${_pages.length}',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }
}

class AuthenticationPage {
  AuthenticationPage({
    required this.imagePath,
    required this.title,
    required this.description,
    required this.icon,
  });
  final String imagePath;
  final String title;
  final String description;
  final IconData icon;
}

Widget _authenticationPageView(
  BuildContext context,
  AuthenticationPage page,
  int index,
) {
  final theme = Theme.of(context);

  return SingleChildScrollView(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Image with elegant border
        Container(
          height: 260,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: theme.dividerColor.withValues(alpha: 0.2),
            ),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.04),
                blurRadius: 32,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(23),
            child: Image.asset(
              page.imagePath,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 56),

        // Title with elegant typography
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            page.title,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Description with optimal line length
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            page.description,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontSize: 16,
              height: 1.6,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ),
        const SizedBox(height: 40),
      ],
    ),
  );
}
