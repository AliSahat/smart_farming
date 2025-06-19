// lib/screens/onboarding_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/onboarding_model.dart';
import '../main.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnBoardingItem> _onBoardingItems = [
    OnBoardingItem(
      title: 'Selamat Datang di Smart Farming',
      description:
          'Sistem monitoring dan kontrol otomatis untuk kolam/wadah air Anda',
      image: '💧',
    ),
    OnBoardingItem(
      title: 'Sensor Ketinggian Air',
      description:
          'Pantau level air secara real-time dengan sensor ultrasonik ESP32 yang akurat',
      image: '📏',
    ),
    OnBoardingItem(
      title: 'Kontrol Otomatis',
      description:
          'Sistem akan otomatis mengatur kran dan pembuangan berdasarkan ketinggian air terdeteksi',
      image: '🚿',
    ),
    OnBoardingItem(
      title: 'Notifikasi Level Air',
      description:
          'Dapatkan notifikasi saat ketinggian air terlalu rendah atau berlebihan',
      image: '🔔',
    ),
    OnBoardingItem(
      title: 'Mulai Monitoring Air',
      description:
          'Siap untuk memulai monitoring ketinggian air otomatis Anda?',
      image: '🌊',
      buttonText: 'Mulai Aplikasi',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            if (_currentPage < _onBoardingItems.length - 1)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Align(
                  alignment: Alignment.topRight,
                  child: TextButton(
                    onPressed: _completeOnBoarding,
                    child: Text(
                      'Lewati',
                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
                    ),
                  ),
                ),
              )
            else
              const SizedBox(height: 56),

            // Page view
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _onBoardingItems.length,
                itemBuilder: (context, index) {
                  return _buildOnBoardingPage(_onBoardingItems[index]);
                },
              ),
            ),

            // Bottom section
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // Page indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _onBoardingItems.length,
                      (index) => _buildPageIndicator(index),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Navigation buttons
                  if (_currentPage < _onBoardingItems.length - 1)
                    Row(
                      children: [
                        if (_currentPage > 0)
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _previousPage,
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                side: BorderSide(color: Colors.blue[600]!),
                              ),
                              child: const Text('Kembali'),
                            ),
                          ),
                        if (_currentPage > 0) const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _nextPage,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[600],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Lanjut'),
                          ),
                        ),
                      ],
                    )
                  else
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _completeOnBoarding,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[600],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          _onBoardingItems[_currentPage].buttonText ?? 'Mulai',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOnBoardingPage(OnBoardingItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Water level visualization container
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue[50]!, Colors.blue[100]!],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.blue[200]!, width: 2),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Water level indicator berdasarkan halaman
                Positioned(
                  bottom: 20,
                  child: Container(
                    width: 160,
                    height: _getWaterHeight(_currentPage),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue[300]!, Colors.blue[500]!],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(80),
                        bottomRight: Radius.circular(80),
                      ),
                    ),
                  ),
                ),
                // Sensor indicator (ultrasonic sensor)
                if (_currentPage == 1)
                  Positioned(
                    top: 30,
                    child: Container(
                      width: 40,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.grey[700],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Center(
                        child: Text(
                          'HC-SR04',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 6,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                // Main emoji/icon
                Center(
                  child: Text(item.image, style: const TextStyle(fontSize: 60)),
                ),
                // Level indicators
                if (_currentPage > 0)
                  Positioned(
                    right: 10,
                    top: 40,
                    child: Column(
                      children: [
                        _buildLevelIndicator('MAX', Colors.red),
                        const SizedBox(height: 20),
                        _buildLevelIndicator('NORMAL', Colors.green),
                        const SizedBox(height: 20),
                        _buildLevelIndicator('MIN', Colors.orange),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 48),

          // Title
          Text(
            item.title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // Description
          Text(
            item.description,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Helper untuk mendapatkan tinggi air berdasarkan halaman
  double _getWaterHeight(int page) {
    switch (page) {
      case 0:
        return 60; // Welcome - medium level
      case 1:
        return 40; // Sensor - low level untuk show detection
      case 2:
        return 80; // Control - high level
      case 3:
        return 100; // Notification - full level
      case 4:
        return 70; // Start - optimal level
      default:
        return 60;
    }
  }

  Widget _buildLevelIndicator(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 8,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildPageIndicator(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: _currentPage == index ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: _currentPage == index ? Colors.blue[600] : Colors.grey[300],
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  void _nextPage() {
    if (_currentPage < _onBoardingItems.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _completeOnBoarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const SmartFarmingMainApp()),
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
