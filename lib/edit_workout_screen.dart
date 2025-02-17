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

    await FirebaseFirestore.instance.collection('Workouts').doc(widget.docId).update({
      'title': _titleController.text,
      'exercises': _exercises.map((e) => {'name': e.name, 'duration': e.durationInSeconds}).toList(),
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
          ElevatedButton(
              onPressed: _saveChanges, child: Text('Save Changes')),
        ],
      ),
    );
  }
}