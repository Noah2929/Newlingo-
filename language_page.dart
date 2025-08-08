import 'package:flutter/material.dart';
// loads in the flutter material design aspects giving acces to things like Scaffold, AppBar, Text

import 'localization_service.dart';
// used for bringing in my own personal strings and loads them in as well as transltes them based on there set JSON code

import 'home_screen.dart';
// imporats my home screen to guide to when the langughe is slected

class LanguagePage extends StatelessWidget {
  //creates my new Language Page widget being stateless widget it does not chnage its directive

  final List<Map<String, String>> languages = [
    {"code": "en", "name": "english"},
    {"code": "es", "name": "spanish"},
  ];
//connects and shows my avibale languges

  @override
  Widget build(BuildContext context) {
    // it wakes the project and begings to describe what evrything should look like

    return Scaffold(
      //has basic material design layout like the app bar and the body

      appBar: AppBar(
        title: Text(LocalizationService.translate('title')),
      ),// corrects the title if certain langue is chosen based on the on the langyge file

      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
        // used as a spacer to make sure everything like my main body really is centered and make sure things are algined

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // the key stacks elements vertically and lines up my child code to the left

            Text(
              LocalizationService.translate('select_language'),
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ), // my display title for my languee selctor and its style

            const SizedBox(height: 20),
            // adds space for my title and list of langugues

            ...languages.map((lang) {
              // ... used to expanded or spread individual elements in my case my json list to select my lagnuges

              return Card(
                elevation: 4,
                child: ListTile(
                  // elevates my conttainer holding my selctions and the listile allowing them to be clickable

                  leading: Text(
                    lang['code'] == 'en' ? '🇬🇧' : '🇪🇸',
                    style: const TextStyle(fontSize: 24),
                  ),// used to show the images 🇬🇧 and 🇪🇸 when selcting which languge

                  title: Text(
                    LocalizationService.translate(lang['name']!),
                    style: const TextStyle(fontSize: 18),
                  ),// rranslates and displays the name of the language using the key like english or spanish

                  onTap: () async {
                    await LocalizationService.loadLanguage(lang['code']!);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const HomeScreen()),
                    );// used to input the final command for this area of code when someone taps on there selcyed languge it will activtae loadLanguag
//when pressed and loads the appropriate translation file from JSON replacing the home screen
                  },
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
