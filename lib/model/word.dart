import 'package:flutter/material.dart';

class Word {
  String english;
  String tibetan;
  String englishSound;
  String? audioUrl;
  String assetPath;
  AnimationController? animationController;

  Word(
      {required this.english,
      required this.tibetan,
      this.audioUrl,
      required this.assetPath,
      required this.englishSound,
      this.animationController});
}
