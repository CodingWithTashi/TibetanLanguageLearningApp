import 'package:flutter/material.dart';
import 'package:tibetan_language_learning_app/util/application_util.dart';

/// Neomorphism-styled back button for consistent UI across all games
class GameBackButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const GameBackButton({
    Key? key,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed ?? () => Navigator.pop(context),
      child: Container(
        width: 48,
        height: 48,
        decoration: ApplicationUtil.getBoxDecorationOne(context).copyWith(
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
    );
  }
}
