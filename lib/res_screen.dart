import 'package:flutter/material.dart';

import 'dif_select.dart';

class ResultScreen extends StatelessWidget {
  final bool isVictory; // Победа или поражение
  final int score; // Текущий счет
  final int bestScore; // Лучший счет

  const ResultScreen({
    required this.isVictory,
    required this.score,
    required this.bestScore,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isVictory ? 'Поздравляем!' : 'Увы...'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isVictory
                  ? 'Вы победили!'
                  : 'Вы проиграли...',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isVictory ? Colors.green : Colors.red,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Ваш счет: $score',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              'Лучший счет: $bestScore',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DifficultySelectionScreen(),
                  ),
                );
              },
              child: Text('Выбрать уровень'),
            ),
          ],
        ),
      ),
    );
  }
}