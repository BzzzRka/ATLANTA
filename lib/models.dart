class Exercise {
  String name;
  int durationInSeconds;
  bool isCompleted;

  Exercise({required this.name, required this.durationInSeconds, this.isCompleted = false});
}

class Workout {
  String title;
  List<Exercise> exercises;

  Workout({required this.title, required this.exercises});
}