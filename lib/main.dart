import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'WorkoutScreen.dart';
import 'add_workout_screen.dart';
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

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Workout> _workouts = [];

  @override
  void initState() {
    super.initState();
    _loadWorkouts();
  }

  void _loadWorkouts() async {
    FirebaseFirestore.instance.collection('Workouts').snapshots().listen((snapshot) {
      List<Workout> workouts = snapshot.docs.map((doc) {
        var data = doc.data();
        return Workout(
          title: data['title'],
          exercises: (data['exercises'] as List)
              .map((e) => Exercise(name: e['name'], durationInSeconds: e['duration']))
              .toList(),
        );
      }).toList();

      setState(() {
        _workouts = workouts;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Workouts')),
      body: ListView.builder(
        itemCount: _workouts.length,
        itemBuilder: (context, index) {
          final workout = _workouts[index];
          return ListTile(
            title: Text(workout.title),
            subtitle: Text('${workout.exercises.length} exercises'),
            onTap: () {
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
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddWorkoutScreen()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}