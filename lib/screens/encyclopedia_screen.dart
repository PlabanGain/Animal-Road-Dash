import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_state.dart';
import '../models/animal.dart';

class EncyclopediaScreen extends StatelessWidget {
  const EncyclopediaScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'BESTIARY CARDS',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5, fontSize: 16.0),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Consumer<GameState>(
        builder: (context, gameState, child) {
          final unlockedCount = gameState.unlockedAnimalIds.length;
          final totalCount = allAnimals.length;
          final percent = (unlockedCount / totalCount * 100).toStringAsFixed(0);

          return Column(
            children: [
              // Unlocked Stats banner
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(16.0),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'COLLECTION COMPLETION',
                            style: TextStyle(color: Colors.white38, fontSize: 9.0, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                          ),
                          const SizedBox(height: 4.0),
                          Text(
                            '$unlockedCount / $totalCount Animals Unlocked',
                            style: const TextStyle(color: Colors.white, fontSize: 14.0, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00FFCC).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20.0),
                          border: Border.all(color: const Color(0xFF00FFCC)),
                        ),
                        child: Text(
                          '$percent%',
                          style: const TextStyle(color: Color(0xFF00FFCC), fontWeight: FontWeight.bold, fontSize: 13.0),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Scrollable Grid of 50 Trading Cards
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.72,
                    crossAxisSpacing: 16.0,
                    mainAxisSpacing: 16.0,
                  ),
                  itemCount: allAnimals.length,
                  itemBuilder: (context, index) {
                    final animal = allAnimals[index];
                    final isUnlocked = gameState.unlockedAnimalIds.contains(animal.id);

                    if (isUnlocked) {
                      return _UnlockedCardItem(animal: animal);
                    } else {
                      return _LockedCardItem(animal: animal);
                    }
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ----------------- LOCKED CARD (With Shake Animation) -----------------
class _LockedCardItem extends StatefulWidget {
  final Animal animal;

  const _LockedCardItem({required this.animal, Key? key}) : super(key: key);

  @override
  State<_LockedCardItem> createState() => _LockedCardItemState();
}

class _LockedCardItemState extends State<_LockedCardItem> with SingleTickerProviderStateMixin {
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    // Shake curve back and forth
    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 12.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 12.0, end: -10.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -10.0, end: 8.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 8.0, end: -6.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -6.0, end: 4.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 4.0, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _triggerLockShake() {
    _shakeController.forward(from: 0.0);
    // Show quick dialog reminder
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Card Locked! Encounter and clear "${widget.animal.name}" in stages to unlock.'),
        backgroundColor: Colors.white24,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_shakeAnimation.value, 0),
          child: child,
        );
      },
      child: GestureDetector(
        onTap: _triggerLockShake,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.02),
            borderRadius: BorderRadius.circular(20.0),
            border: Border.all(color: Colors.white12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.03),
                ),
                child: const Text(
                  '?',
                  style: TextStyle(
                    color: Colors.white30,
                    fontSize: 48.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12.0),
              const Text(
                'LOCKED CARD',
                style: TextStyle(
                  color: Colors.white24,
                  fontSize: 10.0,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ----------------- UNLOCKED CARD (Pokemon Style) -----------------
class _UnlockedCardItem extends StatefulWidget {
  final Animal animal;

  const _UnlockedCardItem({required this.animal, Key? key}) : super(key: key);

  @override
  State<_UnlockedCardItem> createState() => _UnlockedCardItemState();
}

class _UnlockedCardItemState extends State<_UnlockedCardItem> with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    // Shimmering rotating gradient for Pokemon Holo effect
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  void _openCardDetail(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return _TradingCardDetailDialog(animal: widget.animal);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final rarity = widget.animal.rarityCategory;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () => _openCardDetail(context),
        child: AnimatedScale(
          scale: _isHovered ? 1.05 : 1.0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          child: AnimatedBuilder(
            animation: _rotationController,
            builder: (context, child) {
              Gradient borderGradient;
              List<BoxShadow> borderShadow;

              switch (rarity) {
                case AnimalRarity.common:
                  borderGradient = LinearGradient(
                    colors: [Colors.grey.shade400, Colors.grey.shade600],
                  );
                  borderShadow = [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.15),
                      blurRadius: _isHovered ? 8.0 : 4.0,
                      spreadRadius: _isHovered ? 1.0 : 0.5,
                    )
                  ];
                  break;
                case AnimalRarity.uncommon:
                  borderGradient = const LinearGradient(
                    colors: [Color(0xFF38EF7D), Color(0xFF11998E)],
                  );
                  borderShadow = [
                    BoxShadow(
                      color: const Color(0xFF11998E).withOpacity(0.35),
                      blurRadius: _isHovered ? 12.0 : 8.0,
                      spreadRadius: _isHovered ? 1.5 : 1.0,
                    )
                  ];
                  break;
                case AnimalRarity.rare:
                  borderGradient = const LinearGradient(
                    colors: [Colors.amber, Colors.orange],
                  );
                  borderShadow = [
                    BoxShadow(
                      color: Colors.orange.withOpacity(_isHovered ? 0.6 : 0.4),
                      blurRadius: _isHovered ? 16.0 : 12.0,
                      spreadRadius: _isHovered ? 2.0 : 1.5,
                    )
                  ];
                  break;
                case AnimalRarity.exotic:
                  borderGradient = SweepGradient(
                    center: Alignment.center,
                    colors: const [
                      Color(0xFF9400D3), Color(0xFF4B0082), Color(0xFF0000FF), 
                      Color(0xFF00FFCC), Color(0xFF9400D3)
                    ],
                    transform: GradientRotation(_rotationController.value * 2 * pi),
                  );
                  final pulse = (sin(_rotationController.value * 2 * pi) + 1.0) / 2.0; // 0.0 to 1.0
                  final baseBlur = _isHovered ? 18.0 : 12.0;
                  final blur = baseBlur + (pulse * 12.0); // pulses between baseBlur and baseBlur + 12
                  final baseSpread = _isHovered ? 2.5 : 1.5;
                  final spread = baseSpread + (pulse * 2.5); // pulses between baseSpread and baseSpread + 2.5
                  final shadowColor = Color.lerp(const Color(0xFF9400D3), const Color(0xFF00FFCC), pulse)!
                      .withOpacity(_isHovered ? 0.7 : 0.5);

                  borderShadow = [
                    BoxShadow(
                      color: shadowColor,
                      blurRadius: blur,
                      spreadRadius: spread,
                    )
                  ];
                  break;
              }

              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22.0),
                  gradient: borderGradient,
                  boxShadow: borderShadow,
                ),
                padding: const EdgeInsets.all(4.0), // border thickness
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(18.0),
                    image: DecorationImage(
                      image: AssetImage('assets/images/card_${widget.animal.id}.png'),
                      fit: BoxFit.cover,
                      opacity: 0.85,
                    ),
                  ),
                  padding: const EdgeInsets.all(10.0),
                  child: child,
                ),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Name
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        widget.animal.name,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14.0,
                          shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.verified_rounded,
                      color: Color(0xFF00FFCC),
                      size: 14.0,
                    ),
                  ],
                ),
                const SizedBox(height: 2.0),
                Text(
                  widget.animal.scientificName,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontStyle: FontStyle.italic,
                    fontSize: 8.0,
                  ),
                ),

                // Animated high-quality floating animal emoji inside a smooth silhouette
                Expanded(
                  child: Center(
                    child: _AnimatedAnimalWidget(animal: widget.animal, baseSize: 42.0),
                  ),
                ),

                // Card Footer Summary
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Rarity: ${widget.animal.rarity.toStringAsFixed(0)}★',
                        style: const TextStyle(color: Colors.white70, fontSize: 8.5, fontWeight: FontWeight.bold),
                      ),
                      const Text(
                        'VIEW',
                        style: TextStyle(color: Color(0xFF00FFCC), fontSize: 8.5, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ----------------- TRADING CARD DETAILS DIALOG -----------------
class _TradingCardDetailDialog extends StatefulWidget {
  final Animal animal;

  const _TradingCardDetailDialog({required this.animal, Key? key}) : super(key: key);

  @override
  State<_TradingCardDetailDialog> createState() => _TradingCardDetailDialogState();
}

class _TradingCardDetailDialogState extends State<_TradingCardDetailDialog> with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;
  double _tiltX = 0.0;
  double _tiltY = 0.0;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  void _updateTilt(Offset localPosition, Size size) {
    final double width = size.width > 0 ? size.width : 320.0;
    final double height = size.height > 0 ? size.height : 520.0;
    setState(() {
      _tiltX = (localPosition.dx / width * 2) - 1;
      _tiltY = (localPosition.dy / height * 2) - 1;
      _tiltX = _tiltX.clamp(-1.0, 1.0);
      _tiltY = _tiltY.clamp(-1.0, 1.0);
    });
  }

  void _resetTilt() {
    setState(() {
      _tiltX = 0.0;
      _tiltY = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Outer Holographic Premium Card Layout with rotating pokemon-style border
              AnimatedBuilder(
                animation: _rotationController,
                builder: (context, child) {
                  return TweenAnimationBuilder<Offset>(
                    tween: Tween<Offset>(
                      begin: Offset.zero,
                      end: Offset(_tiltX, _tiltY),
                    ),
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCubic,
                    builder: (context, tilt, child) {
                      return Transform(
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.001) // 3D Perspective
                          ..rotateX(-tilt.dy * 0.15) // Rotate X (up/down)
                          ..rotateY(tilt.dx * 0.15), // Rotate Y (left/right)
                        alignment: Alignment.center,
                        child: MouseRegion(
                          onHover: (event) => _updateTilt(event.localPosition, const Size(320, 520)),
                          onExit: (_) => _resetTilt(),
                          child: GestureDetector(
                            onPanUpdate: (details) => _updateTilt(details.localPosition, const Size(320, 520)),
                            onPanEnd: (_) => _resetTilt(),
                            onPanCancel: () => _resetTilt(),
                            child: Container(
                              width: 320,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30.0),
                                gradient: SweepGradient(
                                  center: Alignment.center,
                                  colors: const [
                                    Colors.red, Colors.orange, Colors.yellow, 
                                    Colors.green, Colors.blue, Colors.purple, Colors.red
                                  ],
                                  transform: GradientRotation(_rotationController.value * 2 * pi),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: widget.animal.gradientColors[0].withOpacity(0.6),
                                    blurRadius: 30,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(5.0), // border thickness
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(25.0),
                                child: Stack(
                                  children: [
                                    // Base black layer to prevent see-through edges
                                    Positioned.fill(
                                      child: Container(color: Colors.black),
                                    ),
                                    
                                    // 1. Background layer: bg_*.png shifts opposite of tilt
                                    Positioned.fill(
                                      child: Transform.translate(
                                        offset: Offset(-tilt.dx * 12.0, -tilt.dy * 12.0),
                                        child: Transform.scale(
                                          scale: 1.15,
                                          child: Image.asset(
                                            'assets/images/bg_${widget.animal.id}.png',
                                            fit: BoxFit.cover,
                                            opacity: const AlwaysStoppedAnimation(0.75),
                                          ),
                                        ),
                                      ),
                                    ),
                                    
                                    // 2. Foreground layer: card_*.png shifts with tilt
                                    Transform.translate(
                                      offset: Offset(tilt.dx * 6.0, tilt.dy * 6.0),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.4),
                                          image: DecorationImage(
                                            image: AssetImage('assets/images/card_${widget.animal.id}.png'),
                                            fit: BoxFit.cover,
                                            opacity: 0.85,
                                          ),
                                        ),
                                        padding: const EdgeInsets.all(16.0),
                                        child: child,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    child: child,
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Top Card Bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.animal.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20.0,
                            shadows: [Shadow(color: Colors.black54, blurRadius: 4.0)],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Row(
                            children: const [
                              Icon(Icons.shield_rounded, color: Colors.yellowAccent, size: 12.0),
                              SizedBox(width: 4.0),
                              Text(
                                'TRADING',
                                style: TextStyle(color: Colors.white, fontSize: 8.0, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      widget.animal.scientificName,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontStyle: FontStyle.italic,
                        fontSize: 10.5,
                      ),
                    ),
                    const SizedBox(height: 16.0),

                    // Illustration Box (Custom Painted shape silhouette + sparkles + emoji)
                    Container(
                      height: 160,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.75),
                        borderRadius: BorderRadius.circular(16.0),
                        border: Border.all(color: Colors.white24),
                        image: DecorationImage(
                          image: AssetImage('assets/images/bg_${widget.animal.id}.png'),
                          fit: BoxFit.cover,
                          opacity: 0.75,
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Sparkles
                          const Positioned.fill(
                            child: _HolographicSparklesWidget(),
                          ),
                          // Custom Painter rendering the animal silhouette
                          Positioned.fill(
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: CustomPaint(
                                painter: _SilhouetteDetailPainter(
                                  points: widget.animal.silhouettePoints,
                                  color: widget.animal.gradientColors[0],
                                  useSmooth: true,
                                ),
                              ),
                            ),
                          ),
                          // Animated high-quality floating emoji
                          _AnimatedAnimalWidget(animal: widget.animal, baseSize: 70.0),
                          // Premium Holographic Badge
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.all(4.0),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.08),
                              ),
                              child: const Icon(Icons.stars, color: Colors.amber, size: 16.0),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16.0),

                    // Lore Description
                    Container(
                      padding: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.35),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Text(
                        widget.animal.description,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11.0,
                          height: 1.4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),

                    // Vocalization Clue Hint (Neon banner)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00FFCC).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(color: const Color(0xFF00FFCC).withOpacity(0.4)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.mic_rounded, color: Color(0xFF00FFCC), size: 16.0),
                          const SizedBox(width: 8.0),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'VOCAL CLUE PHONETICS',
                                  style: TextStyle(color: Color(0xFF00FFCC), fontSize: 8.0, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 2.0),
                                Text(
                                  'Try mimic: "${widget.animal.vocalPhonetics.join('", "')}"',
                                  style: const TextStyle(color: Colors.white, fontSize: 10.0),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16.0),

                    // 6-Star Stat Attributes list
                    _buildStatRow('Rarity Tier', widget.animal.rarity),
                    _buildStatRow('Life Expectancy (Age)', widget.animal.ageRating, customText: widget.animal.ageText),
                    _buildStatRow('Average Weight', widget.animal.weightRating, customText: widget.animal.weightText),
                    _buildStatRow('Average Height', widget.animal.heightRating, customText: widget.animal.heightText),
                    _buildStatRow('Physical Strength', widget.animal.strengthRating, customText: widget.animal.strengthText),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),
              // Close button
              IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.white, size: 36.0),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Draw 6-star bar helper
  Widget _buildStatRow(String label, double rating, {String? customText}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 10.0, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 5,
            child: Row(
              children: List.generate(6, (index) {
                final double starIndex = index + 1.0;
                if (rating >= starIndex) {
                  return const Icon(Icons.star_rounded, color: Colors.yellow, size: 14.0);
                } else if (rating >= starIndex - 0.5) {
                  return const Icon(Icons.star_half_rounded, color: Colors.yellow, size: 14.0);
                } else {
                  return const Icon(Icons.star_outline_rounded, color: Colors.white24, size: 14.0);
                }
              }),
            ),
          ),
          if (customText != null)
            Expanded(
              flex: 3,
              child: Text(
                customText,
                textAlign: Alignment.centerRight.x > 0 ? TextAlign.right : TextAlign.left,
                style: const TextStyle(color: Colors.white54, fontSize: 8.5, fontFamily: 'monospace'),
              ),
            ),
        ],
      ),
    );
  }
}

// Simple custom painter to draw the vector silhouette inside the card details
class _SilhouetteDetailPainter extends CustomPainter {
  final List<Offset> points;
  final Color color;
  final bool useSmooth;

  _SilhouetteDetailPainter({
    required this.points,
    required this.color,
    this.useSmooth = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final Path path = Path();
    final double width = size.width;
    final double height = size.height;

    if (useSmooth && points.length > 2) {
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
    } else {
      path.moveTo(points[0].dx * width, points[0].dy * height);
      for (int i = 1; i < points.length; i++) {
        path.lineTo(points[i].dx * width, points[i].dy * height);
      }
      path.close();
    }

    // Draw solid shape with slightly transparent color
    final Paint fillPaint = Paint()
      ..color = color.withOpacity(0.15)
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    // Draw thick glowing vector borders
    final Paint borderPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _SilhouetteDetailPainter oldDelegate) {
    return oldDelegate.points != points || oldDelegate.color != color || oldDelegate.useSmooth != useSmooth;
  }
}

// Animated High-Quality Floating & Breathing Animal Graphic
class _AnimatedAnimalWidget extends StatefulWidget {
  final Animal animal;
  final double baseSize;

  const _AnimatedAnimalWidget({required this.animal, this.baseSize = 50.0, Key? key}) : super(key: key);

  @override
  State<_AnimatedAnimalWidget> createState() => _AnimatedAnimalWidgetState();
}

class _AnimatedAnimalWidgetState extends State<_AnimatedAnimalWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<double>(begin: -3.0, end: 3.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
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
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Glowing background smooth vector silhouette outline
                SizedBox(
                  width: widget.baseSize * 1.5,
                  height: widget.baseSize * 1.5,
                  child: CustomPaint(
                    painter: _SilhouetteDetailPainter(
                      points: widget.animal.silhouettePoints,
                      color: widget.animal.gradientColors[0].withOpacity(0.3),
                      useSmooth: true,
                    ),
                  ),
                ),
                // Realistic Pencil Sketch Image Asset
                ClipRRect(
                  borderRadius: BorderRadius.circular(widget.baseSize * 0.6),
                  child: Container(
                    width: widget.baseSize * 1.2,
                    height: widget.baseSize * 1.2,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F5F0),
                      image: DecorationImage(
                        image: AssetImage('assets/images/bg_${widget.animal.id}.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                    padding: const EdgeInsets.all(4.0),
                    child: Image.asset(
                      widget.animal.assetPath,
                      fit: BoxFit.contain,
                    ),
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

// Sparkles background effect for details box
class _HolographicSparklesWidget extends StatefulWidget {
  const _HolographicSparklesWidget({Key? key}) : super(key: key);

  @override
  State<_HolographicSparklesWidget> createState() => _HolographicSparklesWidgetState();
}

class _HolographicSparklesWidgetState extends State<_HolographicSparklesWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final Random _random = Random();
  late List<Offset> _sparklePositions;
  late List<double> _sparkleSizes;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _sparklePositions = List.generate(15, (index) => Offset(_random.nextDouble(), _random.nextDouble()));
    _sparkleSizes = List.generate(15, (index) => 3.0 + _random.nextDouble() * 5.0);
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
        return CustomPaint(
          painter: _SparklesPainter(
            positions: _sparklePositions,
            sizes: _sparkleSizes,
            progress: _controller.value,
          ),
        );
      },
    );
  }
}

class _SparklesPainter extends CustomPainter {
  final List<Offset> positions;
  final List<double> sizes;
  final double progress;

  _SparklesPainter({required this.positions, required this.sizes, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..color = Colors.white;
    for (int i = 0; i < positions.length; i++) {
      final double offsetProgress = (progress + (i / positions.length)) % 1.0;
      final double alpha = sin(offsetProgress * pi);
      paint.color = Colors.white.withOpacity(alpha * 0.3);

      final double px = positions[i].dx * size.width;
      final double py = positions[i].dy * size.height;
      final double sz = sizes[i];

      // Draw sparkle cross
      canvas.drawLine(Offset(px - sz, py), Offset(px + sz, py), paint);
      canvas.drawLine(Offset(px, py - sz), Offset(px, py + sz), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SparklesPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
