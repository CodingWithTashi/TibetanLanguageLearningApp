class HangmanGame {
  final String word;
  final String category;
  final int maxAttempts;
  List<String> guessedLetters;
  int attemptsRemaining;
  bool isSolved;

  HangmanGame({
    required this.word,
    required this.category,
    this.maxAttempts = 6,
  })  : guessedLetters = [],
        attemptsRemaining = maxAttempts,
        isSolved = false;

  bool guessLetter(String letter) {
    if (guessedLetters.contains(letter)) {
      return false; // Letter already guessed
    }
    guessedLetters.add(letter);
    if (!word.contains(letter)) {
      attemptsRemaining--;
    }
    isSolved = word.split('').every((char) => guessedLetters.contains(char));
    return true;
  }

  String get maskedWord {
    return word.split('').map((char) {
      return guessedLetters.contains(char) ? char : '_';
    }).join(' ');
  }
}
