import 'package:flutter/material.dart';
import '../utils/cesar.dart';

class CesarController with ChangeNotifier {
  String _input = '';
  int _shift = 3;
  String _result = '';

  String get input => _input;
  int get shift => _shift;
  String get result => _result;

  void setInput(String v) {
    _input = v;
    notifyListeners();
  }

  void setShift(int v) {
    _shift = v;
    notifyListeners();
  }

  void encrypt() {
    _result = Cesar.encode(_input, _shift);
    notifyListeners();
  }

  void decrypt() {
    _result = Cesar.decode(_input, _shift);
    notifyListeners();
  }

  void clear() {
    _input = '';
    _result = '';
    _shift = 3;
    notifyListeners();
  }
}
