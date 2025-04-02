
import 'package:atlanta/stardodging.dart';
import 'package:atlanta/utils.dart';
import 'package:flutter/material.dart';

import 'InfoScreen.dart';
import 'dif_select.dart';
import 'main.dart';
import 'models.dart';

class MainMenScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Главное меню'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DifficultySelectionScreen(),
                  ),
                );
              },
              child: Text('Режим Астероиды'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DifficultySelectionScreenStar(),
                  ),
                );
              },
              child: Text('Режим Звезды'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => InfoScreen(),
                  ),
                );
              },
              child: Text('Информация об игре'),
            ),
          ],
        ),
      ),
    );
  }
}