class Exercise {
  String name;
  int durationInSeconds;
  int repetitions;
  bool isTimeBased;
  bool isCompleted;

  Exercise({
    required this.name,
    this.durationInSeconds = 0,
    this.repetitions = 0,
    this.isTimeBased = true,
    this.isCompleted = false,
  });
}

class Workout {
  String title;
  List<Exercise> exercises;
  bool isBasic;

  Workout({required this.title, required this.exercises, this.isBasic = false});
}

class QuoteData {
  static final List<Map<String, String>> quotes = [
    {
      "text": "Don't wait until you've reached your goal to be proud of yourself. Be proud of every step you take toward reaching that goal.",
      "author": "Unknown"
    },
    {
      "text": "Success is no accident. It is hard work, perseverance, learning, studying, sacrifice and most of all, love of what you are doing or learning to do.",
      "author": "Pele"
    },
    {
      "text": "The body achieves what the mind believes.",
      "author": "Unknown"
    },
    {
      "text": "It does not matter how slowly you go as long as you do not stop.",
      "author": "Confucius"
    },
    {
      "text": "Don't watch the clock; do what it does. Keep going.",
      "author": "Sam Levenson"
    },
    {
      "text": "The only way to do great work is to love what you do.",
      "author": "Steve Jobs"
    },
    {
      "text": "Push yourself because no one else is going to do it for you.",
      "author": "Unknown"
    },
    {
      "text": "Don't be afraid of failure. This is the way to succeed.",
      "author": "LeBron James"
    },
    {
      "text": "The pain you feel today is the strength you feel tomorrow.",
      "author": "Unknown"
    },
    {
      "text": "It’s not about perfect. It’s about effort.",
      "author": "Jillian Michaels"
    },
  ];
}

class ExerciseData {
  static final List<Map<String, dynamic>> exercises = [
    {
      "name": "Push-ups",
      "durationInSeconds": 60,
      "repetitions": 15,
      "isTimeBased": false,
    },
    {
      "name": "Squats",
      "durationInSeconds": 90,
      "repetitions": 20,
      "isTimeBased": false,
    },
    {
      "name": "Plank",
      "durationInSeconds": 120,
      "repetitions": 0,
      "isTimeBased": true,
    },
    {
      "name": "Lunges",
      "durationInSeconds": 180,
      "repetitions": 15,
      "isTimeBased": false,
    },
    {
      "name": "Burpees",
      "durationInSeconds": 120,
      "repetitions": 10,
      "isTimeBased": false,
    },
    {
      "name": "Jumping Jacks",
      "durationInSeconds": 150,
      "repetitions": 30,
      "isTimeBased": false,
    },
    {
      "name": "Mountain Climbers",
      "durationInSeconds": 60,
      "repetitions": 20,
      "isTimeBased": false,
    },
    {
      "name": "Tricep Dips",
      "durationInSeconds": 90,
      "repetitions": 15,
      "isTimeBased": false,
    },
    {
      "name": "High Knees",
      "durationInSeconds": 60,
      "repetitions": 30,
      "isTimeBased": false,
    },
    {
      "name": "Bicycle Crunches",
      "durationInSeconds": 60,
      "repetitions": 20,
      "isTimeBased": false,
    },
  ];
}

class WorkoutData {
  static final List<Map<String, dynamic>> workouts = [
    {
      "title": "Basic Workout",
      "exercises": [
        ExerciseData.exercises[0],
        ExerciseData.exercises[1],
        ExerciseData.exercises[2],
      ],
      "isBasic": true, // Флаг для базовой тренировки
    },
    {
      "title": "Advanced Workout",
      "exercises": [
        ExerciseData.exercises[3],
        ExerciseData.exercises[4],
        ExerciseData.exercises[5],
      ],
      "isBasic": true, // Флаг для базовой тренировки
    },
  ];
}