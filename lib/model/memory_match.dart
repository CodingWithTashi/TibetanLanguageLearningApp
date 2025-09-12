class MemoryMatchGame {
  final List<String> cards;
  final List<bool> flipped;
  final List<bool> matched;
  int attempts;
  int pairsFound;
  List<int> currentlyFlipped; // Track indices of currently flipped cards

  MemoryMatchGame({required this.cards})
      : flipped = List.filled(cards.length, false),
        matched = List.filled(cards.length, false),
        attempts = 0,
        pairsFound = 0,
        currentlyFlipped = [];

  void flipCard(int index) {
    if (flipped[index] || matched[index] || currentlyFlipped.length == 2)
      return;
    flipped[index] = true;
    currentlyFlipped.add(index);
    attempts++;
  }

  bool checkMatch() {
    if (currentlyFlipped.length != 2) return false;

    final index1 = currentlyFlipped[0];
    final index2 = currentlyFlipped[1];

    if (cards[index1] == cards[index2]) {
      matched[index1] = true;
      matched[index2] = true;
      pairsFound++;
      currentlyFlipped.clear(); // Clear flipped cards after a match
      return true;
    }
    return false;
  }

  void resetFlippedCards() {
    for (int i = 0; i < currentlyFlipped.length; i++) {
      flipped[currentlyFlipped[i]] = false;
    }
    currentlyFlipped.clear(); // Clear flipped cards after reset
  }

  bool isGameComplete() {
    return pairsFound == cards.length ~/ 2;
  }
}
