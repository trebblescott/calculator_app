import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: CalculatorApp(),
    debugShowCheckedModeBanner: false,
  ));
}

class CalculatorApp extends StatefulWidget {
  @override
  _CalculatorAppState createState() => _CalculatorAppState();
}

class _CalculatorAppState extends State<CalculatorApp> {
  String _expression = '0';
  String _currentNumber = '';
  String _lastOperator = '';
  double _storedValue = 0;

  void _buttonPressed(String text) {
    setState(() {
      if (text == 'AC') {
        _resetAll();
      } else if (text == 'DEL') {
        _deleteLastChar();
      } else if (text == '=') {
        _calculateResult();
      } else if (['+', '-', '*', '/'].contains(text)) {
        _handleOperator(text);
      } else {
        _handleNumberInput(text);
      }
    });
  }

  void _resetAll() {
    _expression = '0';
    _currentNumber = '';
    _lastOperator = '';
    _storedValue = 0;
  }

  void _deleteLastChar() {
    if (_expression.length > 1) {
      _expression = _expression.substring(0, _expression.length - 1);
      if (_currentNumber.isNotEmpty) {
        _currentNumber = _currentNumber.substring(0, _currentNumber.length - 1);
      }
    } else {
      _expression = '0';
      _currentNumber = '';
    }
  }

  void _handleNumberInput(String text) {
    if (_expression == '0' || _lastOperator == '=') {
      _expression = text;
      _currentNumber = text;
      if (_lastOperator == '=') {
        _lastOperator = '';
        _storedValue = 0;
      }
    } else {
      _expression += text;
      _currentNumber += text;
    }
  }

  void _handleOperator(String operator) {
    if (_currentNumber.isNotEmpty) {
      double currentValue = double.parse(_currentNumber);
      if (_lastOperator.isNotEmpty && _lastOperator != '=') {
        _storedValue = _performCalculation(_storedValue, currentValue, _lastOperator);
      } else {
        _storedValue = currentValue;
      }
    }
    _expression += operator;
    _lastOperator = operator;
    _currentNumber = '';
  }

  void _calculateResult() {
    if (_lastOperator.isEmpty || _currentNumber.isEmpty) return;
    
    double currentValue = double.parse(_currentNumber);
    double result = _performCalculation(_storedValue, currentValue, _lastOperator);
    
    _expression = result.toString();
    if (result % 1 == 0) {
      _expression = result.toInt().toString();
    }
    
    _lastOperator = '=';
    _currentNumber = _expression;
    _storedValue = result;
  }

  double _performCalculation(double a, double b, String operator) {
    switch (operator) {
      case '+':
        return a + b;
      case '-':
        return a - b;
      case '*':
        return a * b;
      case '/':
        if (b == 0) {
          _expression = 'ERROR';
          return 0;
        }
        return a / b;
      default:
        return b;
    }
  }

  Widget _buildButton(String text) {
    return OutlinedButton(
      onPressed: () => _buttonPressed(text),
      style: OutlinedButton.styleFrom(
        shape: CircleBorder(),
        side: BorderSide(color: Colors.black),
        padding: EdgeInsets.all(24),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 24, color: Colors.black),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        actions: [
          Icon(
            Icons.more_vert,
            color: Colors.white,
          )
        ],
      ),
      body: Column(
        children: [
          // Display area
          Container(
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20.0),
                bottomRight: Radius.circular(20.0),
              ),
            ),
            padding: EdgeInsets.all(20),
            alignment: Alignment.centerRight,
            child: Text(
              _expression,
              style: TextStyle(fontSize: 40, color: Colors.white),
            ),
          ),

          // Buttons
          Expanded(
            child: GridView.count(
              crossAxisCount: 4,
              physics: NeverScrollableScrollPhysics(),
              padding: EdgeInsets.all(12),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: [
                _buildButton('7'),
                _buildButton('8'),
                _buildButton('9'),
                _buildButton('/'),
                _buildButton('4'),
                _buildButton('5'),
                _buildButton('6'),
                _buildButton('*'),
                _buildButton('1'),
                _buildButton('2'),
                _buildButton('3'),
                _buildButton('-'),
                _buildButton('0'),
                _buildButton('.'),
                _buildButton('='),
                _buildButton('+'),
                _buildButton('AC'),
                _buildButton('%'),
                _buildButton('()'),
                _buildButton("DEL")
              ],
            ),
          ),
        ],
      ),
    );
  }
}