import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'models.dart';

class AddWorkoutScreen extends StatefulWidget {
  @override
  _AddWorkoutScreenState createState() => _AddWorkoutScreenState();
}

class _AddWorkoutScreenState extends State<AddWorkoutScreen> {
  final TextEditingController _titleController = TextEditingController();
  final List<Exercise> _exercises = [];

  void _addExercise() {
    setState(() {
      _exercises.add(Exercise(name: 'New Exercise', durationInSeconds: 30));
    });
  }

  void _saveWorkout() async {
    if (_titleController.text.isEmpty || _exercises.isEmpty) return;

    // Создаем объект тренировки
    Workout newWorkout = Workout(
      title: _titleController.text,
      exercises: _exercises,
    );

    // Сохраняем в Firestore
    await FirebaseFirestore.instance.collection('Workouts').add({
      'title': newWorkout.title,
      'exercises': newWorkout.exercises
          .map((e) => {'name': e.name, 'duration': e.durationInSeconds})
          .toList(),
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Workout')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Workout Title'),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _exercises.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_exercises[index].name),
                  subtitle: Text('${_exercises[index].durationInSeconds} sec'),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      setState(() {
                        _exercises.removeAt(index);
                      });
                    },
                  ),
                );
              },
            ),
          ),
          ElevatedButton(onPressed: _addExercise, child: Text('Add Exercise')),
          ElevatedButton(onPressed: _saveWorkout, child: Text('Save Workout')),
        ],
      ),
    );
  }
}
