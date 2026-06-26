import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_state.dart';
import 'game_screen.dart';
import 'encyclopedia_screen.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({Key? key}) : super(key: key);

  void _launchStage(BuildContext context, GameState gameState, int stageNum) {
    gameState.startStage(stageNum);
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const GameScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Consumer<GameState>(
        builder: (context, gameState, child) {
          final unlocked = gameState.unlockedStage;
          final cardCount = gameState.unlockedAnimalIds.length;

          return Stack(
            children: [
              // 1. High-Altitude clear sky ambient backdrop
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFF0D47A1), // Deep space blue
                        Color(0xFF1976D2), // Sky blue
                        Color(0xFF81D4FA), // Horizon cyan
                      ],
                    ),
                  ),
                ),
              ),

              // Soft distant clouds decorations (Minimalist sky feel)
              Positioned(
                top: 100,
                left: -50,
                child: Icon(
                  Icons.cloud_queue_rounded,
                  size: 200,
                  color: Colors.white.withOpacity(0.06),
                ),
              ),
              Positioned(
                bottom: 120,
                right: -60,
                child: Icon(
                  Icons.cloud_rounded,
                  size: 250,
                  color: Colors.white.withOpacity(0.04),
                ),
              ),

              // 2. Safe Area Dashboard Content
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header Brand Title
                      const SizedBox(height: 20.0),
                      const Text(
                        'ANIMAL ROAD',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32.0,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 3.5,
                          shadows: [
                            Shadow(color: Color(0xFF00FFCC), blurRadius: 15.0),
                            Shadow(color: Colors.blueAccent, blurRadius: 8.0),
                          ],
                        ),
                      ),
                      const Text(
                        'DASH',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF00FFCC),
                          fontSize: 20.0,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 6.0,
                          shadows: [
                            Shadow(color: Color(0xFF00FFCC), blurRadius: 10.0),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32.0),

                      // Quick Stats Deck
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(24.0),
                          border: Border.all(color: const Color(0xFF00FFCC).withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem('STAGE UNLOCKED', '$unlocked / 50', Icons.run_circle_outlined),
                            Container(width: 1.5, height: 40, color: Colors.white24),
                            _buildStatItem('BESTIARY CARDS', '$cardCount Unlocked', Icons.collections_rounded),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24.0),

                      // Navigation Buttons Row
                      Row(
                        children: [
                          // Open Collection Screen
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF00FFCC),
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(vertical: 16.0),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
                                elevation: 4,
                              ),
                              icon: const Icon(Icons.collections_bookmark_rounded),
                              label: const Text(
                                'VIEW COLLECTION',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5, letterSpacing: 1.0),
                              ),
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (context) => const EncyclopediaScreen()),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 12.0),
                          // Wiping reset database option
                          IconButton(
                            icon: const Icon(Icons.settings_backup_restore_rounded, color: Colors.white70),
                            tooltip: 'System Hard Reset',
                            onPressed: () => _showResetDialog(context, gameState),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24.0),

                      // Level Grid Select Label
                      const Text(
                        'SELECT STAGE RUNNER',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 10.0,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 10.0),

                      // Scrollable grid list of 50 levels
                      Expanded(
                        child: GridView.builder(
                          physics: const BouncingScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            crossAxisSpacing: 12.0,
                            mainAxisSpacing: 12.0,
                          ),
                          itemCount: 50,
                          itemBuilder: (context, index) {
                            final int stageNum = index + 1;
                            final bool isLevelUnlocked = stageNum <= unlocked;

                            return GestureDetector(
                              onTap: () {
                                if (isLevelUnlocked) {
                                  _launchStage(context, gameState, stageNum);
                                } else {
                                  ScaffoldMessenger.of(context).clearSnackBars();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Stage $stageNum is Locked! Clear previous stages to unlock.'),
                                      backgroundColor: Colors.white24,
                                      duration: const Duration(seconds: 1),
                                    ),
                                  );
                                }
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                decoration: BoxDecoration(
                                  color: isLevelUnlocked
                                      ? Colors.black.withOpacity(0.5)
                                      : Colors.black.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(16.0),
                                  border: Border.all(
                                    color: isLevelUnlocked
                                        ? const Color(0xFF00FFCC).withOpacity(0.5)
                                        : Colors.white12,
                                    width: 1.5,
                                  ),
                                  boxShadow: isLevelUnlocked
                                      ? [
                                          BoxShadow(
                                            color: const Color(0xFF00FFCC).withOpacity(0.1),
                                            blurRadius: 4.0,
                                          )
                                        ]
                                      : [],
                                ),
                                child: Center(
                                  child: isLevelUnlocked
                                      ? Text(
                                          '$stageNum',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16.0,
                                          ),
                                        )
                                      : const Icon(
                                          Icons.lock_outline_rounded,
                                          color: Colors.white24,
                                          size: 16.0,
                                        ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF00FFCC), size: 20.0),
        const SizedBox(height: 6.0),
        Text(
          label,
          style: const TextStyle(color: Colors.white38, fontSize: 8.0, fontWeight: FontWeight.bold, letterSpacing: 0.8),
        ),
        const SizedBox(height: 2.0),
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontSize: 13.0, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  // System Hard Reset popup dialog
  void _showResetDialog(BuildContext context, GameState gameState) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF161A1D),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.0),
            side: const BorderSide(color: Color(0xFFFF3838), width: 1.5),
          ),
          title: Row(
            children: const [
              Icon(Icons.warning_amber_rounded, color: Color(0xFFFF3838)),
              SizedBox(width: 8.0),
              Text(
                'SYSTEM HARD RESET',
                style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold, color: Color(0xFFFF3838)),
              ),
            ],
          ),
          content: const Text(
            'This action will wipe all unlocked stages and cards collection. Do you want to proceed?',
            style: TextStyle(color: Colors.white70, fontSize: 12.0, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('ABORT', style: TextStyle(color: Colors.white38)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF3838).withOpacity(0.2),
                side: const BorderSide(color: Color(0xFFFF3838)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
              ),
              onPressed: () {
                gameState.resetProgress();
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All progress wiped out successfully.'),
                    backgroundColor: Color(0xFFFF3838),
                  ),
                );
              },
              child: const Text(
                'WIPE DATABASE',
                style: TextStyle(color: Color(0xFFFF3838), fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }
}
