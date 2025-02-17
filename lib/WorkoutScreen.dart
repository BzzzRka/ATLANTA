import 'package:flutter/material.dart';
import 'models.dart';
import 'dart:async';

class WorkoutScreen extends StatefulWidget {
  final Workout workout;

  WorkoutScreen({required this.workout});

  @override
  _WorkoutScreenState createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  late List<Exercise> exercises;
  late Timer _timer;
  late int _remainingTime;
  int _currentExerciseIndex = 0;

  @override
  void initState() {
    super.initState();
    exercises = widget.workout.exercises;
    _remainingTime = exercises[_currentExerciseIndex].durationInSeconds;
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingTime > 0) {
          _remainingTime--;
        } else {
          // Переход к следующему упражнению
          if (_currentExerciseIndex < exercises.length - 1) {
            _currentExerciseIndex++;
            _remainingTime = exercises[_currentExerciseIndex].durationInSeconds;
          } else {
            _timer.cancel(); // Завершаем тренировку
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text('Workout Complete!'),
                  content: Text('Great job!'),
                  actions: <Widget>[
                    TextButton(
                      child: Text('OK'),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                );
              },
            );
          }
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final exercise = exercises[_currentExerciseIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.workout.title),
      ),
      body: Column(
        children: [
          Text(
            'Exercise: ${exercise.name}',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          Text(
            'Time: ${_remainingTime}s',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _startTimer,
            child: Text('Start Timer'),
          ),
        ],
      ),
    );
  }
}