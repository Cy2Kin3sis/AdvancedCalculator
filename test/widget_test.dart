import 'package:flutter/material.dart';

void main() => runApp(AdvancedCalculator());

class AdvancedCalculator extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Advanced Calculator',
    debugShowCheckedModeBanner: false,
  );
}

class Screen extends StatefulWidget {
  @override
  _ScreenState createState() => _ScreenState();
}
class _ScreenState extends State<Screen> {
  @override
  Widget build(BuildContext context) => Scaffold();
}