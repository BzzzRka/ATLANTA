import 'package:flutter/material.dart';
import 'WorkoutScreen.dart';
import 'models.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // необходимо

  await Firebase.initializeApp( // необходимо
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Atlanta Fitness',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final List<Workout> workouts = [
    Workout(
      title: 'Morning Workoutе',
      exercises: [
        Exercise(name: 'Push-ups', durationInSeconds: 30),
        Exercise(name: 'Squats', durationInSeconds: 30),
      ],
    ),
    Workout(
      title: 'Evening Stretch',
      exercises: [
        Exercise(name: 'Plank', durationInSeconds: 60),
        Exercise(name: 'Leg Raises', durationInSeconds: 40),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Workouts')),
      body: ListView.builder(
        itemCount: workouts.length,
        itemBuilder: (context, index) {
          final workout = workouts[index];
          return ListTile(
            title: Text(workout.title),
            subtitle: Text('${workout.exercises.length} exercises'),
            onTap: () {
              // Переход к экрану тренировки
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WorkoutScreen(workout: workout),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Логика для добавления новой тренировки (пока не реализовано)
        },
        child: Icon(Icons.add),
      ),
    );
  }
}