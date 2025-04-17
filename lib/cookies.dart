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

  void _buttonPressed(String text) {
    setState(() {
      if (text == 'AC') {
        _expression = '0';
      } else if (text == '=') {
        _expression = _evaluate(_expression);
      } else {
        if (_expression == '0') {
          _expression = text;
        } else {
          _expression += text;
        }
      }
    });
  }

  String _evaluate(String expr) {
    try {
      List<String> tokens =
          expr.split(RegExp(r'([+\-*/])')).map((e) => e.trim()).toList();
      double result = double.parse(tokens[0]);

      for (int i = 1; i < tokens.length; i += 2) {
        String op = tokens[i];
        double num = double.parse(tokens[i + 1]);

        switch (op) {
          case '+':
            result += num;
            break;
          case '-':
            result -= num;
            break;
          case '*':
            result *= num;
            break;
          case '/':
            result /= num;
            break;
        }
      }

      return result.toString();
    } catch (e) {
      return 'Error';
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
                _buildButton('%'),  // optional functionality
                _buildButton('()'), // optional functionality
              ],
            ),
          ),
        ],
      ),
    );
  }
}
