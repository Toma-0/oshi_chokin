import 'package:flutter/material.dart';

class DentakuPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
          ),
          child: Container(
            child: Text(
              '<',
              style: TextStyle(
                color: Colors.black,
              ),
            ),
          ),
          onPressed: () {
            // 1つ前に戻る
            Navigator.pop(context);
          },
        ),
        title: Text("次のページ"),
      ),
      body: Container(
        height: double.infinity,
        color: Colors.white,
      ),
      ),
    );
  }
}