import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dif_select.dart';
import 'models.dart'; // Импортируем классы из models.dart
import 'game_logic.dart'; // Импортируем логику игры

void main() {
  runApp(SpaceDefenderApp());
}

class SpaceDefenderApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Космический защитник',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: DifficultySelectionScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  final DifficultyLevel difficulty;

  GameScreen({required this.difficulty});

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  double spaceshipPosition = 0; // Позиция корабля (от -1 до 1)
  int score = 0; // Количество уничтоженных астероидов
  int bestScore = 0; // Лучший счет
  int lives = 3; // Количество жизней
  List<Asteroid> asteroids = []; // Список астероидов
  List<Bullet> bullets = []; // Список пуль
  List<Explosion> explosions = []; // Список взрывов
  List<Bonus> bonuses = []; // Список бонусов
  Timer? asteroidTimer; // Таймер для создания новых астероидов
  Timer? bonusTimer; // Таймер для создания новых бонусов
  Timer? movementTimer; // Таймер для движения объектов
  final AudioPlayer _audioPlayer = new AudioPlayer(); // Для воспроизведения звуков
  bool isPaused = false; // Флаг для состояния паузы
  bool isMusicPlaying = true; // Флаг для состояния саундтрека
  final AudioPlayer backgroundMusicPlayer = new AudioPlayer(); // Отдельный аудиоплеер для саундтрека
  int targetScore = 0; // Target score to win the game

  @override
  void initState() {
    super.initState();
    loadBestScore();

    // Set target score based on difficulty
    if (widget.difficulty == DifficultyLevel.easy) {
      targetScore = 10;
    } else if (widget.difficulty == DifficultyLevel.hard) {
      targetScore = 1000;
    } else {
      targetScore = -1; // Infinite mode has no target score
    }

    startAsteroidGeneration();
    startBonusGeneration();
    startMovement();
    _startBackgroundMusic(); // Запускаем саундтрек
  }

  @override
  void dispose() {
    asteroidTimer?.cancel();
    bonusTimer?.cancel();
    movementTimer?.cancel();
    backgroundMusicPlayer.dispose(); // Освобождаем ресурсы аудиоплеера
    super.dispose();
  }

  // Check if the player has won
  void checkWinCondition() {
    if (targetScore > 0 && score >= targetScore) {
      movementTimer?.cancel();
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Победа!"),
          content: Text("Вы достигли цели: $score очков!"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                resetGame();
              },
              child: Text("Играть снова"),
            ),
          ],
        ),
      );
    }
  }

  void playEffect(String s) {
    _audioPlayer.play(AssetSource(s));
  }

  // Загрузка лучшего результата
  Future<void> loadBestScore() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      bestScore = prefs.getInt('bestScore') ?? 0;
    });
  }

  // Сохранение лучшего результата
  Future<void> saveBestScore() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('bestScore', bestScore);
  }

  // Обновление лучшего результата
  void updateBestScore() {
    if (score > bestScore) {
      setState(() {
        bestScore = score;
      });
      saveBestScore();
    }
  }

  // Логика перемещения корабля
  void moveSpaceship(double deltaX) {
    setState(() {
      spaceshipPosition += deltaX;
      if (spaceshipPosition > 1) spaceshipPosition = 1;
      if (spaceshipPosition < -1) spaceshipPosition = -1;
    });
  }

  // Генерация новых астероидов
  void startAsteroidGeneration() {
    asteroidTimer = Timer.periodic(Duration(seconds: 2), (timer) {
      setState(() {
        asteroids.add(Asteroid(speed: GameLogic.getAsteroidSpeed(score)));
      });
    });
  }

  // Генерация новых бонусов
  void startBonusGeneration() {
    bonusTimer = Timer.periodic(Duration(seconds: 10), (timer) {
      setState(() {
        final randomType = Random().nextBool() ? 'life' : 'weapon'; // Случайный тип бонуса
        bonuses.add(Bonus(type: randomType));
      });
    });
  }

  // Движение объектов (астероиды, пули, бонусы)
  void startMovement() {
    movementTimer = Timer.periodic(Duration(milliseconds: 50), (timer) {
      setState(() {
        // Движение астероидов вниз
        for (var asteroid in asteroids) {
          asteroid.position = Offset(
            asteroid.position.dx,
            asteroid.position.dy + asteroid.speed,
          );
        }

        // Движение пуль вверх
        for (var bullet in bullets) {
          bullet.position = Offset(
            bullet.position.dx,
            bullet.position.dy - bullet.speed,
          );
        }

        // Движение бонусов вниз
        for (var bonus in bonuses) {
          bonus.position = Offset(
            bonus.position.dx,
            bonus.position.dy + 2, // Бонусы движутся медленнее
          );
        }

        // Удаляем астероиды, которые вышли за пределы экрана
        asteroids.removeWhere((asteroid) => asteroid.position.dy > 1000);

        // Удаляем пули, которые вышли за пределы экрана
        bullets.removeWhere((bullet) => bullet.position.dy < -100);

        // Удаляем бонусы, которые вышли за пределы экрана
        bonuses.removeWhere((bonus) => bonus.position.dy > 1000);

        // Проверка столкновений пуль с астероидами
        for (var bullet in bullets.toList()) {
          for (var asteroid in asteroids.toList()) {
            if (GameLogic.checkCollision(bullet, asteroid)) {
              // Удаляем пулю и астероид
              bullets.remove(bullet);
              asteroids.remove(asteroid);
              score++; // Увеличиваем счет

              // Добавляем взрыв
              explosions.add(
                Explosion(
                  position: Offset(
                    asteroid.position.dx,
                    asteroid.position.dy,
                  ),
                  size: asteroid.size,
                ),
              );

              // Воспроизведение звука взрыва
              playEffect('sounds/explosion.mp3');

              break; // Переходим к следующей пуле
            }
          }
        }

        // Проверка столкновений бонусов с кораблем
        _checkBonusCollision();

        // Проверка столкновений астероидов с кораблем
        if (GameLogic.checkShipCollision(
          spaceshipPosition: spaceshipPosition,
          asteroids: asteroids,
          context: context,
          lives: lives,
          playExplosionSound: () => playEffect('sounds/ship_explosion.mp3'),
          addExplosion: (position, size) => setState(() {
            explosions.add(Explosion(position: position, size: size));
          }),
        )) {
          GameLogic.destroyAllAsteroids(
            asteroids: asteroids,
            explosions: explosions,
            playExplosionSound: () => playEffect('sounds/explosion.mp3'),
            updateScore: (value) => setState(() => score += value),
          );
          setState(() => lives = lives - 1);
          if (lives == 0) {
            movementTimer?.cancel();
            updateBestScore(); // Обновляем лучший счет
            showDialog(
              context: context,
              builder: (context) =>
                  AlertDialog(
                    title: Text("Game Over"),
                    content: Text(
                        "Вы проиграли! Ваш счет: $score\nЛучший счет: $bestScore"),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context); // Закрыть диалог
                          resetGame(); // Перезапустить игру
                        },
                        child: Text("Попробовать снова"),
                      ),
                    ],
                  ),
            );
          }
        }
      });
      checkWinCondition();
    });
  }

  // Проверка столкновений бонусов с кораблем
  void _checkBonusCollision() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final spaceshipSize = screenWidth * 0.1;

    // Центр корабля
    final spaceshipCenterX = screenWidth / 2 +
        spaceshipPosition * screenWidth / 2 -
        spaceshipSize / 2;
    final spaceshipCenter = Offset(
      spaceshipCenterX + spaceshipSize / 2,
      screenHeight * 0.8 - spaceshipSize * 0.8 + spaceshipSize / 2,
    );

    // Радиус корабля
    final spaceshipRadius = spaceshipSize / 2;

    for (var bonus in bonuses.toList()) {
      // Центр бонуса
      final bonusCenter = Offset(
        bonus.position.dx + bonus.size / 2,
        bonus.position.dy + bonus.size / 2,
      );

      // Радиус бонуса
      final bonusRadius = bonus.size / 2;

      // Расстояние между центрами
      final distance = (spaceshipCenter - bonusCenter).distance;

      // Проверка столкновения
      if (distance <= spaceshipRadius + bonusRadius) {
        // Применяем эффект бонуса
        if (bonus.type == 'life') {
          setState(() {
            lives++;
          });
        } else if (bonus.type == 'weapon') {
          GameLogic.destroyAllAsteroids(
            asteroids: asteroids,
            explosions: explosions,
            playExplosionSound: () => playEffect('sounds/explosion.mp3'),
            updateScore: (value) => setState(() => score += value),
          );
        }
        playEffect('sounds/bonus_sound.mp3');
        bonuses.remove(bonus);
      }
    }
  }

  // Выстрел из корабля
  void shoot() {
    GameLogic.shoot(
      spaceshipPosition: spaceshipPosition,
      bullets: bullets,
      context: context,
    );
    playEffect('sounds/shoot.mp3');;
  }

  // Сброс игры
  void resetGame() {
    setState(() {
      spaceshipPosition = 0;
      score = 0;
      lives = 3;
      asteroids.clear();
      bullets.clear();
      explosions.clear();
      bonuses.clear();
      startAsteroidGeneration();
      startBonusGeneration();
      startMovement();
    });
  }

  // Запуск саундтрека
  void _startBackgroundMusic() {
    if (isMusicPlaying) {
      backgroundMusicPlayer.play(AssetSource('sounds/background_music.mp3'));
      backgroundMusicPlayer.setReleaseMode(ReleaseMode.loop); // Зацикливаем музыку
    }
  }

  // Остановка саундтрека
  void _stopBackgroundMusic() {
    backgroundMusicPlayer.stop();
  }

  // Переключение состояния саундтрека
  void toggleMusic() {
    setState(() {
      isMusicPlaying = !isMusicPlaying;
      if (isMusicPlaying) {
        _startBackgroundMusic();
      } else {
        _stopBackgroundMusic();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final spaceshipSize = screenWidth * 0.1;

    return Scaffold(
      appBar: AppBar(
        title: Text('Космический защитник'),
        actions: [
          // Кнопка паузы
          IconButton(
            onPressed: () {
              setState(() {
                isPaused = !isPaused; // Переключаем состояние паузы
                if (isPaused) {
                  movementTimer?.cancel(); // Останавливаем таймеры
                  asteroidTimer?.cancel();
                  bonusTimer?.cancel();
                } else {
                  startMovement(); // Возобновляем движение
                  startAsteroidGeneration();
                  startBonusGeneration();
                }
              });
            },
            icon: Icon(isPaused ? Icons.play_arrow : Icons.pause),
          ),
          // Кнопка включения/выключения саундтрека
          IconButton(
            onPressed: toggleMusic,
            icon: Icon(isMusicPlaying ? Icons.music_note : Icons.music_off),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: shoot, // Выстрел при нажатии на экран
        child: Stack(
          children: [
            // Фон
            Image.asset(
              'assets/background.jpg',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
            // Космический корабль
            Positioned(
              bottom: screenHeight * 0.1,
              left: screenWidth / 2 +
                  spaceshipPosition * screenWidth / 2 -
                  1.5*spaceshipSize / 2,
              child: Image.asset(
                'assets/spaceship.png',
                width: 1.5*spaceshipSize,
                height: 1.5*spaceshipSize,
              ),
            ),
            // Астероиды
            ...asteroids.map((asteroid) {
              return Positioned(
                top: asteroid.position.dy,
                left: asteroid.position.dx,
                child: Image.asset(
                  'assets/asteroid.png',
                  width: asteroid.size,
                  height: asteroid.size,
                ),
              );
            }).toList(),
            // Пули
            ...bullets.map((bullet) {
              return Positioned(
                top: bullet.position.dy,
                left: bullet.position.dx,
                child: Container(
                  width: bullet.width,
                  height: bullet.height,
                  decoration: BoxDecoration(
                    color: Colors.lightBlueAccent, // Цвет лазера
                    borderRadius: BorderRadius.circular(5), // Закругленные края
                  ),
                ),
              );
            }).toList(),
            // Взрывы
            ...explosions.map((explosion) {
              final opacity = 1.0 - (DateTime.now().difference(explosion.startTime).inMilliseconds / 500);
              if (opacity <= 0) {
                // Создаем копию списка и удаляем старые взрывы
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  setState(() {
                    explosions.remove(explosion);
                  });
                });
                return SizedBox.shrink();
              }
              return Positioned(
                top: explosion.position.dy,
                left: explosion.position.dx,
                child: Opacity(
                  opacity: opacity,
                  child: Container(
                    width: explosion.size,
                    height: explosion.size,
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              );
            }).toList(),
            // Бонусы
            ...bonuses.map((bonus) {
              return Positioned(
                top: bonus.position.dy,
                left: bonus.position.dx,
                child: Image.asset(
                  bonus.type == 'life' ? 'assets/bonus_life.gif' : 'assets/bonus_weapon.gif',
                  width: bonus.size,
                  height: bonus.size,
                ),
              );
            }).toList(),
            // Счётчик очков и лучший счет
            Positioned(
              top: 10,
              left: 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Очки: $score',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Лучший: $bestScore',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            // Жизни
            Positioned(
              top: 10,
              right: 60, // Убираем кнопку паузы из этого места
              child: Row(
                children: List.generate(
                  lives > 0 ? lives : 0, // Защита от отрицательных значений
                      (index) => Icon(Icons.favorite, color: Colors.red, size: 20),
                ),
              ),
            ),
            // Кнопки управления
            Positioned(
              bottom: screenHeight * 0.3, // Расположение кнопок ниже середины
              left: 20, // Отступ слева
              child: FloatingActionButton(
                onPressed: () => moveSpaceship(-0.1),
                child: Icon(Icons.arrow_left),
              ),
            ),
            Positioned(
              bottom: screenHeight * 0.3, // То же расположение по вертикали
              right: 20, // Отступ справа
              child: FloatingActionButton(
                onPressed: () => moveSpaceship(0.1),
                child: Icon(Icons.arrow_right),
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: Text(
                widget.difficulty == DifficultyLevel.easy
                    ? 'Легкий'
                    : widget.difficulty == DifficultyLevel.hard
                    ? 'Сложный'
                    : 'Бесконечный',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),

    );
  }
}