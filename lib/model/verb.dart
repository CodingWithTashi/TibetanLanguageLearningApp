class Verb {
  String fileName;
  String word;
  List<String> characterList;
  Verb(
      {required this.fileName,
      required this.word,
      this.characterList = const []});

  Verb.clone({required Verb verb})
      : this(
          fileName: verb.fileName,
          word: verb.word,
          characterList: verb.characterList,
        );
}
