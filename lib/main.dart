import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:expressions/expressions.dart';

void main() {
  runApp(const PixelCalcApp());
}

class PixelCalcApp extends StatelessWidget {
  const PixelCalcApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        // color palette
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFF9D8E6), // =
          onPrimary: Color(0xFF512435),
          secondary: Color(0xFF633F3F), // buttons
          onSecondary: Colors.white,
          surface: Color(0xFF1C1B1B), // background
          onSurface: Colors.white,
          secondaryContainer: Color(0xFF4A3434), // AC color and others
        ),
      ),
      home: const CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _input = '';
  String _output = '';

  void _onPress(String text) {
    HapticFeedback.lightImpact(); 
    setState(() {
      if (text == 'AC') {
        _input = '';
        _output = '';
      } else if (text == '⌫') {
        if (_input.isNotEmpty) _input = _input.substring(0, _input.length - 1);
      } else if (text == '=') {
        _calculate();
      } else if (text == '()') {
        if (_input.contains('(') && !_input.endsWith('(') && _input.split('(').length > _input.split(')').length) {
          _input += ')';
        } else {
          _input += '(';
        }
      } else {
        _input += text;
      }
    });
  }

  void _calculate() {
    if (_input.isEmpty) return;
    try {
      String expStr = _input.replaceAll('÷', '/').replaceAll('×', '*');
      final expression = Expression.parse(expStr);
      const evaluator = ExpressionEvaluator();
      final result = evaluator.eval(expression, {});
      setState(() => _output = result.toString());
    } catch (e) {
      setState(() => _output = "Error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // display
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
                alignment: Alignment.bottomRight,
                child: SingleChildScrollView( 
                  reverse: true,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(_input, 
                        style: const TextStyle(fontSize: 42, color: Colors.white70, fontWeight: FontWeight.w300)),
                      const SizedBox(height: 12),
                      FittedBox( // automatically scales down the output text
                        fit: BoxFit.scaleDown,
                        child: Text(_output.isEmpty ? '0' : _output, 
                          style: const TextStyle(fontSize: 90, fontWeight: FontWeight.w400, color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // separator
            Icon(Icons.unfold_more_rounded, color: Colors.grey[800], size: 30),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
              child: Column(
                children: [
                  _buildRow(['AC', '()', '%', '÷']),
                  _buildRow(['7', '8', '9', '×']),
                  _buildRow(['4', '5', '6', '-']),
                  _buildRow(['1', '2', '3', '+']),
                  _buildRow(['0', '.', '⌫', '=']),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(List<String> labels) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: labels.map((label) => _CalcButton(
        label: label, 
        onTap: () => _onPress(label),
      )).toList(),
    );
  }
}

class _CalcButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _CalcButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    
    Color bgColor = colors.secondaryContainer.withOpacity(0.3); // Темные кнопки (цифры)
    Color textColor = Colors.white;

    if (label == '=') {
      bgColor = colors.primary; 
      textColor = colors.onPrimary;
    } else if (['÷', '×', '-', '+', '%', '()'].contains(label)) {
      bgColor = colors.secondary; 
      textColor = colors.onSecondary;
    } else if (label == 'AC') {
      bgColor = const Color(0xFF6B4D4D); 
      textColor = colors.primary;
    }

    return Expanded(
      child: AspectRatio( 
        aspectRatio: 1.0, 
        child: Padding(
          padding: const EdgeInsets.all(6.0), //space between buttons
          child: Material(
            color: bgColor,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTap,
              child: Center(
                child: label == '⌫' 
                  ? Icon(Icons.backspace_outlined, color: textColor, size: 28)
                  : Text(
                      label, 
                      style: TextStyle(
                        fontSize: 37,
                        color: textColor, 
                        fontWeight: FontWeight.w400,
                      ),
                    ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}