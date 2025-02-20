import 'package:flutter/material.dart';
import 'main.dart';
import 'models.dart';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart'; // Импортируем пакет для вибрации
import 'package:shared_preferences/shared_preferences.dart'; // Импортируем SharedPreferences

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
    _loadProgress(); // Загружаем сохраненный прогресс

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

  // Сохранение прогресса
  Future<void> _saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('currentExerciseIndex', _currentExerciseIndex);
    await prefs.setInt('remainingTime', _remainingTime);
  }
  // очистка
  void _clearProgress() async {
    _remainingTime = 0;
    _currentExerciseIndex = 0;
  }
  // Загрузка прогресса
  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final savedIndex = prefs.getInt('currentExerciseIndex');
    final savedTime = prefs.getInt('remainingTime');

    if (savedIndex != null && savedTime != null) {
      setState(() {
        _currentExerciseIndex = savedIndex;
        _remainingTime = savedTime;
      });
    } else {
      setState(() {
        _remainingTime = exercises[_currentExerciseIndex].durationInSeconds;
      });
    }
    if (_currentExerciseIndex == 0 && _remainingTime == 0) {
      setState(() {
        _remainingTime = exercises[_currentExerciseIndex].durationInSeconds;
      });
    }
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
        if (exercises[_currentExerciseIndex].isTimeBased) {
          _remainingTime = exercises[_currentExerciseIndex].durationInSeconds;
        } else {
          _remainingTime = exercises[_currentExerciseIndex].repetitions;
        }
        _animationController.forward(from: 0);
      });
    } else {
      _timer?.cancel();
      _playSound('finish.mp3');
      _vibrate();
      _clearProgress();
      _showCompletionDialog();
    }

    _saveProgress(); // Сохраняем прогресс после смены упражнения
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
              onPressed: () {
                Navigator.pop(context);  // Закрываем диалог
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomeScreen()),
                );
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Widget _getExerciseImage(String exerciseName) {
    Map<String, String> exerciseImages = {
      "Push-ups": "assets/animations/push-ups.gif",
      "Squats": "assets/animations/squats.gif",
      "Plank": "assets/animations/plank.gif",
      "Lunges": "assets/animations/lunges.gif",
      "Burpees": "assets/animations/burpees.gif",
      "Arm Swings": "assets/animations/arm_swings.gif",
      "Mountain Climbers": "assets/animations/mountain_climbers.gif",
      "Tricep Dips": "assets/animations/tricep_dips.gif",
      "High Knees": "assets/animations/high_knees.gif",
      "Bicycle Crunches": "assets/animations/bicycle_crunches.gif",
    };

    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white, // Белый фон
        border: Border.all(color: Colors.grey, width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Image.asset(
        exerciseImages[exerciseName] ?? "assets/images/default_exercise.png",
        fit: BoxFit.contain,
      ),
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
          // Анимированная картинка упражнения
          _getExerciseImage(exercise.name),
          SizedBox(height: 20),

          // Название упражнения
          FadeTransition(
            opacity: _animationController,
            child: Text(
              exercise.name,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(height: 20),

          SizedBox(
            height: 100, // Фиксированная высота для таймера, чтобы GIF не двигался
            child: (exercise.isTimeBased)
                ? Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 100,
                  height: 100,
                  child: CircularProgressIndicator(
                    value: (_remainingTime / exercise.durationInSeconds).clamp(0.0, 1.0),
                    strokeWidth: 8,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                ),
                Text(
                  '$_remainingTime s',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            )
                : Text(
              '$_remainingTime reps left',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),

          SizedBox(height: 20),

          // Шкала тренировки
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: LinearProgressIndicator(
              value: (_currentExerciseIndex + 1) / exercises.length,
              minHeight: 10,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          SizedBox(height: 20),

          // Кнопки
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
