import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:tibetan_language_learning_app/model/alphabet.dart';
import 'package:tibetan_language_learning_app/util/constant.dart';

class SnakeGamePage extends StatefulWidget {
  static const routeName = 'snake-game';
  const SnakeGamePage({Key? key}) : super(key: key);
  @override
  _SnakeGamePageState createState() => _SnakeGamePageState();
}

class _SnakeGamePageState extends State<SnakeGamePage> {
  List<int> pos = [42, 62, 82, 182];

  int noSquares = 760;

  static var rNo = Random();

  int food = rNo.nextInt(700);

  var snakeSpeed = 800;

  bool playing = false;
  var direction = 'down';

  bool endGame = false;
  List<Alphabet> foodList = [];
  late Alphabet currentFood;

  @override
  void initState() {
    foodList =
        List.from(AppConstant.getAlphabetList(AlphabetCategoryType.ALPHABET));
    _generateRandomAlphabet();
    super.initState();
    startGame();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
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
                  /* Center(
                    child: Image.asset(
                      'assets/images/snake.png',
                      fit: BoxFit.contain,
                    ),
                  ),*/
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
                            child: Text(
                              currentFood.alphabetName,
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        );
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
                      height: 20,
                      width: 1,
                      color: Colors.white70,
                    ),
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
                                .titleSmall!
                                .copyWith(color: Colors.white),
                          ))))
        ],
      ),
    );
  }

  //Function Declarations!
  generateNewFood() {
    food = rNo.nextInt(700);
    _generateRandomAlphabet();
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
    var duration = Duration(milliseconds: snakeSpeed);
    Timer.periodic(duration, (Timer timer) {
      updateSnake();
      if (gameOver() || endGame) {
        timer.cancel();
        showGameOverDialog();
        playing = false;
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
                    Navigator.of(context).pop(true);
                    startGame();
                  },
                  child: const Text('Play Again'))
            ],
          );
        });
  }

  void _generateRandomAlphabet() {
    currentFood = foodList[Random().nextInt(foodList.length)];
    foodList.remove(currentFood);
  }
}
