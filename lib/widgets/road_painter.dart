import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../models/animal.dart';
import '../models/stage.dart';

class RoadPainter extends CustomPainter {
  final double wallProgress; // 0.0 to 1.0
  final int currentWallIndex;
  final Stage activeStage;
  final String runnerShape;
  final bool isCrashed;
  final double animationTime; // continuously running time variable for road lines
  final Map<String, ui.Image> animalImages;

  RoadPainter({
    required this.wallProgress,
    required this.currentWallIndex,
    required this.activeStage,
    required this.runnerShape,
    required this.isCrashed,
    required this.animationTime,
    required this.animalImages,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // 1. Draw High-Altitude Sky Background (Rich Gradient)
    final Paint skyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF0D47A1), // Deep space blue at top
          Color(0xFF1976D2), // Sky blue
          Color(0xFF81D4FA), // High altitude cyan near horizon
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), skyPaint);

    // Add some soft atmospheric clouds/glow in the distance
    final Paint sunGlowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withOpacity(0.15),
          Colors.white.withOpacity(0.0),
        ],
      ).createShader(Rect.fromCircle(center: Offset(w * 0.8, h * 0.2), radius: w * 0.4));
    canvas.drawCircle(Offset(w * 0.8, h * 0.2), w * 0.4, sunGlowPaint);

    // 2. Road Projection Mathematics
    // Road runs from bottom-left (0, h) to top-right (w, 0).
    // Let t be parameter along road: t=0 is horizon (top-right), t=1 is foreground (bottom-left)
    // To make it look like a 3x3 diagonal, we map:
    // Horizon: (w * 0.75, h * 0.25) (receding into the upper right)
    // Foreground: (w * 0.15, h * 0.95) (passing through the bottom left)
    final Offset horizon = Offset(w, h * 0.42);
    final Offset foreground = Offset(0.0, h);

    // Helper function to get center point at depth t
    Offset getRoadCenter(double t) {
      // Linear interpolation between horizon and foreground
      return Offset(
        horizon.dx + (foreground.dx - horizon.dx) * t,
        horizon.dy + (foreground.dy - horizon.dy) * t,
      );
    }

    // Perpendicular unit vector of the road
    final double dx = foreground.dx - horizon.dx;
    final double dy = foreground.dy - horizon.dy;
    final double len = sqrt(dx * dx + dy * dy);
    final Offset normal = Offset(-dy / len, dx / len); // Normal vector

    // Road width scaling (almost same size all around, from 75 to 100)
    double getRoadWidth(double t) {
      final double minWidth = 75.0;
      final double maxWidth = 100.0;
      return minWidth + (maxWidth - minWidth) * t;
    }

    // Get left and right road boundary coordinates at depth t (slightly flattened to look "almost behind")
    Offset getLeftPoint(double t) {
      final center = getRoadCenter(t);
      final width = getRoadWidth(t);
      final Offset roadNormalRaw = Offset(normal.dx, normal.dy * 0.35);
      final double rLen = sqrt(roadNormalRaw.dx * roadNormalRaw.dx + roadNormalRaw.dy * roadNormalRaw.dy);
      final Offset roadNormal = Offset(roadNormalRaw.dx / rLen, roadNormalRaw.dy / rLen);
      return center - roadNormal * (width / 2);
    }

    Offset getRightPoint(double t) {
      final center = getRoadCenter(t);
      final width = getRoadWidth(t);
      final Offset roadNormalRaw = Offset(normal.dx, normal.dy * 0.35);
      final double rLen = sqrt(roadNormalRaw.dx * roadNormalRaw.dx + roadNormalRaw.dy * roadNormalRaw.dy);
      final Offset roadNormal = Offset(roadNormalRaw.dx / rLen, roadNormalRaw.dy / rLen);
      return center + roadNormal * (width / 2);
    }

    // 3. Draw the Road Path
    final Path roadPath = Path();
    roadPath.moveTo(getLeftPoint(0.0).dx, getLeftPoint(0.0).dy);

    // Draw segment curves
    const int segments = 20;
    for (int i = 1; i <= segments; i++) {
      final double t = i / segments;
      final pt = getLeftPoint(t);
      roadPath.lineTo(pt.dx, pt.dy);
    }
    for (int i = segments; i >= 0; i--) {
      final double t = i / segments;
      final pt = getRightPoint(t);
      roadPath.lineTo(pt.dx, pt.dy);
    }
    roadPath.close();

    final Paint roadPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [
          const Color(0xFF2C3E50).withOpacity(0.8), // receding dark slate
          const Color(0xFF34495E),
          const Color(0xFF1C2833), // foreground dark road
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawPath(roadPath, roadPaint);

    // Draw Road Borders (Glowing Neon Margins)
    final Paint borderPaint = Paint()
      ..color = const Color(0xFF00E5FF).withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final Path leftBorder = Path();
    final Path rightBorder = Path();
    leftBorder.moveTo(getLeftPoint(0.0).dx, getLeftPoint(0.0).dy);
    rightBorder.moveTo(getRightPoint(0.0).dx, getRightPoint(0.0).dy);
    for (int i = 1; i <= segments; i++) {
      final double t = i / segments;
      leftBorder.lineTo(getLeftPoint(t).dx, getLeftPoint(t).dy);
      rightBorder.lineTo(getRightPoint(t).dx, getRightPoint(t).dy);
    }
    canvas.drawPath(leftBorder, borderPaint);
    canvas.drawPath(rightBorder, borderPaint);

    // 4. Draw Moving Dashed Lanes for Speed Parallax
    final Paint lanePaint = Paint()
      ..color = Colors.white.withOpacity(0.4)
      ..style = PaintingStyle.fill;

    // Draw center dashed lines that move towards foreground (speed scale halved)
    final double speedOffset = (animationTime * activeStage.speedScale * 0.4) % 1.0;
    const int laneCount = 8;
    for (int i = 0; i < laneCount; i++) {
      // Calculate fraction depth of this stripe
      final double relativeDepth = (i + speedOffset) / laneCount;
      // Exponential scaling makes the stripes look like they accelerate towards us
      final double t = pow(relativeDepth, 2.0) as double;

      if (t > 0.05 && t < 0.98) {
        final center = getRoadCenter(t);
        final laneWidth = getRoadWidth(t) * 0.06;

        canvas.drawCircle(center, laneWidth, lanePaint);
      }
    }

    // 5. Draw the 3D-Projected Wall Obstacles (Angled skew based on road)
    void drawWall(Animal obstacleAnimal, double tWall, bool isCurrent) {
      if (tWall <= 0.02 || tWall >= 1.0) return;

      final Offset wallCenterBase = getRoadCenter(tWall);

      // Wall base width matches the road width at this point
      final double wallWidth = getRoadWidth(tWall) * 1.5; // wider than road
      // Wall height proportional to width
      final double wallHeight = wallWidth * 0.75;

      // Bottom left and right of the wall base, flattened using a custom normal to stand upright (facing camera)
      final Offset wallNormalRaw = Offset(normal.dx, normal.dy * 0.2);
      final double wLen = sqrt(wallNormalRaw.dx * wallNormalRaw.dx + wallNormalRaw.dy * wallNormalRaw.dy);
      final Offset wallNormal = Offset(wallNormalRaw.dx / wLen, wallNormalRaw.dy / wLen);

      final Offset bL = wallCenterBase - wallNormal * (wallWidth / 2);
      final Offset bR = wallCenterBase + wallNormal * (wallWidth / 2);

      // Top left and right of the wall (standing straight up vertically)
      final Offset tL = Offset(bL.dx, bL.dy - wallHeight);
      final Offset tR = Offset(bR.dx, bR.dy - wallHeight);

      // Build the solid wall polygon
      final Path wallPolygon = Path()
        ..moveTo(bL.dx, bL.dy)
        ..lineTo(tL.dx, tL.dy)
        ..lineTo(tR.dx, tR.dy)
        ..lineTo(bR.dx, bR.dy)
        ..close();

      final Rect wallRect = Rect.fromLTRB(
        min(tL.dx, bL.dx),
        min(tL.dy, tR.dy),
        max(tR.dx, bR.dx),
        max(bL.dy, bR.dy),
      );

      final Offset wallCenter = Offset(
        wallCenterBase.dx,
        wallCenterBase.dy - (wallHeight / 2),
      );
      final double cutoutW = wallWidth * 0.28;
      final double cutoutH = wallHeight * 0.45;
      final Rect cutoutRect = Rect.fromCenter(
        center: wallCenter,
        width: cutoutW,
        height: cutoutH,
      );

      // Styling the wall: dynamic colors based on proximity & crash status
      Color wallColor = const Color(0xFFE53935).withOpacity(0.8); // standard reddish wall
      if (isCurrent && isCrashed) {
        // Flash intense warning red
        wallColor = Colors.red.shade900.withOpacity(0.9);
      } else if (isCurrent && tWall > 0.75) {
        // Nearing collision zone
        wallColor = const Color(0xFFFF5252).withOpacity(0.85);
      } else {
        // Distant/background wall
        wallColor = const Color(0xFFD32F2F).withOpacity(0.4 + (0.5 * tWall));
      }

      // Draw shadow under wall
      final Paint wallShadow = Paint()
        ..color = Colors.black.withOpacity(0.4 * tWall)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10.0);
      canvas.drawOval(
        Rect.fromCenter(
          center: wallCenterBase,
          width: wallWidth * 1.1,
          height: wallWidth * 0.15,
        ),
        wallShadow,
      );

      final ui.Image? animalImage = animalImages[obstacleAnimal.id];

      if (animalImage != null) {
        // High Quality PNG-based alpha mask cutout
        canvas.saveLayer(wallRect, Paint());

        // 1. Draw solid wall background color
        final Paint wallBgPaint = Paint()
          ..color = wallColor
          ..style = PaintingStyle.fill;
        canvas.drawPath(wallPolygon, wallBgPaint);

        // 2. Draw bricks clipped to the wall
        canvas.save();
        canvas.clipPath(wallPolygon);
        final Paint brickLinePaint = Paint()
          ..color = Colors.black.withOpacity(0.35)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0 + (1.5 * tWall);

        final int brickRows = 8;
        for (int r = 1; r < brickRows; r++) {
          final double ratio = r / brickRows;
          final Offset leftPt = Offset(tL.dx + (bL.dx - tL.dx) * ratio, tL.dy + (bL.dy - tL.dy) * ratio);
          final Offset rightPt = Offset(tR.dx + (bR.dx - tR.dx) * ratio, tR.dy + (bR.dy - tR.dy) * ratio);
          canvas.drawLine(leftPt, rightPt, brickLinePaint);

          final int bricksPerRow = 6;
          for (int c = 0; c <= bricksPerRow; c++) {
            double colRatio = (c + (r % 2 == 0 ? 0.5 : 0.0)) / bricksPerRow;
            if (colRatio > 1.0) colRatio -= 1.0;

            final double ratioPrev = (r - 1) / brickRows;
            final Offset lpPrev = Offset(tL.dx + (bL.dx - tL.dx) * ratioPrev, tL.dy + (bL.dy - tL.dy) * ratioPrev);
            final Offset rpPrev = Offset(tR.dx + (bR.dx - tR.dx) * ratioPrev, tR.dy + (bR.dy - tR.dy) * ratioPrev);

            final Offset pt1 = lpPrev + (rpPrev - lpPrev) * colRatio;
            final Offset pt2 = leftPt + (rightPt - leftPt) * colRatio;
            canvas.drawLine(pt1, pt2, brickLinePaint);
          }
        }
        canvas.restore();

        // 3. Cutout the exact shape of the Animal PNG using BlendMode.dstOut
        final Paint cutoutPaint = Paint()..blendMode = BlendMode.dstOut;
        canvas.drawImageRect(
          animalImage,
          Rect.fromLTWH(0, 0, animalImage.width.toDouble(), animalImage.height.toDouble()),
          cutoutRect,
          cutoutPaint,
        );

        canvas.restore();
      } else {
        // Fallback Vector cutout if image is not loaded
        final Path rawAnimalPath = obstacleAnimal.getSmoothPath(cutoutW, cutoutH);
        final Rect animalBounds = rawAnimalPath.getBounds();
        final Offset centerOffset = wallCenter - Offset(animalBounds.width / 2, animalBounds.height / 2);
        final Path animalCutout = rawAnimalPath.shift(centerOffset);

        final Path finalWallPath = Path.combine(
          PathOperation.difference,
          wallPolygon,
          animalCutout,
        );

        canvas.save();
        canvas.clipPath(finalWallPath);

        final Paint wallBgPaint = Paint()
          ..color = wallColor
          ..style = PaintingStyle.fill;
        canvas.drawRect(wallRect, wallBgPaint);

        final Paint brickLinePaint = Paint()
          ..color = Colors.black.withOpacity(0.35)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0 + (1.5 * tWall);

        final int brickRows = 8;
        for (int r = 1; r < brickRows; r++) {
          final double ratio = r / brickRows;
          final Offset leftPt = Offset(tL.dx + (bL.dx - tL.dx) * ratio, tL.dy + (bL.dy - tL.dy) * ratio);
          final Offset rightPt = Offset(tR.dx + (bR.dx - tR.dx) * ratio, tR.dy + (bR.dy - tR.dy) * ratio);
          canvas.drawLine(leftPt, rightPt, brickLinePaint);

          final int bricksPerRow = 6;
          for (int c = 0; c <= bricksPerRow; c++) {
            double colRatio = (c + (r % 2 == 0 ? 0.5 : 0.0)) / bricksPerRow;
            if (colRatio > 1.0) colRatio -= 1.0;

            final double ratioPrev = (r - 1) / brickRows;
            final Offset lpPrev = Offset(tL.dx + (bL.dx - tL.dx) * ratioPrev, tL.dy + (bL.dy - tL.dy) * ratioPrev);
            final Offset rpPrev = Offset(tR.dx + (bR.dx - tR.dx) * ratioPrev, tR.dy + (bR.dy - tR.dy) * ratioPrev);

            final Offset pt1 = lpPrev + (rpPrev - lpPrev) * colRatio;
            final Offset pt2 = leftPt + (rightPt - leftPt) * colRatio;
            canvas.drawLine(pt1, pt2, brickLinePaint);
          }
        }
        canvas.restore();

        // Highlight
        final Paint cutoutHighlight = Paint()
          ..color = const Color(0xFF00FF88).withOpacity(0.5 + (0.5 * tWall))
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5 + (2.0 * tWall);
        canvas.drawPath(animalCutout, cutoutHighlight);
      }

      // Draw neon border around wall outer bounds
      final Paint wallBorderPaint = Paint()
        ..color = (isCurrent && isCrashed) ? Colors.red : Colors.yellow.withOpacity(0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = isCurrent ? (2.0 + (3.0 * tWall)) : (1.0 + (1.5 * tWall));
      canvas.drawPath(wallPolygon, wallBorderPaint);

      // 3D Depth edges (extrusion) - to make the walls look 3D projected!
      final double extrusionDepth = 12.0 * tWall;
      final Offset extVec = Offset(dx / len * extrusionDepth, dy / len * extrusionDepth);

      final Path wallDepthPath = Path()
        ..moveTo(tL.dx, tL.dy)
        ..lineTo(tL.dx - extVec.dx, tL.dy - extVec.dy)
        ..lineTo(tR.dx - extVec.dx, tR.dy - extVec.dy)
        ..lineTo(tR.dx, tR.dy)
        ..close();

      final Paint depthPaint = Paint()
        ..color = Colors.black.withOpacity(0.35)
        ..style = PaintingStyle.fill;
      canvas.drawPath(wallDepthPath, depthPaint);
    }

    // Paint the background wall first (further away), then the foreground wall (painter's algorithm)
    if (currentWallIndex + 1 < activeStage.targetAnimals.length) {
      final Animal nextAnimal = activeStage.targetAnimals[currentWallIndex + 1];
      drawWall(nextAnimal, wallProgress - 0.5, false);
    }
    if (currentWallIndex < activeStage.targetAnimals.length) {
      final Animal currentAnimal = activeStage.targetAnimals[currentWallIndex];
      drawWall(currentAnimal, wallProgress, true);
    }

    // 6. Draw the Runner (Morphed or Human)
    // Runner sits at parameter t = 0.65 (shifted up from 0.85 to be more in front)
    final double runnerT = 0.65;
    final Offset runnerBase = getRoadCenter(runnerT);
    final double runnerScale = getRoadWidth(runnerT) * 0.55; // increased scale factor for visibility

    // Draw shadow under runner
    final Paint runnerShadow = Paint()
      ..color = Colors.black.withOpacity(0.6)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6.0);
    canvas.drawOval(
      Rect.fromCenter(
        center: runnerBase + Offset(0, runnerScale * 0.05),
        width: runnerScale * 1.2,
        height: runnerScale * 0.3,
      ),
      runnerShadow,
    );

    // Get the shape profile path
    Path runnerPath;
    Color runnerColor = const Color(0xFF00FFCC); // Glow teal

    if (runnerShape == 'human') {
      // Draw stylized running humanoid silhouette
      runnerPath = _getHumanRunnerPath(runnerScale);
    } else {
      // Get the animal shape
      final Animal activeAnimal = allAnimals.firstWhere((a) => a.id == runnerShape,
          orElse: () => allAnimals[0]);
      runnerPath = activeAnimal.getSmoothPath(runnerScale, runnerScale); // smooth realistic path
      // Animal shapes might be colored based on their rarity cards
      runnerColor = activeAnimal.gradientColors[0];
    }

    // Shift to position
    final Rect bounds = runnerPath.getBounds();
    final Offset runnerPos = runnerBase - Offset(bounds.width / 2, bounds.height * 0.95);

    // Apply crash animation shake/displacement
    Offset finalRunnerPos = runnerPos;
    if (isCrashed) {
      // Shakes violently in crash state
      final double shakeX = sin(animationTime * 80) * 8.0;
      final double shakeY = cos(animationTime * 95) * 5.0;
      finalRunnerPos += Offset(shakeX - (runnerScale * 0.4), shakeY); // knock back slightly left
      runnerColor = const Color(0xFFFF1744); // Red damage glow
    }

    final Path shiftedRunner = runnerPath.shift(finalRunnerPos);

    // Draw runner glow
    final Paint runnerGlow = Paint()
      ..color = runnerColor.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12.0);
    canvas.drawPath(shiftedRunner, runnerGlow);

    // Draw main runner silhouette
    final Paint runnerPaint = Paint()
      ..color = runnerColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(shiftedRunner, runnerPaint);

    // Draw nice sleek neon border on runner
    final Paint runnerBorder = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawPath(shiftedRunner, runnerBorder);

    // Draw emoji on top of the morphed silhouette
    if (runnerShape != 'human') {
      final Animal activeAnimal = allAnimals.firstWhere((a) => a.id == runnerShape,
          orElse: () => allAnimals[0]);

      // Paint the emoji centered in bounds
      final textPainter = TextPainter(
        text: TextSpan(
          text: activeAnimal.emoji,
          style: TextStyle(fontSize: runnerScale * 0.7),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      // Slightly oscillate the emoji vertically to look like it's running
      final double runBounce = sin(animationTime * 2 * pi * 4) * 2.0;

      final Offset emojiOffset = Offset(
        runnerBase.dx - textPainter.width / 2,
        runnerBase.dy - bounds.height * 0.5 - textPainter.height / 2 + runBounce,
      );

      // Apply crash animation shake/displacement
      Offset finalEmojiOffset = emojiOffset;
      if (isCrashed) {
        final double shakeX = sin(animationTime * 80) * 8.0;
        final double shakeY = cos(animationTime * 95) * 5.0;
        finalEmojiOffset += Offset(shakeX - (runnerScale * 0.4), shakeY);
      }

      textPainter.paint(canvas, finalEmojiOffset);
    }
  }

  // Generate stylized human silhouette in a running pose
  Path _getHumanRunnerPath(double scale) {
    final Path path = Path();
    // Coordinates normalized (0 to 1) for a cool running pose
    // A stylized running stick/polygon shape
    final List<Offset> runningPoints = [
      Offset(0.5, 0.1), // Head center
      Offset(0.55, 0.2), // Neck
      Offset(0.7, 0.35), // Front arm elbow
      Offset(0.8, 0.4),  // Front hand
      Offset(0.65, 0.35),// Elbow return
      Offset(0.55, 0.3), // Chest
      Offset(0.6, 0.55), // Front hip
      Offset(0.75, 0.75),// Front knee
      Offset(0.8, 0.95), // Front foot
      Offset(0.7, 0.95), // Front heel
      Offset(0.5, 0.65), // Pelvis
      Offset(0.3, 0.75), // Back knee
      Offset(0.2, 0.95), // Back foot
      Offset(0.15, 0.9), // Back toe
      Offset(0.35, 0.6), // Hip
      Offset(0.4, 0.35), // Spine back
      Offset(0.25, 0.4), // Back arm elbow
      Offset(0.15, 0.5), // Back hand
      Offset(0.3, 0.3),  // Shoulder
      Offset(0.45, 0.2), // Upper neck
    ];

    path.moveTo(runningPoints[0].dx * scale, runningPoints[0].dy * scale);
    for (int i = 1; i < runningPoints.length; i++) {
      path.lineTo(runningPoints[i].dx * scale, runningPoints[i].dy * scale);
    }
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant RoadPainter oldDelegate) {
    return oldDelegate.wallProgress != wallProgress ||
        oldDelegate.runnerShape != runnerShape ||
        oldDelegate.isCrashed != isCrashed ||
        oldDelegate.animationTime != animationTime ||
        oldDelegate.currentWallIndex != currentWallIndex ||
        oldDelegate.animalImages != animalImages;
  }
}
