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
  bool _nextBracketIsOpen = true;
  bool _shouldResetExpression = false;
  int _openBracketCount = 0;

  void _buttonPressed(String text) {
    setState(() {
      if (text == 'AC') {
        _resetAll();
      } else if (text == 'DEL') {
        _deleteLastChar();
      } else if (text == '=') {
        _calculateResult();
      } else if (text == '()') {
        _handleBrackets();
      } else if (['+', '-', '*', '/'].contains(text)) {
        _handleOperator(text);
      } else if (text == '%') {
        _handlePercentage();
      } else if (text == '.') {
        _handleDecimalPoint();
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
    _nextBracketIsOpen = true;
    _shouldResetExpression = false;
    _openBracketCount = 0;
  }

  void _deleteLastChar() {
    if (_expression.length > 1) {
      final lastChar = _expression.substring(_expression.length - 1);

      if (lastChar == '(') _openBracketCount--;
      if (lastChar == ')') _openBracketCount++;

      if (lastChar == '(' || lastChar == ')') {
        _nextBracketIsOpen = (lastChar == ')');
      }

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
    if (_shouldResetExpression || _expression == '0' || _lastOperator == '=') {
      _expression = text;
      _currentNumber = text;
      _shouldResetExpression = false;
    } else {
      _expression += text;
      _currentNumber += text;
    }
  }

  void _handleDecimalPoint() {
    if (_shouldResetExpression || _expression == '0') {
      _expression = '0.';
      _currentNumber = '0.';
      _shouldResetExpression = false;
    } else if (!_currentNumber.contains('.')) {
      if (_currentNumber.isEmpty) {
        _expression += '0.';
        _currentNumber = '0.';
      } else {
        _expression += '.';
        _currentNumber += '.';
      }
    }
  }

  void _handleOperator(String operator) {
    if (_lastOperator == '=' && _currentNumber.isNotEmpty) {
      _storedValue = double.tryParse(_currentNumber) ?? 0;
      _expression = _currentNumber + operator;
      _lastOperator = operator;
      _currentNumber = '';
      _shouldResetExpression = false;
      return;
    }
    if (_lastOperator == '=' && !_shouldResetExpression) {
      _shouldResetExpression = false;
    }
    if (_currentNumber.isNotEmpty || _lastOperator == '=') {
      if (_currentNumber.isNotEmpty) {
        double currentValue = double.parse(_currentNumber);
        if (_lastOperator.isNotEmpty && _lastOperator != '=') {
          _storedValue =
              _performCalculation(_storedValue, currentValue, _lastOperator);
        } else {
          _storedValue = currentValue;
        }
      }
      _expression += operator;
      _lastOperator = operator;
      _currentNumber = '';
      _shouldResetExpression = false;
      _nextBracketIsOpen = true;
    } else if (_expression != '0' && _lastOperator.isNotEmpty) {
      _expression = _expression.substring(0, _expression.length - 1) + operator;
      _lastOperator = operator;
    }
  }

  void _handleBrackets() {
    if (_nextBracketIsOpen) {
      if (_expression == '0' || _shouldResetExpression) {
        _expression = '(';
        _expression = '(';
        _shouldResetExpression = false;
      } else {
        _expression += '(';
      }
      _openBracketCount++;
    } else if (_openBracketCount > 0 &&
        (_currentNumber.isNotEmpty || _lastOperator.isEmpty)) {
      _expression += ')';
      _openBracketCount--;
    }
    _nextBracketIsOpen = !_nextBracketIsOpen;
    _currentNumber = '';
    _lastOperator = '';
  }

  void _handlePercentage() {
    if (_currentNumber.isNotEmpty) {
      try {
        double percentValue = double.parse(_currentNumber) / 100;
        _expression = _expression.replaceRange(
          _expression.length - _currentNumber.length,
          _expression.length,
          percentValue.toString(),
        );
        _currentNumber = percentValue.toString();
      } catch (e) {
        _expression = 'ERROR';
      }
    }
  }

  void _calculateResult() {
    try {
      if (_openBracketCount != 0) {
        _expression = 'ERROR: Unbalanced';
        return;
      }

      if (_lastOperator.isEmpty || _currentNumber.isEmpty) return;

      double currentValue = double.parse(_currentNumber);
      double result =
          _performCalculation(_storedValue, currentValue, _lastOperator);

      _expression = result % 1 == 0
          ? result.toInt().toString()
          : result
              .toStringAsFixed(result.truncateToDouble() == result ? 0 : 8)
              .replaceAll(RegExp(r'0*$'), '')
              .replaceAll(RegExp(r'\.$'), '');
      _lastOperator = '=';
      _currentNumber = _expression;
      _storedValue = result;
      _shouldResetExpression = true;
      _nextBracketIsOpen = true;
    } catch (e) {
      _expression = 'ERROR';
    }
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
        if (b == 0) throw 'Division by zero';
        return a / b;
      default:
        return b;
    }
  }

  Widget _buildButton(
    String text, {
    required Color backgroundColor,
    IconData? icon,
  }) {
    return OutlinedButton(
      onPressed: () => _buttonPressed(text),
      style: OutlinedButton.styleFrom(
        shape: CircleBorder(),
        side: BorderSide(color: Colors.black),
        padding: EdgeInsets.all(24),
        backgroundColor: backgroundColor,
      ),
      child: icon != null
          ? Icon(icon, color: Colors.white, size: 24)
          : Text(
              text,
              style: TextStyle(fontSize: 24, color: Colors.white),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 50, 65, 50),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {},
          )
        ],
      ),
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 50, 65, 50),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20.0),
                bottomRight: Radius.circular(20.0),
              ),
            ),
            padding: EdgeInsets.all(20),
            alignment: Alignment.centerRight,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Text(
                _expression,
                style: TextStyle(fontSize: 40, color: Colors.white),
              ),
            ),
          ),
          Expanded(
            child: GridView.count(
              crossAxisCount: 4,
              physics: NeverScrollableScrollPhysics(),
              padding: EdgeInsets.all(12),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: [
                _buildButton('AC',
                    backgroundColor: Color.fromARGB(255, 7, 84, 121)),
                _buildButton('()',
                    backgroundColor: Color.fromARGB(255, 69, 102, 70)),
                _buildButton('%',
                    backgroundColor: Color.fromARGB(255, 69, 102, 70)),
                _buildButton('/',
                    backgroundColor: Color.fromARGB(255, 69, 102, 70)),
                _buildButton('7',
                    backgroundColor: Color.fromARGB(255, 55, 65, 56)),
                _buildButton('8',
                    backgroundColor: Color.fromARGB(255, 55, 65, 56)),
                _buildButton('9',
                    backgroundColor: Color.fromARGB(255, 55, 65, 56)),
                _buildButton('*',
                    backgroundColor: Color.fromARGB(255, 69, 102, 70),
                    icon: Icons.close),
                _buildButton('4',
                    backgroundColor: Color.fromARGB(255, 55, 65, 56)),
                _buildButton('5',
                    backgroundColor: Color.fromARGB(255, 55, 65, 56)),
                _buildButton('6',
                    backgroundColor: Color.fromARGB(255, 55, 65, 56)),
                _buildButton('-',
                    backgroundColor: Color.fromARGB(255, 69, 102, 70)),
                _buildButton('1',
                    backgroundColor: Color.fromARGB(255, 55, 65, 56)),
                _buildButton('2',
                    backgroundColor: Color.fromARGB(255, 55, 65, 56)),
                _buildButton('3',
                    backgroundColor: Color.fromARGB(255, 55, 65, 56)),
                _buildButton('+',
                    backgroundColor: Color.fromARGB(255, 69, 102, 70)),
                _buildButton('0',
                    backgroundColor: Color.fromARGB(255, 55, 65, 56)),
                _buildButton('.',
                    backgroundColor: Color.fromARGB(255, 55, 65, 56)),
                 _buildButton('DEL',
                    backgroundColor: Color.fromARGB(255, 55, 65, 56),
                    icon: Icons.backspace),
                _buildButton('=',
                    backgroundColor: Color.fromARGB(255, 69, 102, 70)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
