import 'package:flutter/material.dart';
//import 'package:math_expressions/math_expressions.dart';

class Screen extends StatefulWidget {
  const Screen({super.key});

  @override
  ScreenState createState() => ScreenState();
}
class ScreenState extends State<Screen> {
  String display = '';

  void onButtonPressed(String value) {
    setState(() {
      if(value == 'CE') {
        display = '';
      } else if(value == 'C') {

      } else if(value == '=') {
        // expression evaluation
      } else {
        display += value;
      }
    });
  }

  Widget buildButton(String text, {Color color = Colors.grey}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: ElevatedButton(
          onPressed: () => onButtonPressed(text),
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            padding: const EdgeInsets.symmetric(vertical: 24),
          ),
          child: Text(text, style: const TextStyle(fontSize: 24)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text('Advanced Calculator')),
      body: Column(
        children: [
          Expanded(
            child: Container(
              alignment: Alignment.bottomRight,
              padding: const EdgeInsets.all(24),
              child: Text(
                display,
                style: const TextStyle(fontSize: 32),
              ),
            ),
          ),
          Row(
            children: [
              buildButton('7'),
              buildButton('8'),
              buildButton('9'),
              buildButton('÷', color: Colors.orange),
            ],
          ),
          Row(
            children: [
              buildButton('4'),
              buildButton('5'),
              buildButton('6'),
              buildButton('×', color: Colors.orange),
            ],
          ),
          Row(
            children: [
              buildButton('1'),
              buildButton('2'),
              buildButton('3'),
              buildButton('-', color: Colors.orange),
            ],
          ),
          Row(
            children: [
              buildButton('0'),
              buildButton('%', color: Colors.orange),
              buildButton('C', color: Colors.red),
              buildButton('+', color: Colors.orange),
            ],
          ),
          Row(
            children: [
              buildButton('=', color: Colors.green),
            ],
          ),
        ],
      ),
    );
}