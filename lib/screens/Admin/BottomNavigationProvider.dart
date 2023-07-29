import 'package:flutter/material.dart';

class BottomNavigationModel extends ChangeNotifier {
  // int _selectedIndex = 0;
  //
  // int get selectedIndex => _selectedIndex;
  //
  // void updateSelectedIndex(int newIndex) {
  //   _selectedIndex = newIndex;
  //   notifyListeners();
  // }
  String _selectedValue = 'All';

  String get selectedValue => _selectedValue;

  String? _selectedTitle;
  String? get selectedTitle => _selectedTitle;


  void updateSelectedValue(String newValue) {
    _selectedValue = newValue;
    notifyListeners();
  }

  void updateSelectedTitle(String? newValue) {
    _selectedTitle = newValue;
    notifyListeners();
  }

}
