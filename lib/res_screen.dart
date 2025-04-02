import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'MainMenu.dart';

class ResultScreen extends StatefulWidget {
  final bool isVictory; // Победа или поражение
  final int score; // Текущий счет
  final int bestScore; // Лучший счет

  const ResultScreen({
    required this.isVictory,
    required this.score,
    required this.bestScore,
  });

  @override
  _ResultScreenState createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer(); // Для воспроизведения звука

  @override
  void initState() {
    super.initState();
    _playSound(); // Автоматически проигрываем звук при загрузке экрана
  }

  // Метод для воспроизведения звука победы или поражения
  void _playSound() async {
    String soundPath = widget.isVictory
        ? 'assets/sounds/win.mp3' // Звук победы
        : 'assets/sounds/lose.mp3'; // Звук поражения
    await _audioPlayer.play(AssetSource(soundPath)); // Проигрываем звук
  }

  @override
  void dispose() {
    _audioPlayer.dispose(); // Освобождаем ресурсы при закрытии экрана
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/about.png'), // Путь к вашему фоновому изображению
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Контейнер с черной рамкой и белым текстом
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.8), // Черная рамка с прозрачностью
                  borderRadius: BorderRadius.circular(10), // Закругленные углы
                ),
                child: Column(
                  children: [
                    Text(
                      widget.isVictory ? 'Вы победили!' : 'Вы проиграли...',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: widget.isVictory ? Colors.greenAccent : Colors.redAccent,
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Ваш счет: ${widget.score}',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Лучший счет: ${widget.bestScore}',
                      style: TextStyle(fontSize: 16, color: Colors.grey[400]),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 40),
              // Кнопка "В главное меню"
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MainMenScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black87, // Цвет фона кнопки
                  foregroundColor: Colors.white, // Цвет текста
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 5, // Тень кнопки
                ),
                child: Text(
                  'В главное меню',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}