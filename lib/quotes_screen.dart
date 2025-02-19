import 'package:flutter/material.dart';

import 'models.dart';

class QuotesScreen extends StatelessWidget {
  final List<Map<String, String>> quotes = QuoteData.quotes;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Inspirational Quotes')),
      body: ListView.builder(
        itemCount: quotes.length,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.all(10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            elevation: 5,
            child: ListTile(
              contentPadding: EdgeInsets.all(16),
              title: Text(
                quotes[index]["text"]!,
                style: TextStyle(fontStyle: FontStyle.italic, fontSize: 16),
              ),
              subtitle: Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  '- ${quotes[index]["author"]}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
