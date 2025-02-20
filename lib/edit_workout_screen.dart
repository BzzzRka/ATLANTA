import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'models.dart';

class EditWorkoutScreen extends StatefulWidget {
  final Workout workout;
  final String docId;

  EditWorkoutScreen({required this.workout, required this.docId});

  @override
  _EditWorkoutScreenState createState() => _EditWorkoutScreenState();
}

class _EditWorkoutScreenState extends State<EditWorkoutScreen> {
  late TextEditingController _titleController;
  late List<Exercise> _exercises;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.workout.title);
    _exercises = List.from(widget.workout.exercises);
  }

  void _saveChanges() async {
    if (_titleController.text.isEmpty || _exercises.isEmpty) return;

    List<Map<String, dynamic>> exercisesData = _exercises.map((e) {
      return {
        'name': e.name,
        'duration': e.durationInSeconds,
        'repetitions': e.repetitions,
        'isTimeBased': e.isTimeBased,
      };
    }).toList();

    await FirebaseFirestore.instance.collection('Workouts').doc(widget.docId).update({
      'title': _titleController.text,
      'exercises': exercisesData,
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Workout')),
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
                final exercise = _exercises[index];
                return ListTile(
                  title: Text(exercise.name),
                  subtitle: Text(
                    exercise.isTimeBased
                        ? '${exercise.durationInSeconds} sec'
                        : '${exercise.repetitions} reps',
                  ),
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
          ElevatedButton(
            onPressed: _saveChanges,
            child: Text('Save Changes'),
          ),
        ],
      ),
    );
  }
}