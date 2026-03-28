import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  // Animation values
  double _logoOpacity = 0.0;
  double _logoScale = 0.5;
  Offset _logoOffset = Offset.zero;
  double _textOpacity = 0.0;
  double _taglineOpacity = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _runAnimation();
  }

  Future<void> _runAnimation() async {
    // Phase 1: Logo fades in and scales up
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    setState(() {
      _logoOpacity = 1.0;
      _logoScale = 1.0;
    });

    // Phase 2: Logo slides UP
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() {
      _logoOffset = const Offset(0.0, -0.15);
    });

    // Phase 3: App name appears
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() {
      _textOpacity = 1.0;
    });

    // Phase 4: Tagline appears
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() {
      _taglineOpacity = 1.0;
    });

    // Phase 5: Navigate to dashboard
    await Future.delayed(const Duration(milliseconds: 1200));
    if (mounted) {
      context.go('/');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0D1117) : const Color(0xFFF8FAFC),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            AnimatedSlide(
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeInOutCubic,
              offset: _logoOffset,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 800),
                opacity: _logoOpacity,
                child: AnimatedScale(
                  duration: const Duration(milliseconds: 800),
                  scale: _logoScale,
                  curve: Curves.elasticOut,
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      // Only add BoxShadow without shape/color so it glows but doesn't fill
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withValues(alpha: 0.4),
                          blurRadius: 50,
                          spreadRadius: 10,
                        ),
                        BoxShadow(
                          color: primaryColor.withValues(alpha: 0.2),
                          blurRadius: 80,
                          spreadRadius: 20,
                        ),
                      ],
                    ),
                    // Transparent logo
                    child: Image.asset(
                      'app logo/NexBloom transparent1.png',
                      width: 140,
                      height: 140,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),

            // App Name (appears below logo)
            AnimatedOpacity(
              duration: const Duration(milliseconds: 600),
              opacity: _textOpacity,
              child: AnimatedSlide(
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOutCubic,
                offset: _textOpacity == 0.0
                    ? const Offset(0.0, 0.3)
                    : Offset.zero,
                child: Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    'NexBloom',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : const Color(0xFF1a1a2e),
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              ),
            ),

            // Tagline
            AnimatedOpacity(
              duration: const Duration(milliseconds: 600),
              opacity: _taglineOpacity,
              child: AnimatedSlide(
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOutCubic,
                offset: _taglineOpacity == 0.0
                    ? const Offset(0.0, 0.5)
                    : Offset.zero,
                child: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'A Student Companion App',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: isDark ? Colors.white70 : const Color(0xFF64748B),
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
