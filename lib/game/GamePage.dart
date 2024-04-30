import 'package:flutter/material.dart';
import 'package:flutter_1to100/timer/TimerController.dart';

class GamePage extends StatefulWidget {
  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  TimerController _timerController = TimerController();
  List<int> numbers = [], shuffledNumbers = [];
  Map<int, Color> numberColors = {};
  int currentStage = 1, maxNum = 25, nextNumber = 1;
  bool gameEnded = false;
  List<int> maxNumOptions = [25, 50, 75, 100];
  int selectedMaxNum = 100;

  @override
  void initState() {
    super.initState();
    maxNum = selectedMaxNum;
    _initializeGame();
  }

  void _initializeGame() {
    numbers = _generateNumbersForStage(currentStage);
    nextNumber = 1 + (currentStage - 1) * 25;
    _timerController.resetTimer(() {});
    _setNumberColors();

    setState(() {});
    shuffledNumbers = _generateNumbersForStage(currentStage + 1);
  }

  void _setNumberColors() {
    for (int number in numbers) {
      numberColors[number - 1] = _getBackgroundColor(currentStage - 1);
    }
  }

  Color _getBackgroundColor(int stage) {
    int r = (75 - (16 * stage)).clamp(0, 255);
    int g = (101 - (17 * stage)).clamp(0, 255);
    int b = (165 + (19 * stage)).clamp(0, 255);
    return Color.fromARGB(255, r, g, b);
  }

  List<int> _generateNumbersForStage(int stage) {
    int startNumber = 1 + (stage - 1) * 25;
    return List.generate(25, (index) => startNumber + index)..shuffle();
  }

  void _nextStage() {
    if (currentStage < maxNum / 25) {
      setState(() {
        currentStage++;
        shuffledNumbers = _generateNumbersForStage(currentStage + 1);
      });
    } else {
      _timerController.stopTimer();
      setState(() {
        gameEnded = true;
      });
    }
  }

  void _numberTapped(int index) {
    if (numbers[index] == nextNumber) {
      if (!_timerController.isRunning) {
        _timerController.startTimer(() {
          setState(() {}); 
        });
      }

      _updateNumber(index);

      if (nextNumber > 25 * currentStage) {
        _nextStage();
      } else if (currentStage == maxNum / 25 && nextNumber > maxNum) {
        _timerController.stopTimer();
        setState(() {
          gameEnded = true;
        });
      }

      setState(() {});
    }
  }

  void _updateNumber(int index) {
    if (nextNumber < maxNum - 25 + 1) {
      nextNumber++;
      numbers[index] = shuffledNumbers[index];
      numberColors[index] = _getBackgroundColor(currentStage);
    } else {
      nextNumber++;
      numbers[index] = -1;
      numberColors[index] = Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Text(
            _timerController.seconds.toStringAsFixed(3),
            style: TextStyle(fontSize: screenWidth / 15),
          ),
          _buildGameGrid(),
          _buildMaxNumSelector(),
          SizedBox(height: screenHeight / 20),
          _buildRestartButton(),
        ],
      ),
    );
  }

  Widget _buildGameGrid() {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;
    var gridSize = screenWidth * 0.74; 
    var buttonSize = gridSize / 20; 

    return Container(
      padding: EdgeInsets.only(top: screenHeight / 30, left: (screenWidth / 10), right: (screenWidth / 10), bottom: (screenHeight / 20)), 
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5, 
          childAspectRatio: screenWidth / (screenHeight / 2),
          mainAxisSpacing: 5.0, 
          crossAxisSpacing: 5.0, 
        ),
        itemCount: numbers.length,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () => _numberTapped(index),
            child: Container(
              decoration: BoxDecoration(
                color: numberColors[index],
              ),
              child: Center(
                child: Text(
                  numbers[index] != -1 ? numbers[index].toString() : '',
                  style: TextStyle(
                    fontSize: buttonSize,
                    fontWeight: FontWeight.w700,
                    color: Colors.white
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRestartButton() {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          currentStage = 1;
          gameEnded = false;
          _timerController.stopTimer();
          _initializeGame();
        });
      },
      child: Text('다시하기'),
    );
  }

  Widget _buildMaxNumSelector() {
    var screenWidth = MediaQuery.of(context).size.width;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const Text('최대 숫자', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        SizedBox(width: screenWidth / 100),
        DropdownButton<int> (
          value: selectedMaxNum,
          onChanged: (int? newValue) {
            setState(() {
              selectedMaxNum = newValue!;
              maxNum = newValue;
              _initializeGame();
            });
          },
          items: maxNumOptions.map<DropdownMenuItem<int>>((int value) {
            return DropdownMenuItem<int>(
              value: value,
              child: Text(value.toString(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            );
          }).toList(),
          underline: Container(),
        ),
      ]
    );
  }
}