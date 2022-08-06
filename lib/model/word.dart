import 'package:flutter/material.dart';

class Word {
  final String _english;
  final String _tibetan;
  final String _englishSound;
  final String? _audioUrl;
  final String _assetPath;
  final AnimationController? _animationController;

  const Word({
    required String english,
    required String tibetan,
    required String englishSound,
    String? audioUrl,
    required String assetPath,
    AnimationController? animationController,
  })  : _english = english,
        _tibetan = tibetan,
        _englishSound = englishSound,
        _audioUrl = audioUrl,
        _assetPath = assetPath,
        _animationController = animationController;

  AnimationController? get animationController => _animationController;

  String get assetPath => _assetPath;

  String? get audioUrl => _audioUrl;

  String get englishSound => _englishSound;

  String get tibetan => _tibetan;

  String get english => _english;
}
