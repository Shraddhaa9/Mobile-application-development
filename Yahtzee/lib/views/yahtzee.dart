import 'package:flutter/material.dart';
import 'package:mp2/models/scorecard.dart';
import 'package:mp2/models/dice.dart';

class YahtzeeGame extends StatefulWidget {
  const YahtzeeGame({Key? key});

  @override
  _YahtzeeGameState createState() => _YahtzeeGameState();
}

class _YahtzeeGameState extends State<YahtzeeGame> {
  final Dice dice = Dice(5);
  final ScoreCard scoreCard = ScoreCard();
  int remainingRolls = 3; // Number of rolls remaining
  ScoreCategory? selectedCategory; // Selected category
  final Set<ScoreCategory> usedCategories = {}; // Used categories

  void resetGame() {
    setState(() {
      remainingRolls = 3;
      selectedCategory = null;
      dice.clear();
      scoreCard.clear();
      usedCategories.clear();
    });
  }

  void toggleHold(int index) {
    setState(() {
      dice.toggleHold(index);
    });
  }

  void rollDice() {
    setState(() {
      if (remainingRolls > 0) {
        dice.roll();
        remainingRolls--;

        if (remainingRolls == 0) {
          // Disable the "Roll Dice" button
          remainingRolls = 0;
        }
      }
    });
  }

  void registerScore(ScoreCategory? category) {
    setState(() {
      if (category != null) {
        if (usedCategories.contains(category)) {
          showCategoryUsedAlert(category);
        } else {
          scoreCard.registerScore(category, dice.values);
          dice.clear();
          remainingRolls = 3;
          selectedCategory = null;
          usedCategories.add(category);
          if (scoreCard.completed) {
            showGameOverDialog();
          }
        }
      }
    });
  }

  void showCategoryUsedAlert(ScoreCategory category) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Category is Already Used'),
          content: Text('The category ${category.name} has already been used.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void showGameOverDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Game Over!'),
          content: Text('Your score is: ${scoreCard.total}'),
          actions: [
            TextButton(
              onPressed: () {
                resetGame();
                Navigator.of(context).pop();
              },
              child: const Text('Play Again'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int i = 0; i < dice.values.length; i++)
                Container(
                  margin: const EdgeInsets.all(10),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    border: Border.all(),
                    color: dice.isHeld(i) ? Colors.green : Colors.white,
                  ),
                  child: GestureDetector(
                    onTap: () => toggleHold(i),
                    child: Text(
                      '${dice[i] ?? ''}',
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                ),
            ],
          ),
          ElevatedButton(
            onPressed: remainingRolls > 0 ? rollDice : null,
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(
                remainingRolls > 0 ? Colors.blue : Colors.grey,
              ),
            ),
            child: remainingRolls > 0
                ? Text('Roll ($remainingRolls)')
                : Text('Out of Rolls'),
          ),
          DropdownButton<ScoreCategory>(
            value: selectedCategory,
            hint: const Text('Pick Category'),
            items: ScoreCategory.values
                .map((category) => DropdownMenuItem<ScoreCategory>(
                      value: category,
                      child: Text(category.name),
                    ))
                .toList(),
            onChanged: (ScoreCategory? category) {
              setState(() {
                selectedCategory = category;
              });
            },
          ),
          ElevatedButton(
            onPressed: () {
              if (selectedCategory != null) {
                registerScore(selectedCategory);
              }
            },
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
            ),
            child: const Text('Pick Category'),
          ),
          Text(
            'Current Score: ${scoreCard.total}',
            style: const TextStyle(fontSize: 16),
          ),
          if (usedCategories.isNotEmpty)
            Column(
              children: [
                const SizedBox(height: 10),
                const Text(
                  'Used Categories:',
                  style: TextStyle(fontSize: 12),
                ),
                for (var usedCategory in usedCategories)
                  Text(
                    '- ${usedCategory.name}',
                    style: const TextStyle(fontSize: 12),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
