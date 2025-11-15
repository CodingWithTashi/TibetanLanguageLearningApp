import 'package:flutter/material.dart';
import 'game_score_card.dart';

/// Unified game layout component for consistent UI across all games
/// Ensures all games have the same structure and element positioning
class GameLayout extends StatelessWidget {
  final String title;
  final List<GameScoreCard> scoreCards;
  final Widget gameContent;
  final Widget? topWidget; // Optional widget below score cards (e.g., timer, instructions)
  final VoidCallback? onBack;

  const GameLayout({
    Key? key,
    required this.title,
    required this.scoreCards,
    required this.gameContent,
    this.topWidget,
    this.onBack,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: SafeArea(
        child: Column(
          children: [
            // Standard spacing from top
            const SizedBox(height: 10),

            // Header with back button and title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back button - always in same position
                  IconButton(
                    onPressed: onBack ?? () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 22),
                  ),

                  // Title - always centered
                  Expanded(
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  // Spacer to balance the back button
                  const SizedBox(width: 48),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Score cards - always in same position
            GameScoreRow(cards: scoreCards),

            const SizedBox(height: 20),

            // Optional top widget (timer, instructions, etc.)
            if (topWidget != null) ...[
              topWidget!,
              const SizedBox(height: 20),
            ],

            // Main game content area
            Expanded(
              child: gameContent,
            ),
          ],
        ),
      ),
    );
  }
}
