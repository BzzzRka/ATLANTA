import 'package:flutter/material.dart';
import 'models.dart';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart'; // Импортируем пакет для вибрации

class WorkoutScreen extends StatefulWidget {
  final Workout workout;

  WorkoutScreen({required this.workout});

  @override
  _WorkoutScreenState createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> with SingleTickerProviderStateMixin {
  late List<Exercise> exercises;
  Timer? _timer;
  int _remainingTime = 0;
  int _currentExerciseIndex = 0;
  bool _isPaused = false;

  final AudioPlayer _player = AudioPlayer();
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    exercises = widget.workout.exercises;
    _remainingTime = exercises[_currentExerciseIndex].durationInSeconds;

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _player.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _playSound(String fileName) async {
    await _player.play(AssetSource('sounds/$fileName'));
  }
  Future<void> _vibrate() async {
    if (await Vibration.hasVibrator()) {
      Vibration.vibrate(duration: 500); // Вибрация на 500 миллисекунд
    }
  }

  void _startTimer() {
    if (_timer != null && _timer!.isActive) return;

    _playSound('start.mp3');
    _vibrate();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (!_isPaused) {
        setState(() {
          if (_remainingTime > 0) {
            _remainingTime--;
          } else {
            _nextExercise();
          }
        });
      }
    });
  }

  void _pauseTimer() {
    setState(() {
      _isPaused = !_isPaused;
    });
  }

  void _nextExercise() {
    if (_currentExerciseIndex < exercises.length - 1) {
      _playSound('next.mp3');
      _vibrate();
      setState(() {
        _currentExerciseIndex++;
        _remainingTime = exercises[_currentExerciseIndex].durationInSeconds;
        _animationController.forward(from: 0);
      });
    } else {
      _timer?.cancel();
      _playSound('finish.mp3');
      _vibrate();
      _showCompletionDialog();
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Workout Complete!'),
          content: Text('Great job!'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final exercise = exercises[_currentExerciseIndex];

    return Scaffold(
      appBar: AppBar(title: Text(widget.workout.title)),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Плавная смена названия упражнения
          FadeTransition(
            opacity: _animationController,
            child: Text(
              exercise.name,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(height: 20),

          // Плавный прогресс-бар
          TweenAnimationBuilder<double>(
            tween: Tween(
              begin: (_remainingTime == exercise.durationInSeconds)
                  ? 1 - (_remainingTime / exercise.durationInSeconds)
                  : 1.0, // Фикс: при старте не делаем откат
              end: 1 - (_remainingTime / exercise.durationInSeconds),
            ),
            duration: Duration(milliseconds: 500),
            builder: (context, value, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 150,
                    height: 150,
                    child: CircularProgressIndicator(
                      value: value,
                      strokeWidth: 8,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                  ),
                  Text(
                    '$_remainingTime s',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                ],
              );
            },
          ),

          SizedBox(height: 20),

          // Анимированные кнопки
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildAnimatedButton('Start', _startTimer),
              SizedBox(width: 10),
              _buildAnimatedButton(_isPaused ? 'Resume' : 'Pause', _pauseTimer),
              SizedBox(width: 10),
              _buildAnimatedButton('Skip', _nextExercise),
            ],
          ),
        ],
      ),
    );
  }

  // Анимированная кнопка
  Widget _buildAnimatedButton(String text, VoidCallback onPressed) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(text),
      ),
    );
  }
}
