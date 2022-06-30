import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:flutter/services.dart';

class SnakeGamePage extends StatelessWidget {
  static const routeName = 'snake-game';

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [],
    );
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Snake Game!',
      theme: ThemeData(brightness: Brightness.dark),
      home: const MyApp(),
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<int> pos = [42, 62, 82, 182];

  int noSquares = 760;

  static var rNo = Random();

  int food = rNo.nextInt(700);

  var speed = 300;

  bool playing = false;
  var direction = 'down';
  bool x1 = false;
  bool x2 = false;
  bool x3 = false;

  bool endGame = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white12,
      body: Column(
        children: [
          Expanded(
            child: GestureDetector(
              onVerticalDragUpdate: (details) {
                if (direction != 'up' && details.delta.dy > 0) {
                  direction = 'down';
                } else if (direction != 'down' && details.delta.dy < 0) {
                  direction = 'up';
                }
              },
              onHorizontalDragUpdate: (details) {
                if (direction != 'left' && details.delta.dx > 0) {
                  direction = 'right';
                } else if (direction != 'right' && details.delta.dx < 0) {
                  direction = 'left';
                }
              },
              child: Stack(
                children: [
                  Center(
                    child: Image.asset(
                      'assets/images/snake.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  GridView.builder(
                    itemCount: noSquares,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 20),
                    itemBuilder: (BuildContext context, int index) {
                      if (pos.contains(index)) {
                        return Center(
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(5),
                              child: Container(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        );
                      }
                      if (index == food) {
                        return Container(
                            padding: const EdgeInsets.all(2),
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(5),
                                child: const Center(
                                  child: Icon(
                                    Icons.fastfood,
                                    size: 15,
                                    color: Colors.yellow,
                                  ),
                                )));
                      } else {
                        return Container(
                          padding: const EdgeInsets.all(2),
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(5),
                              child: Container(
                                color: Colors.transparent,
                              )),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          !playing
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        color: x1 ? Colors.green : Colors.transparent,
                      ),
                      margin: const EdgeInsets.all(10),
                      child: TextButton(
                          onPressed: () {
                            setState(() {
                              x1 = true;
                              x2 = false;
                              x3 = false;
                              speed = 300;
                            });
                          },
                          child: const Text(
                            'X1',
                            style: TextStyle(color: Colors.white),
                          )),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        color: x2 ? Colors.green : Colors.transparent,
                      ),
                      margin: const EdgeInsets.all(10),
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            x2 = true;
                            x1 = false;
                            x3 = false;
                            speed = 200;
                          });
                        },
                        child: const Text(
                          'X2',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        color: x3 ? Colors.green : Colors.transparent,
                      ),
                      margin: const EdgeInsets.all(10),
                      child: TextButton(
                          onPressed: () {
                            setState(() {
                              x3 = true;
                              x1 = false;
                              x2 = false;
                              speed = 100;
                            });
                          },
                          child: const Text(
                            'X3',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          )),
                    ),
                    Container(
                      height: 20,
                      width: 1,
                      color: Colors.white70,
                    ),
                    OutlinedButton(
                        onPressed: () {
                          startGame();
                        },
                        child: Row(
                          children: const [
                            Text(
                              'Start',
                              style: TextStyle(color: Colors.yellow),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Icon(Icons.play_arrow, color: Colors.yellow),
                          ],
                        ))
                  ],
                )
              : Container(
                  height: 50,
                  color: Colors.white12,
                  child: Center(
                      child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              endGame = true;
                            });
                          },
                          child: Text(
                            "Quit!",
                            style: Theme.of(context)
                                .textTheme
                                .subtitle2!
                                .copyWith(color: Colors.white),
                          ))))
        ],
      ),
    );
  }

  //Function Declarations!
  generateNewFood() {
    food = rNo.nextInt(700);
  }

  updateSnake() {
    setState(() {
      switch (direction) {
        case 'down':
          if (pos.last > 740) {
            pos.add(pos.last + 20 - 760);
          } else {
            pos.add(pos.last + 20);
          }
          break;
        case 'up':
          if (pos.last < 20) {
            pos.add(pos.last - 20 + 760);
          } else {
            pos.add(pos.last - 20);
          }
          break;
        case 'left':
          if (pos.last % 20 == 0) {
            pos.add(pos.last - 1 + 20);
          } else {
            pos.add(pos.last - 1);
          }
          break;
        case 'right':
          if ((pos.last + 1) % 20 == 0) {
            pos.add(pos.last + 1 - 20);
          } else {
            pos.add(pos.last + 1);
          }
          break;
        default:
      }
      if (pos.last == food) {
        generateNewFood();
      } else {
        pos.removeAt(0);
      }
    });
  }

  startGame() {
    setState(() {
      playing = true;
    });
    endGame = false;
    pos = [42, 62, 82, 102];
    var duration = Duration(milliseconds: speed);
    Timer.periodic(duration, (Timer timer) {
      updateSnake();
      if (gameOver() || endGame) {
        timer.cancel();
        showGameOverDialog();
        playing = false;
        x1 = false;
        x2 = false;
        x3 = false;
      }
    });
  }

  gameOver() {
    for (int i = 0; i < pos.length; i++) {
      int count = 0;
      for (int j = 0; j < pos.length; j++) {
        if (pos[i] == pos[j]) {
          count += 1;
        }
        if (count == 2) {
          setState(() {
            playing = false;
          });
          return true;
        }
      }
    }
    return false;
  }

  showGameOverDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Game Over'),
            content: Text('Score: ' + pos.length.toString() + '!'),
            actions: [
              TextButton(
                  onPressed: () {
                    startGame();
                    Navigator.of(context).pop(true);
                  },
                  child: const Text('Play Again'))
            ],
          );
        });
  }
}
