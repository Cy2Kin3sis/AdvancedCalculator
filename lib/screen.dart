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
  final Color ch = Colors.black54;

  final ShuntingYardParser _parser = ShuntingYardParser();
  final ContextModel _contextModel = ContextModel();

  void _onPressed(String value) => setState(() {
    if (value == 'CE') {
      _expression = '';
      _result = '';
    } else if (value == 'C') {
      if (_expression.isNotEmpty) _expression = _expression.substring(0, _expression.length - 1);
    } else if (value == '=') {
      _evaluateExpression();
    } else if (value == '→x' || value == '→y' || value == '→z') {
      final variable = value.substring(1); // Get 'x', 'y', or 'z'
      _assignToVariable(variable);
    } else {
      _expression += value;
    }
  });

  // Add this method to preprocess expressions for implicit multiplication
  String _preprocessExpression(String expr) {
    // Replace display symbols with parser-compatible ones
    expr = expr.replaceAll('×', '*');
    expr = expr.replaceAll('÷', '/');

    // Handle implicit multiplication patterns
    // Pattern 1: number followed by variable (e.g., "4x", "2.5y")
    expr = expr.replaceAllMapped(RegExp(r'(\d+\.?\d*)\s*([xyz])'), (match) => '${match.group(1)}*${match.group(2)}');

    // Pattern 2: variable followed by number (e.g., "x4", "y2.5")
    expr = expr.replaceAllMapped(RegExp(r'([xyz])\s*(\d+\.?\d*)'), (match) => '${match.group(1)}*${match.group(2)}');

    // Pattern 3: variable followed by variable (e.g., "xy", "xz")
    expr = expr.replaceAllMapped(RegExp(r'([xyz])\s*([xyz])'), (match) => '${match.group(1)}*${match.group(2)}');

    // Pattern 4: number/variable followed by opening parenthesis
    expr = expr.replaceAllMapped(RegExp(r'(\d+\.?\d*|[xyz])\s*\('), (match) => '${match.group(1)}*(');

    // Pattern 5: closing parenthesis followed by number/variable
    expr = expr.replaceAllMapped(RegExp(r'\)\s*(\d+\.?\d*|[xyz])'), (match) => ')*${match.group(1)}');

    return expr;
  }

  void _bindVariables() {
    // Clear and rebind all variables to ensure fresh context
    _contextModel.bindVariable(Variable('x'), Number(_variables['x']!));
    _contextModel.bindVariable(Variable('y'), Number(_variables['y']!));
    _contextModel.bindVariable(Variable('z'), Number(_variables['z']!));
  }

  void _evaluateExpression() {
    try {
      final processedExpr = _preprocessExpression(_expression);
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
      final processedExpr = _preprocessExpression(_expression);
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
    children: List.generate(
      labels.length, (i) => _buildButton(labels[i], color: colors != null ? colors[i] : Colors.grey),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Advanced Calculator')),
      body: Column(
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
          _buildRow(['7', '8', '9', '÷'], colors: [ch, ch, ch, Colors.orange]),
          _buildRow(['4', '5', '6', '×'], colors: [ch, ch, ch, Colors.orange]),
          _buildRow(['1', '2', '3', '-'], colors: [ch, ch, ch, Colors.orange]),
          _buildRow(['0', '.', '%', '+'], colors: [ch, ch, ch, Colors.orange]),
          _buildRow(['C', 'CE', '=', '→x'], colors: [Colors.redAccent, Colors.pink.shade300, Colors.green, Colors.blue]),
          _buildRow(['x', 'y', 'z', '→y'], colors: [Colors.teal, Colors.teal, Colors.teal, Colors.blue]),
          _buildRow(['(', ')', '^', '→z'], colors: [ch, ch, ch, Colors.blue]),
        ],
      ),
    );
  }
}