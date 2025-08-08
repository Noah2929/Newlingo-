import 'package:flutter/material.dart';
// loads in the flutter material design aspects giving acces to things like Scaffold, AppBar, Text

import 'localization_service.dart';
// used for bringing in my own personal strings and loads them in as well as transltes them based on there set JSON code

import 'subject_selection page.dart';
// loads a widget that lets users choose a learning category

class HomeScreen extends StatefulWidget {
  //Creates a new screen widget called the home screen

  const HomeScreen({super.key});
// the main construction for my HomeScreen with the super key being a key widget also allowing flutter to hold a widget if need

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}
// creates and holds the logic and UI building for HomeScreen

class _HomeScreenState extends State<HomeScreen> {
  bool _showWelcome = true;
  // with the class meant to define the private space aka the home screen
 // and a boolen varible used to track to show the welcome screen or not with true meaning show and flase meaning no show

  @override
  void initState() {
    super.initState();
    _startTransition();
  }
  //loads in the transtions and begins to run them once triggred

  void _startTransition() async {
    // puts defantion on the command to start the Transition

    await Future.delayed(const Duration(seconds: 4));
    // meant to delay 4 seconds before showing the welcome

    if (mounted) {
      //make sure the widget still in the widget tree

      setState(() {
        _showWelcome = false;
      });
    }
  }// meant breakdown the widgets set up in the welcome screen so the subject page can load

  @override
  Widget build(BuildContext context) {
    // rebuilds the UI from the welcome

    return _showWelcome
    // if true it shows welcome if flase it goes  Subject Selection

        ? Scaffold(
      body: Center(
        child: Text(
          LocalizationService.translate('welcome'),
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ),
    )
    // used to center style and set up the postion of the welcome

        : const SubjectSelectionPage();
  }
}
// takes users to actual learning UI and takes them to the page where users pick a topic like Colors, Animals
