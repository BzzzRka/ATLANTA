import 'package:flutter/material.dart';

class InfoScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Информация об игре'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Text(
            'Приветствуем в игре "Космический защитник"!\n\n'
                'В этой игре вы управляете космическим кораблем и должны уклоняться от падающих объектов '
                '(астероидов или звезд) и набирать очки.\n\n'
                'Удачи!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}