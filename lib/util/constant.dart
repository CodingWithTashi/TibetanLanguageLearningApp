import 'package:tibetan_language_learning_app/model/alphabet.dart';
import 'package:tibetan_language_learning_app/model/verb.dart';
import 'package:tibetan_language_learning_app/model/word.dart';
import 'package:tibetan_language_learning_app/util/application_util.dart';

enum UseCaseType {
  PRONOUN,
  GREETING,
  COLORS,
  FAMILY,
  NUMBERS,
}
enum AlphabetCategoryType {
  ALPHABET,
  VOWEL,
  FIVE_PREFIX,
  TEN_SUFFIX,
  TWO_POSTFIX,
  RAGO,
  LAGO,
  SAGO,
  YATAK,
  RATAK,
  LATAK
}

class AlphabetType {
  AlphabetCategoryType type = AlphabetCategoryType.ALPHABET;
}

class AppConstant {
  static const String JOMAHALI_FAMILY = 'jomolhari';
  static const String TSUTUNG_FAMILY = 'tsutong';
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
  static const String VIEW_ON_WEB = 'Open Web App';
  static const String WEB_URL = "https://tibetanlanguagelearningapp.web.app/#/";

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

  static List<Alphabet> getAlphabetList(AlphabetCategoryType type) {
    switch (type) {
      case AlphabetCategoryType.ALPHABET:
        {
          return _alphabetList();
        }
      case AlphabetCategoryType.VOWEL:
        {
          return _vowelList();
        }
      case AlphabetCategoryType.FIVE_PREFIX:
        {
          return _fivePrefixList();
        }
      case AlphabetCategoryType.TEN_SUFFIX:
        {
          return _tenSuffixList();
        }
      case AlphabetCategoryType.TWO_POSTFIX:
        {
          return _twoPostfixList();
        }
      case AlphabetCategoryType.RAGO:
        {
          return _ragoList();
        }
      case AlphabetCategoryType.LAGO:
        {
          return _lagoList();
        }
      case AlphabetCategoryType.SAGO:
        {
          return _sogoList();
        }
      case AlphabetCategoryType.YATAK:
        {
          return _yatakList();
        }
      case AlphabetCategoryType.RATAK:
        {
          return _ratakList();
        }
      case AlphabetCategoryType.LATAK:
        {
          return _latakist();
        }
      default:
        return [];
    }
  }

  static List<Word> getWordList(UseCaseType type) {
    switch (type) {
      case UseCaseType.COLORS:
        {
          return _colorList();
        }
      case UseCaseType.FAMILY:
        {
          return _familyWordList();
        }
      case UseCaseType.GREETING:
        {
          return _greetingWordList();
        }
      case UseCaseType.NUMBERS:
        {
          return _numberWordList();
        }
      case UseCaseType.PRONOUN:
        {
          return _pronounWordList();
        }
      default:
        return [];
    }
  }

  static List<Word> _colorList() {
    return [
      Word(english: 'White', tibetan: 'དཀར་པོ།', englishSound: 'karpo'),
      Word(english: 'Red', tibetan: 'དམར་པོ།', englishSound: 'marpo'),
      Word(english: 'Black', tibetan: 'ནག་པོ།', englishSound: 'nakpo'),
      Word(english: 'Yellow', tibetan: 'གསེར་པོ།', englishSound: 'sairpo'),
      Word(english: 'Green', tibetan: 'ལྗང་ཁུ།', englishSound: 'jangkhu'),
      Word(english: 'Blue', tibetan: 'སྔོན་པོ།', englishSound: 'ngonpo'),
      Word(english: 'Pink', tibetan: 'ཟིང་སྐྱ།', englishSound: 'zingkya'),
      Word(english: 'Purple', tibetan: 'མུ་མེན།', englishSound: 'mumain'),
      Word(english: 'Orange', tibetan: 'ལི་ལྦང།', englishSound: 'liwang'),
      Word(english: 'Grey', tibetan: 'ཐལ་མདོག།', englishSound: 'thaldok'),
      Word(english: 'Brown', tibetan: 'རྒྱ་མུག།', englishSound: 'gyamuk'),
      Word(english: 'Gold', tibetan: 'གསེར་མདོག།', englishSound: 'sairdok'),
      Word(english: 'Silver', tibetan: 'དངུལ་མདོག།', englishSound: 'nguldok'),
    ];
  }

  static List<Word> _familyWordList() {
    return [
      Word(english: 'Family', tibetan: 'ནང་མི།', englishSound: 'nang mi'),
      Word(english: 'Parent', tibetan: 'ཕ་མ།', englishSound: 'phama'),
      Word(english: 'Mother', tibetan: 'ཨ་མ་ལགས།', englishSound: 'ama la'),
      Word(english: 'Father', tibetan: 'པྰ་ལགས།', englishSound: 'pa la'),
      Word(english: 'Son', tibetan: 'བུ།', englishSound: 'bu'),
      Word(english: 'Daughter', tibetan: 'བུ་མོ།', englishSound: 'bumo'),
      Word(english: 'Brother', tibetan: 'ཅོ་ཅོ།', englishSound: 'cho cho'),
      Word(
          english: 'Elder Brother',
          tibetan: 'ཅོ་ཅོ་རྒན་པ།',
          englishSound: 'chocho gyanpa'),
      Word(
          english: 'Younger Brother',
          tibetan: 'ཅོ་ཅོ་ཆུང་བ།',
          englishSound: 'chocho chungva'),
      Word(english: 'Sister', tibetan: 'ཨ་ཅག།', englishSound: 'achak'),
      Word(
          english: 'Elder Sister',
          tibetan: 'ཨ་ཅག་རྒན་པ།',
          englishSound: 'achack gyanpa'),
      Word(
          english: 'Younger Sister',
          tibetan: 'ཨ་ཅག་ཆུང་བ།',
          englishSound: 'achack chungva'),
      Word(english: 'Grandson/Nephew', tibetan: 'ཚ་བོ།', englishSound: 'tsapo'),
      Word(
          english: 'GrandDaughter/Niece',
          tibetan: 'ཚ་མོ།',
          englishSound: 'tasmo'),
      Word(english: 'Uncle', tibetan: 'ཨ་ཞང།', englishSound: 'ashang'),
      Word(english: 'Aunt', tibetan: 'ཨ་ནི།', englishSound: 'aani'),
      Word(english: 'Husband', tibetan: 'ཁྱོ་ཁ།', englishSound: 'kyoga'),
      Word(english: 'Wife', tibetan: 'ཟ་ཟླ།', englishSound: 'za dha'),
      Word(english: 'Boy Friend', tibetan: 'དགའ་རོགས', englishSound: 'ga rog'),
      Word(english: 'Relative', tibetan: 'སྤུན་ཉེ།', englishSound: 'pun chath'),
      Word(english: 'Grand Father', tibetan: 'པོ་པོ།', englishSound: 'popo'),
      Word(english: 'Grand Mother', tibetan: 'མོ་མོ།', englishSound: 'mho mho'),
    ];
  }

  static List<Word> _greetingWordList() {
    return [
      Word(
          english: 'Hello/Hi',
          tibetan: 'བཀྲ་ཤིས་བདེ་ལེགས།',
          englishSound: 'Tashi Delek'),
      Word(
          english: 'Good Morning',
          tibetan: 'སྔ་དྲོ་བདེ་ལེགས།',
          englishSound: 'Nga do delek'),
      Word(
          english: 'Good Afternoon',
          tibetan: 'ཉིན་གུང་བདེ་ལེགས།',
          englishSound: 'Nyigung delek'),
      Word(
          english: 'Good Evening',
          tibetan: 'དགོང་དྲོ་བདེ་ལེགས།',
          englishSound: 'Gongdo Delek'),
      Word(
          english: 'Good Night',
          tibetan: 'གཟིམ་འཇག་གནང།',
          englishSound: 'Zim jag nang go'),
      Word(english: 'Good Bye', tibetan: 'བཞུགས་ཨ།', englishSound: 'Jhug ah'),
      Word(
          english: 'Take care',
          tibetan: 'ཅག་པོ་བྱེད།',
          englishSound: 'Chack po jay'),
      Word(
          english: 'See You later',
          tibetan: 'རྗེས་ལ་མཇལ་ཡོང།',
          englishSound: 'Jay la jal yong'),
      Word(
          english: 'Nice to meet you',
          tibetan: 'རང་ཐུག་པ་དགའ་པོ་བྱུང།',
          englishSound: 'rang thukapa gapo jhung'),
      Word(
          english: 'Cheers',
          tibetan: 'དགའ་བསུ་བྱེད།',
          englishSound: 'gasu jay'),
      Word(english: 'Great/Nice', tibetan: 'ལེགས་པོ།', englishSound: 'lakhpo'),
      Word(
          english: 'Celebration',
          tibetan: 'རྟེན་འབྲེལ།',
          englishSound: 'Tendral'),
      Word(english: 'Respect', tibetan: 'གུས་ཞབས།', englishSound: 'Guzhab'),
      Word(english: 'Smile', tibetan: 'འཛུམ།', englishSound: 'zoom'),
    ];
  }

  static List<Word> _numberWordList() {
    return [
      Word(english: 'Zero', tibetan: 'ཀླད་ཀོར།', englishSound: 'lhai koy'),
      Word(english: 'One', tibetan: 'གཅིག།', englishSound: 'chik'),
      Word(english: 'Two', tibetan: 'གཉིས།', englishSound: 'nyi'),
      Word(english: 'Three', tibetan: 'གསུམ།', englishSound: 'syum'),
      Word(english: 'Four', tibetan: 'བཞི།', englishSound: 'zshi'),
      Word(english: 'Five', tibetan: 'ལྔ།', englishSound: 'nga'),
      Word(english: 'Six', tibetan: 'དྲུག།', englishSound: 'druk'),
      Word(english: 'Seven', tibetan: 'བདུན།', englishSound: 'dun'),
      Word(english: 'Eight', tibetan: 'བརྒྱད།', englishSound: 'gyay'),
      Word(english: 'Nine', tibetan: 'དགུ།', englishSound: 'ghu'),
      Word(english: 'Ten', tibetan: 'བཅུ།', englishSound: 'chu'),
      Word(english: 'Hundred', tibetan: 'བརྒྱ།', englishSound: 'gya'),
      Word(
          english: 'Two hundred',
          tibetan: 'གཉིས་བརྒྱ།',
          englishSound: 'nyi gya'),
      Word(
          english: 'Three hundred',
          tibetan: 'གསུམ་བརྒྱ།',
          englishSound: 'syum gya'),
      Word(
          english: 'Four hundred',
          tibetan: 'བཞི་བརྒྱ།',
          englishSound: 'zshi gya'),
      Word(
          english: 'Five hundred',
          tibetan: 'ལྔ་བརྒྱ།',
          englishSound: 'nga gya'),
      Word(
          english: 'Six hundred',
          tibetan: 'དྲུག་བརྒྱ།',
          englishSound: 'druk gya'),
      Word(
          english: 'Seven hundred',
          tibetan: 'བདུན་བརྒྱ།',
          englishSound: 'dun gya'),
      Word(
          english: 'Eight hundred',
          tibetan: 'བརྒྱད་བརྒྱ།',
          englishSound: 'gyay gya'),
      Word(
          english: 'Nine hundred',
          tibetan: 'དགུ་བརྒྱ།',
          englishSound: 'ghu gya'),
      Word(english: 'Thousand', tibetan: 'སྟོང།', englishSound: 'tong'),
      Word(english: 'Ten thousand', tibetan: 'ཁྲི།', englishSound: 'tri'),
      Word(english: 'Hundred Thousand', tibetan: 'འབུམ།', englishSound: 'bhum'),
      Word(english: 'Million', tibetan: 'ས་ཡ།', englishSound: 'saya'),
      Word(english: 'Billion', tibetan: 'བྱེ་བ།', englishSound: 'jayva'),
    ];
  }

  static List<Word> _pronounWordList() {
    return [
      Word(english: 'I', tibetan: 'ང།', englishSound: 'nga'),
      Word(english: 'You', tibetan: 'ཁྱེད་རང།', englishSound: 'khey rang'),
      Word(english: 'He/She', tibetan: 'ཁོང།', englishSound: 'khong'),
      Word(english: 'We', tibetan: 'ང་ཚོ།', englishSound: 'nga tso'),
      Word(english: 'They', tibetan: 'ཁོ་ཚོ།', englishSound: 'khon tso'),
      Word(english: 'This', tibetan: 'འདི།', englishSound: 'di'),
      Word(english: 'That', tibetan: 'དེ།', englishSound: 'dhay'),
      Word(english: 'These', tibetan: 'འདི་ཚོ།', englishSound: 'de tso'),
      Word(english: 'Those', tibetan: 'དེ་ཚོ།', englishSound: 'dhay tso'),
      Word(
          english: 'Their',
          tibetan: 'ཁོང་རང་ཚོ།',
          englishSound: 'khong rang tso'),
    ];
  }

  static List<Alphabet> _alphabetList() {
    return [
      Alphabet(fileName: 'ka', alphabetName: 'ཀ་'),
      Alphabet(fileName: 'kha', alphabetName: 'ཁ་'),
      Alphabet(fileName: 'ga', alphabetName: 'ག་'),
      Alphabet(fileName: 'nga', alphabetName: 'ང་'),
      Alphabet(fileName: 'ca', alphabetName: 'ཅ་'),
      Alphabet(fileName: 'cha', alphabetName: 'ཆ་'),
      Alphabet(fileName: 'ja', alphabetName: 'ཇ་'),
      Alphabet(fileName: 'nya', alphabetName: 'ཉ་'),
      Alphabet(fileName: 'ta', alphabetName: 'ཏ་'),
      Alphabet(fileName: 'tha', alphabetName: 'ཐ་'),
      Alphabet(fileName: 'da', alphabetName: 'ད་'),
      Alphabet(fileName: 'na', alphabetName: 'ན་'),
      Alphabet(fileName: 'pa', alphabetName: 'པ་'),
      Alphabet(fileName: 'pha', alphabetName: 'ཕ་'),
      Alphabet(fileName: 'ba', alphabetName: 'བ་'),
      Alphabet(fileName: 'ma', alphabetName: 'མ་'),
      Alphabet(fileName: 'tsa', alphabetName: 'ཙ་'),
      Alphabet(fileName: 'tsha', alphabetName: 'ཚ་'),
      Alphabet(fileName: 'dza', alphabetName: 'ཛ་'),
      Alphabet(fileName: 'wa', alphabetName: 'ཝ་'),
      Alphabet(fileName: 'jha', alphabetName: 'ཞ་'),
      Alphabet(fileName: 'za', alphabetName: 'ཟ་'),
      Alphabet(fileName: 'yya', alphabetName: 'འ་'),
      Alphabet(fileName: 'ya', alphabetName: 'ཡ་'),
      Alphabet(fileName: 'ra', alphabetName: 'ར་'),
      Alphabet(fileName: 'la', alphabetName: 'ལ་'),
      Alphabet(fileName: 'sha', alphabetName: 'ཤ་'),
      Alphabet(fileName: 'sa', alphabetName: 'ས་'),
      Alphabet(fileName: 'ha', alphabetName: 'ཧ་'),
      Alphabet(fileName: 'aa', alphabetName: 'ཨ་'),
    ];
  }

  static List<Alphabet> _vowelList() {
    return [
      Alphabet(fileName: '', alphabetName: 'ཨི།'),
      Alphabet(fileName: '', alphabetName: 'ཨུ།'),
      Alphabet(fileName: '', alphabetName: 'ཨེ།'),
      Alphabet(fileName: '', alphabetName: 'ཨོ།'),
    ];
  }

  static List<Alphabet> _fivePrefixList() {
    return [
      Alphabet(fileName: 'ga', alphabetName: 'ག'),
      Alphabet(fileName: 'da', alphabetName: 'ད'),
      Alphabet(fileName: 'ba', alphabetName: 'བ'),
      Alphabet(fileName: 'ma', alphabetName: 'མ'),
      Alphabet(fileName: 'yya', alphabetName: 'འ'),
    ];
  }

  static List<Alphabet> _tenSuffixList() {
    return [
      Alphabet(fileName: 'ga', alphabetName: 'ག'),
      Alphabet(fileName: 'nga', alphabetName: 'ང'),
      Alphabet(fileName: 'da', alphabetName: 'ད'),
      Alphabet(fileName: 'na', alphabetName: 'ན'),
      Alphabet(fileName: 'ba', alphabetName: 'བ'),
      Alphabet(fileName: 'ma', alphabetName: 'མ'),
      Alphabet(fileName: 'yya', alphabetName: 'འ'),
      Alphabet(fileName: 'ra', alphabetName: 'ར'),
      Alphabet(fileName: 'la', alphabetName: 'ལ'),
      Alphabet(fileName: 'sa', alphabetName: 'ས'),
    ];
  }

  static List<Alphabet> _twoPostfixList() {
    return [
      Alphabet(fileName: 'da', alphabetName: 'ད'),
      Alphabet(fileName: 'sa', alphabetName: 'ས'),
    ];
  }

  static List<Alphabet> _ragoList() {
    return [
      Alphabet(fileName: '', alphabetName: 'རྐ།'),
      Alphabet(fileName: '', alphabetName: 'རྒ།'),
      Alphabet(fileName: '', alphabetName: 'རྔ།'),
      Alphabet(fileName: '', alphabetName: 'རྗ།'),
      Alphabet(fileName: '', alphabetName: 'རྙ།'),
      Alphabet(fileName: '', alphabetName: 'རྟ།'),
      Alphabet(fileName: '', alphabetName: 'རྡ།'),
      Alphabet(fileName: '', alphabetName: 'རྣ།'),
      Alphabet(fileName: '', alphabetName: 'རྦ།'),
      Alphabet(fileName: '', alphabetName: 'རྨ།'),
      Alphabet(fileName: '', alphabetName: 'རྩ།'),
      Alphabet(fileName: '', alphabetName: 'རྫ'),
    ];
  }

  static List<Alphabet> _lagoList() {
    return [
      Alphabet(fileName: '', alphabetName: 'ལྐ།'),
      Alphabet(fileName: '', alphabetName: 'ལྒ།'),
      Alphabet(fileName: '', alphabetName: 'ལྔ།'),
      Alphabet(fileName: '', alphabetName: 'ལྕ།'),
      Alphabet(fileName: '', alphabetName: 'ལྗ།'),
      Alphabet(fileName: '', alphabetName: 'ལྟ།'),
      Alphabet(fileName: '', alphabetName: 'ལྡ།'),
      Alphabet(fileName: '', alphabetName: 'ལྤ།'),
      Alphabet(fileName: '', alphabetName: 'ལྦ།'),
      Alphabet(fileName: '', alphabetName: 'ལྷ།'),
    ];
  }

  static List<Alphabet> _sogoList() {
    return [
      Alphabet(fileName: '', alphabetName: 'སྐ།'),
      Alphabet(fileName: '', alphabetName: 'སྑ།'),
      Alphabet(fileName: '', alphabetName: 'སྔ།'),
      Alphabet(fileName: '', alphabetName: 'སྙ།'),
      Alphabet(fileName: '', alphabetName: 'སྟ།'),
      Alphabet(fileName: '', alphabetName: 'སྡ།'),
      Alphabet(fileName: '', alphabetName: 'སྣ།'),
      Alphabet(fileName: '', alphabetName: 'སྤ།'),
      Alphabet(fileName: '', alphabetName: 'སྦ།'),
      Alphabet(fileName: '', alphabetName: 'སྨ།'),
      Alphabet(fileName: '', alphabetName: 'སྩ།'),
    ];
  }

  static List<Alphabet> _yatakList() {
    return [
      Alphabet(fileName: '', alphabetName: 'ཀྱ།'),
      Alphabet(fileName: '', alphabetName: 'ཁྱ།'),
      Alphabet(fileName: '', alphabetName: 'གྱ།'),
      Alphabet(fileName: '', alphabetName: 'པྱ།'),
      Alphabet(fileName: '', alphabetName: 'ཕྱ།'),
      Alphabet(fileName: '', alphabetName: 'བྱ།'),
      Alphabet(fileName: '', alphabetName: 'མྱ།'),
    ];
  }

  static List<Alphabet> _ratakList() {
    return [
      Alphabet(fileName: '', alphabetName: 'ཀྲ།'),
      Alphabet(fileName: '', alphabetName: 'ཁྲ།'),
      Alphabet(fileName: '', alphabetName: 'གྲ།'),
      Alphabet(fileName: '', alphabetName: 'ཏྲ།'),
      Alphabet(fileName: '', alphabetName: 'ཐྲ།'),
      Alphabet(fileName: '', alphabetName: 'དྲ།'),
      Alphabet(fileName: '', alphabetName: 'པྲ།'),
      Alphabet(fileName: '', alphabetName: 'ཕྲ།'),
      Alphabet(fileName: '', alphabetName: 'བྲ།'),
      Alphabet(fileName: '', alphabetName: 'མྲ།'),
      Alphabet(fileName: '', alphabetName: 'སྲ།'),
      Alphabet(fileName: '', alphabetName: 'ཧྲ།'),
    ];
  }

  static List<Alphabet> _latakist() {
    return [
      Alphabet(fileName: '', alphabetName: 'ཀླ།'),
      Alphabet(fileName: '', alphabetName: 'གླ།'),
      Alphabet(fileName: '', alphabetName: 'བླ།'),
      Alphabet(fileName: '', alphabetName: 'ཟླ།'),
      Alphabet(fileName: '', alphabetName: 'རླ།'),
      Alphabet(fileName: '', alphabetName: 'སླ།'),
    ];
  }
}
