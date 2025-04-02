import 'package:flutter/material.dart';

class InfoScreen extends StatelessWidget {
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Container(
              padding: EdgeInsets.all(16), // Внутренние отступы для текста
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.8), // Черная рамка с прозрачностью
                borderRadius: BorderRadius.circular(10), // Закругленные углы
              ),
              child: Text(
                'Приветствуем в игре "Космический защитник"!\n\n'
                    'В этой игре вы управляете космическим кораблем по имени atlanta и должны уклоняться от падающих объектов '
                    '(астероидов или звезд) и набирать очки.\n\n'
                    'Удачи!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white, // Белый цвет текста
                  fontWeight: FontWeight.bold, // Жирный шрифт
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}