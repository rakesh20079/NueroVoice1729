import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/screening_state.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/bottom_nav_bar.dart';
import 'home_screen.dart';
import 'voice_recording_screen.dart';
import 'analysis_pipeline_screen.dart';
import 'screening_result_screen.dart';
import 'analysis_detail_screen.dart';
import 'history_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  // 0: Home, 1: Record, 2: Pipeline, 3: Result, 4: History, 5: Detail
  int _activeViewIndex = 0;
  int _previousViewIndex = 0;

  void _navigateTo(int index) {
    setState(() {
      _previousViewIndex = _activeViewIndex;
      _activeViewIndex = index;
    });

    final session = context.read<ScreeningSessionProvider>();
    // Synchronize bottom nav bar index (0: Home, 1: Record, 2: Results, 3: History)
    if (index == 0) {
      session.setTabIndex(0);
    } else if (index == 1 || index == 2) {
      session.setTabIndex(1); // Pipeline loading belongs under Record flow
    } else if (index == 3) {
      session.setTabIndex(2); // Results is tab 2
    } else if (index == 4) {
      session.setTabIndex(3); // History is tab 3
    } else if (index == 5) {
      session.setTabIndex(_previousViewIndex == 4 ? 3 : 2);
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<ScreeningSessionProvider>();

    Widget currentBody;

    switch (_activeViewIndex) {
      case 0:
        currentBody = HomeScreen(
          onStartScreening: () => _navigateTo(1),
        );
        break;
      case 1:
        currentBody = VoiceRecordingScreen(
          onCancel: () => _navigateTo(0),
          onProceedToAnalysis: () => _navigateTo(2),
        );
        break;
      case 2:
        currentBody = AnalysisPipelineScreen(
          onCancel: () => _navigateTo(0),
          onComplete: () => _navigateTo(3),
        );
        break;
      case 3:
        currentBody = ScreeningResultScreen(
          onViewDetail: () => _navigateTo(5),
          onRetake: () {
            session.resetRecording();
            _navigateTo(1);
          },
        );
        break;
      case 4:
        currentBody = HistoryScreen(
          onSelectHistoryItem: (item) {
            session.selectHistoryItem(item);
            _navigateTo(5);
          },
          onStartNewScreening: () => _navigateTo(1),
        );
        break;
      case 5:
        currentBody = AnalysisDetailScreen(
          onBack: () {
            // Return to where we came from (either Results or History)
            _navigateTo(_previousViewIndex == 4 ? 4 : 3);
          },
        );
        break;
      default:
        currentBody = HomeScreen(
          onStartScreening: () => _navigateTo(1),
        );
    }

    return Scaffold(
      // Top navigation bar appears ONLY on Home screen with "NeuroVoice" centered
      appBar: _activeViewIndex == 0
          ? const CustomAppBar(
              title: "NeuroVoice",
              centerTitle: true,
            )
          : null,
      body: SafeArea(
        top: _activeViewIndex != 0, // Safe status bar padding when no top app bar
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: currentBody,
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: session.currentTabIndex,
        onItemSelected: (index) {
          // Bottom bar items: 0 -> Home, 1 -> Record, 2 -> Results, 3 -> History
          if (index == 0) _navigateTo(0);
          if (index == 1) _navigateTo(1);
          if (index == 2) _navigateTo(3);
          if (index == 3) _navigateTo(4);
        },
      ),
    );
  }
}
