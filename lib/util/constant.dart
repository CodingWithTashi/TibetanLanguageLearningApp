import 'package:flutter/material.dart';
import 'package:tibetan_language_learning_app/model/alphabet.dart';
import 'package:tibetan_language_learning_app/model/verb.dart';
import 'package:tibetan_language_learning_app/model/word.dart';

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
  static const String BANNER_AD_PRACTICE_MENU_UNIT_ID =
      'ca-app-pub-8284901143739274/9771506718';
  static const String SPELLING_BEE_REWARD_AD_UNIT_ID =
      'ca-app-pub-8284901143739274/9784292343';
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
  static const List<String> allWords = ["CAT", "PIG", "FOX", "LION"];

  static String getTibetanNumberByNumber({required String number}) {
    String finalNumber = "";
    number.runes.forEach((element) {
      switch (int.parse(String.fromCharCode(element))) {
        case 0:
          finalNumber += '༠';
          break;
        case 1:
          finalNumber += '༡';
          break;

        case 2:
          finalNumber += '༢';
          break;

        case 3:
          finalNumber += '༣';
          break;

        case 4:
          finalNumber += '༤';
          break;

        case 5:
          finalNumber += '༥';
          break;

        case 6:
          finalNumber += '༦';
          break;

        case 7:
          finalNumber += '༧';
          break;

        case 8:
          finalNumber += '༨';
          break;

        case 9:
          finalNumber += '༩';
          break;

        default:
          finalNumber += '༠';
          break;
      }
    });
    return finalNumber;
  }

  static List<Verb> verbsList = [
    Verb(
      fileName: 'phone',
      word: 'ཁ་པར།',
      characterList: ['ཁ་', 'པ', 'ར།'],
    ),
    Verb(
        fileName: 'balloon',
        word: 'སྒང་ཕུག།',
        characterList: ['སྒ', 'ང་', 'ཕུ', 'ག།']),
    Verb(
      fileName: 'duck',
      word: 'ངང་པ།',
      characterList: ['ང', 'ང་', 'པ།'],
    ),
    Verb(
      fileName: 'chain',
      word: 'ལྕགས་ཐག།',
      characterList: ['ལྕ', 'ག', 'ས་', 'ཐ', 'ག།'],
    ),
    Verb(
      fileName: 'water',
      word: 'ཆུ།',
      characterList: ['ཆུ།'],
    ),
    Verb(
      fileName: 'rainbow',
      word: 'འཇའ།',
      characterList: ['འ', 'ཇ', 'འ།'],
    ),
    Verb(
      fileName: 'fish',
      word: 'ཉ།',
      characterList: ['ཉ།'],
    ),
    Verb(fileName: 'horse', word: 'རྟ།', characterList: ['རྟ།']),
    Verb(
      fileName: 'rope',
      word: 'ཐག་པ།',
      characterList: ['ཐ', 'ག་', 'པ།'],
    ),
    Verb(
      fileName: 'flag',
      word: 'དར་ཆ།',
      characterList: ['ད', 'ར་', 'ཆ།'],
    ),
    Verb(
      fileName: 'blackboard',
      word: 'ནག་པང།',
      characterList: ['ན', 'ག་', 'པ', 'ང།'],
    ),
    Verb(
      fileName: 'camera',
      word: 'པར་ཆས།',
      characterList: ['པ', 'ར་', 'ཆ', 'ས།'],
    ),
    Verb(
      fileName: 'pig',
      word: 'ཕག་པ།',
      characterList: ['ཕ', 'ག་', 'པ།'],
    ),
    Verb(
      fileName: 'cow',
      word: 'བ་ཕྱུགས།',
      characterList: ['བ་', 'ཕྱུ', 'ག', 'ས།'],
    ),
    Verb(
      fileName: 'fire',
      word: 'མེ།',
      characterList: ['མེ།'],
    ),
    Verb(
      fileName: 'grass',
      word: 'རྩ།',
      characterList: ['རྩ།'],
    ),
    Verb(
      fileName: 'orange',
      word: 'ཚ་ལུ་མ།',
      characterList: ['ཚ་', 'ལུ་', 'མ།'],
    ),
    Verb(
      fileName: 'earth',
      word: 'འཛམ་བུ་གླིང།',
      characterList: ['འ', 'ཛ', 'མ་', 'བུ་', 'གླི', 'ང།'],
    ),
    Verb(
      fileName: 'fox',
      word: 'ཝ་མོ།',
      characterList: ['ཝ་', 'མོ།'],
    ),
    Verb(
      fileName: 'hat',
      word: 'ཞྭ་མོ།',
      characterList: ['ཞྭ་', 'མོ།'],
    ),
    Verb(
      fileName: 'copper',
      word: 'ཟངས།',
      characterList: ['ཟ', 'ང', 'ས།'],
    ),
    Verb(
      fileName: 'owl',
      word: 'འུག་པ།',
      characterList: ['འུ', 'ག་', 'པ།'],
    ),
    Verb(
      fileName: 'candle',
      word: 'ཡང་ལཱ།',
      characterList: ['ཡ', 'ང་', 'ལཱ།'],
    ),
    Verb(
      fileName: 'goat',
      word: 'ར།',
      characterList: ['ར།'],
    ),
    Verb(
      fileName: 'hand',
      word: 'ལག་པ།',
      characterList: ['ལ', 'ག་', 'པ།'],
    ),
    Verb(
      fileName: 'meat',
      word: 'ཤ།',
      characterList: ['ཤ།'],
    ),
    Verb(
      fileName: 'map',
      word: 'ས་བཀྲ།',
      characterList: ['ས་', 'བ', 'ཀྲ།'],
    ),
    Verb(
      fileName: 'pot',
      word: 'ཧ་ཡང།',
      characterList: ['ཧ་', 'ཡ', 'ང།'],
    ),
    Verb(
      fileName: 'mango',
      word: 'ཨམ།',
      characterList: ['ཨ', 'མ།'],
    ),
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

  static List<Word> getWordList(UseCaseType type, _useCaseItemListState) {
    switch (type) {
      case UseCaseType.COLORS:
        {
          return _colorList(_useCaseItemListState);
        }
      case UseCaseType.FAMILY:
        {
          return _familyWordList(_useCaseItemListState);
        }
      case UseCaseType.GREETING:
        {
          return _greetingWordList(_useCaseItemListState);
        }
      case UseCaseType.NUMBERS:
        {
          return _numberWordList(_useCaseItemListState);
        }
      case UseCaseType.PRONOUN:
        {
          return _pronounWordList(_useCaseItemListState);
        }
      default:
        return [];
    }
  }

  static List<Word> _colorList(useCaseItemListState) {
    return [
      Word(
        english: 'White',
        tibetan: 'དཀར་པོ།',
        englishSound: 'karpo',
        assetPath: 'assets/audio/colors/white.mp3',
        animationController: AnimationController(
          vsync: useCaseItemListState,
          duration: Duration(milliseconds: 100),
          reverseDuration: Duration(milliseconds: 100),
        ),
      ),
      Word(
          english: 'Red',
          tibetan: 'དམར་པོ།',
          englishSound: 'marpo',
          assetPath: 'assets/audio/colors/red.mp3',
          animationController: AnimationController(
            vsync: useCaseItemListState,
            duration: Duration(milliseconds: 100),
            reverseDuration: Duration(milliseconds: 100),
          )),
      Word(
          english: 'Black',
          tibetan: 'ནག་པོ།',
          englishSound: 'nakpo',
          assetPath: 'assets/audio/colors/black.mp3',
          animationController: AnimationController(
            vsync: useCaseItemListState,
            duration: Duration(milliseconds: 100),
            reverseDuration: Duration(milliseconds: 100),
          )),
      Word(
          english: 'Yellow',
          tibetan: 'གསེར་པོ།',
          englishSound: 'sairpo',
          assetPath: 'assets/audio/colors/yellow.mp3',
          animationController: AnimationController(
            vsync: useCaseItemListState,
            duration: Duration(milliseconds: 100),
            reverseDuration: Duration(milliseconds: 100),
          )),
      Word(
          english: 'Green',
          tibetan: 'ལྗང་ཁུ།',
          englishSound: 'jangkhu',
          assetPath: 'assets/audio/colors/green.mp3',
          animationController: AnimationController(
            vsync: useCaseItemListState,
            duration: Duration(milliseconds: 100),
            reverseDuration: Duration(milliseconds: 100),
          )),
      Word(
          english: 'Blue',
          tibetan: 'སྔོན་པོ།',
          englishSound: 'ngonpo',
          assetPath: 'assets/audio/colors/blue.mp3',
          animationController: AnimationController(
            vsync: useCaseItemListState,
            duration: Duration(milliseconds: 100),
            reverseDuration: Duration(milliseconds: 100),
          )),
      Word(
          english: 'Pink',
          tibetan: 'ཟིང་སྐྱ།',
          englishSound: 'zingkya',
          assetPath: 'assets/audio/colors/pink.mp3',
          animationController: AnimationController(
            vsync: useCaseItemListState,
            duration: Duration(milliseconds: 100),
            reverseDuration: Duration(milliseconds: 100),
          )),
      Word(
          english: 'Purple',
          tibetan: 'མུ་མེན།',
          englishSound: 'mumain',
          assetPath: 'assets/audio/colors/purple.mp3',
          animationController: AnimationController(
            vsync: useCaseItemListState,
            duration: Duration(milliseconds: 100),
            reverseDuration: Duration(milliseconds: 100),
          )),
      Word(
          english: 'Orange',
          tibetan: 'ལི་ལྦང།',
          englishSound: 'liwang',
          assetPath: 'assets/audio/colors/orange.mp3',
          animationController: AnimationController(
            vsync: useCaseItemListState,
            duration: Duration(milliseconds: 100),
            reverseDuration: Duration(milliseconds: 100),
          )),
      Word(
          english: 'Grey',
          tibetan: 'ཐལ་མདོག།',
          englishSound: 'thaldok',
          assetPath: 'assets/audio/colors/grey.mp3',
          animationController: AnimationController(
            vsync: useCaseItemListState,
            duration: Duration(milliseconds: 100),
            reverseDuration: Duration(milliseconds: 100),
          )),
      Word(
        english: 'Brown',
        tibetan: 'རྒྱ་མུག།',
        englishSound: 'gyamuk',
        assetPath: 'assets/audio/colors/brown.mp3',
        animationController: AnimationController(
          vsync: useCaseItemListState,
          duration: Duration(milliseconds: 100),
          reverseDuration: Duration(milliseconds: 100),
        ),
      ),
      Word(
        english: 'Gold',
        tibetan: 'གསེར་མདོག།',
        englishSound: 'sairdok',
        assetPath: 'assets/audio/colors/gold.mp3',
        animationController: AnimationController(
          vsync: useCaseItemListState,
          duration: Duration(milliseconds: 100),
          reverseDuration: Duration(milliseconds: 100),
        ),
      ),
      Word(
          english: 'Silver',
          tibetan: 'དངུལ་མདོག།',
          englishSound: 'nguldok',
          assetPath: 'assets/audio/colors/silver.mp3',
          animationController: AnimationController(
            vsync: useCaseItemListState,
            duration: Duration(milliseconds: 100),
            reverseDuration: Duration(milliseconds: 100),
          )),
    ];
  }

  static List<Word> _familyWordList(useCaseItemListState) {
    return [
      Word(
        english: 'Family',
        tibetan: 'ནང་མི།',
        englishSound: 'nang mi',
        assetPath: 'assets/audio/family/family.mp3',
        animationController: AnimationController(
          vsync: useCaseItemListState,
          duration: Duration(milliseconds: 100),
          reverseDuration: Duration(milliseconds: 100),
        ),
      ),
      Word(
        english: 'Parent',
        tibetan: 'ཕ་མ།',
        englishSound: 'phama',
        assetPath: 'assets/audio/family/parent.mp3',
        animationController: AnimationController(
          vsync: useCaseItemListState,
          duration: Duration(milliseconds: 100),
          reverseDuration: Duration(milliseconds: 100),
        ),
      ),
      Word(
        english: 'Mother',
        tibetan: 'ཨ་མ་ལགས།',
        englishSound: 'ama la',
        assetPath: 'assets/audio/family/mother.mp3',
        animationController: AnimationController(
          vsync: useCaseItemListState,
          duration: Duration(milliseconds: 100),
          reverseDuration: Duration(milliseconds: 100),
        ),
      ),
      Word(
        english: 'Father',
        tibetan: 'པྰ་ལགས།',
        englishSound: 'pa la',
        assetPath: 'assets/audio/family/father.mp3',
        animationController: AnimationController(
          vsync: useCaseItemListState,
          duration: Duration(milliseconds: 100),
          reverseDuration: Duration(milliseconds: 100),
        ),
      ),
      Word(
        english: 'Son',
        tibetan: 'བུ།',
        englishSound: 'bu',
        assetPath: 'assets/audio/family/son.mp3',
        animationController: AnimationController(
          vsync: useCaseItemListState,
          duration: Duration(milliseconds: 100),
          reverseDuration: Duration(milliseconds: 100),
        ),
      ),
      Word(
        english: 'Daughter',
        tibetan: 'བུ་མོ།',
        englishSound: 'bumo',
        assetPath: 'assets/audio/family/daughter.mp3',
        animationController: AnimationController(
          vsync: useCaseItemListState,
          duration: Duration(milliseconds: 100),
          reverseDuration: Duration(milliseconds: 100),
        ),
      ),
      Word(
        english: 'Brother',
        tibetan: 'ཅོ་ཅོ།',
        englishSound: 'cho cho',
        assetPath: 'assets/audio/family/brother.mp3',
        animationController: AnimationController(
          vsync: useCaseItemListState,
          duration: Duration(milliseconds: 100),
          reverseDuration: Duration(milliseconds: 100),
        ),
      ),
      Word(
        english: 'Elder Brother',
        tibetan: 'ཅོ་ཅོ་རྒན་པ།',
        englishSound: 'chocho gyanpa',
        assetPath: 'assets/audio/family/elderbrother.mp3',
        animationController: AnimationController(
          vsync: useCaseItemListState,
          duration: Duration(milliseconds: 100),
          reverseDuration: Duration(milliseconds: 100),
        ),
      ),
      Word(
        english: 'Younger Brother',
        tibetan: 'ཅོ་ཅོ་ཆུང་བ།',
        englishSound: 'chocho chungva',
        assetPath: 'assets/audio/family/youngerbrother.mp3',
        animationController: AnimationController(
          vsync: useCaseItemListState,
          duration: Duration(milliseconds: 100),
          reverseDuration: Duration(milliseconds: 100),
        ),
      ),
      Word(
        english: 'Sister',
        tibetan: 'ཨ་ཅག།',
        englishSound: 'achak',
        assetPath: 'assets/audio/family/sister.mp3',
        animationController: AnimationController(
          vsync: useCaseItemListState,
          duration: Duration(milliseconds: 100),
          reverseDuration: Duration(milliseconds: 100),
        ),
      ),
      Word(
        english: 'Elder Sister',
        tibetan: 'ཨ་ཅག་རྒན་པ།',
        englishSound: 'achack gyanpa',
        assetPath: 'assets/audio/family/eldersister.mp3',
        animationController: AnimationController(
          vsync: useCaseItemListState,
          duration: Duration(milliseconds: 100),
          reverseDuration: Duration(milliseconds: 100),
        ),
      ),
      Word(
        english: 'Younger Sister',
        tibetan: 'ཨ་ཅག་ཆུང་བ།',
        englishSound: 'achack chungva',
        assetPath: 'assets/audio/family/youngersister.mp3',
        animationController: AnimationController(
          vsync: useCaseItemListState,
          duration: Duration(milliseconds: 100),
          reverseDuration: Duration(milliseconds: 100),
        ),
      ),
      Word(
        english: 'Grandson/Nephew',
        tibetan: 'ཚ་བོ།',
        englishSound: 'tsapo',
        assetPath: 'assets/audio/family/grandson.mp3',
        animationController: AnimationController(
          vsync: useCaseItemListState,
          duration: Duration(milliseconds: 100),
          reverseDuration: Duration(milliseconds: 100),
        ),
      ),
      Word(
        english: 'GrandDaughter/Niece',
        tibetan: 'ཚ་མོ།',
        englishSound: 'tasmo',
        assetPath: 'assets/audio/family/granddaughter.mp3',
        animationController: AnimationController(
          vsync: useCaseItemListState,
          duration: Duration(milliseconds: 100),
          reverseDuration: Duration(milliseconds: 100),
        ),
      ),
      Word(
        english: 'Uncle',
        tibetan: 'ཨ་ཞང།',
        englishSound: 'ashang',
        assetPath: 'assets/audio/family/uncle.mp3',
        animationController: AnimationController(
          vsync: useCaseItemListState,
          duration: Duration(milliseconds: 100),
          reverseDuration: Duration(milliseconds: 100),
        ),
      ),
      Word(
        english: 'Aunt',
        tibetan: 'ཨ་ནི།',
        englishSound: 'aani',
        assetPath: 'assets/audio/family/aunt.mp3',
        animationController: AnimationController(
          vsync: useCaseItemListState,
          duration: Duration(milliseconds: 100),
          reverseDuration: Duration(milliseconds: 100),
        ),
      ),
      Word(
        english: 'Husband',
        tibetan: 'ཁྱོ་ཁ།',
        englishSound: 'kyoga',
        assetPath: 'assets/audio/family/husband.mp3',
        animationController: AnimationController(
          vsync: useCaseItemListState,
          duration: Duration(milliseconds: 100),
          reverseDuration: Duration(milliseconds: 100),
        ),
      ),
      Word(
        english: 'Wife',
        tibetan: 'ཟ་ཟླ།',
        englishSound: 'za dha',
        assetPath: 'assets/audio/family/wife.mp3',
        animationController: AnimationController(
          vsync: useCaseItemListState,
          duration: Duration(milliseconds: 100),
          reverseDuration: Duration(milliseconds: 100),
        ),
      ),
      Word(
        english: 'Boy Friend',
        tibetan: 'དགའ་རོགས',
        englishSound: 'ga rog',
        assetPath: 'assets/audio/family/bf.mp3',
        animationController: AnimationController(
          vsync: useCaseItemListState,
          duration: Duration(milliseconds: 100),
          reverseDuration: Duration(milliseconds: 100),
        ),
      ),
      Word(
        english: 'Relative',
        tibetan: 'སྤུན་ཉེ།',
        englishSound: 'pun chath',
        assetPath: 'assets/audio/family/relative.mp3',
        animationController: AnimationController(
          vsync: useCaseItemListState,
          duration: Duration(milliseconds: 100),
          reverseDuration: Duration(milliseconds: 100),
        ),
      ),
      Word(
        english: 'Grand Father',
        tibetan: 'པོ་པོ།',
        englishSound: 'popo',
        assetPath: 'assets/audio/family/grandfather.mp3',
        animationController: AnimationController(
          vsync: useCaseItemListState,
          duration: Duration(milliseconds: 100),
          reverseDuration: Duration(milliseconds: 100),
        ),
      ),
      Word(
        english: 'Grand Mother',
        tibetan: 'མོ་མོ།',
        englishSound: 'mho mho',
        assetPath: 'assets/audio/family/grandmother.mp3',
        animationController: AnimationController(
          vsync: useCaseItemListState,
          duration: Duration(milliseconds: 100),
          reverseDuration: Duration(milliseconds: 100),
        ),
      ),
    ];
  }

  static List<Word> _greetingWordList(useCaseItemListState) {
    return [
      Word(
        english: 'Hello/Hi',
        tibetan: 'བཀྲ་ཤིས་བདེ་ལེགས།',
        englishSound: 'Tashi Delek',
        assetPath: 'assets/audio/greeting/hi.mp3',
        animationController: AnimationController(
          vsync: useCaseItemListState,
          duration: Duration(milliseconds: 100),
          reverseDuration: Duration(milliseconds: 100),
        ),
      ),
      Word(
        english: 'Good Morning',
        tibetan: 'སྔ་དྲོ་བདེ་ལེགས།',
        englishSound: 'Nga do delek',
        assetPath: 'assets/audio/greeting/goodmorning.mp3',
        animationController: AnimationController(
          vsync: useCaseItemListState,
          duration: Duration(milliseconds: 100),
          reverseDuration: Duration(milliseconds: 100),
        ),
      ),
      Word(
        english: 'Good Afternoon',
        tibetan: 'ཉིན་གུང་བདེ་ལེགས།',
        englishSound: 'Nyigung delek',
        assetPath: 'assets/audio/greeting/goodafternoon.mp3',
        animationController: AnimationController(
          vsync: useCaseItemListState,
          duration: Duration(milliseconds: 100),
          reverseDuration: Duration(milliseconds: 100),
        ),
      ),
      Word(
        english: 'Good Evening',
        tibetan: 'དགོང་དྲོ་བདེ་ལེགས།',
        englishSound: 'Gongdo Delek',
        assetPath: 'assets/audio/greeting/goodevening.mp3',
        animationController: AnimationController(
          vsync: useCaseItemListState,
          duration: Duration(milliseconds: 100),
          reverseDuration: Duration(milliseconds: 100),
        ),
      ),
      Word(
        english: 'Good Night',
        tibetan: 'གཟིམ་འཇག་གནང།',
        englishSound: 'Zim jag nang go',
        assetPath: 'assets/audio/greeting/goodnight.mp3',
        animationController: AnimationController(
          vsync: useCaseItemListState,
          duration: Duration(milliseconds: 100),
          reverseDuration: Duration(milliseconds: 100),
        ),
      ),
      Word(
        english: 'Good Bye',
        tibetan: 'བཞུགས་ཨ།',
        englishSound: 'Jhug ah',
        assetPath: 'assets/audio/greeting/goodbye.mp3',
        animationController: AnimationController(
          vsync: useCaseItemListState,
          duration: Duration(milliseconds: 100),
          reverseDuration: Duration(milliseconds: 100),
        ),
      ),
      Word(
        english: 'Take care',
        tibetan: 'ཅག་པོ་བྱེད།',
        englishSound: 'Chack po jay',
        assetPath: 'assets/audio/greeting/takecare.mp3',
        animationController: AnimationController(
          vsync: useCaseItemListState,
          duration: Duration(milliseconds: 100),
          reverseDuration: Duration(milliseconds: 100),
        ),
      ),
      Word(
        english: 'See You later',
        tibetan: 'རྗེས་ལ་མཇལ་ཡོང།',
        englishSound: 'Jay la jal yong',
        assetPath: 'assets/audio/greeting/seeyou.mp3',
        animationController: AnimationController(
          vsync: useCaseItemListState,
          duration: Duration(milliseconds: 100),
          reverseDuration: Duration(milliseconds: 100),
        ),
      ),
      Word(
        english: 'Nice to meet you',
        tibetan: 'རང་ཐུག་པ་དགའ་པོ་བྱུང།',
        englishSound: 'rang thukapa gapo jhung',
        assetPath: 'assets/audio/greeting/nicetomeetyou.mp3',
        animationController: AnimationController(
          vsync: useCaseItemListState,
          duration: Duration(milliseconds: 100),
          reverseDuration: Duration(milliseconds: 100),
        ),
      ),
      Word(
        english: 'Cheers',
        tibetan: 'དགའ་བསུ་བྱེད།',
        englishSound: 'gasu jay',
        assetPath: 'assets/audio/greeting/cheers.mp3',
        animationController: AnimationController(
          vsync: useCaseItemListState,
          duration: Duration(milliseconds: 100),
          reverseDuration: Duration(milliseconds: 100),
        ),
      ),
      Word(
        english: 'Great/Nice',
        tibetan: 'ལེགས་པོ།',
        englishSound: 'lakhpo',
        assetPath: 'assets/audio/greeting/great.mp3',
        animationController: AnimationController(
          vsync: useCaseItemListState,
          duration: Duration(milliseconds: 100),
          reverseDuration: Duration(milliseconds: 100),
        ),
      ),
      Word(
        english: 'Celebration',
        tibetan: 'རྟེན་འབྲེལ།',
        englishSound: 'Tendral',
        assetPath: 'assets/audio/greeting/celebration.mp3',
        animationController: AnimationController(
          vsync: useCaseItemListState,
          duration: Duration(milliseconds: 100),
          reverseDuration: Duration(milliseconds: 100),
        ),
      ),
      Word(
        english: 'Respect',
        tibetan: 'གུས་ཞབས།',
        englishSound: 'Guzhab',
        assetPath: 'assets/audio/greeting/respect.mp3',
        animationController: AnimationController(
          vsync: useCaseItemListState,
          duration: Duration(milliseconds: 100),
          reverseDuration: Duration(milliseconds: 100),
        ),
      ),
      Word(
        english: 'Smile',
        tibetan: 'འཛུམ།',
        englishSound: 'zoom',
        assetPath: 'assets/audio/greeting/smile.mp3',
        animationController: AnimationController(
          vsync: useCaseItemListState,
          duration: Duration(milliseconds: 100),
          reverseDuration: Duration(milliseconds: 100),
        ),
      ),
    ];
  }

  static List<Word> _numberWordList(useCaseItemListState) {
    return [
      Word(
        english: 'Zero',
        tibetan: 'ཀླད་ཀོར།',
        englishSound: 'lhai koy',
        assetPath: 'assets/audio/number/zero.mp3',
        animationController: AnimationController(
          vsync: useCaseItemListState,
          duration: Duration(milliseconds: 100),
          reverseDuration: Duration(milliseconds: 100),
        ),
      ),
      Word(
        english: 'One',
        tibetan: 'གཅིག།',
        englishSound: 'chik',
        assetPath: 'assets/audio/number/one.mp3',
        animationController: AnimationController(
          vsync: useCaseItemListState,
          duration: Duration(milliseconds: 100),
          reverseDuration: Duration(milliseconds: 100),
        ),
      ),
      Word(
        english: 'Two',
        tibetan: 'གཉིས།',
        englishSound: 'nyi',
        assetPath: 'assets/audio/number/two.mp3',
        animationController: AnimationController(
          vsync: useCaseItemListState,
          duration: Duration(milliseconds: 100),
          reverseDuration: Duration(milliseconds: 100),
        ),
      ),
      Word(
        english: 'Three',
        tibetan: 'གསུམ།',
        englishSound: 'syum',
        assetPath: 'assets/audio/number/three.mp3',
        animationController: AnimationController(
          vsync: useCaseItemListState,
          duration: Duration(milliseconds: 100),
          reverseDuration: Duration(milliseconds: 100),
        ),
      ),
      Word(
        english: 'Four',
        tibetan: 'བཞི།',
        englishSound: 'zshi',
        assetPath: 'assets/audio/number/four.mp3',
        animationController: AnimationController(
          vsync: useCaseItemListState,
          duration: Duration(milliseconds: 100),
          reverseDuration: Duration(milliseconds: 100),
        ),
      ),
      Word(
        english: 'Five',
        tibetan: 'ལྔ།',
        englishSound: 'nga',
        assetPath: 'assets/audio/number/five.mp3',
        animationController: AnimationController(
          vsync: useCaseItemListState,
          duration: Duration(milliseconds: 100),
          reverseDuration: Duration(milliseconds: 100),
        ),
      ),
      Word(
        english: 'Six',
        tibetan: 'དྲུག།',
        englishSound: 'druk',
        assetPath: 'assets/audio/number/six.mp3',
        animationController: AnimationController(
          vsync: useCaseItemListState,
          duration: Duration(milliseconds: 100),
          reverseDuration: Duration(milliseconds: 100),
        ),
      ),
      Word(
        english: 'Seven',
        tibetan: 'བདུན།',
        englishSound: 'dun',
        assetPath: 'assets/audio/number/seven.mp3',
        animationController: AnimationController(
          vsync: useCaseItemListState,
          duration: Duration(milliseconds: 100),
          reverseDuration: Duration(milliseconds: 100),
        ),
      ),
      Word(
        english: 'Eight',
        tibetan: 'བརྒྱད།',
        englishSound: 'gyay',
        assetPath: 'assets/audio/number/eight.mp3',
        animationController: AnimationController(
          vsync: useCaseItemListState,
          duration: Duration(milliseconds: 100),
          reverseDuration: Duration(milliseconds: 100),
        ),
      ),
      Word(
        english: 'Nine',
        tibetan: 'དགུ།',
        englishSound: 'ghu',
        assetPath: 'assets/audio/number/nine.mp3',
        animationController: AnimationController(
          vsync: useCaseItemListState,
          duration: Duration(milliseconds: 100),
          reverseDuration: Duration(milliseconds: 100),
        ),
      ),
      Word(
        english: 'Ten',
        tibetan: 'བཅུ།',
        englishSound: 'chu',
        assetPath: 'assets/audio/number/ten.mp3',
        animationController: AnimationController(
          vsync: useCaseItemListState,
          duration: Duration(milliseconds: 100),
          reverseDuration: Duration(milliseconds: 100),
        ),
      ),
      Word(
        english: 'Hundred',
        tibetan: 'བརྒྱ།',
        englishSound: 'gya',
        assetPath: 'assets/audio/number/hundred.mp3',
        animationController: AnimationController(
          vsync: useCaseItemListState,
          duration: Duration(milliseconds: 100),
          reverseDuration: Duration(milliseconds: 100),
        ),
      ),
      Word(
        english: 'Two hundred',
        tibetan: 'གཉིས་བརྒྱ།',
        englishSound: 'nyi gya',
        assetPath: 'assets/audio/number/twohundred.mp3',
        animationController: AnimationController(
          vsync: useCaseItemListState,
          duration: Duration(milliseconds: 100),
          reverseDuration: Duration(milliseconds: 100),
        ),
      ),
      Word(
        english: 'Three hundred',
        tibetan: 'གསུམ་བརྒྱ།',
        englishSound: 'syum gya',
        assetPath: 'assets/audio/number/threehundred.mp3',
        animationController: AnimationController(
          vsync: useCaseItemListState,
          duration: Duration(milliseconds: 100),
          reverseDuration: Duration(milliseconds: 100),
        ),
      ),
      Word(
        english: 'Four hundred',
        tibetan: 'བཞི་བརྒྱ།',
        englishSound: 'zshi gya',
        assetPath: 'assets/audio/number/fourhundred.mp3',
        animationController: AnimationController(
          vsync: useCaseItemListState,
          duration: Duration(milliseconds: 100),
          reverseDuration: Duration(milliseconds: 100),
        ),
      ),
      Word(
        english: 'Five hundred',
        tibetan: 'ལྔ་བརྒྱ།',
        englishSound: 'nga gya',
        assetPath: 'assets/audio/number/fivehundred.mp3',
        animationController: AnimationController(
          vsync: useCaseItemListState,
          duration: Duration(milliseconds: 100),
          reverseDuration: Duration(milliseconds: 100),
        ),
      ),
      Word(
        english: 'Six hundred',
        tibetan: 'དྲུག་བརྒྱ།',
        englishSound: 'druk gya',
        assetPath: 'assets/audio/number/sixhundred.mp3',
        animationController: AnimationController(
          vsync: useCaseItemListState,
          duration: Duration(milliseconds: 100),
          reverseDuration: Duration(milliseconds: 100),
        ),
      ),
      Word(
        english: 'Seven hundred',
        tibetan: 'བདུན་བརྒྱ།',
        englishSound: 'dun gya',
        assetPath: 'assets/audio/number/sevenhundred.mp3',
        animationController: AnimationController(
          vsync: useCaseItemListState,
          duration: Duration(milliseconds: 100),
          reverseDuration: Duration(milliseconds: 100),
        ),
      ),
      Word(
        english: 'Eight hundred',
        tibetan: 'བརྒྱད་བརྒྱ།',
        englishSound: 'gyay gya',
        assetPath: 'assets/audio/number/eighthundred.mp3',
        animationController: AnimationController(
          vsync: useCaseItemListState,
          duration: Duration(milliseconds: 100),
          reverseDuration: Duration(milliseconds: 100),
        ),
      ),
      Word(
        english: 'Nine hundred',
        tibetan: 'དགུ་བརྒྱ།',
        englishSound: 'ghu gya',
        assetPath: 'assets/audio/number/ninehundred.mp3',
        animationController: AnimationController(
          vsync: useCaseItemListState,
          duration: Duration(milliseconds: 100),
          reverseDuration: Duration(milliseconds: 100),
        ),
      ),
      Word(
        english: 'Thousand',
        tibetan: 'སྟོང།',
        englishSound: 'tong',
        assetPath: 'assets/audio/number/thousand.mp3',
        animationController: AnimationController(
          vsync: useCaseItemListState,
          duration: Duration(milliseconds: 100),
          reverseDuration: Duration(milliseconds: 100),
        ),
      ),
      Word(
        english: 'Ten thousand',
        tibetan: 'ཁྲི།',
        englishSound: 'tri',
        assetPath: 'assets/audio/number/tenthousand.mp3',
        animationController: AnimationController(
          vsync: useCaseItemListState,
          duration: Duration(milliseconds: 100),
          reverseDuration: Duration(milliseconds: 100),
        ),
      ),
      Word(
        english: 'Hundred Thousand',
        tibetan: 'འབུམ།',
        englishSound: 'bhum',
        assetPath: 'assets/audio/number/hundredthousand.mp3',
        animationController: AnimationController(
          vsync: useCaseItemListState,
          duration: Duration(milliseconds: 100),
          reverseDuration: Duration(milliseconds: 100),
        ),
      ),
      Word(
        english: 'Million',
        tibetan: 'ས་ཡ།',
        englishSound: 'saya',
        assetPath: 'assets/audio/number/million.mp3',
        animationController: AnimationController(
          vsync: useCaseItemListState,
          duration: Duration(milliseconds: 100),
          reverseDuration: Duration(milliseconds: 100),
        ),
      ),
      Word(
        english: 'Billion',
        tibetan: 'བྱེ་བ།',
        englishSound: 'jayva',
        assetPath: 'assets/audio/number/billion.mp3',
        animationController: AnimationController(
          vsync: useCaseItemListState,
          duration: Duration(milliseconds: 100),
          reverseDuration: Duration(milliseconds: 100),
        ),
      ),
    ];
  }

  static List<Word> _pronounWordList(useCaseItemListState) {
    return [
      Word(
        english: 'I',
        tibetan: 'ང།',
        englishSound: 'nga',
        assetPath: 'assets/audio/pronoun/i.mp3',
        animationController: AnimationController(
          vsync: useCaseItemListState,
          duration: Duration(milliseconds: 100),
          reverseDuration: Duration(milliseconds: 100),
        ),
      ),
      Word(
        english: 'You',
        tibetan: 'ཁྱེད་རང།',
        englishSound: 'khey rang',
        assetPath: 'assets/audio/pronoun/you.mp3',
        animationController: AnimationController(
          vsync: useCaseItemListState,
          duration: Duration(milliseconds: 100),
          reverseDuration: Duration(milliseconds: 100),
        ),
      ),
      Word(
        english: 'He/She',
        tibetan: 'ཁོང།',
        englishSound: 'khong',
        assetPath: 'assets/audio/pronoun/heorshe.mp3',
        animationController: AnimationController(
          vsync: useCaseItemListState,
          duration: Duration(milliseconds: 100),
          reverseDuration: Duration(milliseconds: 100),
        ),
      ),
      Word(
        english: 'We',
        tibetan: 'ང་ཚོ།',
        englishSound: 'nga tso',
        assetPath: 'assets/audio/pronoun/we.mp3',
        animationController: AnimationController(
          vsync: useCaseItemListState,
          duration: Duration(milliseconds: 100),
          reverseDuration: Duration(milliseconds: 100),
        ),
      ),
      Word(
        english: 'They',
        tibetan: 'ཁོ་ཚོ།',
        englishSound: 'khon tso',
        assetPath: 'assets/audio/pronoun/they.mp3',
        animationController: AnimationController(
          vsync: useCaseItemListState,
          duration: Duration(milliseconds: 100),
          reverseDuration: Duration(milliseconds: 100),
        ),
      ),
      Word(
        english: 'This',
        tibetan: 'འདི།',
        englishSound: 'di',
        assetPath: 'assets/audio/pronoun/this.mp3',
        animationController: AnimationController(
          vsync: useCaseItemListState,
          duration: Duration(milliseconds: 100),
          reverseDuration: Duration(milliseconds: 100),
        ),
      ),
      Word(
        english: 'That',
        tibetan: 'དེ།',
        englishSound: 'dhay',
        assetPath: 'assets/audio/pronoun/that.mp3',
        animationController: AnimationController(
          vsync: useCaseItemListState,
          duration: Duration(milliseconds: 100),
          reverseDuration: Duration(milliseconds: 100),
        ),
      ),
      Word(
        english: 'These',
        tibetan: 'འདི་ཚོ།',
        englishSound: 'de tso',
        assetPath: 'assets/audio/pronoun/these.mp3',
        animationController: AnimationController(
          vsync: useCaseItemListState,
          duration: Duration(milliseconds: 100),
          reverseDuration: Duration(milliseconds: 100),
        ),
      ),
      Word(
        english: 'Those',
        tibetan: 'དེ་ཚོ།',
        englishSound: 'dhay tso',
        assetPath: 'assets/audio/pronoun/those.mp3',
        animationController: AnimationController(
          vsync: useCaseItemListState,
          duration: Duration(milliseconds: 100),
          reverseDuration: Duration(milliseconds: 100),
        ),
      ),
      Word(
        english: 'Their',
        tibetan: 'ཁོང་རང་ཚོ།',
        englishSound: 'khong rang tso',
        assetPath: 'assets/audio/pronoun/their.mp3',
        animationController: AnimationController(
          vsync: useCaseItemListState,
          duration: Duration(milliseconds: 100),
          reverseDuration: Duration(milliseconds: 100),
        ),
      ),
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
      Alphabet(fileName: 'giguk', alphabetName: 'ཨི།'),
      Alphabet(fileName: 'jamchu', alphabetName: 'ཨུ།'),
      Alphabet(fileName: 'dangpo', alphabetName: 'ཨེ།'),
      Alphabet(fileName: 'naro', alphabetName: 'ཨོ།'),
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
      Alphabet(fileName: 'rakatak', alphabetName: 'རྐ།'),
      Alphabet(fileName: 'ragatak', alphabetName: 'རྒ།'),
      Alphabet(fileName: 'rangatak', alphabetName: 'རྔ།'),
      Alphabet(fileName: 'rajatak', alphabetName: 'རྗ།'),
      Alphabet(fileName: 'ranyatak', alphabetName: 'རྙ།'),
      Alphabet(fileName: 'ratadak', alphabetName: 'རྟ།'),
      Alphabet(fileName: 'radadak', alphabetName: 'རྡ།'),
      Alphabet(fileName: 'ranatak', alphabetName: 'རྣ།'),
      Alphabet(fileName: 'rabatak', alphabetName: 'རྦ།'),
      Alphabet(fileName: 'ramatak', alphabetName: 'རྨ།'),
      Alphabet(fileName: 'ratsatak', alphabetName: 'རྩ།'),
      Alphabet(fileName: 'razatak', alphabetName: 'རྫ'),
    ];
  }

  static List<Alphabet> _lagoList() {
    return [
      Alphabet(fileName: 'lakatak', alphabetName: 'ལྐ།'),
      Alphabet(fileName: 'lagatak', alphabetName: 'ལྒ།'),
      Alphabet(fileName: 'langatak', alphabetName: 'ལྔ།'),
      Alphabet(fileName: 'lachatak', alphabetName: 'ལྕ།'),
      Alphabet(fileName: 'lajatak', alphabetName: 'ལྗ།'),
      Alphabet(fileName: 'latadak', alphabetName: 'ལྟ།'),
      Alphabet(fileName: 'ladatak', alphabetName: 'ལྡ།'),
      Alphabet(fileName: 'lapatak', alphabetName: 'ལྤ།'),
      Alphabet(fileName: 'labadak', alphabetName: 'ལྦ།'),
      Alphabet(fileName: 'lahatak', alphabetName: 'ལྷ།'),
    ];
  }

  static List<Alphabet> _sogoList() {
    return [
      Alphabet(fileName: 'sakadak', alphabetName: 'སྐ།'),
      Alphabet(fileName: 'sakhatak', alphabetName: 'སྒ།'),
      Alphabet(fileName: 'sangatak', alphabetName: 'སྔ།'),
      Alphabet(fileName: 'sanyatak', alphabetName: 'སྙ།'),
      Alphabet(fileName: 'satadak', alphabetName: 'སྟ།'),
      Alphabet(fileName: 'sadatak', alphabetName: 'སྡ།'),
      Alphabet(fileName: 'sanatak', alphabetName: 'སྣ།'),
      Alphabet(fileName: 'sapatak', alphabetName: 'སྤ།'),
      Alphabet(fileName: 'sabatak', alphabetName: 'སྦ།'),
      Alphabet(fileName: 'samatak', alphabetName: 'སྨ།'),
      Alphabet(fileName: 'satsatak', alphabetName: 'སྩ།'),
    ];
  }

  static List<Alphabet> _yatakList() {
    return [
      Alphabet(fileName: 'kayatak', alphabetName: 'ཀྱ།'),
      Alphabet(fileName: 'khayatak', alphabetName: 'ཁྱ།'),
      Alphabet(fileName: 'gayatak', alphabetName: 'གྱ།'),
      Alphabet(fileName: 'payatak', alphabetName: 'པྱ།'),
      Alphabet(fileName: 'phayatak', alphabetName: 'ཕྱ།'),
      Alphabet(fileName: 'bayatak', alphabetName: 'བྱ།'),
      Alphabet(fileName: 'mayatak', alphabetName: 'མྱ།'),
    ];
  }

  static List<Alphabet> _ratakList() {
    return [
      Alphabet(fileName: 'karatak', alphabetName: 'ཀྲ།'),
      Alphabet(fileName: 'kharak', alphabetName: 'ཁྲ།'),
      Alphabet(fileName: 'garatak', alphabetName: 'གྲ།'),
      Alphabet(fileName: 'taratak', alphabetName: 'ཏྲ།'),
      Alphabet(fileName: 'tharatak', alphabetName: 'ཐྲ།'),
      Alphabet(fileName: 'daratak', alphabetName: 'དྲ།'),
      Alphabet(fileName: 'paratak', alphabetName: 'པྲ།'),
      Alphabet(fileName: 'pharatak', alphabetName: 'ཕྲ།'),
      Alphabet(fileName: 'baratak', alphabetName: 'བྲ།'),
      Alphabet(fileName: 'maratak', alphabetName: 'མྲ།'),
      Alphabet(fileName: 'saratak', alphabetName: 'སྲ།'),
      Alphabet(fileName: 'haratak', alphabetName: 'ཧྲ།'),
    ];
  }

  static List<Alphabet> _latakist() {
    return [
      Alphabet(fileName: 'kalatak', alphabetName: 'ཀླ།'),
      Alphabet(fileName: 'galatak', alphabetName: 'གླ།'),
      Alphabet(fileName: 'balatak', alphabetName: 'བླ།'),
      Alphabet(fileName: 'zalatak', alphabetName: 'ཟླ།'),
      Alphabet(fileName: 'ralatak', alphabetName: 'རླ།'),
      Alphabet(fileName: 'salatak', alphabetName: 'སླ།'),
    ];
  }
}
