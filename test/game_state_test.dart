import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chemical_craft/providers/game_state.dart';
import 'package:chemical_craft/models/animal.dart';
import 'package:chemical_craft/models/stage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('GameState Level Progression Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('initial unlocked stage is 1', () async {
      final gameState = GameState();
      // Since _loadProgress is async, let's wait a moment
      await Future.delayed(const Duration(milliseconds: 100));
      expect(gameState.unlockedStage, 1);
    });

    test('stage completion increments unlocked stage and saves to preferences', () async {
      final gameState = GameState();
      await Future.delayed(const Duration(milliseconds: 100));

      // Start stage 1
      gameState.startStage(1);
      expect(gameState.currentStageIndex, 1);
      expect(gameState.unlockedStage, 1);

      // Simulate win
      final wallCount = gameState.activeStage.targetAnimals.length;
      for (int i = 0; i < wallCount; i++) {
        await gameState.simulateSpeechPass();
        await Future.delayed(const Duration(milliseconds: 20));
      }
      
      await Future.delayed(const Duration(milliseconds: 100));

      expect(gameState.unlockedStage, 2);
    });

    test('saving and loading unlocked stage from SharedPreferences works', () async {
      // Setup SharedPreferences with mock value
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('animal_road_unlocked_stage', 5);

      final gameState = GameState();
      // Wait for _loadProgress to complete
      await Future.delayed(const Duration(milliseconds: 100));

      expect(gameState.unlockedStage, 5);
    });

    test('generating stages 1 to 50 works without throwing exceptions', () {
      for (int i = 1; i <= 50; i++) {
        final stage = Stage.generate(i);
        expect(stage, isNotNull);
        expect(stage.targetAnimals, isNotEmpty);
        expect(stage.targetAnimals.first.id, allAnimals[i - 1].id);
      }
    });

    test('replaying a stage awards bonus eco-shards and sets replay flag', () async {
      // Setup unlockedStage to 5 (meaning stages 1, 2, 3, 4 are completed/replays)
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('animal_road_unlocked_stage', 5);
      
      final newGameState = GameState();
      await Future.delayed(const Duration(milliseconds: 100));
      expect(newGameState.unlockedStage, 5);

      final initialShards = newGameState.ecoShards;

      // Start stage 2 (which is less than unlockedStage 5, so it is a replay)
      newGameState.startStage(2);
      expect(newGameState.lastVictoryWasReplay, false);

      // Simulate passing the stage
      final wallCount = newGameState.activeStage.targetAnimals.length;
      for (int i = 0; i < wallCount; i++) {
        await newGameState.simulateSpeechPass();
        await Future.delayed(const Duration(milliseconds: 20));
      }

      // Check if victory triggers properly and awards shards
      // Wait a moment for victory trigger to complete
      await Future.delayed(const Duration(milliseconds: 100));

      expect(newGameState.lastVictoryWasReplay, true);
      // Replaying should add +30 bonus shards, and simulateSpeechPass awards 15 shards per wall.
      // Total shards earned: wallCount * 15 + 30
      final expectedShards = initialShards + (wallCount * 15) + 30;
      expect(newGameState.ecoShards, expectedShards);

      // Start a new stage to check if flag resets
      newGameState.startStage(3);
      expect(newGameState.lastVictoryWasReplay, false);
    });
  });
}
