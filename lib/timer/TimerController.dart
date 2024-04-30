import 'dart:async';

class TimerController {
  double seconds = 0;
  bool isRunning = false;
  Timer? _timer;
  DateTime? _startTime;

  void startTimer(Function callback) {
    if (_timer?.isActive ?? false) {
      _timer!.cancel();
    }

    isRunning = true;
    _startTime = DateTime.now();
    _timer = Timer.periodic(const Duration(milliseconds: 1), (timer) {
      final now = DateTime.now();
      seconds = (now.difference(_startTime!).inMilliseconds / 1000).toDouble();
      callback(); // 이 부분이 시간이 업데이트 될 때마다 호출됩니다.
    });
  }

  void stopTimer() {
    if (_timer?.isActive ?? false) {
      _timer!.cancel();
      isRunning = false;
    }
  }

  void resetTimer(Function callback) {
    stopTimer();
    seconds = 0;
    callback();
  }
}


