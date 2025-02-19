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
    },
    {
      "name": "Squats",
      "durationInSeconds": 90,
    },
    {
      "name": "Plank",
      "durationInSeconds": 120,
    },
    {
      "name": "Lunges",
      "durationInSeconds": 180,
    },
    {
      "name": "Burpees",
      "durationInSeconds": 120,
    },
    {
      "name": "Jumping Jacks",
      "durationInSeconds": 150,
    },
  ];
}