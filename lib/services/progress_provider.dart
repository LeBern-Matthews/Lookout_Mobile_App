import 'package:flutter/material.dart';


class ProgressProvider extends ChangeNotifier {

double _progress=0.0;
Color _colour = Colors.green; // changed from MaterialColor to Color

double get progress => _progress;
Color get colour=>_colour;

  void setProgress(double progress) {
    _progress = progress;
    setColour();
    notifyListeners();
  }

  void setColour(){

    if (progress*100<=25){
      _colour = Colors.red;
    }
    else if (progress*100<=35){
      _colour = Colors.orange;
    }
    else if (progress*100<=60){
      _colour = Colors.yellow;
    }
    else if (progress*100<=79){
      _colour = Colors.green;
    }
    else {
      _colour = Colors.green.shade900;
    }
    notifyListeners();
}
}