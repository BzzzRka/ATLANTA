import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart'; // Импортируйте FirebaseAuth
import 'package:atlanta/stats_screen.dart';
import 'package:flutter/material.dart';
import 'main.dart';
import 'models.dart';
import 'quotes_screen.dart';
import 'notes_screen.dart';
import 'login_screen.dart'; // Импортируйте экран логина

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String? _randomQuote;
  String? _randomAuthor;

  @override
  void initState() {
    super.initState();
    _getRandomQuote();
  }

  void _getRandomQuote() {
    final random = Random();
    final quote = QuoteData.quotes[random.nextInt(QuoteData.quotes.length)];
    setState(() {
      _randomQuote = quote["text"];
      _randomAuthor = quote["author"];
    });
  }

  @override
  Widget build(BuildContext context) {
    // Проверка, авторизован ли пользователь
    final user = FirebaseAuth.instance.currentUser;

    // Если пользователь не авторизован, показываем экран регистрации
    if (user == null) {
      return LoginScreen(); // Отправляем на экран входа
    }

    // Если пользователь авторизован, показываем основной экран
    return Scaffold(
      appBar: AppBar(title: Text('Atlanta Fitness')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _randomQuote ?? "",
                      style: TextStyle(fontStyle: FontStyle.italic, fontSize: 16),
                    ),
                    SizedBox(height: 8),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Text(
                        '- ${_randomAuthor ?? ""}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              children: [
                _buildMenuButton('Workouts', Icons.fitness_center, HomeScreen()),
                _buildMenuButton('Statistics', Icons.show_chart, StatisticsScreen()),
                _buildMenuButton('Quotes', Icons.format_quote, QuotesScreen()),
                _buildMenuButton('Notes', Icons.note, NotesScreen()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton(String title, IconData icon, Widget destination) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => destination),
        );
      },
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32),
          SizedBox(height: 8),
          Text(title),
        ],
      ),
    );
  }
}
