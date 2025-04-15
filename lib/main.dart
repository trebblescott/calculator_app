import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

void main() {
  runApp(CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
const CalculatorApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Calculator',
theme: ThemeData(
  brightness: Brightness.light,
  scaffoldBackgroundColor: Colors.white,
  primarySwatch: Colors.indigo,
  textTheme: const TextTheme(
    bodyMedium: TextStyle(fontFamily: 'Roboto'),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      side: BorderSide(color: Colors.grey.shade300),
      backgroundColor: Colors.grey.shade100,
      padding: EdgeInsets.symmetric(vertical: 20),
    ),
  ),
),

      home: CalculatorHome(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class CalculatorHome extends StatefulWidget {
const CalculatorHome({Key? key}) : super(key: key);

  @override
  _CalculatorHomeState createState() => _CalculatorHomeState();
}

class _CalculatorHomeState extends State<CalculatorHome> {
  String _input = '';
  String _result = '';

  void _buttonPressed(String buttonText) {
    setState(() {
      if (buttonText == 'C') {
        _input = '';
        _result = '';
      } else if (buttonText == '=') {
        _calculateResult();
      } else {
        _input += buttonText;
      }
    });
  }

  void _calculateResult() {
    try {
      Parser p = Parser();
      Expression exp = p.parse(_input.replaceAll('×', '*').replaceAll('÷', '/'));
      ContextModel cm = ContextModel();
      double eval = exp.evaluate(EvaluationType.REAL, cm);
      _result = eval.toString();
    } catch (e) {
      _result = 'Error';
    }
  }

Widget _buildButton(String text, {Color? color}) {
  return Expanded(
    child: Container(
      margin: EdgeInsets.all(8),
      child: OutlinedButton(
        onPressed: () => _buttonPressed(text),
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: Colors.white,
          foregroundColor: color ?? Colors.black,
          padding: EdgeInsets.all(22),
          side: BorderSide(color: Colors.grey.shade300),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 24,
            color: color ?? Colors.black,
          ),
        ),
      ),
    ),
  );
}


  @override
  Widget build(BuildContext ) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calculator'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Container(
              padding: EdgeInsets.all(24),
              alignment: Alignment.bottomRight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(_input, style: TextStyle(fontSize: 32, color: Colors.black54)),
                  SizedBox(height: 8),
                  Text(_result, style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          Column(
            children: [
              Row(children: [_buildButton('7'), _buildButton('8'), _buildButton('9'), _buildButton('÷')]),
              Row(children: [_buildButton('4'), _buildButton('5'), _buildButton('6'), _buildButton('×')]),
              Row(children: [_buildButton('1'), _buildButton('2'), _buildButton('3'), _buildButton('-')]),
              Row(children: [_buildButton('0'), _buildButton('.'), _buildButton('='), _buildButton('+')]),
              Row(children: [_buildButton('AC', color: Colors.red)]),
            ],
          )
        ],
      ),
    );
  }
}
