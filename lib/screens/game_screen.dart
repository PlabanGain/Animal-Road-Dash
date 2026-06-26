import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/game_state.dart';
import '../models/animal.dart';
import '../widgets/road_painter.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final TextEditingController _voiceInputController = TextEditingController();
  Map<String, ui.Image> _animalImages = {};
  bool _imagesLoaded = false;

  @override
  void initState() {
    super.initState();
    // Continuous loop for road movement lines & rendering ticks
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
    _loadAllAnimalImages();
  }

  Future<void> _loadAllAnimalImages() async {
    final Map<String, ui.Image> loaded = {};
    for (final animal in allAnimals) {
      try {
        final data = await rootBundle.load(animal.assetPath);
        final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
        final frame = await codec.getNextFrame();
        loaded[animal.id] = frame.image;
      } catch (e) {
        debugPrint('Error loading image for ${animal.id}: $e');
      }
    }
    if (mounted) {
      setState(() {
        _animalImages = loaded;
        _imagesLoaded = true;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _voiceInputController.dispose();
    super.dispose();
  }

  // Handle manual mock text submission (Microphone sound input)
  void _submitVoiceInput(GameState gameState) async {
    final text = _voiceInputController.text.trim();
    if (text.isEmpty) return;
    _voiceInputController.clear();
    FocusScope.of(context).unfocus();

    final isMatch = await gameState.processVoiceInput(text);
    if (!mounted) return;

    if (isMatch) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vocal recognition matched! Shapeshifted successfully!'),
          backgroundColor: Color(0xFF00FF88),
          duration: Duration(milliseconds: 1200),
        ),
      );
    } else {
      // No notification on failure as requested!
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Consumer<GameState>(
        builder: (context, gameState, child) {
          if (!gameState.isPlaying && gameState.isFinished) {
            // Show Victory Screen Overlay
            return _buildVictoryScreen(context, gameState);
          }

          final activeStage = gameState.activeStage;

          return Stack(
            children: [
              // 1. Core 3D Road Canvas (Animated)
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Positioned.fill(
                    child: CustomPaint(
                      painter: RoadPainter(
                        wallProgress: gameState.currentWallProgress,
                        currentWallIndex: gameState.currentWallIndex,
                        activeStage: activeStage,
                        runnerShape: gameState.runnerShape,
                        isCrashed: gameState.isCrashed,
                        animationTime: _animationController.value,
                        animalImages: _animalImages,
                      ),
                    ),
                  );
                },
              ),

              // 2. HUD Top Control Bar
              Positioned(
                top: 40.0,
                left: 16.0,
                right: 16.0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Back to Menu
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                          onPressed: () {
                            gameState.exitGame();
                            Navigator.of(context).pop();
                          },
                        ),
                        // Level Indicator
                        Column(
                          children: [
                            Text(
                              'STAGE ${gameState.currentStageIndex}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22.0,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                              ),
                            ),
                            Text(
                              'Speed: ${activeStage.speedScale.toStringAsFixed(1)}x',
                              style: const TextStyle(
                                color: Color(0xFF00FFCC),
                                fontSize: 11.0,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ],
                        ),
                        // Pause Button
                        IconButton(
                          icon: Icon(
                            gameState.isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                            color: Colors.white,
                            size: 28.0,
                          ),
                          onPressed: () => gameState.togglePause(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12.0),
                    // Progress Tracker Line
                    Row(
                      children: [
                        Text(
                          'Wall ${gameState.currentWallIndex + 1}/${activeStage.targetAnimals.length}',
                          style: const TextStyle(color: Colors.white60, fontSize: 11.0),
                        ),
                        const SizedBox(width: 8.0),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4.0),
                            child: LinearProgressIndicator(
                              value: (gameState.currentWallIndex + 1) / activeStage.targetAnimals.length,
                              backgroundColor: Colors.white12,
                              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00FFCC)),
                              minHeight: 6.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    // Score
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'SCORE: ${gameState.score}',
                          style: const TextStyle(color: Colors.white70, fontSize: 13.0, fontFamily: 'monospace'),
                        ),
                        Text(
                          'HI: ${gameState.highScore}',
                          style: const TextStyle(color: Colors.white30, fontSize: 13.0, fontFamily: 'monospace'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // 3. Middle Stage Crash Vignette (Non-blocking)
              if (gameState.isCrashed)
                Positioned.fill(
                  child: IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.red.withOpacity(0.5 + 0.3 * sin(_animationController.value * 2 * pi * 5)),
                          width: 12.0,
                        ),
                        color: Colors.red.withOpacity(0.08),
                      ),
                    ),
                  ),
                ),

              // 4. In-Game Pause Screen Overlay
              if (gameState.isPaused)
                Positioned.fill(
                  child: Container(
                    color: Colors.black87,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'SIMULATION PAUSED',
                            style: TextStyle(color: Colors.white, fontSize: 24.0, fontWeight: FontWeight.bold, letterSpacing: 2.0),
                          ),
                          const SizedBox(height: 20.0),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00FFCC),
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
                            ),
                            icon: const Icon(Icons.play_arrow_rounded),
                            label: const Text('RESUME RUN', style: TextStyle(fontWeight: FontWeight.bold)),
                            onPressed: () => gameState.togglePause(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // 5. Dynamic Voice/Phonetic Input Control Panel (At the Bottom)
              if (!gameState.isPaused && !gameState.isFinished)
                Positioned(
                  bottom: 24.0,
                  left: 16.0,
                  right: 16.0,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [


                      // Voice input actions
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Left spacing to center the mic button
                          const SizedBox(width: 50.0),
                          
                          // Centered Speech mic activator button
                          Expanded(
                            child: Center(
                              child: GestureDetector(
                                onTapDown: (_) => gameState.startVoiceListening(),
                                onTapUp: (_) {
                                  final activeStage = gameState.activeStage;
                                  final wallIndex = gameState.currentWallIndex.clamp(0, activeStage.targetAnimals.length - 1);
                                  final targetAnimal = activeStage.targetAnimals[wallIndex];
                                  gameState.processVoiceInput(targetAnimal.vocalPhonetics[0]);
                                },
                                onTapCancel: () {
                                  final activeStage = gameState.activeStage;
                                  final wallIndex = gameState.currentWallIndex.clamp(0, activeStage.targetAnimals.length - 1);
                                  final targetAnimal = activeStage.targetAnimals[wallIndex];
                                  gameState.processVoiceInput(targetAnimal.vocalPhonetics[0]);
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: 64,
                                  height: 64,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: gameState.isListening ? Colors.red : const Color(0xFF00FFCC),
                                    boxShadow: [
                                      BoxShadow(
                                        color: (gameState.isListening ? Colors.red : const Color(0xFF00FFCC)).withOpacity(0.4),
                                        blurRadius: gameState.isListening ? 20 : 10,
                                        spreadRadius: gameState.isListening ? 4 : 1,
                                      )
                                    ],
                                  ),
                                  child: gameState.isListening
                                      ? Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: List.generate(5, (index) {
                                            final double amp = gameState.micAmplitude;
                                            final double barHeight = 8.0 + (28.0 * amp * (0.3 + 0.7 * sin(index * 45)));
                                            return Container(
                                              margin: const EdgeInsets.symmetric(horizontal: 2.0),
                                              width: 3.5,
                                              height: barHeight,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(2.0),
                                              ),
                                            );
                                          }),
                                        )
                                      : const Icon(
                                          Icons.mic_none_rounded,
                                          color: Colors.black,
                                          size: 30.0,
                                        ),
                                ),
                              ),
                            ),
                          ),
                          
                          // Simulation Cheat button for easy passing
                          GestureDetector(
                            onTap: () {
                              gameState.simulateSpeechPass();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Auto-passed shape cutout (Mocked speech match).'),
                                  backgroundColor: Color(0xFF00FFCC),
                                  duration: Duration(milliseconds: 1000),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.15),
                                border: Border.all(color: Colors.blueAccent),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'AUTO',
                                style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 10),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }



  // Beautiful Victory Overlay Screen when stage is cleared
  Widget _buildVictoryScreen(BuildContext context, GameState gameState) {
    // Determine unlocked animal (corresponds to currentStageIndex)
    final int stageIndex = (gameState.currentStageIndex - 1).clamp(0, 49);
    final Animal unlockedAnimal = allAnimals[stageIndex];

    return Scaffold(
      backgroundColor: Colors.black87,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            // Glassmorphic Victory card
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.04),
                borderRadius: BorderRadius.circular(30.0),
                border: Border.all(color: const Color(0xFF00FFCC), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00FFCC).withOpacity(0.15),
                    blurRadius: 30,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Animated glowing trophy
                  const Icon(
                    Icons.emoji_events_rounded,
                    color: Colors.amber,
                    size: 80.0,
                  ),
                  const SizedBox(height: 12.0),
                  const Text(
                    'STAGE COMPLETE!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28.0,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    'Stage ${gameState.currentStageIndex} cleared successfully!',
                    style: const TextStyle(color: Colors.white60, fontSize: 13.0),
                  ),
                  const SizedBox(height: 24.0),

                  const Text(
                    'NEW TRADING CARD UNLOCKED',
                    style: TextStyle(
                      color: Color(0xFF00FFCC),
                      fontSize: 12.0,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12.0),

                  // Showcase unlocked Pokemon Card Style preview
                  _VictoryCardWidget(unlockedAnimal: unlockedAnimal),

                  const SizedBox(height: 32.0),

                  // Actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // Return to Menu
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text(
                          'MAIN MENU',
                          style: TextStyle(color: Colors.white54, fontSize: 13.0, fontWeight: FontWeight.bold),
                        ),
                      ),
                      // Continue to next stage
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00FFCC),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                        ),
                        onPressed: () {
                          if (gameState.currentStageIndex < 50) {
                            gameState.startStage(gameState.currentStageIndex + 1);
                          } else {
                            Navigator.of(context).pop();
                          }
                        },
                        child: Text(
                          gameState.currentStageIndex < 50 ? 'NEXT STAGE' : 'DONE',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.0),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Beautiful rotating sweep-gradient Pokemon-style Victory Card preview widget
class _VictoryCardWidget extends StatefulWidget {
  final Animal unlockedAnimal;

  const _VictoryCardWidget({required this.unlockedAnimal, Key? key}) : super(key: key);

  @override
  State<_VictoryCardWidget> createState() => _VictoryCardWidgetState();
}

class _VictoryCardWidgetState extends State<_VictoryCardWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22.0),
            gradient: SweepGradient(
              center: Alignment.center,
              colors: const [
                Colors.red, Colors.orange, Colors.yellow, 
                Colors.green, Colors.blue, Colors.purple, Colors.red
              ],
              transform: GradientRotation(_controller.value * 2 * pi),
            ),
            boxShadow: [
              BoxShadow(
                color: widget.unlockedAnimal.gradientColors[0].withOpacity(0.5),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          padding: const EdgeInsets.all(4.0), // rainbow border width
          child: Container(
            width: 170,
            height: 240,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.9),
              borderRadius: BorderRadius.circular(18.0),
              image: DecorationImage(
                image: AssetImage('assets/images/card_${widget.unlockedAnimal.id}.png'),
                fit: BoxFit.cover,
                opacity: 0.85,
              ),
            ),
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        widget.unlockedAnimal.name,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13.0,
                          shadows: [Shadow(color: Colors.black45, blurRadius: 4.0)],
                        ),
                      ),
                    ),
                    const Icon(Icons.star, color: Colors.yellowAccent, size: 12.0),
                  ],
                ),
                const SizedBox(height: 4.0),
                Text(
                  widget.unlockedAnimal.scientificName,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontStyle: FontStyle.italic,
                    fontSize: 7.5,
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Transform.translate(
                      offset: Offset(0, sin(_controller.value * 2 * pi) * 4.0),
                      child: Transform.scale(
                        scale: 1.0 + sin(_controller.value * 2 * pi) * 0.05,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Glowing background smooth silhouette outline
                            SizedBox(
                              width: 60,
                              height: 60,
                              child: CustomPaint(
                                painter: _SimpleSilhouettePainter(
                                  points: widget.unlockedAnimal.silhouettePoints,
                                  color: widget.unlockedAnimal.gradientColors[0],
                                ),
                              ),
                            ),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(25.0),
                              child: Container(
                                width: 50.0,
                                height: 50.0,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF7F5F0),
                                  image: DecorationImage(
                                    image: AssetImage('assets/images/bg_${widget.unlockedAnimal.id}.png'),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                padding: const EdgeInsets.all(3.0),
                                child: Image.asset(
                                  widget.unlockedAnimal.assetPath,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // Core status
                Container(
                  padding: const EdgeInsets.all(4.0),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Rarity: ${widget.unlockedAnimal.rarity.toStringAsFixed(1)} ★',
                        style: const TextStyle(color: Colors.white, fontSize: 8.0, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2.0),
                      Text(
                        widget.unlockedAnimal.vocalClue,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white70, fontSize: 7.0),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Simple custom painter to draw smooth animal silhouette behind emoji
class _SimpleSilhouettePainter extends CustomPainter {
  final List<Offset> points;
  final Color color;

  _SimpleSilhouettePainter({required this.points, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;
    final Path path = Path();
    final double width = size.width;
    final double height = size.height;
    final List<Offset> scaledPoints = points.map((p) => Offset(p.dx * width, p.dy * height)).toList();

    path.moveTo(scaledPoints[0].dx, scaledPoints[0].dy);
    final int len = scaledPoints.length;
    for (int i = 0; i < len; i++) {
      final Offset p0 = scaledPoints[i == 0 ? len - 1 : i - 1];
      final Offset p1 = scaledPoints[i];
      final Offset p2 = scaledPoints[(i + 1) % len];
      final Offset p3 = scaledPoints[(i + 2) % len];
      const double tension = 0.5;
      final Offset cp1 = p1 + (p2 - p0) * (tension / 3.0);
      final Offset cp2 = p2 - (p3 - p1) * (tension / 3.0);
      path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, p2.dx, p2.dy);
    }
    path.close();

    final Paint fillPaint = Paint()
      ..color = color.withOpacity(0.25)
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    final Paint borderPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _SimpleSilhouettePainter oldDelegate) {
    return oldDelegate.points != points || oldDelegate.color != color;
  }
}
