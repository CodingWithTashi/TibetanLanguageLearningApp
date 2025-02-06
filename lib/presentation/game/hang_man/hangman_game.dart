import 'package:flutter/material.dart';
import 'package:tibetan_language_learning_app/presentation/game/util/hang_man.dart';

class HangmanGameScreen extends StatefulWidget {
  static const routeName = 'hangman-game';

  const HangmanGameScreen({Key? key}) : super(key: key);

  @override
  State<HangmanGameScreen> createState() => _HangmanGameScreenState();
}

class _HangmanGameScreenState extends State<HangmanGameScreen> {
  late HangmanGame _game;
  final TextEditingController _guessController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _game = HangmanGame(
      word: 'FLUTTER',
      category: 'Programming',
      maxAttempts: 6,
    );
  }

  void _guessLetter() {
    final letter = _guessController.text.toUpperCase();
    if (letter.isEmpty || letter.length != 1) return;

    setState(() {
      _game.guessLetter(letter);
    });
    _guessController.clear();

    if (_game.isSolved || _game.attemptsRemaining == 0) {
      _showGameOverDialog();
    }
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(_game.isSolved ? 'You Won!' : 'Game Over'),
          content: Text(_game.isSolved
              ? 'Congratulations! You guessed the word: ${_game.word}'
              : 'The word was: ${_game.word}'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hangman'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Category: ${_game.category}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              _game.maskedWord,
              style: TextStyle(fontSize: 24, letterSpacing: 2),
            ),
            SizedBox(height: 20),
            Text(
              'Attempts Remaining: ${_game.attemptsRemaining}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _guessController,
              maxLength: 1,
              decoration: InputDecoration(
                labelText: 'Guess a letter',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _guessLetter,
              child: Text('Guess'),
            ),
          ],
        ),
      ),
    );
  }
}
