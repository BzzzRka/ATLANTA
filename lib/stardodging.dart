import 'dart:async';
import 'dart:math';

import 'package:atlanta/res_screen.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'MainMenu.dart';
import 'game_logic.dart';
import 'models.dart';

class StarDodgingScreen extends StatefulWidget {
  final DifficultyLevel difficulty;

  StarDodgingScreen({required this.difficulty});

  @override
  _StarDodgingScreenState createState() => _StarDodgingScreenState();
}

class _StarDodgingScreenState extends State<StarDodgingScreen> {
  double spaceshipPosition = 0; // Позиция корабля (от -1 до 1)
  int score = 0; // Количество уничтоженных астероидов
  int bestScore1 = 0; // Лучший счет
  int lives = 3; // Количество жизней
  List<Asteroid> asteroids = []; // Список астероидов
  List<Bullet> bullets = []; // Список пуль
  List<Explosion> explosions = []; // Список взрывов
  List<Bonus> bonuses = []; // Список бонусов
  Timer? asteroidTimer; // Таймер для создания новых астероидов
  Timer? bonusTimer; // Таймер для создания новых бонусов
  Timer? gameTimer;
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
    targetScore = 60;
    startAsteroidGeneration();
    startBonusGeneration();
    startMovement();
    startGameTimer();
    _startBackgroundMusic(); // Запускаем саундтрек
  }

  @override
  void dispose() {
    asteroidTimer?.cancel();
    bonusTimer?.cancel();
    gameTimer?.cancel();
    movementTimer?.cancel();
    backgroundMusicPlayer.dispose(); // Освобождаем ресурсы аудиоплеера
    super.dispose();
  }

  // Отсчет времени игры
  void startGameTimer() {
    gameTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        score++;
        checkWinCondition();
      });
    });
  }

  // Check if the player has won
  void checkWinCondition() {
    if (targetScore > 0 && score >= targetScore) {
      movementTimer?.cancel();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              ResultScreen(
                isVictory: true,
                score: score,
                bestScore: bestScore1,
              ),
        ),
      );
    }
  }

  void playEffect(String s) {
    if (!isMusicPlaying)
    {
      _audioPlayer.play(AssetSource(s));
    }
  }

  // Загрузка лучшего результата
  Future<void> loadBestScore() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      bestScore1 = prefs.getInt('bestScore1') ?? 0;
    });
  }

  // Сохранение лучшего результата
  Future<void> saveBestScore() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('bestScore1', bestScore1);
  }

  // Обновление лучшего результата
  void updateBestScore() {
    if (score > bestScore1) {
      setState(() {
        bestScore1 = score;
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
    if (widget.difficulty == DifficultyLevel.easy) {
      bonusTimer = Timer.periodic(Duration(seconds: 10), (timer) {
        setState(() {
          final randomType = Random().nextBool()
              ? 'life'
              : 'weapon'; // Случайный тип бонуса
          bonuses.add(Bonus(type: randomType));
        });
      });
    }
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
          addExplosion: (position, size) =>
              setState(() {
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
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ResultScreen(
                      isVictory: false,
                      score: score,
                      bestScore: bestScore1,
                    ),
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
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    final screenHeight = MediaQuery
        .of(context)
        .size
        .height;
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
      backgroundMusicPlayer.setReleaseMode(
          ReleaseMode.loop); // Зацикливаем музыку
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
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    final screenHeight = MediaQuery
        .of(context)
        .size
        .height;

    final spaceshipSize = screenWidth * 0.1;

    return Scaffold(
      appBar: AppBar(
        title: Text('Космический защитник'),
        actions: [
          // главное меню
          IconButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => MainMenScreen(),
                ),
              );
            },
            icon: Icon(Icons.home),
            tooltip: 'В главное меню',
          ),
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
              'assets/bg.gif',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
            // Космический корабль
            Positioned(
              bottom: screenHeight * 0.1,
              left: screenWidth / 2 +
                  spaceshipPosition * screenWidth / 2 -
                  1.5 * spaceshipSize / 2,
              child: Image.asset(
                'assets/ufo.gif',
                width: 1.5 * spaceshipSize,
                height: 1.5 * spaceshipSize,
              ),
            ),
            // Астероиды
            ...asteroids.map((asteroid) {
              return Positioned(
                top: asteroid.position.dy,
                left: asteroid.position.dx,
                child: Image.asset(
                  'assets/star.gif',
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
                    borderRadius: BorderRadius.circular(
                        5), // Закругленные края
                  ),
                ),
              );
            }).toList(),
            // Взрывы
            ...explosions.map((explosion) {
              final opacity = 1.0 - (DateTime
                  .now()
                  .difference(explosion.startTime)
                  .inMilliseconds / 500);
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
                  bonus.type == 'life'
                      ? 'assets/bonus_life.gif'
                      : 'assets/bonus_weapon.gif',
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
                    'Лучший: $bestScore1',
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
                      (index) =>
                      Icon(Icons.favorite, color: Colors.red, size: 20),
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
                    : 'Cложный',
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