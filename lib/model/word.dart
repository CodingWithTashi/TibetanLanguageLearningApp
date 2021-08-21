class Word {
  String english;
  String tibetan;
  String englishSound;
  String? audioUrl;

  Word(
      {required this.english,
      required this.tibetan,
      this.audioUrl,
      required this.englishSound});
}
