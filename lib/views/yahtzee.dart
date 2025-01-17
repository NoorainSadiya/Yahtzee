import 'package:flutter/material.dart';
import '../models/dice.dart';
import '../models/scorecard.dart';

class Yahtzee extends StatefulWidget {
  const Yahtzee({super.key});

  @override
  _YahtzeeState createState() => _YahtzeeState();
}

class _YahtzeeState extends State<Yahtzee> {
  final Dice _dice = Dice(5);
  final ScoreCard _scoreCard = ScoreCard();
  int _rollCount = 0;

  // Method to roll dice
  void _rollDice() {
    if (_rollCount < 3) {
      setState(() {
        _dice.roll();
        _rollCount++;
      });
    }
  }

  // Method to hold/unhold dice
  void _toggleHold(int index) {
    if (_rollCount > 0) {
      setState(() {
        _dice.toggleHold(index);
      });
    }
  }

  // Reset the game for a new turn
  void _resetTurn() {
    setState(() {
      _dice.clear();
      _rollCount = 0;
    });
  }

  // Method to register the score
  void _registerScore(ScoreCategory category) {
    if (_rollCount == 0) {
      // Prevent registering the score before any rolls
      return;
    }

    setState(() {
      _scoreCard.registerScore(category, _dice.values);
      _resetTurn();
      if (_scoreCard.completed) {
        _showGameOverDialog();
      }
    });
  }

  // Method to reset the entire game
  void _resetGame() {
    setState(() {
      _scoreCard.clear();
      _resetTurn();
    });
  }

  // Show dialog when the game ends
  void _showGameOverDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Game Over'),
          content: Text('Your total score: ${_scoreCard.total}'),
          actions: <Widget>[
            TextButton(
              child: const Text('Reset Game'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _resetGame(); // Reset the game
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.05), // Responsive padding
          child: Column(
            children: [
              _buildDiceRow(),
              SizedBox(height: screenHeight * 0.02), // Responsive spacing
              _buildRollButton(),
              SizedBox(height: screenHeight * 0.02), // Responsive spacing
              _buildScorecard(),
              SizedBox(height: screenHeight * 0.02), // Responsive spacing
              _buildResetButton(),
            ],
          ),
        ),
      ),
    );
  }

  // Widget for displaying the dice row
  Widget _buildDiceRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return Flexible(
          child: GestureDetector(
            onTap: () => _toggleHold(index), // Toggle hold on tap
            child: Container(
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(
                    color: _dice.isHeld(index) ? Colors.red : Colors.black),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                _dice[index]?.toString() ?? '-',
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
        );
      }),
    );
  }

  // Widget for the roll button
  Widget _buildRollButton() {
    return ElevatedButton(
      onPressed: _rollCount < 3 ? _rollDice : null,
      child: Text('Roll Dice (${_rollCount}/3)'),
    );
  }

  // Widget for displaying the scorecard
  Widget _buildScorecard() {
    return Column(
      children: ScoreCategory.values.map((category) {
        return ListTile(
          title: Text(category.name),
          trailing: Text(
            _scoreCard[category]?.toString() ?? '-',
            style: const TextStyle(fontSize: 18),
          ),
          onTap: _scoreCard[category] == null
              ? () => _registerScore(category)
              : null, // Allow only unscored categories to be tapped
        );
      }).toList(),
    );
  }

  // Widget for Reset Game button
  Widget _buildResetButton() {
    return ElevatedButton(
      onPressed: _resetGame,
      child: const Text('Reset Game'),
    );
  }
}
