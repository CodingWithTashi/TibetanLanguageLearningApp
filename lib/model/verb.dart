import 'package:equatable/equatable.dart';

class Verb extends Equatable {
  final String _fileName;
  final String _word;
  final List<String> _characterList;

  const Verb({
    required String fileName,
    required String word,
    List<String> characterList = const [],
  })  : _fileName = fileName,
        _word = word,
        _characterList = characterList;

  String get fileName => _fileName;

  @override
  // TODO: implement props
  List<Object?> get props => [_fileName, _word, _characterList];

  String get word => _word;

  List<String> get characterList => _characterList;
}
