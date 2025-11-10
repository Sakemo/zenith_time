import 'package:flutter/material.dart';
import 'package:zenith_time/features/projects/ui/projects_screen.dart';
import 'package:zenith_time/features/tracker/ui/tracker_screen.dart';
import 'package:zenith_time/app/theme/app_theme.dart';

enum AppScreen { tracker, projects }

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  AppScreen _currentScreen = AppScreen.tracker;

  Widget _buildCurrentScreen() {
    switch (_currentScreen) {
      case AppScreen.tracker:
        return const TrackerScreen();
      case AppScreen.projects:
        return const ProjectsScreen();
    }
  }

  Widget _buildSidebar() {
    return Container(
      width: 80,
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      decoration: BoxDecoration(
        color: const Color(0xFF1e1e1e),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        children: [
          IconButton(
            icon: Icon(
              Icons.timer_outlined,
              color: _currentScreen == AppScreen.tracker
                  ? Colors.white
                  : Colors.grey,
              size: 32,
            ),
            onPressed: () => setState(() => _currentScreen = AppScreen.tracker),
          ),
          const SizedBox(height: 16),
          IconButton(
            icon: Icon(
              Icons.folder_outlined,
              color: _currentScreen == AppScreen.projects
                  ? Colors.white
                  : Colors.grey,
              size: 32,
            ),
            onPressed: () =>
                setState(() => _currentScreen = AppScreen.projects),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.adwaitaHeaderBar,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            _buildSidebar(),
            const SizedBox(width: 16),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.adwaitaBackground,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: _buildCurrentScreen(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
