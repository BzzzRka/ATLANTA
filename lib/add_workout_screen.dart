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

  void _addExerciseDialog(Exercise? exercise) {
    TextEditingController nameController = TextEditingController(text: exercise?.name ?? '');
    TextEditingController durationController = TextEditingController(text: exercise?.durationInSeconds.toString() ?? '');
    TextEditingController repetitionsController = TextEditingController(text: exercise?.repetitions.toString() ?? '');
    bool isTimeBased = exercise?.isTimeBased ?? true;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(exercise == null ? 'Add Exercise' : 'Edit Exercise'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: 'Exercise Name'),
                  ),
                  if (isTimeBased)
                    TextField(
                      controller: durationController,
                      decoration: InputDecoration(labelText: 'Duration (seconds)'),
                      keyboardType: TextInputType.number,
                    )
                  else
                    TextField(
                      controller: repetitionsController,
                      decoration: InputDecoration(labelText: 'Repetitions'),
                      keyboardType: TextInputType.number,
                    ),
                  Row(
                    children: [
                      Text('Time-based'),
                      Switch(
                        value: isTimeBased,
                        onChanged: (value) {
                          setState(() {
                            isTimeBased = value;
                          });
                        },
                      ),
                    ],
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
                    if (nameController.text.isNotEmpty &&
                        (isTimeBased ? durationController.text.isNotEmpty : repetitionsController.text.isNotEmpty)) {
                      setState(() {
                        if (exercise == null) {
                          _exercises.add(
                            Exercise(
                              name: nameController.text,
                              durationInSeconds: isTimeBased ? int.parse(durationController.text) : 0,
                              repetitions: isTimeBased ? 0 : int.parse(repetitionsController.text),
                              isTimeBased: isTimeBased,
                            ),
                          );
                        } else {
                          exercise.name = nameController.text;
                          exercise.durationInSeconds = isTimeBased ? int.parse(durationController.text) : 0;
                          exercise.repetitions = isTimeBased ? 0 : int.parse(repetitionsController.text);
                          exercise.isTimeBased = isTimeBased;
                        }
                      });
                    }
                    Navigator.pop(context);
                  },
                  child: Text(exercise == null ? 'Add' : 'Save'),
                ),
              ],
            );
          },
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
            .map((e) => {
          'name': e.name,
          'duration': e.durationInSeconds,
          'repetitions': e.repetitions,
          'isTimeBased': e.isTimeBased,
        })
            .toList(),
        'isBasic': false,
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Workout Title'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return Container(
                      height: 400,
                      child: Column(
                        children: [
                          ListTile(
                            title: Text('Add Custom Exercise'),
                            onTap: () {
                              Navigator.pop(context);
                              _addExerciseDialog(null);
                            },
                          ),
                          Expanded(
                            child: ListView(
                              children: ExerciseData.exercises.map((exerciseData) {
                                return ListTile(
                                  title: Text(exerciseData['name']),
                                  subtitle: Text(
                                    exerciseData['isTimeBased']
                                        ? '${exerciseData['durationInSeconds']} sec'
                                        : '${exerciseData['repetitions']} reps',
                                  ),
                                  onTap: () {
                                    Navigator.pop(context);
                                    setState(() {
                                      _exercises.add(
                                        Exercise(
                                          name: exerciseData['name'],
                                          durationInSeconds: exerciseData['durationInSeconds'],
                                          isTimeBased: true,
                                        ),
                                      );
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              child: Text('Add Exercise'),
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: _exercises.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 4),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListTile(
                      title: Text(_exercises[index].name),
                      subtitle: Text(
                        _exercises[index].isTimeBased
                            ? '${_exercises[index].durationInSeconds} sec'
                            : '${_exercises[index].repetitions} reps',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () => _addExerciseDialog(_exercises[index]),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              setState(() {
                                _exercises.removeAt(index);
                              });
                            },
                          ),
                        ],
                      ),
                    ),
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