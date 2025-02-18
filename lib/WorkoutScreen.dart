import 'package:flutter/material.dart';
import 'models.dart';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart'; // Импортируем аудиоплеер

class WorkoutScreen extends StatefulWidget {
  final Workout workout;

  WorkoutScreen({required this.workout});

  @override
  _WorkoutScreenState createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  late List<Exercise> exercises;
  Timer? _timer;
  int _remainingTime = 0;
  int _currentExerciseIndex = 0;
  bool _isPaused = false;

  final AudioPlayer _player = AudioPlayer(); // Создаём плеер

  @override
  void initState() {
    super.initState();
    exercises = widget.workout.exercises;
    _remainingTime = exercises[_currentExerciseIndex].durationInSeconds;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _player.dispose(); // Освобождаем плеер
    super.dispose();
  }

  Future<void> _playSound(String fileName) async {
    await _player.play(AssetSource('sounds/$fileName')); // Добавляем 'sounds/'
  }

  void _startTimer() {
    if (_timer != null && _timer!.isActive) return;

    _playSound('start.mp3'); // Звук старта тренировки

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
      _playSound('next.mp3'); // Звук смены упражнения
      setState(() {
        _currentExerciseIndex++;
        _remainingTime = exercises[_currentExerciseIndex].durationInSeconds;
      });
    } else {
      _timer?.cancel();
      _playSound('finish.mp3'); // Звук завершения тренировки
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
    double progress = 1 - (_remainingTime / exercise.durationInSeconds);

    return Scaffold(
      appBar: AppBar(title: Text(widget.workout.title)),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            exercise.name,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),

          // Анимация прогресса
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 150,
                height: 150,
                child: CircularProgressIndicator(
                  value: progress,
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
          ),

          SizedBox(height: 20),

          // Кнопки управления
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _startTimer,
                child: Text('Start'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: _pauseTimer,
                child: Text(_isPaused ? 'Resume' : 'Pause'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: _nextExercise,
                child: Text('Skip'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
