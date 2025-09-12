import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/memory_match/memory_match_bloc.dart';

class MemoryMatchGameScreen extends StatelessWidget {
  static const routeName = 'memory-match-game';

  const MemoryMatchGameScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          MemoryMatchBloc()..add(InitializeGame(cards: _generateCards())),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Memory Match'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              BlocBuilder<MemoryMatchBloc, MemoryMatchState>(
                builder: (context, state) {
                  if (state.game == null) {
                    return Center(child: CircularProgressIndicator());
                  }
                  return Expanded(
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8.0,
                        mainAxisSpacing: 8.0,
                      ),
                      itemCount: state.game!.cards.length,
                      itemBuilder: (context, index) {
                        return CardWidget(
                          card: state.game!.cards[index],
                          isFlipped: state.game!.flipped[index],
                          isMatched: state.game!.matched[index],
                          onTap: () {
                            if (state.game!.currentlyFlipped.length < 2) {
                              context.read<MemoryMatchBloc>().add(
                                    FlipCard(index: index),
                                  );
                            }
                          },
                        );
                      },
                    ),
                  );
                },
              ),
              BlocBuilder<MemoryMatchBloc, MemoryMatchState>(
                builder: (context, state) {
                  if (state.isGameComplete) {
                    return Text(
                      'Congratulations! You found all pairs!',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    );
                  }
                  return SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<String> _generateCards() {
    final words = ['🍎', '🍌', '🍒', '🍇', '🍉', '🍓'];
    final cards = [...words, ...words]..shuffle();
    return cards;
  }
}

class CardWidget extends StatelessWidget {
  final String card;
  final bool isFlipped;
  final bool isMatched;
  final VoidCallback onTap;

  const CardWidget({
    required this.card,
    required this.isFlipped,
    required this.isMatched,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isMatched
              ? Colors.green
              : (isFlipped ? Colors.blue : Colors.grey),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Center(
          child: isFlipped || isMatched
              ? Text(
                  card,
                  style: TextStyle(fontSize: 32),
                )
              : null,
        ),
      ),
    );
  }
}
