import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Plastic Swap Game',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const PlasticSwapGame(),
    );
  }
}

class PlasticSwapGame extends StatefulWidget {
  const PlasticSwapGame({super.key});

  @override
  _PlasticSwapGameState createState() => _PlasticSwapGameState();
}

class _PlasticSwapGameState extends State<PlasticSwapGame> {
  List<String> items = [
    'Plastic Bottle',
    'Plastic Straw',
    'Reusable Water Bottle',
    'Reusable Straw',
    'Plastic Bag',
    'Reusable Tote Bag',
    'Paper Cup',
    'Metal Straw',
    'Glass Jar',
  ];

  List<String> shuffledItems = [];
  int moves = 0;
  int remainingMoves = 15; // Limited Moves
  int score = 0;
  int secondsLeft = 60; // Time Limit
  Timer? timer;
  bool gameEnded = false;
  bool tutorialMode = true; // Tutorial mode flag
  int tutorialStep = 1; // Tutorial step tracker

  @override
  void initState() {
    super.initState();
    shuffledItems.addAll(items);
    shuffledItems.shuffle();
    startTimer();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      setState(() {
        if (secondsLeft > 0) {
          secondsLeft--;
        } else {
          t.cancel();
          endGame();
        }
      });
    });
  }

  void swapItems(int index1, int index2) {
    setState(() {
      moves++;
      remainingMoves--; // Decrease remaining moves
      String temp = shuffledItems[index1];
      shuffledItems[index1] = shuffledItems[index2];
      shuffledItems[index2] = temp;
      checkGameStatus();
    });
  }

  void checkGameStatus() {
    if (remainingMoves == 0 || isSolutionCorrect()) {
      endGame();
    }
  }

  bool isSolutionCorrect() {
    for (int i = 0; i < 3; i++) {
      if (!shuffledItems[i].startsWith('Reusable')) {
        return false;
      }
    }
    return true;
  }

  void endGame() {
    timer?.cancel();
    gameEnded = true;
    // Calculate score based on remaining moves and time left
    score = (remainingMoves * 10) + (secondsLeft * 2);
    // You can add leaderboard and achievements logic here
  }

  void nextTutorialStep() {
    setState(() {
      tutorialStep++;
      if (tutorialStep > 3) {
        tutorialMode = false; // Exit tutorial mode after all steps are completed
      }
    });
  }

  void resetGame() {
    setState(() {
      shuffledItems.clear();
      shuffledItems.addAll(items);
      shuffledItems.shuffle();
      moves = 0;
      remainingMoves = 15;
      secondsLeft = 60;
      gameEnded = false;
      tutorialMode = true;
      tutorialStep = 1;
      startTimer();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plastic Swap Game'),
      ),
      body: Center(
        child: gameEnded
            ? GameOverScreen(score: score, onReset: resetGame)
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (tutorialMode)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        children: [
                          const Text(
                            'Welcome to the Plastic Swap Game!',
                            style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20.0),
                          Text(
                            'Tutorial Step $tutorialStep/3:',
                            style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10.0),
                          Text(
                            tutorialStep == 1
                                ? 'Swipe two items to swap them and make matches of reusable items.'
                                : tutorialStep == 2
                                    ? 'You have limited moves. Use them wisely to complete the level.'
                                    : 'Complete the level before time runs out.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 16.0),
                          ),
                          const SizedBox(height: 20.0),
                          ElevatedButton(
                            onPressed: nextTutorialStep,
                            child: const Text('Next'),
                          ),
                        ],
                      ),
                    ),
                  if (!tutorialMode)
                    Column(
                      children: [
                        Text(
                          'Moves: $moves / $remainingMoves', // Display remaining moves
                          style: const TextStyle(fontSize: 24.0),
                        ),
                        const SizedBox(height: 10.0),
                        Text(
                          'Time Left: $secondsLeft s', // Display time left
                          style: const TextStyle(fontSize: 20.0),
                        ),
                      ],
                    ),
                  const SizedBox(height: 20.0),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 1.0, // Adjust aspect ratio
                      ),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        return Draggable<String>(
                          data: items[index],
                          feedback: Container(
                            margin: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: AspectRatio(
                              aspectRatio: 1.0, // Aspect ratio for resizable box
                              child: IntrinsicWidth(
                                child: IntrinsicHeight(
                                  child: Center(
                                    child: Text(
                                         items[index],style: const TextStyle(fontSize: 18.0,
                                    color: Colors.white,
                                    ),
                                    textAlign: TextAlign.center,
),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          childWhenDragging: Container(),
                          child: DragTarget<String>(
                            builder: (context, candidateData, rejectedData) {
                              return Container(
                                margin: const EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: AspectRatio(
                                  aspectRatio: 1.0, // Aspect ratio for resizable box
                                  child: IntrinsicWidth(
                                    child: IntrinsicHeight(
                                      child: Center(
                                        child: Text(
                                          items[index],
                                          style: const TextStyle(
                                            fontSize: 18.0,
                                            color: Colors.white,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                            onWillAccept: (data) {
                              return true;
                            },
                            onAccept: (data) {
                              if (!gameEnded && !tutorialMode) {
                                swapItems(index, shuffledItems.indexOf(data));
                              }
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class GameOverScreen extends StatelessWidget {
  final int score;
  final VoidCallback onReset;

  const GameOverScreen({Key? key, required this.score, required this.onReset}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Game Over!\nYour Score: $score',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24.0),
          ),
          const SizedBox(height: 20.0),
          ElevatedButton(
            onPressed: onReset,
            child: const Text('Play Again'),
          ),
        ],
      ),
    );
  }
}
