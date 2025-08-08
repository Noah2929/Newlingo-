import 'dart:convert';
// imports the dart main libary for encoding and decoding data like json

import 'package:flutter/services.dart';
//tools for interacting with platform assets and services used to load my app service like JSON

class LocalizationService {
  // used for loading language files and translating certain keys to my localized strings

  static Map<String, String> _localizedStrings = {};
// delcares my private localized Strings where my code is stored as well as connecting my strings

  static Future<void> loadLanguage(String code) async {
    String jsonString =
    await rootBundle.loadString('assets/languages/$code.json');
   //Loads my JSON files from the my app asset folder

    Map<String, dynamic> jsonMap = json.decode(jsonString);
// Converts the JSON string content into a Dart

    _localizedStrings = jsonMap.map((key, value) => MapEntry(key, value.toString()));
  }// converts the main values into strings and assigns them to my localized strings

  static String translate(String key) {
    return _localizedStrings[key] ?? key;
  }// a fallsafe just in case a certain key does not load or work it will make sure that key won't cause a crash (my json)
}
