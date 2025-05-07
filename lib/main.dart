import 'package:flutter/cupertino.dart';
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
  bool _nextBracketIsOpen = true;
  bool _shouldResetExpression = false;
  int _openBracketCount = 0;
  String _formatExpressionForDisplay(String expression) {
  final buffer = StringBuffer();
  final regExp = RegExp(r'(\d+|\D)'); // splits digits and non-digits

  for (final match in regExp.allMatches(expression)) {
    final token = match.group(0)!;

    if (RegExp(r'^\d+$').hasMatch(token)) {
      // Format only digit blocks (not decimals or operations)
      final number = int.tryParse(token);
      if (number != null) {
        buffer.write(_formatWithCommas(number));
      } else {
        buffer.write(token);
      }
    } else {
      buffer.write(token); // Operators, brackets, etc.
    }
  }

  return buffer.toString();
}

String _formatWithCommas(int number) {
  return number.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
}


  void _buttonPressed(String text) {
    setState(() {
      if (text == 'x') text = '*'; // 👈 Handle 'x' as multiplication

      if (text == 'AC') {
        _resetAll();
      } else if (text == 'DEL') {
        _deleteLastChar();
      } else if (text == '=') {
        _calculateResult();
      } else if (text == '( )') {
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
      _lastOperator = '';
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
      _lastOperator = '';
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
      _expression = _currentNumber + operator;
      _lastOperator = operator;
      _currentNumber = '';
      _shouldResetExpression = false;
      return;
    }

    if (_currentNumber.isNotEmpty || _expression.endsWith(')')) {
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
      // Opening bracket logic (unchanged)
      if (_expression == '0' || _shouldResetExpression) {
        _expression = '(';
        _shouldResetExpression = false;
      } else if (_lastOperator.isNotEmpty || _expression.endsWith('(')) {
        _expression += '(';
      } else {
        _expression += '*('; // Implicit multiplication
      }
      _openBracketCount++;
    } else {
      // Modified closing bracket condition
      if (_openBracketCount > 0) {
        _expression += ')';
        _openBracketCount--;
      }
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

      // Replace 'x' with '*' before evaluation
      String evalExpression = _expression.replaceAll('x', '*');

      // Evaluate the expression with BODMAS rules
      double result = _evaluateExpression(evalExpression);

      _expression = result % 1 == 0
          ? result.toInt().toString()
          : result
              .toStringAsFixed(8)
              .replaceAll(RegExp(r'0*$'), '')
              .replaceAll(RegExp(r'\.$'), '');
      _lastOperator = '=';
      _currentNumber = _expression;
      _shouldResetExpression = true;
      _nextBracketIsOpen = true;
    } catch (e) {
      _expression = 'ERROR';
    }
  }

  double _evaluateExpression(String expression) {
    // First evaluate all expressions in brackets recursively
    while (expression.contains('(')) {
      int openIndex = expression.lastIndexOf('(');
      int closeIndex = expression.indexOf(')', openIndex);

      if (closeIndex == -1) throw 'Unbalanced brackets';

      String subExpression = expression.substring(openIndex + 1, closeIndex);
      double subResult = _evaluateSimpleExpression(subExpression);

      expression = expression.replaceRange(
          openIndex, closeIndex + 1, subResult.toString());
    }

    return _evaluateSimpleExpression(expression);
  }

  double _evaluateSimpleExpression(String expression) {
    // Handle multiplication and division first
    List<String> tokens = _tokenizeExpression(expression);

    // First pass for * and /
    for (int i = 1; i < tokens.length - 1; i++) {
      if (tokens[i] == '*' || tokens[i] == '/') {
        double left = double.parse(tokens[i - 1]);
        double right = double.parse(tokens[i + 1]);
        double result = tokens[i] == '*' ? left * right : left / right;

        tokens.removeRange(i - 1, i + 2);
        tokens.insert(i - 1, result.toString());
        i -= 2; // Adjust index after removing elements
      }
    }

    // Second pass for + and -
    for (int i = 1; i < tokens.length - 1; i++) {
      if (tokens[i] == '+' || tokens[i] == '-') {
        double left = double.parse(tokens[i - 1]);
        double right = double.parse(tokens[i + 1]);
        double result = tokens[i] == '+' ? left + right : left - right;

        tokens.removeRange(i - 1, i + 2);
        tokens.insert(i - 1, result.toString());
        i -= 2; // Adjust index after removing elements
      }
    }

    if (tokens.length != 1) throw 'Invalid expression';

    return double.parse(tokens[0]);
  }

  List<String> _tokenizeExpression(String expression) {
    List<String> tokens = [];
    String currentNumber = '';

    for (int i = 0; i < expression.length; i++) {
      String char = expression[i];

      if (['+', '-', '*', '/'].contains(char)) {
        if (currentNumber.isNotEmpty) {
          tokens.add(currentNumber);
          currentNumber = '';
        }
        tokens.add(char);
      } else {
        currentNumber += char;
      }
    }

    if (currentNumber.isNotEmpty) {
      tokens.add(currentNumber);
    }

    return tokens;
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
              style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontFamily: text == 'AC' ? 'Roboto' : 'Arial'),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 47, 49, 31),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: Colors.white),
            color: Color.fromARGB(255, 47, 49, 31),
            onSelected: (value) {},
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(value: 'settings', child: Text('History')),
              PopupMenuItem(value: 'help', child: Text('Choose theme')),
              PopupMenuItem(value: 'about', child: Text('Privacy policy')),
              PopupMenuItem(
                  value: 'more settings', child: Text('Send feedback')),
              PopupMenuItem(value: 'log in', child: Text('Help')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 47, 49, 31),
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
                _formatExpressionForDisplay(_expression),
                style: TextStyle(fontSize: 60, color: Colors.white),
              ),
            ),
          ),
          Expanded(
            child: GridView.count(
              crossAxisCount: 4,
              physics: NeverScrollableScrollPhysics(),
              padding: EdgeInsets.only(bottom: 2, top: 20),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: [
                _buildButton('AC',
                    backgroundColor: const Color.fromARGB(255, 25, 121, 111)),
                _buildButton('( )',
                    backgroundColor: Color.fromARGB(255, 69, 102, 70)),
                _buildButton('%',
                    backgroundColor: Color.fromARGB(255, 69, 102, 70)),
                _buildButton('/',
                    backgroundColor: Color.fromARGB(255, 69, 102, 70)),
                _buildButton('7',
                    backgroundColor: Color.fromARGB(255, 47, 49, 31)),
                _buildButton('8',
                    backgroundColor: Color.fromARGB(255, 47, 49, 31)),
                _buildButton('9',
                    backgroundColor: Color.fromARGB(255, 47, 49, 31)),
                _buildButton('*',
                    backgroundColor: Color.fromARGB(255, 69, 102, 70),
                    icon: Icons.close),
                _buildButton('4',
                    backgroundColor: Color.fromARGB(255, 47, 49, 31)),
                _buildButton('5',
                    backgroundColor: Color.fromARGB(255, 47, 49, 31)),
                _buildButton('6',
                    backgroundColor: Color.fromARGB(255, 47, 49, 31)),
                _buildButton('-',
                    backgroundColor: Color.fromARGB(255, 69, 102, 70)),
                _buildButton('1',
                    backgroundColor: Color.fromARGB(255, 47, 49, 31)),
                _buildButton('2',
                    backgroundColor: Color.fromARGB(255, 47, 49, 31)),
                _buildButton('3',
                    backgroundColor: Color.fromARGB(255, 47, 49, 31)),
                _buildButton('+',
                    backgroundColor: Color.fromARGB(255, 69, 102, 70)),
                _buildButton('0',
                    backgroundColor: Color.fromARGB(255, 47, 49, 31)),
                _buildButton('.',
                    backgroundColor: Color.fromARGB(255, 47, 49, 31)),
                _buildButton('DEL',
                    backgroundColor: Color.fromARGB(255, 47, 49, 31),
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
