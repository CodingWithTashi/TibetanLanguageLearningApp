import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../../util/application_util.dart';

class GameResultDialog extends StatelessWidget {
  final String title;
  final int score;
  final int stars;
  final int coinsEarned;
  final String message;
  final VoidCallback onPlayAgain;
  final VoidCallback onExit;

  const GameResultDialog({
    Key? key,
    required this.title,
    required this.score,
    required this.stars,
    required this.coinsEarned,
    required this.message,
    required this.onPlayAgain,
    required this.onExit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Victory animation
            SizedBox(
              height: 120,
              child: Lottie.network(
                'https://assets9.lottiefiles.com/packages/lf20_aEFaHc.json',
                repeat: false,
              ),
            ),

            // Title
            Text(
              title,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),

            // Message
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 20),

            // Stars display
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(
                    index < stars ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 40,
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),

            // Score and coins
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatCard(
                  context,
                  'Score',
                  score.toString(),
                  Icons.emoji_events,
                ),
                _buildStatCard(
                  context,
                  'Coins',
                  '+$coinsEarned',
                  Icons.monetization_on,
                ),
              ],
            ),
            const SizedBox(height: 25),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: onExit,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: ApplicationUtil.getBoxDecorationOne(context),
                      child: const Center(
                        child: Text(
                          'Exit',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: onPlayAgain,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: ApplicationUtil.getBoxDecorationOne(context),
                      child: const Center(
                        child: Text(
                          'Play Again',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: ApplicationUtil.getBoxDecorationOne(context),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 32),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
