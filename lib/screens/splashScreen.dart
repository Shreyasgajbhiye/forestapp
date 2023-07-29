import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:forestapp/screens/Admin/homeAdmin.dart';
import 'package:forestapp/screens/User/homeUser.dart';
import 'package:forestapp/screens/loginScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isVisible = false;
  // late String _userEmail;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? _userEmail;
  User? _user;

  @override
  void initState() {
    fetchUserEmail();
    super.initState();
    // Listen to auth state changes
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        // User is logged in
        setState(() {
          _user = user;
        });
      } else {
        // User is not logged in
        setState(() {
          _user = null;
        });
      }
    });
  }

  Future<void> fetchUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final userEmail = prefs.getString('userEmail');
    setState(() {
      _userEmail = userEmail;
    });
  }

  _SplashScreenState() {
    Timer(const Duration(milliseconds: 3000), () {
      setState(() {
        if (_user != null) {
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => const HomeAdmin(
                  title: 'title',
                ),
              ),
              (route) => false);
        }
        else if (_userEmail != null) {
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => const HomeUser(
                  title: 'title',
                ),
              ),
              (route) => false);
        }
        else {
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const LoginScreen()),
              (route) => false);
        }
      });
    });

    Timer(const Duration(milliseconds: 30), () {
      setState(() {
        _isVisible =
            true; // Now it is showing fade effect and navigating to Login page
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white,
            Colors.white,
          ],
          begin: const FractionalOffset(0, 0),
          end: const FractionalOffset(1.0, 0.0),
          stops: const [0.0, 1.0],
          tileMode: TileMode.clamp,
        ),
      ),
      child: AnimatedOpacity(
        opacity: _isVisible ? 1.0 : 0,
        duration: const Duration(milliseconds: 500),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: SizedBox(
                  width: 200,
                  height: 200,
                  child: Image.asset('assets/penchlogo.png'),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 30.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children:[
                  SizedBox(
                    width: 22,
                    height: 22,
                    child: Image.asset(
                    'assets/flag.png',
                    width: 20,
                    height: 20
                   ),
                  ),
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: Icon(Icons.favorite, color: Colors.redAccent),
                  ),
                  SizedBox(
                  width: 2,
                  height: 2,
                  
                ),
                  Container(
                    margin: EdgeInsets.only(top: 5),
                    width: 20,
                    height: 20,
                    child: Image.asset('assets/t.png', width: 26, height: 26),
                  ),
                ]
              ),
            ),
          ],
        ),
      ),
    );
  }
}
