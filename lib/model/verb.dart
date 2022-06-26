import 'package:equatable/equatable.dart';

class Verb extends Equatable {
  final String fileName;
  final String word;
  final List<String> characterList;
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

  @override
  // TODO: implement props
  List<Object?> get props => [fileName, word, characterList];
}
