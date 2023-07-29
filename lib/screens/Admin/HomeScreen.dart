import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlng/latlng.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../common/models/TigerModel.dart';
import '../Admin/ForestDetail.dart';
import '../loginScreen.dart';

import 'package:intl/intl.dart';



class ProfileData {
  final String title;
  final String description;
  final String imageUrl;
  final String userName;
  final String userEmail;
  final Timestamp? datetime;

  ProfileData({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.userName,
    required this.userEmail,
    this.datetime,
  });
}

class HomeScreen extends StatefulWidget {
  final Function(int) changeScreen;
  final VoidCallback showNavBar;

  const HomeScreen({
    super.key,
    required this.changeScreen,
    required this.showNavBar
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final LatLng _circleCenter = LatLng(20.9189175, 77.7736374);
  final double _circleRadius = 500; // radius in meters
  ValueNotifier<int> dialogTrigger = ValueNotifier(0);

  LatLng? _currentLocation;

  late String _userEmail;
  Future<void>? _future;
  late List<TigerModel> _profileDataList = [];

  late int _count=0;
  late int _countUser=0;

  @override
  void initState() {
    super.initState();
    fetchUserEmail();
    getTotalDocumentsCount().then((value) {
      setState(() {
        _count = value;
      });
    });
    getTotalDocumentsCountUser().then((value) {
      setState(() {
        _countUser = value;
      });
    });

    //_future = init();

  }

  Future<void> init() async {
    // if( Util.hasUserLocation == false ) {
    //   await _getCurrentLocation();
    //
    //   isPointInsideCircle( _currentLocation! );
    //   //Util.hasUserLocation = true;
    //   dialogTrigger.value = 1;
    // }
  }


  Future<void> fetchUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final userEmail = prefs.getString('userEmail');
    setState(() {
      _userEmail = userEmail ?? '';
    });
    fetchUserProfileData();
  }



  Future<void> fetchUserProfileData() async {
    final userSnapshot = await FirebaseFirestore.instance
        .collection('forestdata')
        .orderBy('createdAt', descending: true)
        .limit(5)
        .get();
    final profileDataList = userSnapshot.docs
        .map((doc) => TigerModel(
            id: doc['id'],
            range: doc['range']['name'] ?? "empty range",
            round: doc['round']['name'],
            beat: doc['beat']['name'],
            imageUrl: doc['imageUrl'],
            title: doc['title'],
            description: doc['description'],
            userName: doc['user_name'],
            userEmail: doc['user_email'],
            datetime: doc['createdAt'] as Timestamp?,
            location: doc['location'] as GeoPoint,
            noOfCubs: doc['number_of_cubs'],
            noOfTigers: doc['number_of_tiger'],
            remark: doc['remark'],
            userContact: doc['user_contact'],
            userImage: doc['user_imageUrl'],
          ),
        ).toList();


    for( var profileData in profileDataList ) {
      print( profileData.range);

    }
    setState(() {
      _profileDataList = profileDataList;
    });
  }


  Future<int> getTotalDocumentsCount() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('forestdata').get();
    return snapshot.size;
  }

  Future<int> getTotalDocumentsCountUser() async {
    final snapshot = await FirebaseFirestore.instance.collection('users').get();
    return snapshot.size;
  }

  // late final int numberOfTigers;
  final CollectionReference users =
      FirebaseFirestore.instance.collection('users');

  Future<bool> _onWillPop(BuildContext context) async {
    bool? exitResult = await showDialog(
      context: context,
      builder: (context) => _buildExitDialog(context),
    );
    return exitResult ?? false;
  }

  AlertDialog _buildExitDialog(BuildContext context) {
    return AlertDialog(
      title: const Text('Please confirm'),
      content: const Text('Do you want to exit the app?'),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text('No'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text('Yes'),
        ),
      ],
    );
  }


  AlertDialog _isInside(BuildContext context) {
    return AlertDialog(
      title: const Text('You are outside the previliged area..'),
      content: const Text('Do you want to exit the app?'),
      actions: <Widget>[
        TextButton(
          onPressed: () => exit(0),
          child: Text('Yes'),
        ),
      ],
    );
  }


  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: Text('Location Services Disabled'),
          content: Text('Please enable location services to continue.'),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
      return;
    }

    // Request location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: Text('Location Permissions Denied'),
            content: Text('Please grant location permissions to continue.'),
            actions: [
              TextButton(
                child: Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: Text('Location Permissions Denied'),
          content: Text(
              'Location permissions are permanently denied, we cannot request permissions.'),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
      return;
    }

    // Get the current location
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.bestForNavigation,
    );

    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
    });

    return;
  }

  bool isPointInsideCircle(LatLng point) {
    double distance = Geolocator.distanceBetween(
      point.latitude,
      point.longitude,
      _circleCenter.latitude,
      _circleCenter.longitude,
    );

    return (distance <= _circleRadius);
  }

  @override
  Widget build(BuildContext context) {
          if ( _currentLocation != null && isPointInsideCircle( _currentLocation! ) == false ) {
            return WillPopScope(
              onWillPop: ()=> _onWillPop(context),
              child: Container(
                  child: ValueListenableBuilder(
                    valueListenable: dialogTrigger,
                    builder: (ctx, value, child) {

                      Future.delayed(const Duration(seconds: 0), () {
                        showDialog(
                            barrierDismissible: false,
                            context: ctx,
                            builder: (ctx) {
                              return _isInside(context);
                            });
                      });

                      return const SizedBox();
                    })
              ),
            );
          }
          else if (_profileDataList.isEmpty) {
            return WillPopScope(
                child: Scaffold(
                  appBar: AppBar(
                    elevation: 0.0,
                    flexibleSpace: Container(
                        height: 90,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.green, Colors.greenAccent],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        )),
                    title: const Text('Pench MH'),
                    actions: [
                      Column(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.logout),
                            onPressed: () async {
                              final confirm = await showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Confirm Logout'),
                                  content:
                                  const Text('Are you sure you want to log out?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        await FirebaseAuth.instance.signOut();
                                        // ignore: use_build_context_synchronously
                                        Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => const LoginScreen()),
                                              (route) => false,
                                        );
                                      },
                                      child: const Text('Logout'),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                // perform logout
                              }
                            },
                          ),
                          // const Text("Logout"),
                        ],
                      ),
                    ],
                  ),
                  body: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "No Data Found.....",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        CircularProgressIndicator()
                      ],
                    ),
                  ),
                ), onWillPop: ()=> _onWillPop(context));
          }
          else{
            return WillPopScope(
                child: Scaffold(
                  appBar: AppBar(
                    elevation: 0.0,
                    flexibleSpace: Container(
                        height: 90,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.green, Colors.greenAccent],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        )),
                    title: const Text('Pench MH'),
                    actions: [
                      Column(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.logout),
                            onPressed: () async {
                              final confirm = await showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Confirm Logout'),
                                  content: const Text('Are you sure you want to log out?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        await FirebaseAuth.instance.signOut();
                                        // ignore: use_build_context_synchronously
                                        Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => const LoginScreen()),
                                              (route) => false,
                                        );
                                      },
                                      child: const Text('Logout'),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                // perform logout
                              }
                            },
                          ),
                          // const Text("Logout"),
                        ],
                      ),
                    ],
                  ),
                  body: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 16.0),
                          InkWell(
                            onTap: () {
                              {
                                widget.changeScreen( 2 );
                              };


                              // Provider.of<BottomNavigationModel>(context, listen: false).currentIndex ;
                              // Navigator.of(context).pushAndRemoveUntil(
                              // MaterialPageRoute(
                              //         builder: (context) => const ForestDataScreen()),
                              //      (route) => false);
                            },
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  children: [
                                    const Text(
                                      'Total Tigers',
                                      style: TextStyle(fontSize: 20.0),
                                    ),
                                    const Icon(
                                      Icons.trending_up,
                                      size: 50.0,
                                    ),
                                    const SizedBox(height: 16.0),
                                    Text(
                                      '$_count',
                                      style: TextStyle(fontSize: 24.0),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16.0),
                          InkWell(
                            onTap: () {
                              widget.changeScreen(1);
                            },
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  children: [
                                    const Text(
                                      'Total Guards',
                                      style: TextStyle(fontSize: 20.0),
                                    ),
                                    const Icon(
                                      Icons.security,
                                      size: 50.0,
                                    ),
                                    const SizedBox(height: 16.0),
                                    Text(
                                      '$_countUser',
                                      style: TextStyle(fontSize: 24.0),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16.0),
                          Container(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "Recent Entries",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: SingleChildScrollView(
                              child: DataTable(
                                columnSpacing: 16.0,
                                decoration: BoxDecoration(

                                  border: Border.all(color: Colors.grey.shade500),
                                ),
                                columns: const [
                                  DataColumn(
                                    label: Text(
                                      'Tiger Name',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'User Name',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Date & Time',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'View',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  // DataColumn(
                                  //   label: Text(
                                  //     'View',
                                  //     style: TextStyle(fontWeight: FontWeight.bold),
                                  //   ),
                                  // ),
                                ],
                                rows: _profileDataList.map((profileData) {
                                  return DataRow(
                                    cells: [
                                      DataCell(Text(profileData.title)),
                                      DataCell(Text(profileData.userName)),
                                      DataCell(Text(DateFormat('dd/MM/yyyy hh:mm')
                                          .format(profileData.datetime!.toDate()))),
                                      DataCell(IconButton(
                                        onPressed: () {
                                          {
                                            //widget.changeScreen(2);
                                            // navigating to ForestDetails SCreen
                                            Navigator.of(context).push(
                                                MaterialPageRoute(
                                                    builder: (context) => ForestDetail(
                                                      changeIndex: (int) {
                                                        widget.changeScreen( 2 );
                                                      },
                                                      changeData:  (TigerModel newData) {
                                                        setState(() {
                                                          print( _profileDataList.where((element) => element.id == newData.id ).toList().first.id );
                                                          print( newData.id );

                                                          _profileDataList.removeWhere((element) => element.id == newData.id );
                                                          _profileDataList.insert(0, newData);
                                                        });
                                                      },
                                                      deleteData: (TigerModel data) {
                                                        setState(() {
                                                          _profileDataList.removeWhere((element) => element.id == data.id);
                                                        });
                                                      },
                                                      forestData: profileData,
                                                    )
                                                )
                                            );
                                          }

                                        },
                                        icon: Icon(Icons.visibility),
                                      )),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                onWillPop: ()=> _onWillPop(context));
          }
  }
}

