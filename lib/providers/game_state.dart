import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/animal.dart';
import '../models/stage.dart';

class GameState extends ChangeNotifier {
  // Persistence Keys
  static const String _keyUnlockedStage = 'animal_road_unlocked_stage';
  static const String _keyUnlockedAnimals = 'animal_road_unlocked_animals';
  static const String _keyHighScore = 'animal_road_highscore';

  // Game Persistence States
  int _unlockedStage = 1;
  Set<String> _unlockedAnimalIds = {};
  int _highScore = 0;

  // Active Play States
  bool _isPlaying = false;
  bool _isPaused = false;
  bool _isCrashed = false;
  double _recoveryTimeLeft = 0.0;
  bool _isFinished = false;
  int _currentStageIndex = 1;
  late Stage _activeStage;
  int _currentWallIndex = 0;
  double _currentWallProgress = 0.0; // 0.0 (horizon) to 1.0 (passed runner)
  String _runnerShape = 'human'; // 'human' or the animal id
  int _score = 0;

  // Vocal / Microphone Simulation States
  bool _isListening = false;
  String _lastSpokenText = '';
  String _listeningWaveformMessage = 'Tap Mic and Speak!';
  double _micAmplitude = 0.0; // Used for animated mic ripples
  Timer? _waveTimer;

  // Game Loop Ticker
  Timer? _gameLoopTimer;
  DateTime? _lastTickTime;

  // Getters
  int get unlockedStage => _unlockedStage;
  Set<String> get unlockedAnimalIds => _unlockedAnimalIds;
  int get highScore => _highScore;
  bool get isPlaying => _isPlaying;
  bool get isPaused => _isPaused;
  bool get isCrashed => _isCrashed;
  double get recoveryTimeLeft => _recoveryTimeLeft;
  bool get isFinished => _isFinished;
  int get currentStageIndex => _currentStageIndex;
  Stage get activeStage => _activeStage;
  int get currentWallIndex => _currentWallIndex;
  double get currentWallProgress => _currentWallProgress;
  String get runnerShape => _runnerShape;
  int get score => _score;

  bool get isListening => _isListening;
  String get lastSpokenText => _lastSpokenText;
  String get listeningWaveformMessage => _listeningWaveformMessage;
  double get micAmplitude => _micAmplitude;

  // Constructor
  GameState() {
    _activeStage = Stage.generate(1);
    _loadProgress();
  }

  // Load saved levels and unlocked cards
  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    _unlockedStage = prefs.getInt(_keyUnlockedStage) ?? 1;
    _highScore = prefs.getInt(_keyHighScore) ?? 0;
    final unlockedList = prefs.getStringList(_keyUnlockedAnimals) ?? [];
    _unlockedAnimalIds = unlockedList.toSet();
    notifyListeners();
  }

  // Save progress
  Future<void> _saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyUnlockedStage, _unlockedStage);
    await prefs.setInt(_keyHighScore, _highScore);
    await prefs.setStringList(_keyUnlockedAnimals, _unlockedAnimalIds.toList());
  }

  // Force reset all progress
  Future<void> resetProgress() async {
    _unlockedStage = 1;
    _unlockedAnimalIds.clear();
    _highScore = 0;
    _score = 0;
    _isPlaying = false;
    _isPaused = false;
    _isCrashed = false;
    _recoveryTimeLeft = 0.0;
    _isFinished = false;
    _currentWallIndex = 0;
    _currentWallProgress = 0.0;
    _runnerShape = 'human';
    _stopGameLoop();
    await _saveProgress();
    notifyListeners();
  }

  // Initialize and start a Stage
  void startStage(int stageNum) {
    _currentStageIndex = stageNum;
    _activeStage = Stage.generate(stageNum);
    _isPlaying = true;
    _isPaused = false;
    _isCrashed = false;
    _recoveryTimeLeft = 0.0;
    _isFinished = false;
    _currentWallIndex = 0;
    _currentWallProgress = 0.0;
    _runnerShape = 'human';
    _score = 0;
    _lastSpokenText = '';
    _isListening = false;

    _startGameLoop();
    notifyListeners();
  }

  // Stop running and clean up timers
  void exitGame() {
    _isPlaying = false;
    _isPaused = false;
    _isCrashed = false;
    _recoveryTimeLeft = 0.0;
    _isFinished = false;
    _stopGameLoop();
    notifyListeners();
  }

  void togglePause() {
    if (!_isPlaying || _isFinished) return;
    _isPaused = !_isPaused;
    if (_isPaused) {
      _lastTickTime = null;
    } else {
      _lastTickTime = DateTime.now();
    }
    notifyListeners();
  }

  // Starts the high frequency update loop (approx. 60 FPS)
  void _startGameLoop() {
    _stopGameLoop();
    _lastTickTime = DateTime.now();
    _gameLoopTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      _onGameTick();
    });
  }

  void _stopGameLoop() {
    _gameLoopTimer?.cancel();
    _gameLoopTimer = null;
    _waveTimer?.cancel();
    _waveTimer = null;
  }

  // Core running logic tick
  void _onGameTick() {
    if (!_isPlaying || _isPaused || _isFinished) return;

    final now = DateTime.now();
    if (_lastTickTime == null) {
      _lastTickTime = now;
      return;
    }
    final double dt = (now.difference(_lastTickTime!).inMilliseconds) / 1000.0;
    _lastTickTime = now;

    // Handle recovery timer
    if (_isCrashed) {
      _recoveryTimeLeft -= dt;
      if (_recoveryTimeLeft <= 0.0) {
        _isCrashed = false;
        _recoveryTimeLeft = 0.0;
      }
    }

    // Advance wall progress based on active stage speed (speed scale halved from 0.22 to 0.11)
    final speed = _activeStage.speedScale * 0.11;
    _currentWallProgress += speed * dt;

    // Check collision / pass boundaries (Runner is at 0.65)
    final double collisionProgress = 0.68;
    final double passingProgress = 0.62;

    if (_currentWallProgress >= passingProgress && _currentWallProgress < 0.95) {
      final currentTargetAnimal = _activeStage.targetAnimals[_currentWallIndex];
      final isShapeMatch = _runnerShape == currentTargetAnimal.id;

      if (!isShapeMatch && !_isCrashed) {
        if (_currentWallProgress >= collisionProgress) {
          // Trigger crash!
          _triggerCrash();
        }
      }
    }

    // If wall has passed beyond player view (1.0 progress), load next wall or clear stage
    if (_currentWallProgress >= 1.0) {
      _score += 100 * _currentStageIndex;
      if (_score > _highScore) {
        _highScore = _score;
      }

      if (_currentWallIndex < _activeStage.targetAnimals.length - 1) {
        // Load next wall
        _currentWallIndex++;
        _currentWallProgress = _currentWallProgress - 0.5;
      } else {
        // Stage Complete!
        _triggerVictory();
      }
    }

    notifyListeners();
  }

  // Trigger a crash back animation (fallback 3.5 seconds worth of running)
  void _triggerCrash() {
    _isCrashed = true;
    _recoveryTimeLeft = 3.5; // Invulnerable fallback state for 3.5 seconds
    
    // Fall back 3.5 seconds worth of running progress
    final speed = _activeStage.speedScale * 0.11;
    _currentWallProgress = (_currentWallProgress - (3.5 * speed)).clamp(0.0, 1.0);
    _micAmplitude = 0.1; // Alert ripples
    notifyListeners();
  }

  // Trigger stage cleared success
  void _triggerVictory() {
    _isFinished = true;
    _isPlaying = false;
    _stopGameLoop();

    // Unlock next stage
    if (_currentStageIndex == _unlockedStage && _unlockedStage < 50) {
      _unlockedStage++;
    }

    // Automatically unlock all cards encountered in this stage
    for (final animal in _activeStage.targetAnimals) {
      _unlockedAnimalIds.add(animal.id);
    }

    _saveProgress();
    notifyListeners();
  }

  // Start simulating voice/vocal recognition
  void startVoiceListening() {
    if (_isListening) return;
    _isListening = true;
    _lastSpokenText = '';
    _listeningWaveformMessage = 'Listening for animal sound...';
    notifyListeners();

    // Start wave visualizer timer
    int ticks = 0;
    _waveTimer?.cancel();
    _waveTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      ticks++;
      // Simulate amplitude fluctuations
      _micAmplitude = 0.2 + (0.8 * (ticks % 3 == 0 ? 0.9 : (ticks % 2 == 0 ? 0.3 : 0.6)));
      notifyListeners();
    });
  }

  // Process voice input and perform phonetic checking
  Future<bool> processVoiceInput(String input) async {
    _waveTimer?.cancel();
    _isListening = false;
    _micAmplitude = 0.0;
    _lastSpokenText = input.trim().toLowerCase();

    if (_lastSpokenText.isEmpty) {
      _listeningWaveformMessage = 'Quiet... Try again!';
      notifyListeners();
      return false;
    }

    final Animal targetAnimal = _activeStage.targetAnimals[_currentWallIndex];
    bool isMatch = false;

    // Check phonetic matches
    for (final phonetic in targetAnimal.vocalPhonetics) {
      if (_lastSpokenText.contains(phonetic) || phonetic.contains(_lastSpokenText)) {
        isMatch = true;
        break;
      }
    }

    if (isMatch) {
      // SUCCESS CONDITION: Morph player, restore speed if crashed, let wall pass
      _runnerShape = targetAnimal.id;
      _isCrashed = false;
      _recoveryTimeLeft = 0.0;
      _listeningWaveformMessage = 'Perfect! Shapeshifted to ${targetAnimal.name}!';

      // Unlock this card in the bestiary if not unlocked already
      if (!_unlockedAnimalIds.contains(targetAnimal.id)) {
        _unlockedAnimalIds.add(targetAnimal.id);
        _saveProgress();
      }

      // Resume tick time tracker
      _lastTickTime = DateTime.now();
    } else {
      // FAILURE CONDITION
      _listeningWaveformMessage = 'Sound mismatch. Try again!';
    }

    notifyListeners();
    return isMatch;
  }

  // Direct mock passing helper to make testing accessible without real microphone typing
  void simulateSpeechPass() {
    final Animal targetAnimal = _activeStage.targetAnimals[_currentWallIndex];
    // Morph immediately to the target animal
    _runnerShape = targetAnimal.id;
    _isCrashed = false;
    _listeningWaveformMessage = 'Simulation Auto-Passed!';
    if (!_unlockedAnimalIds.contains(targetAnimal.id)) {
      _unlockedAnimalIds.add(targetAnimal.id);
      _saveProgress();
    }
    _lastTickTime = DateTime.now();
    notifyListeners();
  }

  @override
  void dispose() {
    _stopGameLoop();
    super.dispose();
  }
}
