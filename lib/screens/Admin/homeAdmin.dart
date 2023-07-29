// ignore_for_file: library_private_types_in_public_api, avoid_unnecessary_containers

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'AddUserScreen.dart';
import 'BottomNavigationProvider.dart';
import 'ForestDataScreen.dart';
import 'HomeScreen.dart';
import 'MapScreen.dart';
import 'UserScreen.dart';

class HomeAdmin extends StatefulWidget {
  const HomeAdmin({Key? key, required this.title}) : super(key: key);

  final String title;



  @override
  _HomeAdminState createState() => _HomeAdminState();
}

class _HomeAdminState extends State<HomeAdmin> {
  bool _showNavBar = true;
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

  //@override
  // void initState() {
  //   super.initState();
  //   List<Widget> _widgetOptions = <Widget>[
  //     HomeScreen(
  //       changeScreen: _changeScreen,
  //     ),
  //     UserScreen(),
  //     const ForestDataScreen(),
  //     MapScreen(
  //       latitude: 37.4220,
  //       longitude: -122.0841,
  //     ),
  //   ];
  // }

  late final List<Widget> _widgetOptions;
  @override
  void initState() {
    super.initState();

    _widgetOptions = <Widget>[
      HomeScreen(
        changeScreen: _changeScreen,
          showNavBar: () {
            setState(() {
              _showNavBar = false;
            });

          }
      ),
      UserScreen(changeIndex: _changeScreen,),
      ForestDataScreen(changeIndex: _changeScreen,),
      MapScreen(
        latitude: 37.4220,
        longitude: -122.0841,
        changeIndex: _changeScreen,
      ),
    ];
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar:  BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
            backgroundColor: Colors.black,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_add),
            label: 'Add Guards',
            backgroundColor: Colors.black,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.eco),
            label: 'Forest Data',
            backgroundColor: Colors.black,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Map',
            backgroundColor: Colors.black,
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green,
        onTap: _onItemTapped,

      )
    );
    //   CupertinoTabScaffold(
    //     tabBar: CupertinoTabBar(
    //
    //       activeColor: Colors.green,
    //       currentIndex: _selectedIndex,
    //       onTap: _onItemTapped,
    //       items: <BottomNavigationBarItem>[
    //         BottomNavigationBarItem(
    //             icon: Icon(Icons.home),
    //             label: "Home"
    //         ),
    //         BottomNavigationBarItem(
    //             icon: Icon(Icons.person_add),
    //             label: "Add Guard"
    //         ),
    //         BottomNavigationBarItem(
    //             icon: Icon(Icons.eco),
    //             label: "Forest Data"
    //         ),
    //         BottomNavigationBarItem(
    //             icon: Icon(Icons.map),
    //             label: "Maps"
    //         ),
    //
    //       ],), tabBuilder: (context, index) {
    //       return CupertinoTabView(
    //         builder: (context) {
    //           return CupertinoPageScaffold(
    //             child: _widgetOptions.elementAt(_selectedIndex),
    //           );
    //         },
    //       );
    //
    //
    //
    //
    // });
  }
  }



class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: const Center(
        child: Text(
          'Map Screen',
          style: TextStyle(fontSize: 30),
        ),
      ),
    );
  }
}


