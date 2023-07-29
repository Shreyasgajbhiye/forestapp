// ignore_for_file: library_private_types_in_public_api, avoid_unnecessary_containers

import 'package:flutter/material.dart';
import 'package:forestapp/screens/User/ProfileScreen.dart';

import 'AddForestData.dart';
import 'ForestDataScreen.dart';
import 'HomeScreen.dart';

class HomeUser extends StatefulWidget {
  const HomeUser({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _HomeUserState createState() => _HomeUserState();
}

class _HomeUserState extends State<HomeUser> {
  bool _showNavBar = false;
  int _selectedIndex = 0;

  void _changeScreen( int index ) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // static final List<Widget> _widgetOptions = <Widget>[
  //   const HomeScreen(),
  //   AddForestData(),
  //   const ForestDataScreen(changeIndex: _changeScreen,),
  //   const ProfileScreen(),
  // ];

  late final List<Widget> _widgetOptions;
  @override
  void initState() {
    super.initState();


    _widgetOptions = <Widget>[
      HomeScreen(changeScreen: _changeScreen,
        showNavBar: (bool value) {
          setState(() {
            _showNavBar = value;
          });

        },),
      AddForestData(changeIndex: _changeScreen,),
      ForestDataScreen(changeIndex: _changeScreen,),
      ProfileScreen(changeIndex: _changeScreen,),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar:_showNavBar? BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
            backgroundColor: Colors.black,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_add),
            label: 'Add',
            backgroundColor: Colors.black,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.eco),
            label: 'Forest Data',
            backgroundColor: Colors.black,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
            backgroundColor: Colors.black,
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green,
        onTap: _onItemTapped,
      ): SizedBox(height: 0,)
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: const Center(
        child: Text(
          'Settings Screen',
          style: TextStyle(fontSize: 30),
        ),
      ),
    );
  }
}
