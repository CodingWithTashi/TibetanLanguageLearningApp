import 'package:tibetan_language_learning_app/util/application_util.dart';

class AppConstant {
  static List<String> alphabetList = [
    'A',
    'B',
    'C',
    'D',
    'E',
    'F',
    'G',
    'H',
    'I',
    'J',
    'K',
    'L',
    'M',
    'N',
    'O',
    'P',
    'Q',
    'R',
    'S',
    'T',
    'U',
    'V',
    'W',
    'X',
    'Y',
    'Z'
  ];
  static getAudioByAlphabet(String alphabet){
    return alphabet+".mp3";
  }
}
