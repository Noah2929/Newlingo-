import 'dart:convert';// For decoding JSON data
import 'dart:math'; //For generating random numbers

import 'package:flutter/material.dart';// Materieal design widgets
import 'package:flutter/services.dart'; //  For loading assets like JSON files

class TestPage extends StatefulWidget {
  final String subject; //Subject for which the test will be loaded

  const TestPage({super.key, required this.subject});//

  @override
  State<TestPage> createState() => _TestPageState();// Creates the  state
}

class _TestPageState extends State<TestPage> {
  List<Map<String, dynamic>> _questions = [];// Stores list of questions and answers
  int _currentIndex = 0;// Current question index
  int _score = 0; // Number of correct answers
  List<bool> _correctAnswers = []; //chck if each answered question was correct
  List<Map<String, String>> _incorrectQuestions = [];//List of incorrect answers with details
  TextEditingController _textController = TextEditingController();//UI input

  bool _isLoading = true;// if questions are still being loaded
  bool _showResult = false;//if to show results

  @override
  void initState() {
    super.initState();
    _loadQuestions();// Start loading questions from assets
  }

  Future<void> _loadQuestions() async {
    final data = await rootBundle.loadString('assets/flashcards/${widget.subject.toLowerCase()}.json');
    // Load JSON file for the selected subject
    final List<dynamic> jsonResult = json.decode(data);
    // Decode JSON into a list of maps
    jsonResult.shuffle();
    // randomly shuffles json

    setState(() {
      _questions = jsonResult.take(10).map((item) => {
        'question': item['english'],// the question in english ( or vice versa)
        'answer': item['spanish'],//the correct answer in spanish (vice verse)
      }).toList();
      _isLoading = false;//if loading is done
    });
  }

  void _submitAnswer(String userAnswer) {// handles submissions
    final correctAnswer = _questions[_currentIndex]['answer'].toString().toLowerCase().trim();
    //Gets the correct answer for the current question
    final isCorrect = userAnswer.toLowerCase().trim() == correctAnswer;
    //compares user answer to right one

    setState(() {
      _correctAnswers.add(isCorrect);//Tracks if your right
      if (isCorrect) {
        _score++;// your score if right
      } else {
        _incorrectQuestions.add({//saves your inocrrect inputs
          'question': _questions[_currentIndex]['question'],
          'yourAnswer': userAnswer,
          'correctAnswer': _questions[_currentIndex]['answer'],
        });
      }

      _textController.clear();

      if (_currentIndex < _questions.length - 1) {
        _currentIndex++; // move next question
      } else {
        _showResult = true; // All questions answered = show results
      }
    });
  }

  List<String> _generateOptions(int currentIndex) {
    // Start with the correct answer
    List<String> options = [_questions[currentIndex]['answer']];
    Random random = Random(); // Random number generator


    while (options.length < 4) {
      int randIndex = random.nextInt(_questions.length); // Pick random question
      String choice = _questions[randIndex]['answer']; // Get its answer
      if (!options.contains(choice)) {
        options.add(choice);
      }
    }
    options.shuffle(); // Shuffle option order
    return options;
  }

  @override
  Widget build(BuildContext context) {
    // Loading screen
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()), // Show spinner while loading
      );
    }

    // Results screen
    if (_showResult) {
      return Scaffold(
        appBar: AppBar(title: const Text("Test Results")), // Page title
        body: Padding(
          padding: const EdgeInsets.all(16.0), // Outer padding
          child: Column(
            children: [
              // Test completion message
              Text("Test Completed!", style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 16),
              // Show correct and incorrect counts
              Text("✅ Correct: $_score / 10", style: const TextStyle(fontSize: 20)),
              Text("❌ Incorrect: ${10 - _score}", style: const TextStyle(fontSize: 20)),
              const SizedBox(height: 20),

              // List of incorrect questions if any
              if (_incorrectQuestions.isNotEmpty)
                Expanded(
                  child: ListView.builder(
                    itemCount: _incorrectQuestions.length, // Number of incorrect answers
                    itemBuilder: (context, index) {
                      final item = _incorrectQuestions[index]; // Get incorrect item
                      return Card(
                        color: Colors.red[50],
                        child: ListTile(
                          title: Text("❌ ${item['question']}"),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Your Answer: ${item['yourAnswer']}"), // User's answer
                              Text("Correct Answer: ${item['correctAnswer']}"), // Correct answer
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

              const SizedBox(height: 20),
              // Back button to go to subjects list
              ElevatedButton(
                onPressed: () => Navigator.pop(context), // Go back
                child: const Text("Back to Subjects"),
              ),
            ],
          ),
        ),
      );
    }

    final question = _questions[_currentIndex]['question']; // Current question text
    final correctAnswer = _questions[_currentIndex]['answer']; // Current correct answer
    final isMultipleChoice = _currentIndex % 2 == 0; // Even index → multiple choice, odd → text input

    return Scaffold(
      appBar: AppBar(title: Text('Test: ${widget.subject}')), // Test title with subject
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question number display
            Text("Question ${_currentIndex + 1}/10", style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            // Question text
            Text(question, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),

            // Multiple-choice layout
            if (isMultipleChoice)
              ..._generateOptions(_currentIndex).map((option) => ElevatedButton(
                onPressed: () => _submitAnswer(option), // Submit selected option
                child: Text(option), // Option text
              ))
            // Text input layout
            else
              Column(
                children: [

                  TextField(
                    controller: _textController, // Controls input value
                    decoration: const InputDecoration(
                      labelText: "Type your answer", // Placeholder label
                      border: OutlineInputBorder(), // Box border
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Submit button for typed answer
                  ElevatedButton(
                    onPressed: () => _submitAnswer(_textController.text), // Submit typed text
                    child: const Text("Submit"),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}