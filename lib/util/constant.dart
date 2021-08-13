import 'package:tibetan_language_learning_app/util/application_util.dart';

class Alphabet {
  String fileName;
  String alphabetName;
  Alphabet({required this.fileName, required this.alphabetName});
}

class AppConstant {
  static List<Alphabet> alphabetList = [
    Alphabet(fileName: 'ka', alphabetName: 'ཀ'),
    Alphabet(fileName: 'kha', alphabetName: 'ཁ'),
    Alphabet(fileName: 'ga', alphabetName: 'ག'),
    Alphabet(fileName: 'nga', alphabetName: 'ང'),
    Alphabet(fileName: 'ca', alphabetName: 'ཅ'),
    Alphabet(fileName: 'cha', alphabetName: 'ཆ'),
    Alphabet(fileName: 'ja', alphabetName: 'ཇ'),
    Alphabet(fileName: 'nya', alphabetName: 'ཉ'),
    Alphabet(fileName: 'ta', alphabetName: 'ཏ'),
    Alphabet(fileName: 'tha', alphabetName: 'ཐ'),
    Alphabet(fileName: 'da', alphabetName: 'ད'),
    Alphabet(fileName: 'na', alphabetName: 'ན'),
    Alphabet(fileName: 'pa', alphabetName: 'པ'),
    Alphabet(fileName: 'pha', alphabetName: 'ཕ'),
    Alphabet(fileName: 'ba', alphabetName: 'བ'),
    Alphabet(fileName: 'ma', alphabetName: 'མ'),
    Alphabet(fileName: 'tsa', alphabetName: 'ཙ'),
    Alphabet(fileName: 'tsha', alphabetName: 'ཚ'),
    Alphabet(fileName: 'dza', alphabetName: 'ཛ'),
    Alphabet(fileName: 'wa', alphabetName: 'ཝ'),
    Alphabet(fileName: 'ja', alphabetName: 'ཞ'),
    Alphabet(fileName: 'za', alphabetName: 'ཟ'),
    Alphabet(fileName: 'yya', alphabetName: 'འ'),
    Alphabet(fileName: 'ya', alphabetName: 'ཡ'),
    Alphabet(fileName: 'ra', alphabetName: 'ར'),
    Alphabet(fileName: 'la', alphabetName: 'ལ'),
    Alphabet(fileName: 'sha', alphabetName: 'ཤ'),
    Alphabet(fileName: 'sa', alphabetName: 'ས'),
    Alphabet(fileName: 'ha', alphabetName: 'ཧ'),
    Alphabet(fileName: 'aa', alphabetName: 'ཨ'),
  ];
  static getAudioByAlphabet(String alphabet) {
    return alphabet + ".mp3";
  }
}
