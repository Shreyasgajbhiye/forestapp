// import 'package:flutter/cupertino.dart';
// import 'package:forestapp/screens/Admin/ForestDataScreen.dart';
// import 'package:forestapp/screens/Admin/MapScreen.dart';
// import 'package:forestapp/screens/Admin/UserScreen.dart';
// import 'package:forestapp/screens/User/HomeScreen.dart';
//
// class TabNavigator extends StatelessWidget {
//   final GlobalKey<NavigatorState> navigatorkey;
//   final String tabItem;
//   const TabNavigator({required Key key,required this.navigatorkey,required this.tabItem}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     Widget child=HomeScreen();
//     if(tabItem == "HomeScreen")
//       child = HomeScreen();
//     else if(tabItem == "UserScreen")
//       child = UserScreen();
//     else if(tabItem == "ForestDataScreen")
//       child = ForestDataScreen();
//     else if(tabItem == "MapScreen")
//       child = MapScreen(latitude: 37.4220,
//         longitude: -122.0841,);
//
//     return Container(
//       child: child,
//     );
//   }
// }
