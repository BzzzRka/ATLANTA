import 'package:flutter/material.dart';
import 'main.dart';
import 'models.dart';


class DifficultySelectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Выберите уровень сложности'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GameScreen(difficulty: DifficultyLevel.easy),
                  ),
                );
              },
              child: Text('Легкий уровень'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GameScreen(difficulty: DifficultyLevel.hard),
                  ),
                );
              },
              child: Text('Сложный уровень'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GameScreen(difficulty: DifficultyLevel.infinite),
                  ),
                );
              },
              child: Text('Бесконечный уровень'),
            ),
          ],
        ),
      ),
    );
  }
}