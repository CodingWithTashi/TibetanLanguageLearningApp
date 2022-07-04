import 'package:equatable/equatable.dart';

class Alphabet extends Equatable {
  final String fileName;
  final String alphabetName;
  Alphabet({required this.fileName, required this.alphabetName});

  @override
  List<Object?> get props => [fileName, alphabetName];
}
