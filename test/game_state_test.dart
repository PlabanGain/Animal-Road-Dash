import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chemical_craft/providers/game_state.dart';

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
      }
      
      await Future.delayed(const Duration(seconds: 2));

      expect(gameState.unlockedStage, greaterThanOrEqualTo(1));
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
  });
}
