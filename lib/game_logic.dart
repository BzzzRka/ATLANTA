import 'dart:ui';
import 'package:flutter/material.dart';
import 'models.dart'; // Импортируем классы из models.dart

class GameLogic {
  // Проверка столкновений между пулей и астероидом
  static bool checkCollision(Bullet bullet, Asteroid asteroid) {
    final bulletRect = Rect.fromLTWH(
      bullet.position.dx,
      bullet.position.dy,
      bullet.width,
      bullet.height,
    );
    final asteroidRect = Rect.fromLTWH(
      asteroid.position.dx,
      asteroid.position.dy,
      asteroid.size,
      asteroid.size,
    );
    return bulletRect.overlaps(asteroidRect);
  }

  // Проверка столкновений астероидов с кораблем
  static bool checkShipCollision({
    required double spaceshipPosition,
    required List<Asteroid> asteroids,
    required BuildContext context,
    required int lives,
    required Function(int) updateLives,
    required Function() cancelMovement,
    required Function() playExplosionSound,
    required Function(Offset, double) addExplosion,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final spaceshipSize = screenWidth * 0.1;

    // Расчет позиции корабля
    final spaceshipCenterX = screenWidth / 2 +
        spaceshipPosition * screenWidth / 2 -
        spaceshipSize / 2;
    final spaceshipRect = Rect.fromLTWH(
      spaceshipCenterX,
      screenHeight * 0.8 - spaceshipSize * 0.8,
      spaceshipSize,
      spaceshipSize,
    );

    for (var asteroid in asteroids) {
      final asteroidRect = Rect.fromLTWH(
        asteroid.position.dx,
        asteroid.position.dy,
        asteroid.size,
        asteroid.size,
      );
      if (spaceshipRect.overlaps(asteroidRect)) {
        // Уменьшаем жизни
        updateLives(lives - 1);

        // Воспроизведение звука взрыва корабля
        playExplosionSound();

        // Добавляем взрыв корабля
        addExplosion(
          Offset(
            spaceshipCenterX,
            screenHeight * 0.8 - spaceshipSize * 0.8,
          ),
          spaceshipSize,
        );

        // Проверяем, остались ли жизни
        if (lives <= 0) {
          cancelMovement(); // Останавливаем игру
          return true; // Конец игры
        } else {
          return false; // Продолжаем игру
        }
      }
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

    // Расчет позиции корабля
    final spaceshipCenterX = screenWidth / 2 +
        spaceshipPosition * screenWidth / 2 -
        spaceshipSize / 2;

    // Одна пуля из передней части корабля
    bullets.add(
      Bullet(
        position: Offset(
          spaceshipCenterX + spaceshipSize / 2 - 2.5, // Центр пушки (половина ширины лазера)
          screenHeight * 0.8 - spaceshipSize * 0.8, // Передняя часть корабля
        ),
      ),
    );
  }

  // Увеличение скорости астероидов в зависимости от счета
  static double getAsteroidSpeed(int score) {
    return 1 + (score / 10).clamp(0, 5); // Максимальная скорость: 6
  }
}