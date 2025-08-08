import 'dart:convert';
// imports the dart main libary for encoding and decoding data like json

import 'package:flutter/material.dart';
// loads in the flutter material design aspects giving acces to things like Scaffold, AppBar, Text

import 'package:flutter/services.dart';
//tools for interacting with platform assets and services used to load my app service like JSON

class FlashcardPage extends StatefulWidget {
  // used to make a widget for my flashcard which can change its content based on the user

  final String subject;
  //Stores the subject to be shown on the screen meant for choosing which my json files to load

  const FlashcardPage({super.key, required this.subject});
//consturcks the subject needed with the super key being the the main support of the widget identificatoin

  @override
  State<FlashcardPage> createState() => _FlashcardPageState();
}
//tells flutter to use my FlashcardPage connecting the UI above to the commands below

class _FlashcardPageState extends State<FlashcardPage> {
  List<Map<String, String>> _flashcards = [];
  //this creates a private state that wakes up and loads the UI and commands my strings to set up a list in whcih they load onto the page
  int _currentIndex = 0;
  bool _showEnglish = false;
// these bits tracks and controls which flashcard and lang is being shown with 0 being the first false = show Spanish.

  @override
  void initState() {
    super.initState();
    _loadFlashcards();
  }
//Runs the default startup and loads the flashcards from JSON when the screen opens


  Future<void> _loadFlashcards() async {
    // loads and parses the flashcards from assets

    final String jsonString = await rootBundle.loadString(
        'assets/flashcards/${widget.subject.toLowerCase()}.json');
    // uses the widget to match the file name in json (when something is metioned like Colors it loads colors.json) and loads from assets

    final List<dynamic> jsonData = json.decode(jsonString);
//  finds and loads my Json strings

    setState(() {
      // makes sure the UI is rebulit for next use

      _flashcards = jsonData.map<Map<String, String>>((item) {
        return {
          'spanish': item['spanish'].toString(),
          'english': item['english'].toString(),
        };
      }).toList();
    });
  }
  // loads and loops the JSON files making sure the strings conect to the strings that will load and save my flashcards

  void _nextCard() {
    setState(() {
      _showEnglish = false;
      // when the UI is triggred in this case the button next it makes sure the flashcard seen next reset to show Spanisn

      if (_currentIndex < _flashcards.length - 1) {
        _currentIndex++;
      }
    });
  }
  //Only move forward if there are more cards

  void _flipCard() {
    setState(() {
      _showEnglish = !_showEnglish;
    });
  }
  // triggers the JSOn English to load on the other side of the card
 // If the user taps the card it flips between Spanish and English

  @override
  Widget build(BuildContext context) {
    // loads the UI and runs what it is meant to be shown on the screen

    if (_flashcards.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    } // if flashcards are not loading to avoid crashing the app a spiner will show

    final currentCard = _flashcards[_currentIndex];
    // stores whatever the current flashcard is data (makes a map pretty much with english and spanish)

    return Scaffold(
      // Standard Flutter page structure

      appBar: AppBar(
        //// makes a material design app bar at the top of the screen

        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          // creates a widget that holds my own custom back button with const being used to make sure the UI dones;t have to rebulid it everytime

          onPressed: () {
            Navigator.pop(context);
          },// navgates UI to the page before

        ),
        title: Text('${widget.subject}  (${_currentIndex + 1}/${_flashcards.length})'),
      ),
      // widget.subject shows the current topic like JSON colors, JSON animals
      // (${_currentIndex + 1}/${_flashcards.length}) shows the current card number out of total with + 1 defineing only one displayed

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: _flipCard,
              child: Card(
                elevation: 8,
                margin: const EdgeInsets.all(24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Container(
                  width: 300,
                  height: 200,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(24),
                  // this whole area of code simply sets up the design and look of the code how big, its place on the screen, etc

                  child: Text(
                    _showEnglish ? currentCard['english']! : currentCard['spanish']!,
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _currentIndex < _flashcards.length - 1 ? _nextCard : null,
              child: const Text('Next'),
            ),
          ],
        ),
      ),
    );
  }
}

