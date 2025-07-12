import 'package:advanced_calculator/screen.dart';
import 'package:flutter/material.dart';

void main() => runApp(AdvancedCalculator());

class AdvancedCalculator extends StatelessWidget {
  const AdvancedCalculator({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Advanced Calculator',
    home: Screen(),
    debugShowCheckedModeBanner: false,
  );
}