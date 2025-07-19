import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

class Screen extends StatefulWidget {
  const Screen({super.key});

  @override
  ScreenState createState() => ScreenState();
}
class ScreenState extends State<Screen> {
  String _expression = '';
  String _result = '';
  final Map<String, double> _variables = {'x': 0, 'y': 0, 'z': 0};
  final Color ch = Colors.black87;

  final ShuntingYardParser _parser = ShuntingYardParser();
  final ContextModel _contextModel = ContextModel();

  void _onPressed(String value) => setState(() {
    if (value == 'CE') {
      _expression = '';
      _result = '';
    } else if (value == 'C') {
      if (_expression.isNotEmpty) {
        _expression = _expression.substring(0, _expression.length - 1);
      }
    } else if (value == '=') {
      _evaluateExpression();
    } else if (value == '→x' || value == '→y' || value == '→z') {
      final variable = value.substring(1); // Get 'x', 'y', or 'z'
      _assignToVariable(variable);
    } else if (['sin', 'cos', 'tan', 'ln', 'sqrt', 'log', 'nrt'].contains(value)) {
      // Automatically add space after functions for better formatting
      _expression += value + ' ';
    } else if (value == '.') {
      // Validate decimal point input to prevent multiple decimals in one number
      if (_canAddDecimal()) {
        _expression += value;
      }
    } else {
      _expression += value;
    }
  });

  // Validate if a decimal point can be added to prevent multiple decimals in one number
  bool _canAddDecimal() {
    if (_expression.isEmpty) return true;

    // Find the current number being typed (from the end of expression)
    // Look for the last occurrence of operators, spaces, or parentheses
    final operatorPattern = RegExp(r'[+\-×÷*/()^%,\s]');
    int lastOperatorIndex = -1;

    // Find the last operator position
    for (int i = _expression.length - 1; i >= 0; i--) {
      if (operatorPattern.hasMatch(_expression[i])) {
        lastOperatorIndex = i;
        break;
      }
    }

    // Extract the current number being typed
    String currentNumber = _expression.substring(lastOperatorIndex + 1);

    // Check if current number already contains a decimal point
    return !currentNumber.contains('.');
  }
  String _preprocessExpression(String expr) {
    // Replace display symbols with parser-compatible ones
    expr = expr.replaceAll('×', '*');
    expr = expr.replaceAll('÷', '/');

    // Remove extra spaces around function names
    expr = expr.replaceAll(RegExp(r'\s+'), ' ').trim();

    // Handle percentage conversion (e.g., "50%" becomes "50/100", "x%" becomes "x/100")
    expr = expr.replaceAllMapped(RegExp(r'([0-9.]+|[xyz])\s*%'), (match) => '(${match.group(1)}/100)');

    // Handle implicit multiplication patterns with improved regex
    // Pattern 1: number followed by variable (e.g., "4x", "2.5y")
    expr = expr.replaceAllMapped(
      RegExp(r'(\d+(?:\.\d+)?)\s*([xyz])(?![a-zA-Z])'),
          (match) => '${match.group(1)}*${match.group(2)}',
    );

    // Pattern 2: variable followed by number (e.g., "x4", "y2.5")
    expr = expr.replaceAllMapped(
      RegExp(r'([xyz])\s*(\d+(?:\.\d+)?)'),
          (match) => '${match.group(1)}*${match.group(2)}',
    );

    // Pattern 3: variable followed by variable (e.g., "xy", "xz")
    expr = expr.replaceAllMapped(
      RegExp(r'([xyz])\s*([xyz])'),
          (match) => '${match.group(1)}*${match.group(2)}',
    );

    // Pattern 4: number/variable followed by opening parenthesis (avoid function names)
    expr = expr.replaceAllMapped(
      RegExp(r'(\d+(?:\.\d+)?|[xyz])(?!\s*(?:sin|cos|tan|log|ln|sqrt|nrt))\s*\('),
          (match) => '${match.group(1)}*(',
    );

    // Pattern 5: closing parenthesis followed by number/variable
    expr = expr.replaceAllMapped(
      RegExp(r'\)\s*(\d+(?:\.\d+)?|[xyz])'),
          (match) => ')*${match.group(1)}',
    );

    return expr;
  }

  void _bindVariables() {
    // Clear and rebind all variables to ensure fresh context
    _contextModel.bindVariable(Variable('x'), Number(_variables['x']!));
    _contextModel.bindVariable(Variable('y'), Number(_variables['y']!));
    _contextModel.bindVariable(Variable('z'), Number(_variables['z']!));
    _contextModel.bindVariable(Variable('e'), Number(math.e));
    _contextModel.bindVariable(Variable('pi'), Number(math.pi));
  }

  // Handle special function processing
  String _processFunctions(String expr) {
    // Handle nth root: nrt(n,x) becomes x^(1/n)
    expr = expr.replaceAllMapped(
      RegExp(r'nrt\s*\(\s*([^,)]+)\s*,\s*([^)]+)\s*\)'),
          (match) => 'pow(${match.group(2)}, 1/${match.group(1)})',
    );

    // Handle custom base logarithms: log(x,base) becomes log(x)/log(base)
    expr = expr.replaceAllMapped(
      RegExp(r'log\s*\(\s*([^,)]+)\s*,\s*([^)]+)\s*\)'),
          (match) => '(log(${match.group(1)})/log(${match.group(2)}))',
    );

    // Handle standard square root with proper function name
    expr = expr.replaceAllMapped(
      RegExp(r'sqrt\s*\(\s*([^)]+)\s*\)'),
          (match) => 'sqrt(${match.group(1)})',
    );

    // Handle mod operator
    expr = expr.replaceAll('mod', '%');

    return expr;
  }

  void _evaluateExpression() {
    try {
      String processedExpr = _preprocessExpression(_expression);
      processedExpr = _processFunctions(processedExpr);
      final exp = _parser.parse(processedExpr);
      _bindVariables();

      final eval = exp.evaluate(EvaluationType.REAL, _contextModel);
      _result = eval.toString();
    } catch (e) {
      _result = 'Error: ${e.toString()}';
    }
  }

  void _assignToVariable(String variable) {
    try {
      String processedExpr = _preprocessExpression(_expression);
      processedExpr = _processFunctions(processedExpr);
      final exp = _parser.parse(processedExpr);

      // Bind current variable values before evaluation
      _bindVariables();

      final val = exp.evaluate(EvaluationType.REAL, _contextModel);
      _variables[variable] = val;

      // Update the context with the new variable value
      _bindVariables();

      _expression = '';
      _result = '$variable = $val';
    } catch (e) {
      _result = 'Error: ${e.toString()}';
    }
  }

  Widget _buildButton(String label, {Color color = Colors.grey}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: ElevatedButton(
          onPressed: () => _onPressed(label),
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            padding: const EdgeInsets.symmetric(vertical: 22),
          ),
          child: Text(
            label,
            style: const TextStyle(fontSize: 20, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildRow(List<String> labels, {List<Color>? colors}) => Row(
      children: List.generate(labels.length, (i) => _buildButton(labels[i], color: colors![i]))
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
        title: const Text('Advanced Calculator', style: TextStyle(color: Colors.white)),
        backgroundColor: ch
    ),
    backgroundColor: Colors.grey,
    body: Column(
      children: [
        // Fixed display area that stays visible when scrolling
        Container(
          color: Colors.grey[100],
          child: Column(
            children: [
              Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(_expression, style: const TextStyle(fontSize: 28)),
              ),
              Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Text(_result, style: const TextStyle(fontSize: 22, color: Colors.blueGrey)),
              ),
              const Divider(),
            ],
          ),
        ),
        // Scrollable button area
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildRow(['7', '8', '9', '÷'], colors: [ch, ch, ch, Colors.orange]),
                _buildRow(['4', '5', '6', '×'], colors: [ch, ch, ch, Colors.orange]),
                _buildRow(['1', '2', '3', '-'], colors: [ch, ch, ch, Colors.orange]),
                _buildRow(['0', '.', '%', '+'], colors: [ch, ch, Colors.purple, Colors.orange]),
                _buildRow(['C', 'CE', '=', '→x'], colors: [Colors.red, Colors.red, Colors.green, Colors.blue]),
                _buildRow(['x', 'y', 'z', '→y'], colors: [Colors.teal, Colors.teal, Colors.teal, Colors.blue]),
                _buildRow(['(', ')', '^', '→z'], colors: [ch, ch, ch, Colors.blue]),
                _buildRow(['sin', 'cos', 'tan', 'mod'], colors: [Colors.indigo, Colors.indigo, Colors.indigo, Colors.brown]),
                _buildRow(['log', 'ln', 'sqrt', 'nrt'], colors: [Colors.indigo, Colors.indigo, Colors.indigo, Colors.deepOrange]),
                _buildRow(['e', 'π', ',', 'log('], colors: [Colors.deepPurple, Colors.deepPurple, ch, Colors.indigo]),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
