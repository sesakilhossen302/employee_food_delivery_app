import 'package:get/get_navigation/get_navigation.dart';

import 'english.dart' show english;


class Language extends Translations{
  @override
  

  Map<String, Map<String, String>> get keys => {
    "en_US":english,
    // "es":spanish,
    // "he":hibrew,
  };

}