import 'package:equatable/equatable.dart';

class Alphabet extends Equatable {
  final String _fileName;
  final String _alphabetName;

  const Alphabet({
    required String fileName,
    required String alphabetName,
  })  : _fileName = fileName,
        _alphabetName = alphabetName;

  String get fileName => _fileName;

  String get alphabetName => _alphabetName;

  @override
  List<Object?> get props => [_fileName, _alphabetName];
}
