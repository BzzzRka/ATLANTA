import 'package:atlanta/utils.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'InfoScreen.dart';
import 'dif_select.dart';
import 'stardodging.dart';

class MainMenScreen extends StatefulWidget {
  @override
  _MainMenScreenState createState() => _MainMenScreenState();
}

class _MainMenScreenState extends State<MainMenScreen> with WidgetsBindingObserver {
  final AudioPlayer _audioPlayer = AudioPlayer(); // Для воспроизведения звука
  bool _isMusicPlaying = true; // Флаг для состояния музыки

  @override
  void initState() {
    super.initState();
    _playBackgroundMusic(); // Автоматически запускаем музыку при загрузке экрана
    WidgetsBinding.instance.addObserver(this); // Подписываемся на изменения состояния
  }

  // Метод для воспроизведения фоновой музыки
  void _playBackgroundMusic() async {
    if (_isMusicPlaying) {
      _audioPlayer.play(AssetSource('sounds/track.mp3')); // Указываем путь к треку
      _audioPlayer.setReleaseMode(ReleaseMode.loop); // Зацикливаем музыку
    }
  }

  // Остановка саундтрека
  void _stopBackgroundMusic() {
    _audioPlayer.stop();
  }

  // Переключение состояния саундтрека
  void toggleMusic() {
    setState(() {
      _isMusicPlaying = !_isMusicPlaying;
      if (_isMusicPlaying) {
        _playBackgroundMusic();
      } else {
        _stopBackgroundMusic();
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose(); // Освобождаем ресурсы при закрытии экрана
    WidgetsBinding.instance.removeObserver(this); // Отписываемся от изменений состояния
    super.dispose();
  }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.paused) {
      // Приложение свернуто — останавливаем музыку и таймеры
      _stopBackgroundMusic();
    } else if (state == AppLifecycleState.resumed) {
      // Приложение снова активно — возобновляем музыку и таймеры
      if (_isMusicPlaying) {
        _playBackgroundMusic();
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/im.png'), // Путь к вашему фоновому изображению
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Улучшенный заголовок
              Text(
                'Главное меню',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      blurRadius: 5,
                      color: Colors.black.withOpacity(0.7),
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 40),

              // Кнопка "Режим Астероиды"
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DifficultySelectionScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black87,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 5,
                ),
                child: Text(
                  'Режим Астероиды',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              SizedBox(height: 20),

              // Кнопка "Режим Звезды"
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DifficultySelectionScreenStar(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black87,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 5,
                ),
                child: Text(
                  'Режим Звезды',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              SizedBox(height: 20),

              // Кнопка "Информация об игре"
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => InfoScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black87,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 5,
                ),
                child: Text(
                  'Информация об игре',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              SizedBox(height: 20),

              // Иконка для отключения/включения музыки
              IconButton(
                onPressed: toggleMusic,
                icon: Icon(
                  _isMusicPlaying ? Icons.volume_up : Icons.volume_off,
                  size: 40, // Размер иконки
                  color: Colors.white, // Цвет иконки
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}