import 'package:tibetan_language_learning_app/util/application_util.dart';

class Alphabet {
  String fileName;
  String alphabetName;
  Alphabet({required this.fileName, required this.alphabetName});
}

class Verb {
  String fileName;
  String word;
  Verb({required this.fileName, required this.word});
}

class AppConstant {
  static const String CONTACT_US = 'Contact Us';
  static const String EMAIL = 'developer.kharag@gmail.com';
  static const String SUBJECT = 'Feedback & report';
  static const String BANNER_AD_HOME_UNIT_ID =
      'ca-app-pub-8284901143739274/2994092444';
  static const String BANNER_AD_LEARN_MENU_UNIT_ID =
      'ca-app-pub-8284901143739274/6651100571';
  static const String TEST_UNIT_ID = 'ca-app-pub-3940256099942544/6300978111';
  static const String APP_ID = 'ca-app-pub-8284901143739274~1421990473';
  static const String SHARE_URL =
      'https://play.google.com/store/apps/details?id=com.kharagedition.tibetan_language_learning_app';
  static const String MORE_URL =
      'https://play.google.com/store/apps/dev?id=5910382695653514663';
  static const String CALENDER_URL =
      'http://www.digitaltibetan.org/cgi-bin/phugpa.pl';
  static const String APP_URL =
      'https://play.google.com/store/apps/details?id=com.kharagedition.tibetan_language_learning_app';

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
    Alphabet(fileName: 'jha', alphabetName: 'ཞ'),
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

  static List<Verb> verbsList = [
    Verb(fileName: 'apple', word: 'ཀུ་ཤུ།'),
    Verb(fileName: 'phone', word: 'ཁ་པར།'),
    Verb(fileName: 'balloon', word: 'སྒང་ཕུག།'),
    Verb(fileName: 'duck', word: 'ངང་པ།'),
    Verb(fileName: 'chain', word: 'ལྕགས་ཐག།'),
    Verb(fileName: 'water', word: 'ཆུ།'),
    Verb(fileName: 'rainbow', word: 'འཇའ།'),
    Verb(fileName: 'fish', word: 'ཉ།'),
    Verb(fileName: 'horse', word: 'རྟ།'),
    Verb(fileName: 'rope', word: 'ཐག་པ།'),
    Verb(fileName: 'flag', word: 'དར་ཆ།'),
    Verb(fileName: 'blackboard', word: 'ནག་པང།'),
    Verb(fileName: 'camera', word: 'པར་ཆས།'),
    Verb(fileName: 'pig', word: 'ཕག་པ།'),
    Verb(fileName: 'cow', word: 'བ་ཕྱུགས།'),
    Verb(fileName: 'fire', word: 'མེ།'),
    Verb(fileName: 'grass', word: 'རྩ།'),
    Verb(fileName: 'orange', word: 'ཚ་ལུ་མ།'),
    Verb(fileName: 'earth', word: 'འཛམ་བུ་གླིང།'),
    Verb(fileName: 'fox', word: 'ཝ་མོ།'),
    Verb(fileName: 'hat', word: 'ཞྭ་མོ།'),
    Verb(fileName: 'copper', word: 'ཟངས།'),
    Verb(fileName: 'owl', word: 'འུག་པ།'),
    Verb(fileName: 'candle', word: 'ཡང་ལཱ།'),
    Verb(fileName: 'goat', word: 'ར།'),
    Verb(fileName: 'hand', word: 'ལག་པ།'),
    Verb(fileName: 'meat', word: 'ཤ།'),
    Verb(fileName: 'map', word: 'ས་བཀྲ།'),
    Verb(fileName: 'pot', word: 'ཧ་ཡང།'),
    Verb(fileName: 'mango', word: 'ཨམ།'),
  ];
  static getAudioByVerb(String verb) {
    return 'assets/audio/words/' + verb + ".mp3";
  }
}
