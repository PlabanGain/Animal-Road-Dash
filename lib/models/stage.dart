import 'dart:math';
import 'animal.dart';

class Stage {
  final int stageNumber;
  final double speedScale;
  final double wallFrequency; // Time/distance factor between walls
  final List<Animal> targetAnimals; // The ordered walls for this stage

  Stage({
    required this.stageNumber,
    required this.speedScale,
    required this.wallFrequency,
    required this.targetAnimals,
  });

  // Procedurally generate a stage according to difficulty, speed, and animal pool guidelines
  factory Stage.generate(int num) {
    // Stage number must be 1 to 50
    final int stageIndex = (num - 1).clamp(0, 49);
    final Animal newAnimal = allAnimals[stageIndex];

    // Speed scales from 1.0 (Stage 1) to 2.5 (Stage 50)
    final double speedScale = 1.0 + (stageIndex * 0.03);

    // Wall frequency/density: walls appear closer in later stages
    // Delay time multiplier between walls (smaller = more frequent)
    final double wallFrequency = (1.5 - (stageIndex * 0.015)).clamp(0.6, 1.5);

    // Number of walls in the stage scales from 3 (Stage 1) to 15 (Stage 50)
    final int wallCount = (3 + (stageIndex * 0.25).floor()).clamp(3, 15);

    // Determine how many walls will feature past animals (minority check)
    // Stage 1 has 0 past animals because none exist.
    // For later stages, past count is roughly 15-20% of walls, clamped between 1 and 4.
    int pastCount = 0;
    if (stageIndex > 0) {
      pastCount = (wallCount * 0.2).round().clamp(1, 4);
    }

    final List<Animal> stageWalls = [];
    final Random random = Random(num * 100); // Seeded random for consistent stage design

    // Fill the list of walls
    // We want the newly introduced animal to be the star, but also some past ones.
    for (int i = 0; i < wallCount; i++) {
      if (stageIndex > 0 && i < pastCount) {
        // Select from past animals (indices 0 to stageIndex - 1)
        final int pastIndex = random.nextInt(stageIndex);
        stageWalls.add(allAnimals[pastIndex]);
      } else {
        // Majority are the newly introduced animal, or recent animals of similar tier
        if (random.nextDouble() < 0.7 || stageIndex < 3) {
          stageWalls.add(newAnimal);
        } else {
          // Occasionally throw in a recent animal of the same tier for variety
          final int recentOffset = random.nextInt(3) + 1; // 1, 2, or 3 stages back
          final int recentIndex = (stageIndex - recentOffset).clamp(0, 49);
          stageWalls.add(allAnimals[recentIndex]);
        }
      }
    }

    // Shuffle the walls slightly so that the new animal is spread out,
    // but ensure the first wall is always the new animal to introduce it.
    if (stageWalls.length > 2) {
      final Animal first = stageWalls.removeAt(stageWalls.indexOf(newAnimal));
      stageWalls.shuffle(random);
      stageWalls.insert(0, first);
    }

    return Stage(
      stageNumber: num,
      speedScale: speedScale,
      wallFrequency: wallFrequency,
      targetAnimals: stageWalls,
    );
  }
}
