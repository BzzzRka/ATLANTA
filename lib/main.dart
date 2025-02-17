import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'WorkoutScreen.dart';
import 'add_workout_screen.dart';
import 'edit_workout_screen.dart';
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
  List<String> _workoutDocs = []; // Список для хранения ID документов

  @override
  void initState() {
    super.initState();
    _loadWorkouts();
  }

  void _loadWorkouts() {
    FirebaseFirestore.instance.collection('Workouts').snapshots().listen((snapshot) {
      List<Workout> workouts = [];
      List<String> docIds = [];

      for (var doc in snapshot.docs) {
        var data = doc.data();
        workouts.add(
          Workout(
            title: data['title'],
            exercises: (data['exercises'] as List)
                .map((e) => Exercise(name: e['name'], durationInSeconds: e['duration']))
                .toList(),
          ),
        );
        docIds.add(doc.id); // Добавляем ID документа
      }

      setState(() {
        _workouts = workouts;
        _workoutDocs = docIds; // Обновляем список ID
      });
    });
  }

  void _deleteWorkout(String docId) async {
    await FirebaseFirestore.instance.collection('Workouts').doc(docId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Workouts')),
      body: ListView.builder(
        itemCount: _workouts.length,
        itemBuilder: (context, index) {
          final workout = _workouts[index];
          final docId = _workoutDocs[index]; // Теперь docId правильно заполняется

          return ListTile(
            title: Text(workout.title),
            subtitle: Text('${workout.exercises.length} exercises'),
            trailing: IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteWorkout(docId),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditWorkoutScreen(workout: workout, docId: docId),
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