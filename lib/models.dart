import 'dart:math';
import 'dart:ui';

// Класс для астероидов
class Asteroid {
  Offset position;
  double size;
  double speed;
  double rotationAngle; // Угол поворота
  final double rotationSpeed; // Скорость вращения

  Asteroid({double? speed})
      : position = Offset(
    Random().nextDouble() * 300, // Случайная позиция по X
    0, // Начальная позиция над экраном
  ),
        size = 50 + Random().nextDouble() * 50, // Случайный размер
        speed = speed ?? 1 + Random().nextDouble() * 2, // Скорость
        rotationAngle = Random().nextDouble() * 360, // Начальный угол
        rotationSpeed = 0.5 + Random().nextDouble() * 2; // Случайная скорость вращения
}

// Класс для пуль
class Bullet {
  Offset position;
  double width; // Ширина лазера
  double height; // Длина лазера
  double speed;

  Bullet({required this.position})
      : width = 5, // Ширина лазера
        height = 20, // Длина лазера
        speed = 15; // Скорость лазера
}

// Класс для взрывов
class Explosion {
  Offset position;
  double size;
  DateTime startTime;

  Explosion({required this.position, required this.size})
      : startTime = DateTime.now();
}

// Класс для бонусов
class Bonus {
  Offset position;
  double size;
  String type; // Тип бонуса ('life' или 'weapon')

  Bonus({required this.type})
      : position = Offset(
    Random().nextDouble() * 300, // Случайная позиция по X
    0, // Начальная позиция над экраном
  ),
        size = 30 + Random().nextDouble() * 20; // Случайный размер
}

enum DifficultyLevel { easy, hard, infinite, starDodging }

DifficultyLevel currentLevel = DifficultyLevel.easy;