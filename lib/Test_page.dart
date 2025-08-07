import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TestPage extends StatefulWidget {
  final String subject;

  const TestPage({super.key, required this.subject});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  List<Map<String, dynamic>> _questions = [];
  int _currentIndex = 0;
  int _score = 0;
  List<bool> _correctAnswers = [];
  List<Map<String, String>> _incorrectQuestions = [];
  TextEditingController _textController = TextEditingController();

  bool _isLoading = true;
  bool _showResult = false;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    final data = await rootBundle.loadString('assets/flashcards/${widget.subject.toLowerCase()}.json');
    final List<dynamic> jsonResult = json.decode(data);
    jsonResult.shuffle();

    setState(() {
      _questions = jsonResult.take(10).map((item) => {
        'question': item['english'],
        'answer': item['spanish'],
      }).toList();
      _isLoading = false;
    });
  }

  void _submitAnswer(String userAnswer) {
    final correctAnswer = _questions[_currentIndex]['answer'].toString().toLowerCase().trim();
    final isCorrect = userAnswer.toLowerCase().trim() == correctAnswer;

    setState(() {
      _correctAnswers.add(isCorrect);
      if (isCorrect) {
        _score++;
      } else {
        _incorrectQuestions.add({
          'question': _questions[_currentIndex]['question'],
          'yourAnswer': userAnswer,
          'correctAnswer': _questions[_currentIndex]['answer'],
        });
      }

      _textController.clear();

      if (_currentIndex < _questions.length - 1) {
        _currentIndex++;
      } else {
        _showResult = true;
      }
    });
  }

  List<String> _generateOptions(int currentIndex) {
    List<String> options = [_questions[currentIndex]['answer']];
    Random random = Random();

    while (options.length < 4) {
      int randIndex = random.nextInt(_questions.length);
      String choice = _questions[randIndex]['answer'];
      if (!options.contains(choice)) {
        options.add(choice);
      }
    }
    options.shuffle();
    return options;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_showResult) {
      return Scaffold(
        appBar: AppBar(title: const Text("Test Results")),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text("Test Completed!", style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 16),
              Text("✅ Correct: $_score / 10", style: const TextStyle(fontSize: 20)),
              Text("❌ Incorrect: ${10 - _score}", style: const TextStyle(fontSize: 20)),
              const SizedBox(height: 20),

              if (_incorrectQuestions.isNotEmpty)
                Expanded(
                  child: ListView.builder(
                    itemCount: _incorrectQuestions.length,
                    itemBuilder: (context, index) {
                      final item = _incorrectQuestions[index];
                      return Card(
                        color: Colors.red[50],
                        child: ListTile(
                          title: Text("❌ ${item['question']}"),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Your Answer: ${item['yourAnswer']}"),
                              Text("Correct Answer: ${item['correctAnswer']}"),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Back to Subjects"),
              ),
            ],
          ),
        ),
      );
    }

    final question = _questions[_currentIndex]['question'];
    final correctAnswer = _questions[_currentIndex]['answer'];
    final isMultipleChoice = _currentIndex % 2 == 0; // Alternate types

    return Scaffold(
      appBar: AppBar(title: Text('Test: ${widget.subject}')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Question ${_currentIndex + 1}/10", style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            Text(question, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),

            if (isMultipleChoice)
              ..._generateOptions(_currentIndex).map((option) => ElevatedButton(
                onPressed: () => _submitAnswer(option),
                child: Text(option),
              ))
            else
              Column(
                children: [
                  TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      labelText: "Type your answer",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _submitAnswer(_textController.text),
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
