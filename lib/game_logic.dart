import 'dart:ui';
import 'package:flutter/material.dart';
import 'models.dart'; // Импортируем классы из models.dart

class GameLogic {
  // Проверка столкновений между пулей и астероидом
  static bool checkCollision(Bullet bullet, Asteroid asteroid) {
    // Центр пули
    final bulletCenter = Offset(
      bullet.position.dx + bullet.width / 2,
      bullet.position.dy + bullet.height / 2,
    );

    // Центр астероида
    final asteroidCenter = Offset(
      asteroid.position.dx + asteroid.size / 2,
      asteroid.position.dy + asteroid.size / 2,
    );

    // Радиус астероида (половина его размера)
    final asteroidRadius = asteroid.size / 2;

    // Расстояние между центрами
    final distance = (bulletCenter - asteroidCenter).distance;

    // Проверка столкновения
    return distance <= asteroidRadius;
  }

  // Проверка столкновений астероидов с кораблем
  static bool checkShipCollision({
    required double spaceshipPosition,
    required List<Asteroid> asteroids,
    required BuildContext context,
    required int lives,
    required Function() playExplosionSound,
    required Function(Offset, double) addExplosion,
  }) {
    print('Current lives before collision check: $lives');
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final spaceshipSize = screenWidth * 0.1;

    // Центр корабля
    final spaceshipCenterX = screenWidth / 2 +
        spaceshipPosition * screenWidth / 2 -
        spaceshipSize / 2;
    final spaceshipCenter = Offset(
      spaceshipCenterX + spaceshipSize / 2, // Центр корабля по X
      screenHeight * 0.8 - spaceshipSize * 0.8 + spaceshipSize / 2, // Центр корабля по Y
    );

    // Радиус корабля (половина его размера)
    final spaceshipRadius = spaceshipSize / 2;

    for (var asteroid in asteroids) {
      // Центр астероида
      final asteroidCenter = Offset(
        asteroid.position.dx + asteroid.size / 2,
        asteroid.position.dy + asteroid.size / 2,
      );

      // Радиус астероида
      final asteroidRadius = asteroid.size / 2;

      // Расстояние между центрами
      final distance = (spaceshipCenter - asteroidCenter).distance;

      // Проверка столкновения
      if (distance <= spaceshipRadius + asteroidRadius)
        return true;
    }
    return false; // Нет столкновения
  }
  // Уничтожение всех астероидов на экране
  static void destroyAllAsteroids({
    required List<Asteroid> asteroids,
    required List<Explosion> explosions,
    required Function() playExplosionSound,
    required Function(int) updateScore,
  }) {
    for (var asteroid in asteroids.toList()) {
      // Добавляем взрыв для каждого астероида
      explosions.add(
        Explosion(
          position: Offset(
            asteroid.position.dx,
            asteroid.position.dy,
          ),
          size: asteroid.size,
        ),
      );

      // Удаляем астероид
      asteroids.remove(asteroid);

      // Увеличиваем счет за каждый уничтоженный астероид
      updateScore(1);
    }

    // Воспроизведение звука взрыва
    playExplosionSound();
  }

  // Выстрел из корабля
  static void shoot({
    required double spaceshipPosition,
    required List<Bullet> bullets,
    required BuildContext context,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final spaceshipSize = screenWidth * 0.1;

    // Расчет центра корабля
    final spaceshipCenterX = screenWidth / 2 +
        spaceshipPosition * screenWidth / 2 -
        spaceshipSize / 2;

    // Пуля вылетает из центра корабля (по X) и из передней части (по Y)
    bullets.add(
      Bullet(
        position: Offset(
          spaceshipCenterX + spaceshipSize / 2 - 2.5, // Центр корабля по X
          screenHeight * 0.8 - spaceshipSize * 0.8 - 20, // Передняя часть корабля по Y
        ),
      ),
    );
  }

  // Увеличение скорости астероидов в зависимости от счета
  static double getAsteroidSpeed(int score) {
    return 1 + (score / 10).clamp(0, 5); // Максимальная скорость: 6
  }
}
