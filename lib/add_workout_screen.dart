import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'models.dart';

class AddWorkoutScreen extends StatefulWidget {
  @override
  _AddWorkoutScreenState createState() => _AddWorkoutScreenState();
}

class _AddWorkoutScreenState extends State<AddWorkoutScreen> {
  final TextEditingController _titleController = TextEditingController();
  List<Exercise> _exercises = [];

  void _addExercise() {
    TextEditingController nameController = TextEditingController();
    TextEditingController durationController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Exercise'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Exercise Name'),
              ),
              TextField(
                controller: durationController,
                decoration: InputDecoration(labelText: 'Duration (seconds)'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty && durationController.text.isNotEmpty) {
                  setState(() {
                    _exercises.add(
                      Exercise(
                        name: nameController.text,
                        durationInSeconds: int.parse(durationController.text),
                      ),
                    );
                  });
                }
                Navigator.pop(context);
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _saveWorkout() async {
    if (_titleController.text.isEmpty || _exercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please add a title and at least one exercise')),
      );
      return;
    }

    try {
      // Добавляем новую тренировку в базу данных
      await FirebaseFirestore.instance.collection('Workouts').add({
        'title': _titleController.text,
        'exercises': _exercises
            .map((e) => {'name': e.name, 'duration': e.durationInSeconds})
            .toList(),
      });

      // Возвращаемся на главный экран после успешного добавления
      Navigator.pop(context); // Это возвращает на экран с обновленным списком тренировок
    } catch (error) {
      print('Error saving workout: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save workout. Try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('New Workout')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Workout Title'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _addExercise,
              child: Text('Add Exercise'),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _exercises.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_exercises[index].name),
                    subtitle: Text('${_exercises[index].durationInSeconds} sec'),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: _saveWorkout,
              child: Text('Save Workout'),
            ),
          ],
        ),
      ),
    );
  }
}
